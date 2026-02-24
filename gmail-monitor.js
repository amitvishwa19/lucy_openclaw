#!/usr/bin/env node
/**
 * Gmail Monitor (Manual Refresh)
 *
 * Polls Gmail every minute for new messages in INBOX.
 * Reads messages, prints details, and can optionally delete them.
 *
 * Credentials are read from 'gmail-creds.json' in the same directory.
 * Format:
 * {
 *   "access_token": "...",
 *   "refresh_token": "...",
 *   "scope": "https://www.googleapis.com/auth/gmail.modify"
 * }
 *
 * Usage: node gmail-monitor.js
 *
 * Note: Access token expires in ~1 hour. When it expires, get new tokens
 * using get-tokens-save.js and overwrite gmail-creds.json, then restart this script.
 */

const https = require('https');
const fs = require('fs');
const path = require('path');

const WORKSPACE = '/home/ubuntu/.openclaw/workspace';
const CRED_FILE = path.join(WORKSPACE, 'gmail-creds.json');

const args = process.argv.slice(2);
const RUN_ONCE = args.includes('--once') || args.includes('-o');

let creds = null;
const seenMessages = new Set();

function loadCreds() {
  try {
    const data = fs.readFileSync(CRED_FILE, 'utf8');
    creds = JSON.parse(data);
    if (!creds.access_token) throw new Error('Missing access_token');
    console.log('[' + new Date().toISOString() + '] Credentials loaded. Access token (first 30 chars):', creds.access_token.substring(0,30) + '...');
  } catch (e) {
    console.error('Failed to load credentials from ' + CRED_FILE + ':', e.message);
    process.exit(1);
  }
}

function listMessages(accessToken, cb) {
  const options = {
    hostname: 'gmail.googleapis.com',
    path: '/gmail/v1/users/devlomatix@gmail.com/messages?maxResults=10&labelIds=INBOX',
    method: 'GET',
    headers: { 'Authorization': 'Bearer ' + accessToken }
  };
  const req = https.request(options, (res) => {
    let data = '';
    res.on('data', chunk => data += chunk);
    res.on('end', () => {
      if (res.statusCode === 200) {
        cb(null, JSON.parse(data));
      } else {
        cb(new Error('HTTP ' + res.statusCode + ': ' + data));
      }
    });
  });
  req.on('error', cb);
  req.end();
}

function getMessageDetails(accessToken, messageId, cb) {
  const options = {
    hostname: 'gmail.googleapis.com',
    path: '/gmail/v1/users/devlomatix@gmail.com/messages/' + messageId + '?format=full',
    method: 'GET',
    headers: { 'Authorization': 'Bearer ' + accessToken }
  };
  const req = https.request(options, (res) => {
    let d = '';
    res.on('data', chunk => d += chunk);
    res.on('end', () => {
      if (res.statusCode === 200) {
        cb(null, JSON.parse(d));
      } else {
        cb(new Error('HTTP ' + res.statusCode + ': ' + d));
      }
    });
  });
  req.on('error', cb);
  req.end();
}

function extractHeader(payload, name) {
  if (!payload.headers) return '';
  const hdr = payload.headers.find(h => h.name.toLowerCase() === name.toLowerCase());
  return hdr ? hdr.value : '';
}

function decodePlainBody(payload) {
  if (!payload.parts) {
    if (payload.body && payload.body.data) {
      return Buffer.from(payload.body.data, 'base64').toString('utf8');
    }
    return '';
  }
  // Try to find a text/plain part
  const findPlain = (parts) => {
    for (const p of parts) {
      if (p.mimeType === 'text/plain' && p.body && p.body.data) {
        return p.body.data;
      }
      if (p.parts) {
        const inner = findPlain(p.parts);
        if (inner) return inner;
      }
    }
    return null;
  };
  const plainData = findPlain(payload.parts);
  return plainData ? Buffer.from(plainData, 'base64').toString('utf8') : '';
}

function processNewMessage(msg, details) {
  const from = extractHeader(details.payload, 'From');
  const subject = extractHeader(details.payload, 'Subject');
  const body = decodePlainBody(details.payload);
  const snippet = details.snippet || '';

  console.log('\n=== NEW EMAIL ===');
  console.log('Timestamp:', new Date().toISOString());
  console.log('From:', from);
  console.log('Subject:', subject);
  console.log('Snippet:', snippet.substring(0, 200) + (snippet.length > 200 ? '...' : ''));
  if (body) {
    console.log('Body (first 500 chars):');
    console.log(body.substring(0, 500) + (body.length > 500 ? '...' : ''));
  } else {
    console.log('(No plain text body, possibly HTML-only)');
  }
  console.log('Message ID:', msg.id);
  console.log('Labels:', details.labelIds);
  console.log('================\n');
}

function monitor() {
  if (!creds) loadCreds();
  const accessToken = creds.access_token;

  listMessages(accessToken, (err, list) => {
    if (err) {
      console.error('[' + new Date().toISOString() + '] Error listing messages:', err.message);
      if (err.message.includes('401') || err.message.includes('invalid_token')) {
        console.error('!!! Access token may be expired. Please run get-tokens-save.js to get new credentials and restart this monitor.');
      }
      if (RUN_ONCE) process.exit(1);
      setTimeout(monitor, 60 * 1000);
      return;
    }

    // Debug: show what we got
    console.log('[' + new Date().toISOString() + '] list.messages length:', list?.messages?.length, 'list keys:', list ? Object.keys(list) : 'none');

    if (!list.messages || list.messages.length === 0) {
      console.log('[' + new Date().toISOString() + '] No messages in INBOX.');
    } else {
      // Process only new messages we haven't seen
      let newCount = 0;
      list.messages.forEach(msg => {
        if (seenMessages.has(msg.id)) return;
        seenMessages.add(msg.id);
        newCount++;
        getMessageDetails(accessToken, msg.id, (err2, details) => {
          if (!err2 && details) {
            processNewMessage(msg, details);
            // If you want automatic deletion, uncomment:
            // deleteMessage(accessToken, msg.id);
          }
        });
      });
      if (newCount === 0) {
        console.log('[' + new Date().toISOString() + '] No new messages.');
      }
    }

    if (RUN_ONCE) {
      console.log('--- Run once mode: exiting after this poll ---');
      process.exit(0);
    }

    // Schedule next poll
    setTimeout(monitor, 60 * 1000); // 1 minute
  });
}

// Start
console.log('Gmail monitor started. Polling every minute. Ctrl+C to stop.');
loadCreds();
monitor();
