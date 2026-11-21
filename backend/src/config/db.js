const fs = require('fs');
const path = require('path');
const { DatabaseSync } = require('node:sqlite');
const { MongoClient } = require('mongodb');
const { Pool } = require('pg');

// Load .env if present (supports MONGODB_URI, MONGODB_DB_NAME, DATABASE_URL)
const ENV_FILE = path.join(__dirname, '../../.env');
try {
  require('dotenv').config({ path: ENV_FILE });
} catch (_) {}

const DATA_DIR = path.join(__dirname, '../data');
const DB_FILE = path.join(DATA_DIR, 'db.json');
const SEED_FILE = path.join(DATA_DIR, 'seed.json');
const SQLITE_FILE = path.join(DATA_DIR, 'chiniot_power_hse.db');

// Collection mapping: db.json key -> SQLite table / MongoDB collection name
const COLLECTION_MAP = {
  users: 'users',
  zones: 'zones',
  hazards: 'hazards',
  checklistTemplates: 'checklist_templates',
  checklistAudits: 'checklist_audits',
  permits: 'permits',
  roster: 'roster',
  auditLogs: 'audit_logs',
  alarms: 'alarms',
  emailLogs: 'email_logs',
  pendingUsers: 'pending_users',
};

// Reverse map: table name -> db.json key
const TABLE_TO_KEY = Object.fromEntries(
  Object.entries(COLLECTION_MAP).map(([k, v]) => [v, k])
);

// =========================================================================
// 1. NATIVE SQLITE RELATIONAL DATABASE (Node.js Built-in node:sqlite)
// =========================================================================
let sqliteDb = null;
let isSqliteActive = false;

function initSqlite() {
  try {
    fs.mkdirSync(DATA_DIR, { recursive: true });
    sqliteDb = new DatabaseSync(SQLITE_FILE);
    sqliteDb.exec(`
      PRAGMA journal_mode = DELETE;
      PRAGMA foreign_keys = OFF;

      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        employee_id TEXT,
        name TEXT,
        urdu_name TEXT,
        email TEXT,
        role TEXT,
        department TEXT,
        shift TEXT,
        cnic TEXT,
        plant_zone TEXT,
        is_active INTEGER,
        raw_json TEXT
      );

      CREATE TABLE IF NOT EXISTS zones (
        id TEXT PRIMARY KEY,
        name TEXT,
        ur TEXT,
        coords TEXT,
        workers INTEGER,
        risk_level TEXT,
        raw_json TEXT
      );

      CREATE TABLE IF NOT EXISTS hazards (
        id TEXT PRIMARY KEY,
        nm_number TEXT,
        title TEXT,
        zone TEXT,
        severity TEXT,
        probability INTEGER,
        score INTEGER,
        reporter TEXT,
        status TEXT,
        time TEXT,
        coords TEXT,
        observation_type TEXT,
        category_type TEXT,
        responsible_team TEXT,
        corrective_action TEXT,
        assigned_to TEXT,
        raw_json TEXT
      );

      CREATE TABLE IF NOT EXISTS checklist_templates (
        id TEXT PRIMARY KEY,
        doc_no TEXT,
        title TEXT,
        title_ur TEXT,
        category TEXT,
        frequency TEXT,
        target_zone TEXT,
        description TEXT,
        items_count INTEGER,
        raw_json TEXT
      );

      CREATE TABLE IF NOT EXISTS checklist_audits (
        id TEXT PRIMARY KEY,
        template_id TEXT,
        plant_zone TEXT,
        shift_type TEXT,
        inspector_id TEXT,
        inspector_name TEXT,
        completion_rate REAL,
        pass_count INTEGER,
        fail_count INTEGER,
        signature_verified INTEGER,
        timestamp TEXT,
        raw_json TEXT
      );

      CREATE TABLE IF NOT EXISTS permits (
        id TEXT PRIMARY KEY,
        type TEXT,
        title TEXT,
        zone TEXT,
        requester TEXT,
        status TEXT,
        telemetry TEXT,
        timer TEXT,
        loto_tags TEXT,
        approved_by TEXT,
        raw_json TEXT
      );

      CREATE TABLE IF NOT EXISTS roster (
        emp_id TEXT PRIMARY KEY,
        name TEXT,
        ur TEXT,
        role TEXT,
        designation TEXT,
        shift TEXT,
        zone TEXT,
        attendance_status TEXT,
        nights_performed INTEGER,
        helmet INTEGER,
        shoes INTEGER,
        gloves INTEGER,
        ear INTEGER,
        raw_json TEXT
      );

      CREATE TABLE IF NOT EXISTS audit_logs (
        id TEXT PRIMARY KEY,
        actor_id TEXT,
        actor_role TEXT,
        action TEXT,
        target_resource TEXT,
        coords TEXT,
        timestamp TEXT,
        details TEXT,
        raw_json TEXT
      );

      CREATE TABLE IF NOT EXISTS alarms (
        id TEXT PRIMARY KEY,
        title TEXT,
        zone TEXT,
        severity TEXT,
        triggered_by TEXT,
        timestamp TEXT,
        coords TEXT,
        is_acknowledged INTEGER,
        raw_json TEXT
      );

      CREATE TABLE IF NOT EXISTS email_logs (
        id TEXT PRIMARY KEY,
        recipient TEXT,
        subject TEXT,
        status TEXT,
        timestamp TEXT,
        raw_json TEXT
      );

      CREATE TABLE IF NOT EXISTS pending_users (
        emp_id TEXT PRIMARY KEY,
        name TEXT,
        cnic TEXT,
        role TEXT,
        shift TEXT,
        zone TEXT,
        status TEXT,
        created_at TEXT,
        raw_json TEXT
      );
    `);
    isSqliteActive = true;
    console.log(`[Database] Native SQLite database active: ${SQLITE_FILE}`);
  } catch (err) {
    console.error('[Database] SQLite init error:', err.message);
    isSqliteActive = false;
  }
}

