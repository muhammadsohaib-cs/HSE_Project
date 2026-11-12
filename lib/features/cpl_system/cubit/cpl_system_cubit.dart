import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/platform/audio_service.dart';
import '../../../../core/storage/hive_boxes.dart';
import '../../../../core/storage/offline_sync_queue.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/cpl_models.dart';
import 'cpl_system_state.dart';

class CplSystemCubit extends Cubit<CplSystemState> {
  final AudioAlarmService _audioService;
  final DioClient? _dioClient;
  final OfflineSyncQueue? _syncQueue;
  final SecureStorageService? _secureStorage;
  IO.Socket? _socket;

  CplSystemCubit({
    AudioAlarmService? audioService,
    DioClient? dioClient,
    OfflineSyncQueue? syncQueue,
    SecureStorageService? secureStorage,
  })  : _audioService = audioService ?? AudioAlarmService(),
        _dioClient = dioClient,
        _syncQueue = syncQueue,
        _secureStorage = secureStorage,
        super(_initialState);

  static final CplSystemState _initialState = CplSystemState(
    language: 'en',
    activeScreenIndex: 1, // Default to Dashboard (Screen 02)
    currentUser: const UserSession(
      empId: 'CPL-EMP-1001',
      name: 'Engr. Tariq Khan',
      urduName: 'انجینئر طارق خان',
      role: 'HSE Manager',
      shift: 'Shift A: Morning (06:00 - 14:00)',
      cnic: '33202-1234567-1',
      zone: 'Plant Headquarters',
    ),
    zones: const [
      PlantZone(id: 'Z1', name: 'Boiler House Unit-1', ur: 'بوائلر ہاؤس یونٹ-1', coords: '31.7204° N, 72.9791° E', workers: 34),
      PlantZone(id: 'Z2', name: 'Steam Turbine Hall', ur: 'سٹیم ٹربائن ہال', coords: '31.7201° N, 72.9788° E', workers: 26),
      PlantZone(id: 'Z3', name: 'Bagasse & Coal Yard', ur: 'بگاس اور کوئلہ یارڈ', coords: '31.7195° N, 72.9802° E', workers: 38),
      PlantZone(id: 'Z4', name: '132kV Grid Switchyard', ur: '132 کے وی گرڈ سوئچ یارڈ', coords: '31.7208° N, 72.9780° E', workers: 14),
      PlantZone(id: 'Z5', name: 'Water Treatment Plant', ur: 'واٹر ٹریٹمنٹ پلانٹ', coords: '31.7198° N, 72.9784° E', workers: 18),
      PlantZone(id: 'Z6', name: 'Cooling Tower', ur: 'کولنگ ٹاور', coords: '31.7192° N, 72.9795° E', workers: 18),
    ],
    hazards: const [
      HazardItem(
        id: 'HAZ-309',
        title: 'Steam Flange Weeping (FV-14)',
        zone: 'Boiler House Unit-1',
        severity: 'High',
        reporter: 'Muhammad Tariq (CPL-EMP-1042)',
        status: 'Open',
        time: '12m ago',
        coords: '31.7204° N, 72.9791° E',
      ),
      HazardItem(
        id: 'HAZ-308',
        title: 'Bagasse Conveyor Belt Guard Loose',
        zone: 'Bagasse & Coal Yard',
        severity: 'Critical',
        reporter: 'Zeeshan Ahmed (CPL-EMP-1088)',
        status: 'In Progress',
        time: '1h ago',
        coords: '31.7195° N, 72.9802° E',
      ),
      HazardItem(
        id: 'HAZ-307',
        title: 'Switchyard Earth Pit Resistance > 2 Ohms',
        zone: '132kV Grid Switchyard',
        severity: 'Moderate',
        reporter: 'Usman Ghani (CPL-EMP-1015)',
        status: 'Resolved',
        time: '4h ago',
        coords: '31.7208° N, 72.9780° E',
      ),
    ],
    selectedLikelihood: 4,
    selectedSeverity: 4,
    capas: const [
      CapaItem(
        id: 'CAPA-104',
        title: 'Bagasse Conveyor Emergency Stop Cord Re-anchoring',
        zone: 'Bagasse Yard',
        score: 20,
        level: 'Critical',
        owner: 'Mechanical Team',
        due: 'Today 18:00',
        signedOff: false,
      ),
      CapaItem(
        id: 'CAPA-103',
        title: 'Turbine Vibration Sensor Calibration on Bearing 2',
        zone: 'Turbine Hall',
        score: 12,
        level: 'High',
        owner: 'I&C Department',
        due: 'Tomorrow 10:00',
        signedOff: true,
      ),
      CapaItem(
        id: 'CAPA-102',
        title: 'Deaerator Pressure Relief Valve Recertification',
        zone: 'Boiler House Unit-1',
        score: 9,
        level: 'Moderate',
        owner: 'Operations Shift Lead',
        due: '14 Nov 14:00',
        signedOff: true,
      ),
    ],
    checklistZone: 'Boiler House Unit-1',
    checklistSigned: false,
    checklistItems: const [
      ChecklistAuditItem(
        id: 1,
        en: 'Main Steam Line (105 bar) expansion joints checked for weeping',
        ur: 'مین سٹیم لائن (105 بار) ایکسپینشن جوائنٹس کا معائنہ مکمل ہے',
        status: 'pass',
      ),
      ChecklistAuditItem(
        id: 2,
        en: 'Bagasse feeder emergency stop pull-cords tested & responsive',
        ur: 'بگاس فیڈر ایمرجنسی اسٹاپ پل کورڈز مکمل طور پر فعال ہیں',
        status: 'pass',
      ),
      ChecklistAuditItem(
        id: 3,
        en: 'FD & ID Fan lubrication oil level & vibration within limits',
        ur: 'ایف ڈی اور آئی ڈی فین کا لوبریکیشن آئل لیول اور وائبریشن نارمل ہے',
        status: 'pass',
      ),
      ChecklistAuditItem(
        id: 4,
        en: 'Furnace flame scanner & purge interlock status verified',
        ur: 'فرنس فلیم سکینر اور پرج انٹرلاک سٹیٹس تصدیق شدہ ہے',
        status: 'pass',
      ),
      ChecklistAuditItem(
        id: 5,
        en: 'Safety relief valves manual lever inspection tagged',
        ur: 'سیفٹی ریلیف والوز کی مینوئل لیور ٹیگنگ درست ہے',
        status: 'fail',
      ),
      ChecklistAuditItem(
        id: 6,
        en: 'Fire hydrant pressure gauge reading >= 8.5 bar',
        ur: 'فائر ہائیڈرنٹ پریشر گیج 8.5 بار یا زائد ہے',
        status: 'pass',
      ),
    ],
    ptwFilter: 'All',
    permits: const [
      PtwItem(
        id: 'PTW-842',
        type: 'Hot Work',
        title: 'Boiler Deaerator Header Steam Line Welding',
        zone: 'Boiler House Unit-1 (Elev. 18m)',
        requester: 'Muhammad Tariq (Lead Welder)',
        status: 'Active',
        telemetry: 'O2: 20.9% • LEL: 0.0%',
        timer: '03:42:18 Remaining',
        lotoTags: 'LOTO-14 (Padlock #42 Applied)',
      ),
      PtwItem(
        id: 'PTW-841',
        type: 'Confined Space',
        title: 'Furnace Grate Chamber Internal Ash Inspection',
        zone: 'Boiler Furnace Chamber',
        requester: 'Zeeshan Ahmed (Boiler Tech)',
        status: 'Active',
        telemetry: 'CO: 2 ppm • Temp: 38°C',
        timer: '01:14:05 Remaining',
        lotoTags: 'LOTO-12 (Mechanical Blind Applied)',
      ),
      PtwItem(
        id: 'PTW-840',
        type: 'Electrical HV',
        title: '132kV Bus-Coupler Circuit Breaker Annual Overhaul',
        zone: '132kV Grid Switchyard',
        requester: 'Usman Ghani (Grid Engineer)',
        status: 'Hold',
        telemetry: '0.00 kV (Discharged & Earthed)',
        timer: 'Expired / Review',
        lotoTags: 'LOTO-08 (Dual Key Trapped Lock)',
      ),
      PtwItem(
        id: 'PTW-839',
        type: 'Working at Height',
        title: 'Chimney Flue Gas Emission Continuous Analyzer Sensor',
        zone: 'Boiler Stack (Elev. 65m)',
        requester: 'Bilal Mahmood (I&C Tech)',
        status: 'Pending',
        telemetry: 'Wind: 14 km/h (Permissible)',
        timer: 'Pending Shift Eng Approval',
        lotoTags: 'Full Body Harness & Lifeline Rigged',
      ),
    ],
    activeAlarm: null,
    emailLogs: const [
      EmailLogItem(
        id: 'EM-904',
        to: 'plant.head@chiniotpower.com',
        subject: '[DISPATCH] Boiler Header Steam Flange Weeping Alert',
        time: '14m ago',
        status: 'Delivered',
      ),
      EmailLogItem(
        id: 'EM-903',
        to: 'safety.board@chiniotpower.com',
        subject: '[NEPRA] Shift A Daily HSE Turnover Log Signed Off',
        time: '1h ago',
        status: 'Delivered',
      ),
      EmailLogItem(
        id: 'EM-902',
        to: 'rescue1122.chiniot@punjab.gov.pk',
        subject: '[DRILL] CPL Unit-1 Emergency Evacuation Routine Confirmation',
        time: '3h ago',
        status: 'Acknowledged',
      ),
    ],
    trainings: const [
      TrainingModule(
        id: 'TRN-101',
        title: 'High Pressure Steam Safety & Scald Mitigation',
        ur: 'ہائی پریشر سٹیم سیفٹی اور جلنے سے بچاؤ',
        duration: '45 mins • Practical On-Site',
        status: 'Certified',
        expiry: 'Valid until 12 Oct 2027',
        score: '96%',
      ),
      TrainingModule(
        id: 'TRN-102',
        title: '132kV Switchyard High Voltage ARC Flash Protection',
        ur: '132 کے وی گرڈ آرک فلیش حفاظتی طریقہ کار',
        duration: '60 mins • High Voltage Safety',
        status: 'Certified',
        expiry: 'Valid until 18 Dec 2026',
        score: '92%',
      ),
      TrainingModule(
        id: 'TRN-103',
        title: 'Bagasse Dust Explosive Fire Prevention Drill',
        ur: 'بگاس ڈسٹ فائر ڈرل و حفاظتی تدابیر',
        duration: '30 mins • Practical Drill',
        status: 'Expiring Soon',
        expiry: 'Expires in 6 days',
        score: '84%',
      ),
    ],
    qrCheckedIn: false,
    roster: const [
      WorkerRosterItem(
        empId: 'CPL-EMP-1042',
        name: 'Muhammad Tariq',
        ur: 'محمد طارق',
        role: 'Safety Officer',
        zone: 'Boiler House Unit-1',
        helmet: true,
        shoes: true,
        gloves: true,
        ear: false,
      ),
      WorkerRosterItem(
        empId: 'CPL-EMP-1088',
        name: 'Zeeshan Ahmed',
        ur: 'ذیشان احمد',
        role: 'Boiler Fuel Operator',
        zone: 'Bagasse & Coal Yard',
        helmet: true,
        shoes: true,
        gloves: true,
        ear: true,
      ),
      WorkerRosterItem(
        empId: 'CPL-EMP-1015',
        name: 'Usman Ghani',
        ur: 'عثمان غنی',
        role: 'Grid Switchyard Tech',
        zone: '132kV Grid Switchyard',
        helmet: true,
        shoes: true,
        gloves: true,
        ear: true,
      ),
      WorkerRosterItem(
        empId: 'CPL-EMP-1104',
        name: 'Kamran Siddiqui',
        ur: 'کامران صدیقی',
        role: 'Turbine Shift Eng.',
        zone: 'Steam Turbine Hall',
        helmet: true,
        shoes: true,
        gloves: false,
        ear: true,
      ),
    ],
    analyticsPeriod: '6M',
    pendingUsers: const [
      PendingUserRegistration(
        empId: 'CPL-EMP-1129',
        name: 'Faisal Mehmood',
        cnic: '33202-9918273-5',
        role: 'Plant Worker',
        shift: 'Shift B',
        status: 'Pending',
      ),
      PendingUserRegistration(
        empId: 'CPL-EMP-1134',
        name: 'Asadullah Khan',
        cnic: '33202-7741290-3',
        role: 'Safety Officer',
        shift: 'Shift C',
        status: 'Pending',
      ),
      PendingUserRegistration(
        empId: 'CPL-EMP-1088',
        name: 'Zeeshan Ahmed',
        cnic: '33202-5512098-1',
        role: 'Boiler Operator',
        shift: 'Shift A',
        status: 'Approved',
      ),
    ],
    emailRecipients: const [
      'kamran.siddiqui@chiniotpower.com (HSE Manager)',
      'plant.head@chiniotpower.com (VP Operations)',
      'controlroom.unit1@chiniotpower.com (DCS Desk)',
    ],
    pendingOfflineCount: 0,
    auditLogs: const [
      AuditLogItem(
        id: 'LOG-INIT-01',
        actorId: 'CP-EMP-1001',
        actorRole: 'admin',
        action: 'SYSTEM_BOOTSTRAP',
        targetResource: 'PLANT_UNIT_1',
        timestamp: '2026-11-12T06:00:00Z',
        coords: '31.7204° N, 72.9791° E',
        details: 'Initial CPL 62.4 MW Power Plant master database provisioned.',
      ),
    ],
  );

