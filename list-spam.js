const https = require('https');
const fs = require('fs');

const creds = JSON.parse(fs.readFileSync('gmail-creds.json', 'utf8'));
const accessToken = creds.access_token;

function getSpamMessages(cb) {
  // Query SPAM label
  const path = '/gmail/v1/users/devlomatix@gmail.com/messages?maxResults=10&labelIds=SPAM';
  const options = {
    hostname: 'gmail.googleapis.com',
    path: path,
    method: 'GET',
    headers: { 'Authorization': 'Bearer ' + accessToken }
  };
  https.request(options, (res) => {
    let data = '';
    res.on('data', chunk => data += chunk);
    res.on('end', () => {
      if (res.statusCode === 200) {
        cb(null, JSON.parse(data));
      } else {
        cb(new Error('HTTP ' + res.statusCode + ': ' + data));
      }
    });
  }).on('error', cb).end();
}

function getMessageDetails(msgId, cb) {
  const options = {
    hostname: 'gmail.googleapis.com',
    path: `/gmail/v1/users/devlomatix@gmail.com/messages/${msgId}?format=metadata`,
    method: 'GET',
    headers: { 'Authorization': 'Bearer ' + accessToken }
  };
  https.request(options, (res) => {
    let d = '';
    res.on('data', chunk => d += chunk);
    res.on('end', () => {
      if (res.statusCode === 200) cb(null, JSON.parse(d));
      else cb(new Error('HTTP ' + res.statusCode + ': ' + d));
    });
  }).on('error', cb).end();
}

function extractHeader(payload, name) {
  if (!payload.headers) return '';
  const hdr = payload.headers.find(h => h.name.toLowerCase() === name.toLowerCase());
  return hdr ? hdr.value : '';
}

getSpamMessages((err, list) => {
  if (err) {
    console.error('Error fetching spam:', err.message);
    process.exit(1);
  }
  if (!list.messages || list.messages.length === 0) {
    console.log('No messages in Spam folder.');
    process.exit(0);
  }
  console.log(`Latest ${list.messages.length} spam emails:\n`);
  let count = 1;
  const pending = list.messages.length;
  list.messages.forEach(msg => {
    getMessageDetails(msg.id, (err2, det) => {
      if (!err2 && det) {
        const from = extractHeader(det.payload, 'From');
        const subject = extractHeader(det.payload, 'Subject');
        const date = extractHeader(det.payload, 'Date');
        console.log(`${count}. [${date}]`);
        console.log(`   From: ${from}`);
        console.log(`   Subject: ${subject}`);
        console.log('');
      } else {
        console.log(`${count}. (Failed to load details)`);
      }
      count++;
      if (count > pending) process.exit(0);
    });
  });
});
