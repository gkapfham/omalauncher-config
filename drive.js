#!/usr/bin/env node
// Google Drive side of the omalauncher backup app.
//
//   node drive.js upload FILE EMAIL [KEEP]   upload a backup, prune old ones
//   node drive.js list EMAIL                 the backups, newest first, as JSON
//   node drive.js download ID OUT EMAIL      download one backup
//
// Uses the Google account already signed in for owl-agenda / the google-workspace skill.
const fs = require('node:fs');
const path = require('node:path');
const { pipeline } = require('node:stream/promises');
const { authorize, getGoogleApis } = require('/root/.pi/agent/skills/google-workspace/scripts/common.js');

const FOLDER = 'omalauncher-backups';
const [command, ...args] = process.argv.slice(2);

async function drive(email) {
  const auth = await authorize({ email, interactive: false });
  return getGoogleApis().drive({ version: 'v3', auth });
}

async function folderId(d) {
  const found = await d.files.list({
    q: `name='${FOLDER}' and mimeType='application/vnd.google-apps.folder' and trashed=false`,
    fields: 'files(id,name)',
    pageSize: 1,
  });
  if (found.data.files && found.data.files[0]) return found.data.files[0].id;
  const created = await d.files.create({
    requestBody: { name: FOLDER, mimeType: 'application/vnd.google-apps.folder' },
    fields: 'id',
  });
  return created.data.id;
}

async function list(email) {
  const d = await drive(email);
  const parent = await folderId(d);
  const res = await d.files.list({
    q: `'${parent}' in parents and trashed=false and mimeType != 'application/vnd.google-apps.folder'`,
    orderBy: 'createdTime desc',
    fields: 'files(id,name,size,createdTime,webViewLink)',
    pageSize: 100,
  });
  const files = (res.data.files || []).map((f) => ({
    id: f.id,
    name: f.name,
    size: Number(f.size || 0),
    at: Math.floor(Date.parse(f.createdTime) / 1000),
    link: f.webViewLink,
  }));
  console.log(JSON.stringify(files));
}

async function upload(file, email, keep = 10) {
  const d = await drive(email);
  const parent = await folderId(d);
  const res = await d.files.create({
    requestBody: { name: path.basename(file), parents: [parent] },
    media: { mimeType: 'application/gzip', body: fs.createReadStream(file) },
    fields: 'id,name,size,createdTime,webViewLink',
  });
  console.log(JSON.stringify(res.data));
  const all = await d.files.list({
    q: `'${parent}' in parents and trashed=false and mimeType != 'application/vnd.google-apps.folder'`,
    orderBy: 'createdTime desc',
    fields: 'files(id,name,createdTime)',
    pageSize: 100,
  });
  const old = (all.data.files || []).slice(Number(keep) || 10);
  for (const f of old) await d.files.delete({ fileId: f.id });
  if (old.length) console.error(`Pruned ${old.length} old backup(s), kept ${Number(keep) || 10}.`);
}

async function download(id, out, email) {
  const d = await drive(email);
  const res = await d.files.get({ fileId: id, alt: 'media' }, { responseType: 'stream' });
  await pipeline(res.data, fs.createWriteStream(out));
  console.log(out);
}

(async () => {
  if (command === 'upload' && args.length >= 2) return upload(args[0], args[1], args[2]);
  if (command === 'list' && args.length >= 1) return list(args[0]);
  if (command === 'download' && args.length >= 3) return download(args[0], args[1], args[2]);
  console.error('usage: drive.js upload FILE EMAIL [KEEP] | list EMAIL | download ID OUT EMAIL');
  process.exit(2);
})().catch((error) => {
  console.error(error && error.message ? error.message : error);
  process.exit(1);
});