  /// Load persisted state, restore JWT session, connect Socket.io, and fetch dynamic API records
  Future<void> initFromStorage() async {
    try {
      final storage = _secureStorage;
      if (storage != null) {
        // 1. Restore configured server URL
        final savedUrl = await storage.getServerUrl();
        if (savedUrl != null && savedUrl.isNotEmpty) {
          ApiEndpoints.setBaseUrl(savedUrl);
          _dioClient?.updateBaseUrl(savedUrl);
        }

        // 2. Hydrate user session from storage
        final token = await storage.getAccessToken();
        final userJson = await storage.getUserJson();
        if (token != null && token.isNotEmpty && userJson != null) {
          try {
            final userMap = jsonDecode(userJson) as Map<String, dynamic>;
            final user = UserSession.fromJson(userMap);
            emit(state.copyWith(currentUser: user, activeScreenIndex: 1));
          } catch (_) {}
        }
      }

      final queueCount = _syncQueue?.pendingCount ?? 0;
      emit(state.copyWith(pendingOfflineCount: queueCount));

      // 3. Connect real-time alert gateway via Socket.io
      _initSocketIo();

      // 4. Fetch dynamic operational records from backend REST API
      await loadLiveData();

      // 5. Attempt background sync of queued offline items
      syncOfflineNow();
    } catch (e) {
      debugPrint('initFromStorage notice: $e');
    }
  }

