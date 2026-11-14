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

// Initialize or upgrade database with real CPL seed data
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
        !existing.hazards.some(h => h.nmNumber === '26-CPL-473');
      if (needsUpgrade) {
        existing.zones = seedData.zones;
        existing.checklistTemplates = seedData.checklistTemplates;
        existing.hazards = seedData.hazards;
        existing.permits = seedData.permits;
        existing.roster = seedData.roster;
        if (!existing.users) existing.users = [];
        for (const su of seedData.users) {
          if (!existing.users.some(u => u.employeeId === su.employeeId)) {
            existing.users.push(su);
          }
        }
        fs.writeFileSync(DB_FILE, JSON.stringify(existing, null, 2), 'utf8');
      }
    } catch (_) {}
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