function syncJsonToSqlite(data) {
  if (!isSqliteActive || !sqliteDb || !data) return;
  try {
    sqliteDb.exec('BEGIN TRANSACTION');

    // users
    sqliteDb.exec('DELETE FROM users');
    const insUser = sqliteDb.prepare(
      `INSERT OR REPLACE INTO users (id, employee_id, name, urdu_name, email, role, department, shift, cnic, plant_zone, is_active, raw_json)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
    );
    for (const u of data.users || []) {
      insUser.run(
        String(u.id || u.employeeId || ''),
        String(u.employeeId || ''),
        String(u.name || u.fullName || ''),
        String(u.urduName || ''),
        String(u.email || ''),
        String(u.role || ''),
        String(u.department || ''),
        String(u.shift || ''),
        String(u.cnic || ''),
        String(u.plantZone || u.assignedZone || ''),
        u.isActive === false ? 0 : 1,
        JSON.stringify(u)
      );
    }

    // zones
    sqliteDb.exec('DELETE FROM zones');
    const insZone = sqliteDb.prepare(
      `INSERT OR REPLACE INTO zones (id, name, ur, coords, workers, risk_level, raw_json)
       VALUES (?, ?, ?, ?, ?, ?, ?)`
    );
    for (const z of data.zones || []) {
      insZone.run(
        String(z.id || ''),
        String(z.name || ''),
        String(z.ur || ''),
        String(z.coords || ''),
        Number(z.workers || 0),
        String(z.riskLevel || 'Medium'),
        JSON.stringify(z)
      );
    }

    // hazards
    sqliteDb.exec('DELETE FROM hazards');
    const insHazard = sqliteDb.prepare(
      `INSERT OR REPLACE INTO hazards (id, nm_number, title, zone, severity, probability, score, reporter, status, time, coords, observation_type, category_type, responsible_team, corrective_action, assigned_to, raw_json)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
    );
    for (const h of data.hazards || []) {
      insHazard.run(
        String(h.id || ''),
        String(h.nmNumber || ''),
        String(h.title || ''),
        String(h.zone || ''),
        String(h.severity || ''),
        Number(h.probability || 0),
        Number(h.score || 0),
        String(h.reporter || ''),
        String(h.status || ''),
        String(h.time || ''),
        String(h.coords || ''),
        String(h.observationType || ''),
        String(h.categoryType || ''),
        String(h.responsibleTeam || ''),
        String(h.correctiveAction || ''),
        String(h.assignedTo || ''),
        JSON.stringify(h)
      );
    }

    // checklist_templates
    sqliteDb.exec('DELETE FROM checklist_templates');
    const insTpl = sqliteDb.prepare(
      `INSERT OR REPLACE INTO checklist_templates (id, doc_no, title, title_ur, category, frequency, target_zone, description, items_count, raw_json)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
    );
    for (const t of data.checklistTemplates || []) {
      insTpl.run(
        String(t.id || ''),
        String(t.docNo || t.id || ''),
        String(t.title || ''),
        String(t.titleUr || ''),
        String(t.category || ''),
        String(t.frequency || ''),
        String(t.targetZone || ''),
        String(t.description || ''),
        Array.isArray(t.items) ? t.items.length : 0,
        JSON.stringify(t)
      );
    }

    // checklist_audits
    sqliteDb.exec('DELETE FROM checklist_audits');
    const insAudit = sqliteDb.prepare(
      `INSERT OR REPLACE INTO checklist_audits (id, template_id, plant_zone, shift_type, inspector_id, inspector_name, completion_rate, pass_count, fail_count, signature_verified, timestamp, raw_json)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
    );
    for (const a of data.checklistAudits || []) {
      insAudit.run(
        String(a.id || ''),
        String(a.templateId || ''),
        String(a.plantZone || ''),
        String(a.shiftType || ''),
        String(a.inspectorId || ''),
        String(a.inspectorName || ''),
        Number(a.completionRate || 0),
        Number(a.passCount || 0),
        Number(a.failCount || 0),
        a.signatureVerified ? 1 : 0,
        String(a.timestamp || ''),
        JSON.stringify(a)
      );
    }

    // permits
    sqliteDb.exec('DELETE FROM permits');
    const insPtw = sqliteDb.prepare(
      `INSERT OR REPLACE INTO permits (id, type, title, zone, requester, status, telemetry, timer, loto_tags, approved_by, raw_json)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
    );
    for (const p of data.permits || []) {
      insPtw.run(
        String(p.id || ''),
        String(p.type || ''),
        String(p.title || ''),
        String(p.zone || ''),
        String(p.requester || ''),
        String(p.status || ''),
        String(p.telemetry || ''),
        String(p.timer || ''),
        String(p.lotoTags || ''),
        String(p.approvedBy || ''),
        JSON.stringify(p)
      );
    }

    // roster
    sqliteDb.exec('DELETE FROM roster');
    const insRoster = sqliteDb.prepare(
      `INSERT OR REPLACE INTO roster (emp_id, name, ur, role, designation, shift, zone, attendance_status, nights_performed, helmet, shoes, gloves, ear, raw_json)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
    );
    for (const r of data.roster || []) {
      insRoster.run(
        String(r.empId || ''),
        String(r.name || ''),
        String(r.ur || ''),
        String(r.role || ''),
        String(r.designation || ''),
        String(r.shift || ''),
        String(r.zone || ''),
        String(r.attendanceStatus || ''),
        Number(r.nightsPerformed || 0),
        r.helmet ? 1 : 0,
        r.shoes ? 1 : 0,
        r.gloves ? 1 : 0,
        r.ear ? 1 : 0,
        JSON.stringify(r)
      );
    }

    // audit_logs
    sqliteDb.exec('DELETE FROM audit_logs');
    const insLog = sqliteDb.prepare(
      `INSERT OR REPLACE INTO audit_logs (id, actor_id, actor_role, action, target_resource, coords, timestamp, details, raw_json)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`
    );
    for (const l of data.auditLogs || []) {
      insLog.run(
        String(l.id || ''),
        String(l.actorId || ''),
        String(l.actorRole || ''),
        String(l.action || ''),
        String(l.targetResource || ''),
        String(l.coords || ''),
        String(l.timestamp || ''),
        typeof l.details === 'string' ? l.details : JSON.stringify(l.details || ''),
        JSON.stringify(l)
      );
    }

    // alarms
    sqliteDb.exec('DELETE FROM alarms');
    const insAlarm = sqliteDb.prepare(
      `INSERT OR REPLACE INTO alarms (id, title, zone, severity, triggered_by, timestamp, coords, is_acknowledged, raw_json)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`
    );
    for (const al of data.alarms || []) {
      insAlarm.run(
        String(al.id || ''),
        String(al.title || ''),
        String(al.zone || ''),
        String(al.severity || ''),
        String(al.triggeredBy || ''),
        String(al.timestamp || ''),
        String(al.coords || ''),
        al.isAcknowledged ? 1 : 0,
        JSON.stringify(al)
      );
    }

    // email_logs
    sqliteDb.exec('DELETE FROM email_logs');
    const insEmail = sqliteDb.prepare(
      `INSERT OR REPLACE INTO email_logs (id, recipient, subject, status, timestamp, raw_json)
       VALUES (?, ?, ?, ?, ?, ?)`
    );
    for (const e of data.emailLogs || []) {
      insEmail.run(
        String(e.id || ''),
        String(e.to || ''),
        String(e.subject || ''),
        String(e.status || ''),
        String(e.timestamp || ''),
        JSON.stringify(e)
      );
    }

    // pending_users
    sqliteDb.exec('DELETE FROM pending_users');
    const insPending = sqliteDb.prepare(
      `INSERT OR REPLACE INTO pending_users (emp_id, name, cnic, role, shift, zone, status, created_at, raw_json)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`
    );
    for (const p of data.pendingUsers || []) {
      insPending.run(
        String(p.empId || ''),
        String(p.fullName || p.name || ''),
        String(p.cnic || ''),
        String(p.role || ''),
        String(p.shift || ''),
        String(p.assignedZone || p.zone || ''),
        String(p.status || ''),
        String(p.createdAt || ''),
        JSON.stringify(p)
      );
    }

    sqliteDb.exec('COMMIT');
  } catch (err) {
    try {
      sqliteDb.exec('ROLLBACK');
    } catch (_) {}
    console.error('[Database] SQLite sync error:', err.message);
  }
}

