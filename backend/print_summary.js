const fs = require('fs');
const summary = JSON.parse(fs.readFileSync('d:\\Chiniot Power HSE\\checklist_summary.json', 'utf8'));

for (const [filename, info] of Object.entries(summary)) {
  console.log(`\n======================================================`);
  console.log(`FILE: ${filename}`);
  if (info.error) {
    console.log(`  ERROR: ${info.error}`);
    console.log(`  PREVIEW: ${info.textPreview}`);
    continue;
  }
  console.log(`  SHEETS: ${info.sheets.join(', ')}`);
  for (const [sheet, sdata] of Object.entries(info.data)) {
    console.log(`  --- SHEET: ${sheet} (${sdata.rowCount} rows) ---`);
    for (let i = 0; i < Math.min(8, sdata.rows.length); i++) {
      const nonNull = (sdata.rows[i] || []).filter(c => c !== null && c !== undefined && c !== '');
      if (nonNull.length > 0) {
        console.log(`    Row ${i + 1}: ${JSON.stringify(nonNull.slice(0, 7))}`);
      }
    }
  }
}
