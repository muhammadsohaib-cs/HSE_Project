const fs = require('fs');
const data = JSON.parse(fs.readFileSync('d:\\Chiniot Power HSE\\extracted_checklists_raw.json', 'utf8'));

for (const [file, sheets] of Object.entries(data)) {
  console.log(`\n======================================================`);
  console.log(`FILE: ${file}`);
  for (const [sheetName, rows] of Object.entries(sheets)) {
    console.log(`--- Sheet: ${sheetName} (Rows: ${rows.length}) ---`);
    for (let i = 0; i < Math.min(12, rows.length); i++) {
      console.log(`  Row ${i}: ${JSON.stringify(rows[i])}`);
    }
  }
}