function runReadOnlySql(sql) {
  if (!isSqliteActive || !sqliteDb) {
    throw new Error('SQLite engine is not initialized.');
  }
  const trimmed = String(sql || '').trim();
  if (!trimmed) {
    throw new Error('SQL query cannot be empty.');
  }
  const upper = trimmed.toUpperCase();
  const allowedStarts = ['SELECT', 'PRAGMA', 'EXPLAIN', 'WITH'];
  if (!allowedStarts.some((kw) => upper.startsWith(kw))) {
    throw new Error('Only read-only SELECT / PRAGMA / WITH queries are permitted in Database Studio.');
  }
  const forbidden = /\b(DROP|DELETE|UPDATE|INSERT|ALTER|REPLACE|CREATE|TRUNCATE|ATTACH|DETACH|VACUUM)\b/i;
  if (forbidden.test(trimmed)) {
    throw new Error('Write/DDL statements are blocked in read-only SQL Console.');
  }

  const start = Date.now();
  const stmt = sqliteDb.prepare(trimmed);
  const rows = stmt.all();
  const executionMs = Date.now() - start;
  const columns = rows.length > 0 ? Object.keys(rows[0]) : [];
  return { columns, rows, rowCount: rows.length, executionMs };
}

// =========================================================================
// 2. OFFICIAL MONGODB CONNECTOR (Atlas mongodb+srv:// or Local mongodb://)
// =========================================================================
let mongoClient = null;
let mongoDb = null;
let mongoStatus = {
  connected: false,
  dbName: process.env.MONGODB_DB_NAME || 'chiniot_power_hse',
  host: null,
  lastSync: null,
  lastError: null,
};