  /// Change backend server URL and reconnect gateway
  Future<void> updateServerUrl(String newUrl) async {
    ApiEndpoints.setBaseUrl(newUrl);
    _dioClient?.updateBaseUrl(newUrl);
    await _secureStorage?.saveServerUrl(newUrl);
    _initSocketIo();
    await loadLiveData();
  }

  /// Initialize real-time WebSocket / Socket.io plant alert connection
  void _initSocketIo() {
    try {
      final baseUrl = ApiEndpoints.baseUrl;
      final uri = Uri.parse(baseUrl);
      final socketUri = '${uri.scheme}://${uri.host}:${uri.port}';
      _socket?.disconnect();
      _socket?.dispose();

      _socket = IO.io(
        socketUri,
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .disableAutoConnect()
            .build(),
      );
      _socket?.connect();

      _socket?.on('connect', (_) {
        debugPrint('[Socket.io Client] Connected to CPL Alert Gateway: $socketUri');
      });

      _socket?.on('alarm:triggered', (data) {
        debugPrint('[Socket.io Client] Real-time Plant Siren Triggered: $data');
        final title = data is Map ? (data['title']?.toString() ?? 'PLANT EMERGENCY SIREN') : data.toString();
        emit(state.copyWith(activeAlarm: () => title));
        _audioService.playSiren();
        _recordAudit(
          action: 'REALTIME_ALARM_RECEIVED',
          targetResource: 'SIREN_BROADCAST',
          details: 'Real-time emergency siren broadcast received from server: "$title".',
        );
      });

      _socket?.on('alarm:cleared', (data) {
        debugPrint('[Socket.io Client] Real-time All-Clear Drill Cleared: $data');
        emit(state.copyWith(activeAlarm: () => null));
        _audioService.stopSiren();
      });
    } catch (e) {
      debugPrint('Socket.io client notice: $e');
    }
  }

