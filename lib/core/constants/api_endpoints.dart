import 'package:flutter/foundation.dart';

class ApiEndpoints {
  static String _activeBaseUrl = getDefaultBaseUrl();

  static String getDefaultBaseUrl() {
    const envUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (envUrl.isNotEmpty) return envUrl;
    if (kIsWeb) return 'http://localhost:5000/api/v1';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000/api/v1';
    }
    return 'http://localhost:5000/api/v1';
  }

  static String get baseUrl => _activeBaseUrl;

  static void setBaseUrl(String newUrl) {
    var clean = newUrl.trim();
    if (clean.endsWith('/')) {
      clean = clean.substring(0, clean.length - 1);
    }
    _activeBaseUrl = clean;
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Authentication
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String profile = '/auth/me';

  // Hazards & Incidents
  static const String hazards = '/hazards';
  static String hazardDetails(String id) => '/hazards/$id';
  static String hazardCapa(String id) => '/hazards/$id/capa';
  static String hazardUploadMedia(String id) => '/hazards/$id/media';
  static const String hazardSyncQueue = '/hazards/batch-sync';

  // Checklists
  static const String checklistTemplates = '/checklists/templates';
  static const String checklists = '/checklists';
  static String checklistDetails(String id) => '/checklists/$id';
  static const String shiftSummary = '/checklists/shift-summary';

  // PTW & LOTO
  static const String ptw = '/ptw';
  static String ptwApprove(String id) => '/ptw/$id/approve';

  // Alarms
  static const String alarms = '/alarms';
  static const String triggerAlarm = '/alarms/trigger';
  static const String clearAlarm = '/alarms/clear';
  static String acknowledgeAlarm(String id) => '/alarms/$id/acknowledge';

  // Roster & PPE
  static const String roster = '/roster';
  static String workerPpe(String empId) => '/roster/$empId/ppe';

  // Training
  static const String trainings = '/trainings';
  static String trainingAttendance(String id) => '/trainings/$id/attendance';
  static const String userCertifications = '/trainings/my-certificates';

  // Analytics & Export
  static const String metrics = '/analytics/summary';
  static const String exportCsv = '/analytics/export/csv';
  static const String exportPdf = '/analytics/export/pdf';

  // Immutable Audit Trail (NEPRA / ISO 45001)
  static const String auditLogs = '/audit/logs';
}