function maskMongoUri(uri) {
  if (!uri) return null;
  try {
    return uri.replace(/\/\/([^:@]+):([^@]+)@/, '//$1:****@');
  } catch (_) {
    return 'configured';
  }
}

async function connectMongo(uri, dbName = 'chiniot_power_hse', persistToEnv = false) {
  if (!uri || typeof uri !== 'string') {
    throw new Error('A valid MongoDB connection string (mongodb:// or mongodb+srv://) is required.');
  }
  const cleanUri = uri.trim();
  const targetDb = (dbName || 'chiniot_power_hse').trim();

  // Close existing client if any
  if (mongoClient) {
    try {
      await mongoClient.close();
    } catch (_) {}
    mongoClient = null;
    mongoDb = null;
  }

  const client = new MongoClient(cleanUri, {
    serverSelectionTimeoutMS: 6000,
    connectTimeoutMS: 6000,
  });

  try {
    await client.connect();
    await client.db(targetDb).command({ ping: 1 });

    mongoClient = client;
    mongoDb = client.db(targetDb);
    mongoStatus = {
      connected: true,
      dbName: targetDb,
      host: maskMongoUri(cleanUri),
      lastSync: null,
      lastError: null,
    };

    if (persistToEnv) {
      saveEnvVar('MONGODB_URI', cleanUri);
      saveEnvVar('MONGODB_DB_NAME', targetDb);
    }

    console.log(`[Database] Connected to MongoDB (${mongoStatus.host}) -> DB: ${targetDb}`);
    await syncAllToMongo(readDb());
    return { ...mongoStatus };
  } catch (err) {
    try {
      await client.close();
    } catch (_) {}
    mongoStatus = {
      connected: false,
      dbName: targetDb,
      host: maskMongoUri(cleanUri),
      lastSync: null,
      lastError: err.message,
    };
    throw err;
  }
}