  /// Fetch dynamic live data from backend REST endpoints with offline Hive fallback
  Future<void> loadLiveData() async {
    final client = _dioClient;
    if (client == null) return;

    // 1. Fetch Hazards
    try {
      final res = await client.dio.get('/hazards');
      if (res.statusCode == 200 && res.data['hazards'] != null) {
        final list = (res.data['hazards'] as List)
            .map((h) => HazardItem.fromJson(Map<String, dynamic>.from(h as Map)))
            .toList();
        final box = Hive.box(HiveBoxes.hazardsBox);
        await box.put('hazards_cache', list.map((h) => h.toJson()).toList());
        emit(state.copyWith(hazards: list));
      }
    } catch (_) {
      try {
        final box = Hive.box(HiveBoxes.hazardsBox);
        final cached = box.get('hazards_cache');
        if (cached is List) {
          final list = cached
              .map((c) => HazardItem.fromJson(Map<String, dynamic>.from(c as Map)))
              .toList();
          emit(state.copyWith(hazards: list));
        }
      } catch (_) {}
    }

    // 2. Fetch Checklists
    try {
      final res = await client.dio.get('/checklists/templates');
      if (res.statusCode == 200 && res.data['templates'] != null) {
        final tpls = res.data['templates'] as List;
        if (tpls.isNotEmpty && tpls.first['items'] != null) {
          final items = (tpls.first['items'] as List)
              .map((it) => ChecklistAuditItem(
                    id: it['id'] is int ? it['id'] : int.tryParse(it['id'].toString()) ?? 1,
                    en: it['en'] ?? '',
                    ur: it['ur'] ?? '',
                    status: 'pass',
                  ))
              .toList();
          emit(state.copyWith(checklistItems: items));
        }
      }
    } catch (_) {}

    // 3. Fetch PTW
    try {
      final res = await client.dio.get('/ptw');
      if (res.statusCode == 200 && res.data['permits'] != null) {
        final permits = (res.data['permits'] as List)
            .map((p) => PtwItem(
                  id: p['id'] ?? 'PTW-000',
                  type: p['type'] ?? 'General',
                  title: p['title'] ?? 'Work Permit',
                  zone: p['zone'] ?? 'Unit-1',
                  requester: p['requester'] ?? 'CPL Lead',
                  status: p['status'] ?? 'Active',
                  telemetry: p['telemetry'] ?? 'Nominal',
                  timer: p['timer'] ?? '04:00:00',
                  lotoTags: p['lotoTags'] ?? 'LOTO Tagged',
                ))
            .toList();
        emit(state.copyWith(permits: permits));
      }
    } catch (_) {}

    // 4. Fetch Roster
    try {
      final res = await client.dio.get('/roster');
      if (res.statusCode == 200) {
        final rawList = res.data['roster'] ?? res.data['workers'];
        if (rawList is List) {
          final roster = rawList
              .map((r) => WorkerRosterItem(
                    empId: r['empId'] ?? 'CPL-EMP-000',
                    name: r['name'] ?? '',
                    ur: r['ur'] ?? r['name'] ?? '',
                    role: r['role'] ?? 'Worker',
                    zone: r['zone'] ?? 'Unit-1',
                    helmet: r['helmet'] ?? true,
                    shoes: r['shoes'] ?? true,
                    gloves: r['gloves'] ?? true,
                    ear: r['ear'] ?? true,
                  ))
              .toList();
          emit(state.copyWith(roster: roster));
        }
      }
    } catch (_) {}

    // 5. Fetch Alarms
    try {
      final res = await client.dio.get('/alarms');
      if (res.statusCode == 200) {
        final active = res.data['activeAlarm'] as String?;
        emit(state.copyWith(activeAlarm: () => active));
      }
    } catch (_) {}

    // 6. Fetch Pending User Registrations
    try {
      final res = await client.dio.get('/auth/pending-users');
      if (res.statusCode == 200 && res.data['pendingUsers'] != null) {
        final list = (res.data['pendingUsers'] as List)
            .map((p) => PendingUserRegistration.fromJson(Map<String, dynamic>.from(p as Map)))
            .toList();
        emit(state.copyWith(pendingUsers: list));
      }
    } catch (_) {}

    // 7. Fetch Immutable Audit Logs (NEPRA / ISO 45001)
    try {
      final res = await client.dio.get('/audit/logs');
      if (res.statusCode == 200 && res.data['logs'] != null) {
        final list = (res.data['logs'] as List)
            .map((l) => AuditLogItem.fromJson(Map<String, dynamic>.from(l as Map)))
            .toList();
        emit(state.copyWith(auditLogs: list));
      }
    } catch (_) {}
  }

  // Language Toggle
  void toggleLanguage() {
    final next = state.language == 'en' ? 'ur' : 'en';
    emit(state.copyWith(language: next));
  }

  // Navigation
  void setScreenIndex(int index) {
    emit(state.copyWith(activeScreenIndex: index));
  }

