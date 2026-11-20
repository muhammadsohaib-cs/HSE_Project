const fs = require('fs');
const path = require('path');
const xlsx = require('xlsx');

const rootDir = 'd:\\Chiniot Power HSE';

const files = [
  'fire Extinguishers inspection checklist.xlsx',
  'Fire Fighting Equipment cleaning cheklist.xlsx',
  'Fire Hose cabenit inventory Checklist.xlsx',
  'Fire Water Drum inspection checklist.xlsx',
  'FIREFIGHTING EQUIPMENT WEEKLY INPSECTION SCHEDULE.xlsx',
  'First Aid Box inspection checklist.xlsx',
  'Hydrant inspection checklist.xlsx',
  'Landing valve inspection checklist.xlsx',
  'Monitor inspecction checklist.xlsx',
  'Safety Induction Attendance Sheet.xlsx',
  'Tractor inspection Checklist.xlsx',
  'Weekly Routine work checklist.xlsx',
];

const extracted = {};

for (const f of files) {
  const fullPath = path.join(rootDir, f);
  if (!fs.existsSync(fullPath)) continue;
  const wb = xlsx.readFile(fullPath);
  extracted[f] = {};
  for (const sheetName of wb.SheetNames) {
    const sheet = wb.Sheets[sheetName];
    const data = xlsx.utils.sheet_to_json(sheet, { header: 1, blankrows: false });
    extracted[f][sheetName] = data;
  }
}

fs.writeFileSync(path.join(rootDir, 'extracted_checklists_raw.json'), JSON.stringify(extracted, null, 2));
console.log('Finished extracting full raw data for all 12 checklists.');