async function disconnectMongo() {
  if (mongoClient) {
    try {
      await mongoClient.close();
    } catch (_) {}
  }
  mongoClient = null;
  mongoDb = null;
  mongoStatus = {
    connected: false,
    dbName: mongoStatus.dbName,
    host: null,
    lastSync: null,
    lastError: null,
  };
  return { ...mongoStatus };
}

async function syncAllToMongo(data) {
  if (!mongoDb || !mongoStatus.connected || !data) return null;
  const syncedCounts = {};
  try {
    for (const [jsonKey, colName] of Object.entries(COLLECTION_MAP)) {
      const docs = Array.isArray(data[jsonKey]) ? data[jsonKey] : [];
      const col = mongoDb.collection(colName);
      await col.deleteMany({});
      if (docs.length > 0) {
        // Clone documents without mutating in-memory objects
        const cleanDocs = docs.map((d) => {
          const copy = { ...d };
          delete copy._id;
          return copy;
        });
        await col.insertMany(cleanDocs);
      }
      syncedCounts[colName] = docs.length;
    }
    mongoStatus.lastSync = new Date().toISOString();
    mongoStatus.lastError = null;
    console.log(`[Database] Synced ${Object.keys(syncedCounts).length} collections to MongoDB (${mongoStatus.dbName})`);
    return syncedCounts;
  } catch (err) {
    mongoStatus.lastError = err.message;
    console.error('[Database] MongoDB sync error:', err.message);
    throw err;
  }
}

async function getMongoCollection(colName, limit = 500) {
  if (!mongoDb || !mongoStatus.connected) {
    throw new Error('MongoDB is not connected.');
  }
  return await mongoDb.collection(colName).find({}).limit(limit).toArray();
}

function saveEnvVar(key, value) {
  try {
    let content = fs.existsSync(ENV_FILE) ? fs.readFileSync(ENV_FILE, 'utf8') : '';
    const line = `${key}=${value}`;
    const regex = new RegExp(`^${key}=.*$`, 'm');
    if (regex.test(content)) {
      content = content.replace(regex, line);
    } else {
      content = content.trim() ? `${content.trim()}\n${line}\n` : `${line}\n`;
    }
    fs.writeFileSync(ENV_FILE, content, 'utf8');
  } catch (err) {
    console.error('[Database] Could not save .env variable:', err.message);
  }
}

// =========================================================================
// 3. OPTIONAL POSTGRESQL POOL
// =========================================================================
let pgPool = null;
let isPgActive = false;

if (process.env.DATABASE_URL) {
  try {
    pgPool = new Pool({
      connectionString: process.env.DATABASE_URL,
      connectionTimeoutMillis: 2000,
    });
    pgPool.query('SELECT 1', (err) => {
      if (err) {
        isPgActive = false;
      } else {
        console.log('[Database] Connected to PostgreSQL database');
        isPgActive = true;
      }
    });
  } catch (_) {
    isPgActive = false;
  }
}