  // Record an immutable audit log entry (ISO 45001 / NEPRA)
  void _recordAudit({
    required String action,
    required String targetResource,
    required String details,
    String? coords,
  }) {
    final entry = AuditLogItem(
      id: 'LOG-${DateTime.now().millisecondsSinceEpoch}',
      actorId: state.currentUser.empId,
      actorRole: state.currentUser.role,
      action: action,
      targetResource: targetResource,
      timestamp: DateTime.now().toIso8601String(),
      coords: coords ?? '31.7204° N, 72.9791° E',
      details: details,
    );

    final updated = [entry, ...state.auditLogs];
    emit(state.copyWith(auditLogs: updated));

    try {
      _dioClient?.dio.post('/audit/logs', data: entry.toJson()).catchError((_) {});
    } catch (_) {}
  }

  // Auth: Login with Employee ID + PIN / Password
  Future<bool> login({
    required String empId,
    required String shift,
    required String role,
    String? pin,
    String? password,
  }) async {
    final cleanId = empId.trim().toUpperCase();
    final cleanPin = pin?.trim() ?? '1001';

    // 1. Try backend API login
    try {
      final res = await _dioClient?.dio.post('/auth/login', data: {
        'employeeId': cleanId,
        'pin': cleanPin,
        'password': password ?? cleanPin,
      });

      if (res != null && res.statusCode == 200 && res.data['success'] == true) {
        final token = res.data['token'] as String?;
        final refreshToken = res.data['refreshToken'] as String?;
        if (token != null && refreshToken != null) {
          await _secureStorage?.saveAuthTokens(accessToken: token, refreshToken: refreshToken);
        }

        final userMap = res.data['user'] as Map<String, dynamic>?;
        if (userMap != null) {
          final session = UserSession.fromJson(userMap);
          await _secureStorage?.saveUserSession(
            employeeId: session.empId,
            role: session.role,
            userJson: jsonEncode(session.toJson()),
          );
          final userBox = Hive.box(HiveBoxes.userBox);
          await userBox.put('currentUser', session.toJson());
          emit(state.copyWith(currentUser: session, activeScreenIndex: 1));
        }

        _recordAudit(
          action: 'USER_LOGIN',
          targetResource: state.currentUser.zone,
          details: 'Staff member $cleanId (${state.currentUser.name}) authenticated via CPL Backend Gateway.',
        );

        await loadLiveData();
        return true;
      }
    } catch (e) {
      debugPrint('Backend login notice: $e (checking local/offline validation)');
    }

    // 2. Offline / Local fallback: Dynamically resolve name and details
    String resolvedName = 'CPL Staff';
    String resolvedUrdu = 'سٹاف ممبر';
    String resolvedRole = role;
    String resolvedZone = 'Boiler House Unit-1';
    String resolvedCnic = '33202-0000000-1';

    // Check pendingUsers
    final pending = state.pendingUsers.where((u) => u.empId.toUpperCase() == cleanId).firstOrNull;
    if (pending != null) {
      resolvedName = pending.name;
      resolvedUrdu = pending.name;
      resolvedRole = pending.role;
      resolvedZone = pending.zone ?? 'Boiler House Unit-1';
      resolvedCnic = pending.cnic;
    } else {
      // Check roster
      final worker = state.roster.where((w) => w.empId.toUpperCase() == cleanId).firstOrNull;
      if (worker != null) {
        resolvedName = worker.name;
        resolvedUrdu = worker.ur;
        resolvedRole = worker.role;
        resolvedZone = worker.zone;
      } else if (cleanId == 'CP-EMP-1001' || cleanId == 'CPL-EMP-1001') {
        resolvedName = 'Engr. Tariq Khan';
        resolvedUrdu = 'انجینئر طارق خان';
        resolvedRole = 'HSE Manager';
        resolvedZone = 'Plant Headquarters';
      } else if (cleanId == 'CP-EMP-1002' || cleanId == 'CPL-EMP-1002') {
        resolvedName = 'Asim Raza';
        resolvedUrdu = 'عاصم رضا';
        resolvedRole = 'HSE Manager';
        resolvedZone = 'Safety & Compliance';
      } else if (cleanId == 'CPL-EMP-1042') {
        resolvedName = 'Muhammad Tariq';
        resolvedUrdu = 'محمد طارق';
        resolvedRole = 'Safety Officer';
        resolvedZone = 'Boiler House Unit-1';
      } else if (cleanId == 'CPL-EMP-1088') {
        resolvedName = 'Zeeshan Ahmed';
        resolvedUrdu = 'ذیشان احمد';
        resolvedRole = 'Plant Worker';
        resolvedZone = 'Bagasse & Coal Yard';
      }
    }

    final updatedUser = UserSession(
      empId: cleanId,
      name: resolvedName,
      urduName: resolvedUrdu,
      role: resolvedRole,
      shift: shift,
      cnic: resolvedCnic,
      zone: resolvedZone,
    );

    emit(state.copyWith(currentUser: updatedUser, activeScreenIndex: 1));

    _recordAudit(
      action: 'USER_LOGIN_OFFLINE',
      targetResource: updatedUser.zone,
      details: 'Staff member $cleanId ($resolvedName) logged in offline as $resolvedRole ($shift).',
    );

    return true;
  }

  // Logout & clear secure session
  Future<void> logout() async {
    await _secureStorage?.clearSession();
    try {
      final userBox = Hive.box(HiveBoxes.userBox);
      await userBox.delete('currentUser');
    } catch (_) {}
    emit(state.copyWith(activeScreenIndex: 0));
  }

