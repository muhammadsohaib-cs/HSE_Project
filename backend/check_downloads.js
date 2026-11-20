const fs = require('fs');
const summary = JSON.parse(fs.readFileSync('d:\\Chiniot Power HSE\\checklist_summary.json', 'utf8'));
console.log('First Aid Box Weekly Inspection Checklist.download:', summary['First Aid Box Weekly Inspection Checklist.download']);
console.log('First Aid Items Usage Log Checkl list.download:', summary['First Aid Items Usage Log Checkl list.download']);
