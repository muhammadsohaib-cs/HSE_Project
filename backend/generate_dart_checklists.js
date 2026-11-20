const fs = require('fs');
const path = require('path');

const catalogPath = path.join(__dirname, 'src', 'data', 'checklist_catalog.json');
const outPath = path.join(__dirname, '..', 'lib', 'core', 'constants', 'cpl_checklists_data.dart');

const templates = JSON.parse(fs.readFileSync(catalogPath, 'utf8'));

let dart = `// Auto-generated real Chiniot Power Limited (CPL) HSE Checklist Catalog
import '../features/cpl_system/models/cpl_models.dart';

const List<ChecklistTemplate> kCplChecklistTemplates = [
`;

for (const t of templates) {
  dart += `  ChecklistTemplate(\n`;
  dart += `    id: ${JSON.stringify(t.id)},\n`;
  dart += `    docNo: ${JSON.stringify(t.docNo)},\n`;
  dart += `    title: ${JSON.stringify(t.title)},\n`;
  dart += `    titleUr: ${JSON.stringify(t.titleUr)},\n`;
  dart += `    category: ${JSON.stringify(t.category)},\n`;
  dart += `    categoryUr: ${JSON.stringify(t.categoryUr || '')},\n`;
  dart += `    frequency: ${JSON.stringify(t.frequency)},\n`;
  dart += `    frequencyUr: ${JSON.stringify(t.frequencyUr || '')},\n`;
  dart += `    targetZone: ${JSON.stringify(t.targetZone)},\n`;
  dart += `    description: ${JSON.stringify(t.description)},\n`;
  dart += `    items: const [\n`;
  for (const item of t.items) {
    dart += `      ChecklistAuditItem(\n`;
    dart += `        id: ${item.id},\n`;
    dart += `        en: ${JSON.stringify(item.en)},\n`;
    dart += `        ur: ${JSON.stringify(item.ur)},\n`;
    dart += `        status: ${JSON.stringify(item.status || 'pass')},\n`;
    dart += `        standard: ${JSON.stringify(item.standard || '')},\n`;
    dart += `        category: ${JSON.stringify(t.category)},\n`;
    dart += `      ),\n`;
  }
  dart += `    ],\n`;
  dart += `  ),\n`;
}

dart += `];\n`;

fs.writeFileSync(outPath, dart);
console.log(`Generated Dart checklist data at ${outPath}`);