  Future<void> signup({
    required String empId,
    required String fullName,
    required String cnic,
    required String shift,
    required String role,
    String? pin,
  }) async {
    final cleanId = empId.trim().toUpperCase();
    final cleanPin = (pin != null && pin.isNotEmpty) ? pin.trim() : '1234';
    final newReg = PendingUserRegistration(
      empId: cleanId,
      name: fullName.trim(),
      cnic: cnic.trim(),
      role: role,
      shift: shift,
      status: 'Pending',
      pin: cleanPin,
      zone: 'Boiler House Unit-1',
    );

    final updatedList = [
      newReg,
      ...state.pendingUsers.where((u) => u.empId.toUpperCase() != cleanId),
    ];
    emit(state.copyWith(pendingUsers: updatedList));

    _recordAudit(
      action: 'STAFF_SIGNUP',
      targetResource: cleanId,
      details: 'Registration submitted for $fullName ($cleanId) as $role. Awaiting HSE Manager approval.',
    );

    try {
      await _dioClient?.dio.post('/auth/register', data: {
        'employeeId': newReg.empId,
        'name': newReg.name,
        'cnic': newReg.cnic,
        'role': newReg.role,
        'shift': newReg.shift,
        'pin': cleanPin,
        'plantZone': newReg.zone,
      });
    } catch (e) {
      debugPrint('Error posting registration to backend: $e');
    }
  }

  // Hazards: Report new hazard with real multipart photo and voice note upload
  void dispatchHazard({
    required String category,
    required String zone,
    required String severity,
    required String description,
    required String coords,
    String? photoPath,
    String? voicePath,
  }) {
    final newHazard = HazardItem(
      id: 'HAZ-${310 + state.hazards.length}',
      title: '$category Alert — $zone',
      zone: zone,
      severity: severity,
      reporter: '${state.currentUser.name} (${state.currentUser.empId})',
      status: 'Open',
      time: 'Just now',
      coords: coords,
      photoAttached: photoPath != null,
      voiceSaved: voicePath != null,
    );
    final updated = [newHazard, ...state.hazards];
    emit(state.copyWith(hazards: updated, activeScreenIndex: 1)); // Return to Dashboard

    _recordAudit(
      action: 'HAZARD_REPORTED',
      targetResource: newHazard.id,
      coords: coords,
      details: '${newHazard.severity} hazard: "${newHazard.title}" reported at $zone. Geotagged: $coords.',
    );

    final payload = {
      'id': newHazard.id,
      'title': newHazard.title,
      'zone': newHazard.zone,
      'severity': newHazard.severity,
      'reporter': newHazard.reporter,
      'reporterId': state.currentUser.empId,
      'coords': coords,
      'description': description,
    };

    _syncQueue?.enqueue(id: newHazard.id, actionType: 'CREATE_HAZARD', payload: payload);
    emit(state.copyWith(pendingOfflineCount: (_syncQueue?.pendingCount ?? 0)));

    _pushHazardToBackend(newHazard.id, payload, photoPath: photoPath, voicePath: voicePath);
  }

  Future<void> _pushHazardToBackend(
    String id,
    Map<String, dynamic> payload, {
    String? photoPath,
    String? voicePath,
  }) async {
    final client = _dioClient;
    if (client == null) return;

    try {
      if (photoPath != null || voicePath != null) {
        final formMap = Map<String, dynamic>.from(payload);
        if (photoPath != null && photoPath.isNotEmpty && !kIsWeb) {
          formMap['photo'] = await MultipartFile.fromFile(photoPath, filename: 'incident_photo.jpg');
        }
        if (voicePath != null && voicePath.isNotEmpty && !kIsWeb) {
          formMap['voiceNote'] = await MultipartFile.fromFile(voicePath, filename: 'urdu_voice.m4a');
        }
        final formData = FormData.fromMap(formMap);
        final res = await client.dio.post('/hazards', data: formData);
        if (res.statusCode == 201 && res.data['hazard'] != null) {
          final serverHazard = HazardItem.fromJson(Map<String, dynamic>.from(res.data['hazard'] as Map));
          final updated = state.hazards.map((h) => h.id == id ? serverHazard : h).toList();
          emit(state.copyWith(hazards: updated));
        }
      } else {
        await client.dio.post('/hazards', data: payload);
      }
      await _syncQueue?.markSynced(id);
      emit(state.copyWith(pendingOfflineCount: (_syncQueue?.pendingCount ?? 0)));
    } catch (e) {
      debugPrint('Hazard queued offline: $e');
    }
  }

  // Risk Matrix
  void selectRiskCell(int likelihood, int severity) {
    emit(state.copyWith(
      selectedLikelihood: likelihood,
      selectedSeverity: severity,
    ));
  }

  void toggleCapaSignOff(String capaId) {
    if (!state.canSignOffCapa) return; // RBAC Guard

    final updated = state.capas.map((c) {
      if (c.id == capaId) {
        final newSigned = !c.signedOff;
        _recordAudit(
          action: 'CAPA_SIGNOFF',
          targetResource: capaId,
          details: 'CAPA $capaId sign-off toggled to $newSigned by ${state.currentUser.name}.',
        );
        return c.copyWith(signedOff: newSigned);
      }
      return c;
    }).toList();
    emit(state.copyWith(capas: updated));
  }

