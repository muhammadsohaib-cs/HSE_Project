const express = require('express');
const fs = require('fs');
const router = express.Router();
const {
  readDb,
  COLLECTION_MAP,
  TABLE_TO_KEY,
  SQLITE_FILE,
  runReadOnlySql,
  connectMongo,
  disconnectMongo,
  syncAllToMongo,
  getMongoCollection,
  getDatabaseOverview,
} = require('../config/db');

// GET /api/v1/db/overview
router.get('/overview', (req, res) => {
  try {
    const overview = getDatabaseOverview();
    return res.json({ success: true, ...overview });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
});

// GET /api/v1/db/collection/:name?search=&source=sqlite|mongodb&limit=500
router.get('/collection/:name', async (req, res) => {
  try {
    const rawName = req.params.name;
    const jsonKey = COLLECTION_MAP[rawName] ? rawName : TABLE_TO_KEY[rawName];
    if (!jsonKey) {
      return res.status(404).json({
        success: false,
        message: `Unknown collection/table "${rawName}". Valid tables: ${Object.values(COLLECTION_MAP).join(', ')}`,
      });
    }
    const tableName = COLLECTION_MAP[jsonKey];
    const source = (req.query.source || 'sqlite').toLowerCase();
    const search = (req.query.search || '').toString().trim().toLowerCase();
    const limit = Math.min(Math.max(parseInt(req.query.limit, 10) || 500, 1), 2000);

    let docs = [];
    let actualSource = 'sqlite';

    if (source === 'mongodb') {
      docs = await getMongoCollection(tableName, limit);
      actualSource = 'mongodb';
    } else {
      // Read directly from SQLite raw_json so every record reflects live SQLite state
      try {
        const result = runReadOnlySql(`SELECT raw_json FROM ${tableName} LIMIT ${limit}`);
        docs = result.rows.map((r) => {
          try {
            return JSON.parse(r.raw_json);
          } catch (_) {
            return r;
          }
        });
        actualSource = 'sqlite';
      } catch (_) {
        const db = readDb();
        docs = Array.isArray(db[jsonKey]) ? db[jsonKey].slice(0, limit) : [];
        actualSource = 'json';
      }
    }

    // Sanitize sensitive password hashes in viewer output
    const safeDocs = docs.map((d) => {
      if (!d || typeof d !== 'object') return d;
      const copy = { ...d };
      if (copy.passwordHash) copy.passwordHash = '[bcrypt-protected]';
      return copy;
    });

    const filtered = search
      ? safeDocs.filter((d) => JSON.stringify(d).toLowerCase().includes(search))
      : safeDocs;

    return res.json({
      success: true,
      collection: tableName,
      jsonKey,
      source: actualSource,
      total: safeDocs.length,
      count: filtered.length,
      documents: filtered,
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
});

// POST /api/v1/db/query (Execute read-only SQL against chiniot_power_hse.db)
router.post('/query', (req, res) => {
  try {
    const { sql } = req.body || {};
    const result = runReadOnlySql(sql);
    return res.json({ success: true, ...result });
  } catch (err) {
    return res.status(400).json({ success: false, message: err.message });
  }
});

// POST /api/v1/db/mongo/connect
router.post('/mongo/connect', async (req, res) => {
  try {
    const { uri, dbName, persist } = req.body || {};
    const status = await connectMongo(uri, dbName || 'chiniot_power_hse', persist !== false);
    return res.json({
      success: true,
      message: `Connected to MongoDB (${status.dbName}) and synced all 11 CPL HSE collections.`,
      mongodb: status,
    });
  } catch (err) {
    return res.status(400).json({
      success: false,
      message: `MongoDB connection failed: ${err.message}`,
    });
  }
});

// POST /api/v1/db/mongo/sync
router.post('/mongo/sync', async (req, res) => {
  try {
    const counts = await syncAllToMongo(readDb());
    if (!counts) {
      return res.status(400).json({ success: false, message: 'MongoDB is not connected yet.' });
    }
    return res.json({
      success: true,
      message: 'All 11 CPL collections synced to MongoDB.',
      counts,
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
});

// POST /api/v1/db/mongo/disconnect
router.post('/mongo/disconnect', async (req, res) => {
  const status = await disconnectMongo();
  return res.json({ success: true, mongodb: status });
});

// GET /api/v1/db/export/:name?format=json|csv
router.get('/export/:name', (req, res) => {
  const rawName = req.params.name;
  const jsonKey = COLLECTION_MAP[rawName] ? rawName : TABLE_TO_KEY[rawName];
  if (!jsonKey) {
    return res.status(404).json({ success: false, message: 'Collection not found.' });
  }
  const tableName = COLLECTION_MAP[jsonKey];
  const db = readDb();
  const docs = (Array.isArray(db[jsonKey]) ? db[jsonKey] : []).map((d) => {
    const copy = { ...d };
    if (copy.passwordHash) copy.passwordHash = '[protected]';
    return copy;
  });

  const format = (req.query.format || 'json').toLowerCase();
  if (format === 'csv') {
    const cols = docs.length > 0 ? Array.from(new Set(docs.flatMap((d) => Object.keys(d)))) : [];
    const escapeCsv = (val) => {
      const str = val === null || val === undefined ? '' : (typeof val === 'object' ? JSON.stringify(val) : String(val));
      return `"${str.replace(/"/g, '""')}"`;
    };
    const lines = [cols.map(escapeCsv).join(',')];
    for (const d of docs) {
      lines.push(cols.map((c) => escapeCsv(d[c])).join(','));
    }
    res.setHeader('Content-Type', 'text/csv; charset=utf-8');
    res.setHeader('Content-Disposition', `attachment; filename="cpl_hse_${tableName}.csv"`);
    return res.send(lines.join('\n'));
  }

  res.setHeader('Content-Type', 'application/json; charset=utf-8');
  res.setHeader('Content-Disposition', `attachment; filename="cpl_hse_${tableName}.json"`);
  return res.send(JSON.stringify(docs, null, 2));
});

// GET /api/v1/db/download-sqlite
router.get('/download-sqlite', (req, res) => {
  if (!fs.existsSync(SQLITE_FILE)) {
    return res.status(404).json({ success: false, message: 'SQLite database file not found.' });
  }
  return res.download(SQLITE_FILE, 'chiniot_power_hse.db');
});

module.exports = router;
