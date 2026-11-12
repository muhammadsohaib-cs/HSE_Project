import 'package:csv/csv.dart';

class CsvExporter {
  /// Converts a list of records into formatted CSV string
  static String exportHazardsCsv(List<Map<String, dynamic>> hazards) {
    final List<List<dynamic>> rows = [];

    // Header row
    rows.add([
      'Hazard ID',
      'Reporter ID',
      'Plant Zone',
      'Coordinates',
      'Severity',
      'Probability',
      'Risk Score',
      'Risk Band',
      'Status',
      'Reported Timestamp',
      'Action Owner',
      'Resolution Notes'
    ]);

    for (final h in hazards) {
      rows.add([
        h['id'] ?? '',
        h['reporter_id'] ?? '',
        h['plant_zone'] ?? '',
        h['coordinates'] ?? '',
        h['severity'] ?? '',
        h['probability'] ?? '',
        h['score'] ?? '',
        h['risk_band'] ?? '',
        h['status'] ?? '',
        h['timestamp'] ?? '',
        h['action_owner'] ?? '',
        h['resolution_notes'] ?? '',
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  /// Converts shift checklists into formatted CSV
  static String exportChecklistsCsv(List<Map<String, dynamic>> checklists) {
    final List<List<dynamic>> rows = [];

    rows.add([
      'Audit ID',
      'Template Title',
      'Inspector ID',
      'Plant Unit',
      'Shift Type',
      'Pass Count',
      'Fail Count',
      'Completion Rate (%)',
      'Status',
      'Audit Date'
    ]);

    for (final c in checklists) {
      rows.add([
        c['id'] ?? '',
        c['title'] ?? '',
        c['inspector_id'] ?? '',
        c['plant_unit'] ?? '',
        c['shift_type'] ?? '',
        c['pass_count'] ?? '',
        c['fail_count'] ?? '',
        c['completion_rate'] ?? '',
        c['status'] ?? '',
        c['audit_date'] ?? '',
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }
}

