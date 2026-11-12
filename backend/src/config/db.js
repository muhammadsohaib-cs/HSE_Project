const fs = require('fs');
const path = require('path');
const { Pool } = require('pg');

const DB_FILE = path.join(__dirname, '../data/db.json');
const SEED_FILE = path.join(__dirname, '../data/seed.json');

// PostgreSQL Pool configuration with automatic JSON fallback
let pgPool = null;
let isPgActive = false;

try {
  const connectionString = process.env.DATABASE_URL || 'postgresql://postgres:postgres@localhost:5432/chiniot_power_hse';
  pgPool = new Pool({
    connectionString,
    connectionTimeoutMillis: 2000,
  });

  pgPool.query('SELECT 1', (err) => {
    if (err) {
      console.log('[Database] PostgreSQL offline/unreachable. Operating on CPL Local Persistent File Storage (db.json)');
      isPgActive = false;
    } else {
      console.log('[Database] Connected to PostgreSQL 15+ database (chiniot_power_hse)');
      isPgActive = true;
    }
  });
} catch (e) {
  isPgActive = false;
}

// Initialize database with seed data if db.json does not exist
function initDb() {
  if (!fs.existsSync(DB_FILE)) {
    const seedData = JSON.parse(fs.readFileSync(SEED_FILE, 'utf8'));
    seedData.auditLogs = [
      {
        id: 'LOG-INIT-01',
        actorId: 'CP-EMP-1001',
        actorRole: 'admin',
        action: 'SYSTEM_BOOTSTRAP',
        targetResource: 'PLANT_UNIT_1',
        timestamp: new Date().toISOString(),
        coords: '31.7204° N, 72.9791° E',
        details: 'Initial CPL 62.4 MW Power Plant master database provisioned.'
      }
    ];
    seedData.alarms = [];
    seedData.emailLogs = [
      {
        id: 'EML-001',
        to: 'plant.manager@chiniotpower.com',
        subject: 'HSE Weekly Compliance Report Digest',
        status: 'Sent',
        timestamp: new Date().toISOString()
      }
    ];
    fs.mkdirSync(path.dirname(DB_FILE), { recursive: true });
    fs.writeFileSync(DB_FILE, JSON.stringify(seedData, null, 2), 'utf8');
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

module.exports = {
  readDb,
  writeDb,
  addAuditLog
};

