const fs = require('fs');
const path = require('path');

const templatesPath = path.join(__dirname, 'src', 'data', 'checklist_catalog.json');
const seedPath = path.join(__dirname, 'src', 'data', 'seed.json');
const dbPath = path.join(__dirname, 'src', 'data', 'db.json');

const templates = JSON.parse(fs.readFileSync(templatesPath, 'utf8'));

// Update seed.json
const seed = JSON.parse(fs.readFileSync(seedPath, 'utf8'));
seed.checklistTemplates = templates;
fs.writeFileSync(seedPath, JSON.stringify(seed, null, 2));
console.log(`Updated seed.json with ${templates.length} checklist templates.`);

// Update db.json
const db = JSON.parse(fs.readFileSync(dbPath, 'utf8'));
db.checklistTemplates = templates;
if (!db.checklistAudits) db.checklistAudits = [];
fs.writeFileSync(dbPath, JSON.stringify(db, null, 2));
console.log(`Updated db.json with ${templates.length} checklist templates.`);