// =========================================================================
// 4. CORE PERSISTENCE LIFECYCLE (db.json <-> SQLite <-> MongoDB)
// =========================================================================
function initDb() {
  const seedData = JSON.parse(fs.readFileSync(SEED_FILE, 'utf8'));
  if (!fs.existsSync(DB_FILE)) {
    seedData.auditLogs = [
      {
        id: 'LOG-INIT-01',
        actorId: 'CPL-EMP-3648',
        actorRole: 'HSE Manager',
        action: 'SYSTEM_BOOTSTRAP',
        targetResource: 'PLANT_UNIT_1_2',
        timestamp: new Date().toISOString(),
        coords: '31.7204° N, 72.9791° E',
        details: 'CPL 62.4 MW Co-Gen Plant real operational datasets (Oct/Nov 2026) provisioned.'
      }
    ];
    seedData.alarms = [];
    seedData.emailLogs = [
      {
        id: 'EML-001',
        to: 'sumaira.rafique@chiniotpower.com',
        subject: 'CPL Oct-2026 Near-Miss & Man-Hours Compliance Digest',
        status: 'Sent',
        timestamp: new Date().toISOString()
      }
    ];
    fs.mkdirSync(path.dirname(DB_FILE), { recursive: true });
    fs.writeFileSync(DB_FILE, JSON.stringify(seedData, null, 2), 'utf8');
  } else {
    try {
      const existing = JSON.parse(fs.readFileSync(DB_FILE, 'utf8'));
      const needsUpgrade =
        !existing.zones ||
        existing.zones.length < 10 ||
        !existing.hazards ||
        !existing.hazards.some((h) => h.nmNumber === '26-CPL-473');
      if (needsUpgrade) {
        existing.zones = seedData.zones;
        existing.checklistTemplates = seedData.checklistTemplates;
        existing.hazards = seedData.hazards;
        existing.permits = seedData.permits;
        existing.roster = seedData.roster;
        if (!existing.users) existing.users = [];
        for (const su of seedData.users) {
          if (!existing.users.some((u) => u.employeeId === su.employeeId)) {
            existing.users.push(su);
          }
        }
        fs.writeFileSync(DB_FILE, JSON.stringify(existing, null, 2), 'utf8');
      }
    } catch (_) {}
  }

  initSqlite();
  try {
    const currentData = JSON.parse(fs.readFileSync(DB_FILE, 'utf8'));
    syncJsonToSqlite(currentData);
  } catch (err) {
    console.error('[Database] Initial SQLite population notice:', err.message);
  }

  // Auto-connect MongoDB if MONGODB_URI is configured in .env or environment
  if (process.env.MONGODB_URI) {
    connectMongo(process.env.MONGODB_URI, process.env.MONGODB_DB_NAME || 'chiniot_power_hse', false)
      .catch((err) => {
        console.log(`[Database] Configured MONGODB_URI unreachable (${err.message}). Running on SQLite + JSON.`);
      });
  }
}

initDb();

function readDb() {
  try {
    return JSON.parse(fs.readFileSync(DB_FILE, 'utf8'));
  } catch (err) {
    initDb();
    return JSON.parse(fs.readFileSync(DB_FILE, 'utf8'));
  }
}

function writeDb(data) {
  fs.writeFileSync(DB_FILE, JSON.stringify(data, null, 2), 'utf8');
  syncJsonToSqlite(data);
  if (mongoStatus.connected && mongoDb) {
    syncAllToMongo(data).catch(() => {});
  }
}

// Log immutable audit entry for NEPRA / ISO 45001 compliance
function addAuditLog({ actorId, actorRole, action, targetResource, coords, details }) {
  const db = readDb();
  if (!db.auditLogs) db.auditLogs = [];
  const logEntry = {
    id: `LOG-${Date.now()}-${Math.floor(Math.random() * 1000)}`,
    actorId: actorId || 'SYSTEM',
    actorRole: actorRole || 'worker',
    action,
    targetResource: targetResource || 'GENERAL',
    coords: coords || '31.7204° N, 72.9791° E',
    timestamp: new Date().toISOString(),
    details: details || {}
  };
  db.auditLogs.unshift(logEntry);
  writeDb(db);
  return logEntry;
}

function getDatabaseOverview() {
  const data = readDb();
  let sqliteSizeKb = 0;
  try {
    if (fs.existsSync(SQLITE_FILE)) {
      sqliteSizeKb = Math.round((fs.statSync(SQLITE_FILE).size / 1024) * 10) / 10;
    }
  } catch (_) {}

  const collections = Object.entries(COLLECTION_MAP).map(([jsonKey, tableName]) => {
    const arr = Array.isArray(data[jsonKey]) ? data[jsonKey] : [];
    const sampleKeys = arr.length > 0 && typeof arr[0] === 'object' ? Object.keys(arr[0]) : [];
    return {
      key: jsonKey,
      tableName,
      count: arr.length,
      fields: sampleKeys,
    };
  });

  const totalRecords = collections.reduce((sum, c) => sum + c.count, 0);

  return {
    engines: {
      sqlite: {
        active: isSqliteActive,
        file: SQLITE_FILE,
        fileName: 'chiniot_power_hse.db',
        sizeKb: sqliteSizeKb,
        engine: `Node.js Native SQLite (${process.version})`,
      },
      mongodb: { ...mongoStatus },
      postgres: { active: isPgActive },
    },
    totalRecords,
    collections,
  };
}

module.exports = {
  readDb,
  writeDb,
  addAuditLog,
  COLLECTION_MAP,
  TABLE_TO_KEY,
  SQLITE_FILE,
  runReadOnlySql,
  connectMongo,
  disconnectMongo,
  syncAllToMongo,
  getMongoCollection,
  getDatabaseOverview,
};
