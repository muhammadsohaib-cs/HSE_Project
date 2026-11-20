const fs = require('fs');
const path = require('path');

const raw = JSON.parse(fs.readFileSync('d:\\Chiniot Power HSE\\extracted_checklists_raw.json', 'utf8'));

for (const [file, sheets] of Object.entries(raw)) {
  console.log(`\n======================================================`);
  console.log(`FILE: ${file}`);
  for (const [sheetName, rows] of Object.entries(sheets)) {
    console.log(`--- Sheet: ${sheetName} (Rows: ${rows.length}) ---`);
    for (let i = 0; i < Math.min(8, rows.length); i++) {
      const filtered = rows[i].filter(c => c !== null && c !== undefined && c !== '');
      if (filtered.length > 0) {
        console.log(`  Row ${i}: ${JSON.stringify(filtered.slice(0, 8))}`);
      }
    }
  }
}