  // Daily Safety Checklist
  void setChecklistItemStatus(int itemId, String status) {
    final updated = state.checklistItems.map((item) {
      if (item.id == itemId) {
        return item.copyWith(status: status);
      }
      return item;
    }).toList();
    emit(state.copyWith(checklistItems: updated));

    // If failed, auto-dispatch a high-severity hazard
    if (status == 'fail') {
      final failedItem = state.checklistItems.firstWhere((i) => i.id == itemId);
      final autoHazard = HazardItem(
        id: 'HAZ-AUTO-${DateTime.now().millisecondsSinceEpoch % 1000}',
        title: 'Checklist Defect: ${failedItem.en}',
        zone: state.checklistZone,
        severity: 'High',
        reporter: '${state.currentUser.name} (${state.currentUser.empId})',
        status: 'Open',
        time: 'Just now',
        coords: '31.7204° N, 72.9791° E',
      );
      emit(state.copyWith(hazards: [autoHazard, ...state.hazards]));
      _recordAudit(
        action: 'DEFECT_AUTO_CAPA',
        targetResource: autoHazard.id,
        details: 'Defect flagged in Checkpoint #$itemId. Auto-CAPA dispatched.',
      );
    }
  }

  void setChecklistZone(String zone) {
    emit(state.copyWith(checklistZone: zone));
  }

  void toggleChecklistSignature() {
    final nextSigned = !state.checklistSigned;
    emit(state.copyWith(checklistSigned: nextSigned));
    if (nextSigned) {
      _recordAudit(
        action: 'CHECKLIST_DIGITAL_SIGNATURE',
        targetResource: state.checklistZone,
        details: 'Operator ${state.currentUser.name} digitally verified and locked shift audit.',
      );
    }
  }

  void addAdminChecklistItem(String en, String ur) {
    if (!state.canAccessAdminPanel) return; // RBAC Guard

    final newItem = ChecklistAuditItem(
      id: DateTime.now().millisecondsSinceEpoch,
      en: en,
      ur: ur,
      status: 'pass',
    );
    emit(state.copyWith(checklistItems: [...state.checklistItems, newItem]));

    _recordAudit(
      action: 'CHECKLIST_SOP_CREATED',
      targetResource: 'TEMPLATES',
      details: 'New safety checkpoint added: "$en".',
    );
  }

  // PTW & LOTO
  void setPtwFilter(String filter) {
    emit(state.copyWith(ptwFilter: filter));
  }

  void approvePtw(String ptwId) {
    if (!state.canApprovePtw) return; // RBAC Guard

    final updated = state.permits.map((p) {
      if (p.id == ptwId) {
        final newStatus = p.status == 'Pending' ? 'Active' : (p.status == 'Active' ? 'Closed' : 'Active');
        _recordAudit(
          action: 'PTW_APPROVAL',
          targetResource: ptwId,
          details: 'PTW $ptwId transitioned to $newStatus by ${state.currentUser.name}.',
        );
        return p.copyWith(status: newStatus);
      }
      return p;
    }).toList();
    emit(state.copyWith(permits: updated));

    try {
      _dioClient?.dio.put('/ptw/$ptwId/approve', data: {
        'status': 'Active',
        'supervisorId': state.currentUser.empId,
      }).catchError((_) {});
    } catch (_) {}
  }

  void setPermitStatus(String ptwId, String newStatus) {
    if (!state.canApprovePtw) return; // RBAC Guard

    final updated = state.permits.map((p) {
      if (p.id == ptwId) {
        _recordAudit(
          action: 'PTW_STATUS_CHANGE',
          targetResource: ptwId,
          details: 'PTW $ptwId status transitioned to $newStatus by ${state.currentUser.name}.',
        );
        return p.copyWith(status: newStatus);
      }
      return p;
    }).toList();
    emit(state.copyWith(permits: updated));

    try {
      _dioClient?.dio.put('/ptw/$ptwId/approve', data: {
        'status': newStatus,
        'supervisorId': state.currentUser.empId,
      }).catchError((_) {});
    } catch (_) {}
  }

  // Emergency Siren Center
  void triggerPlantAlarm(String alarmName) {
    _audioService.playSiren();
    final newLog = EmailLogItem(
      id: 'EM-${905 + state.emailLogs.length}',
      to: 'all-shift-engineers@chiniotpower.com',
      subject: '[CRITICAL SIREN] $alarmName Triggered at Chiniot Plant!',
      time: 'Just now',
      status: 'Sent (Gateway)',
    );
    emit(state.copyWith(
      activeAlarm: () => alarmName,
      emailLogs: [newLog, ...state.emailLogs],
    ));

    _recordAudit(
      action: 'PLANT_SIREN_TRIGGERED',
      targetResource: 'PLANT_WIDE',
      details: 'CRITICAL SIREN: "$alarmName" activated by ${state.currentUser.name}. Evacuation broadcast triggered.',
    );

    try {
      _dioClient?.dio.post('/alarms/trigger', data: {
        'title': alarmName,
        'triggeredBy': state.currentUser.empId,
      }).catchError((_) {});
    } catch (_) {}
  }

  void clearPlantAlarm() {
    _audioService.stopBuzzer();
    emit(state.copyWith(activeAlarm: () => null));

    _recordAudit(
      action: 'PLANT_SIREN_ALL_CLEAR',
      targetResource: 'PLANT_WIDE',
      details: 'All-clear drill confirmed. Siren silenced by ${state.currentUser.name}.',
    );

    try {
      _dioClient?.dio.post('/alarms/clear', data: {
        'clearedBy': state.currentUser.empId,
      }).catchError((_) {});
    } catch (_) {}
  }

