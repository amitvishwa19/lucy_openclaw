#!/usr/bin/env node
/**
 * Delete all emails from SPAM folder
 * Existing credentials: gmail-creds.json
 */

const https = require('https');
const fs = require('fs');

const creds = JSON.parse(fs.readFileSync('gmail-creds.json', 'utf8'));
const accessToken = creds.access_token;

function listSpamMessages(cb) {
  const options = {
    hostname: 'gmail.googleapis.com',
    path: '/gmail/v1/users/devlomatix@gmail.com/messages?maxResults=100&labelIds=SPAM',
    method: 'GET',
    headers: { 'Authorization': 'Bearer ' + accessToken }
  };
  https.request(options, (res) => {
    let data = '';
    res.on('data', chunk => data += chunk);
    res.on('end', () => {
      if (res.statusCode === 200) cb(null, JSON.parse(data));
      else cb(new Error('HTTP ' + res.statusCode + ': ' + data));
    });
  }).on('error', cb).end();
}

function deleteMessage(messageId, cb) {
  const options = {
    hostname: 'gmail.googleapis.com',
    path: '/gmail/v1/users/devlomatix@gmail.com/messages/' + messageId,
    method: 'DELETE',
    headers: { 'Authorization': 'Bearer ' + accessToken }
  };
  https.request(options, (res) => {
    let d = '';
    res.on('data', chunk => d += chunk);
    res.on('end', () => {
      if (res.statusCode === 204) cb(null);
      else cb(new Error('HTTP ' + res.statusCode + ': ' + d));
    });
  }).on('error', cb).end();
}

listSpamMessages((err, list) => {
  if (err) {
    console.error('Failed to list spam:', err.message);
    process.exit(1);
  }
  if (!list.messages || list.messages.length === 0) {
    console.log('No spam messages to delete.');
    process.exit(0);
  }

  const ids = list.messages.map(m => m.id);
  console.log(`Found ${ids.length} spam messages. Deleting...`);

  let remaining = ids.length;
  ids.forEach(id => {
    deleteMessage(id, (err2) => {
      if (err2) {
        console.error(`Failed to delete ${id}:`, err2.message);
      } else {
        console.log(`Deleted message ${id}`);
      }
      remaining--;
      if (remaining === 0) {
        console.log('Spam cleanup complete.');
        process.exit(0);
      }
    });
  });
});
