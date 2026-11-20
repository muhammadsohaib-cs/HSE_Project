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
  'First Aid Box Weekly Inspection Checklist.download',
  'First Aid Items Usage Log Checkl list.download',
  'Hydrant inspection checklist.xlsx',
  'Landing valve inspection checklist.xlsx',
  'Monitor inspecction checklist.xlsx',
  'Safety Induction Attendance Sheet.xlsx',
  'Tractor inspection Checklist.xlsx',
  'Weekly Routine work checklist.xlsx',
];

const results = {};

for (const f of files) {
  const fullPath = path.join(rootDir, f);
  if (!fs.existsSync(fullPath)) {
    results[f] = { error: 'file not found' };
    continue;
  }
  const stat = fs.statSync(fullPath);
  try {
    const wb = xlsx.readFile(fullPath);
    const sheetData = {};
    for (const sheetName of wb.SheetNames) {
      const sheet = wb.Sheets[sheetName];
      const json = xlsx.utils.sheet_to_json(sheet, { header: 1 });
      sheetData[sheetName] = {
        rowCount: json.length,
        rows: json.slice(0, 15) // first 15 rows
      };
    }
    results[f] = {
      size: stat.size,
      sheets: wb.SheetNames,
      data: sheetData
    };
  } catch (err) {
    // If not a workbook, read as text or hex
    let textPreview = '';
    try {
      const buf = fs.readFileSync(fullPath);
      textPreview = buf.slice(0, 300).toString('utf8');
    } catch (_) {}
    results[f] = {
      size: stat.size,
      error: err.message,
      textPreview: textPreview
    };
  }
}

fs.writeFileSync(path.join(rootDir, 'checklist_summary.json'), JSON.stringify(results, null, 2));
console.log('Successfully written checklist_summary.json');