  // Training & QR
  void scanQrPass() {
    final next = !state.qrCheckedIn;
    emit(state.copyWith(qrCheckedIn: next));

    _recordAudit(
      action: 'QR_TOOLBOX_ATTENDANCE',
      targetResource: 'TRN-TOOLBOX-SHIFT-A',
      details: 'Worker ${state.currentUser.name} marked attendance via dynamic QR token.',
    );
  }

  void setQrAttendanceCheckedIn() {
    emit(state.copyWith(qrCheckedIn: true));
    _recordAudit(
      action: 'QR_TOOLBOX_ATTENDANCE',
      targetResource: 'TRN-TOOLBOX-SHIFT-A',
      details: 'Worker ${state.currentUser.name} verified TBT attendance via dynamic QR code.',
    );
  }

  void openTrainingQuiz(String quizId) {
    emit(state.copyWith(activeQuizId: () => quizId));
  }

  void closeTrainingQuiz() {
    emit(state.copyWith(activeQuizId: () => null));
  }

  void completeTrainingQuiz(String trainingId) {
    final updated = state.trainings.map((t) {
      if (t.id == trainingId) {
        return t.copyWith(
          status: 'Certified',
          score: '100%',
          expiry: 'Valid until Nov 2027',
        );
      }
      return t;
    }).toList();
    emit(state.copyWith(trainings: updated, activeQuizId: () => null));

    _recordAudit(
      action: 'SAFETY_QUIZ_COMPLETED',
      targetResource: trainingId,
      details: 'Safety training quiz $trainingId completed with 100% score by ${state.currentUser.name}.',
    );
  }

  // Worker Roster PPE Toggle
  void togglePpe(String empId, String ppeKey) {
    final updated = state.roster.map((w) {
      if (w.empId == empId) {
        switch (ppeKey) {
          case 'helmet':
            return w.copyWith(helmet: !w.helmet);
          case 'shoes':
            return w.copyWith(shoes: !w.shoes);
          case 'gloves':
            return w.copyWith(gloves: !w.gloves);
          case 'ear':
            return w.copyWith(ear: !w.ear);
        }
      }
      return w;
    }).toList();
    emit(state.copyWith(roster: updated));

    _recordAudit(
      action: 'PPE_VERIFICATION',
      targetResource: empId,
      details: 'Worker $empId PPE ($ppeKey) verified.',
    );

    try {
      _dioClient?.dio.put('/roster/$empId/ppe', data: {'ppeType': ppeKey}).catchError((_) {});
    } catch (_) {}
  }

  void toggleWorkerPpe(String empId, String ppeKey) => togglePpe(empId, ppeKey);

  // Analytics Period
  void setAnalyticsPeriod(String period) {
    emit(state.copyWith(analyticsPeriod: period));
  }

  // Admin Pending User Approval/Block
  Future<void> updateUserApproval(String empId, String newStatus) async {
    if (!state.canAccessAdminPanel) return; // RBAC Guard

    final cleanId = empId.trim().toUpperCase();
    PendingUserRegistration? targetUser;

    final updated = state.pendingUsers.map((u) {
      if (u.empId.toUpperCase() == cleanId) {
        targetUser = u.copyWith(status: newStatus);
        return targetUser!;
      }
      return u;
    }).toList();

    // If approved, synchronize into local plant roster
    List<WorkerRosterItem> updatedRoster = List.from(state.roster);
    if (newStatus == 'Approved' && targetUser != null) {
      final alreadyInRoster = updatedRoster.any((w) => w.empId.toUpperCase() == cleanId);
      if (!alreadyInRoster) {
        updatedRoster.add(WorkerRosterItem(
          empId: cleanId,
          name: targetUser!.name,
          ur: targetUser!.name,
          role: targetUser!.role,
          zone: targetUser!.zone ?? 'Boiler House Unit-1',
          helmet: true,
          shoes: true,
          gloves: true,
          ear: true,
        ));
      }
    }

    emit(state.copyWith(pendingUsers: updated, roster: updatedRoster));

    _recordAudit(
      action: newStatus == 'Approved' ? 'STAFF_ID_APPROVAL' : 'STAFF_ID_BLOCKED',
      targetResource: cleanId,
      details: 'Staff member $cleanId (${targetUser?.name ?? ""}) registration marked as $newStatus by ${state.currentUser.name} (${state.currentUser.empId}). Credentials ${newStatus == 'Approved' ? 'activated' : 'deactivated'}.',
    );

    try {
      await _dioClient?.dio.put('/auth/users/$cleanId/approve', data: {
        'status': newStatus,
        'approverId': state.currentUser.empId,
        'approverName': state.currentUser.name,
      });
    } catch (e) {
      debugPrint('Error updating user approval on backend: $e');
    }
  }

  // Manually trigger immediate flush of offline queued reports
  Future<void> syncOfflineNow() async {
    final queue = _syncQueue;
    final client = _dioClient;
    if (queue == null || client == null) return;
    final items = queue.getQueuedItems();
    if (items.isEmpty) return;

    for (final item in items) {
      try {
        if (item.actionType == 'CREATE_HAZARD') {
          await client.dio.post('/hazards', data: item.payload);
        } else if (item.actionType == 'SUBMIT_CHECKLIST') {
          await client.dio.post('/checklists', data: item.payload);
        }
        await queue.markSynced(item.id);
      } catch (e) {
        debugPrint('Retry sync failed for item ${item.id}: $e');
      }
    }
    emit(state.copyWith(pendingOfflineCount: queue.pendingCount));
  }

  @override
  Future<void> close() {
    _socket?.disconnect();
    _socket?.dispose();
    return super.close();
  }
}
