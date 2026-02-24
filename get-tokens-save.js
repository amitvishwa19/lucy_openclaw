#!/usr/bin/env node
/**
 * Get Gmail OAuth tokens (access + refresh) and save to gmail-creds.json
 *
 * This script opens the Google OAuth consent page, you authorize with your Gmail account,
 * and it saves the tokens for use by gmail-monitor.js.
 *
 * Usage: node get-tokens-save.js
 *
 * Requires: npm install googleapis open (if you want it to auto-open browser; optional)
 */

const { google } = require('googleapis');
const readline = require('readline');
const fs = require('fs');
const path = require('path');

const CLIENT_ID = '729176862353-8d1sr9vr4u978cd3k3ckhcaqljfkikug.apps.googleusercontent.com';
const CLIENT_SECRET = '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';
const REDIRECT_URI = 'urn:ietf:wg:oauth:2.0:oob';

const oauth2Client = new google.auth.OAuth2(CLIENT_ID, CLIENT_SECRET, REDIRECT_URI);
const scopes = ['https://www.googleapis.com/auth/gmail.modify'];

const authUrl = oauth2Client.generateAuthUrl({
  access_type: 'offline',
  scope: scopes,
});

console.log('\n=== OpenClaw Gmail Auth ===');
console.log('1. Copy the URL below and open it in your browser.');
console.log('2. Sign in with devlomatix@gmail.com');
console.log('3. Click "Allow"');
console.log('4. Copy the authorization code displayed by Google');
console.log('\nURL:\n' + authUrl + '\n');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

rl.question('Paste the authorization code here: ', async (code) => {
  try {
    const { tokens } = await oauth2Client.getToken(code.trim());
    const creds = {
      access_token: tokens.access_token,
      refresh_token: tokens.refresh_token,
      scope: tokens.scope
    };
    const outPath = path.join(__dirname, 'gmail-creds.json');
    fs.writeFileSync(outPath, JSON.stringify(creds, null, 2));
    console.log('\n✅ Success! Credentials saved to:', outPath);
    console.log('Now you can start gmail-monitor.js. It will poll every minute.');
  } catch (err) {
    console.error('\n❌ Error getting token:');
    if (err.response) {
      console.error('Google response:', JSON.stringify(err.response.data, null, 2));
    } else {
      console.error(err.message);
    }
    console.error('\nTroubleshooting:');
    console.error('- Make sure devlomatix@gmail.com is added as a Test user in OAuth consent screen');
    console.error('- Ensure your OAuth client is of type "Desktop app"');
    console.error('- Check you granted the Gmail modify scope');
  } finally {
    rl.close();
  }
});
