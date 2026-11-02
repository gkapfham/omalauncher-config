#!/usr/bin/env node
// Upload a backup to Google Drive, into omalauncher-backups/, keeping the newest ones.
// Usage: node drive-upload.js FILE EMAIL [KEEP]
const fs = require('node:fs');
const path = require('node:path');
const { authorize, getGoogleApis } = require('/root/.pi/agent/skills/google-workspace/scripts/common.js');

const file = process.argv[2];
const email = process.argv[3];
const keep = Number(process.argv[4] || 10);

if (!file || !email) {
  console.error('usage: drive-upload.js FILE EMAIL [KEEP]');
  process.exit(2);
}

(async () => {
  const auth = await authorize({ email, interactive: false });
  const drive = getGoogleApis().drive({ version: 'v3', auth });

  const folderName = 'omalauncher-backups';
  const found = await drive.files.list({
    q: `name='${folderName}' and mimeType='application/vnd.google-apps.folder' and trashed=false`,
    fields: 'files(id,name)',
    pageSize: 1,
  });
  let folderId = found.data.files && found.data.files[0] && found.data.files[0].id;
  if (!folderId) {
    const created = await drive.files.create({
      requestBody: { name: folderName, mimeType: 'application/vnd.google-apps.folder' },
      fields: 'id',
    });
    folderId = created.data.id;
  }

  const uploaded = await drive.files.create({
    requestBody: { name: path.basename(file), parents: [folderId] },
    media: { mimeType: 'application/gzip', body: fs.createReadStream(file) },
    fields: 'id,name,size,createdTime,webViewLink',
  });
  console.log(JSON.stringify(uploaded.data, null, 2));

  const list = await drive.files.list({
    q: `'${folderId}' in parents and trashed=false`,
    orderBy: 'createdTime desc',
    fields: 'files(id,name,createdTime)',
    pageSize: 100,
  });
  const old = (list.data.files || []).slice(keep);
  for (const f of old) {
    await drive.files.delete({ fileId: f.id });
  }
  if (old.length) console.log(`Pruned ${old.length} old backup(s), kept ${keep}.`);
})().catch((error) => {
  console.error(error && error.message ? error.message : error);
  process.exit(1);
});
