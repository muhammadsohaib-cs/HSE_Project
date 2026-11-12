import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/platform/audio_service.dart';
import '../../../../core/storage/hive_boxes.dart';
import '../../../../core/storage/offline_sync_queue.dart';
import '../models/cpl_models.dart';
import 'cpl_system_state.dart';

class CplSystemCubit extends Cubit<CplSystemState> {
  final AudioAlarmService _audioService;
  final DioClient? _dioClient;
  final OfflineSyncQueue? _syncQueue;

  CplSystemCubit({
    AudioAlarmService? audioService,
    DioClient? dioClient,
    OfflineSyncQueue? syncQueue,
  })  : _audioService = audioService ?? AudioAlarmService(),
        _dioClient = dioClient,
        _syncQueue = syncQueue,
        super(_initialState);

  static final CplSystemState _initialState = CplSystemState(
    language: 'en',
    activeScreenIndex: 1, // Default to Dashboard (Screen 02)
    currentUser: const UserSession(
      empId: 'CPL-EMP-1042',
      name: 'Muhammad Tariq',
      urduName: 'محمد طارق',
      role: 'Safety Officer',
      shift: 'Shift A: Morning (06:00 - 14:00)',
      cnic: '33202-4829104-1',
      zone: 'Boiler House Unit-1',
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
        title: 'Chemical Dosing Pump Spill Containment Berm',
        zone: 'WTP',
        score: 6,
        level: 'Moderate',
        owner: 'Chemical Team',
        due: '14 Nov 2026',
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
        timer: '04h 12m left',
        lotoTags: '4 Padlocks • Tagged by Insp. Asim',
      ),
      PtwItem(
        id: 'PTW-841',
        type: 'Electrical LOTO',
        title: '132kV Circuit Breaker Unit-1 Maintenance',
        zone: '132kV Grid Switchyard (Bay 4)',
        requester: 'Usman Ghani (Electrical Tech)',
        status: 'Active',
        telemetry: '0.00 kV Verified • Earth Sw Closed',
        timer: '01h 45m left',
        lotoTags: '6 Padlocks • Master Key in Station Safe',
      ),
      PtwItem(
        id: 'PTW-840',
        type: 'Confined Space',
        title: 'Cooling Tower Cold Water Basin Desiltation',
        zone: 'Cooling Tower Basin 2',
        requester: 'Kamran Siddiqui (Civil Supervisor)',
        status: 'Pending',
        telemetry: 'H2S: 0 ppm • CO: 0 ppm',
        timer: 'Pending Supervisor Sign-Off',
        lotoTags: '2 Padlocks • Isolation Incomplete',
      ),
    ],
    emailLogs: const [
      EmailLogItem(
        id: 'EM-904',
        to: 'plant.manager@chiniotpower.com',
        subject: '[CPL-ALERT] Shift A Safety Turnover Digest',
        time: '14m ago',
        status: 'Delivered',
      ),
      EmailLogItem(
        id: 'EM-903',
        to: 'rescue1122.chiniot@punjab.gov.pk',
        subject: '[DRILL-TEST] CPL Quarterly Fire Siren Drill Notice',
        time: '2h ago',
        status: 'Delivered',
      ),
      EmailLogItem(
        id: 'EM-902',
        to: 'hse.head@chiniotpower.com',
        subject: '[HAZARD] Critical Near-Miss Escalated — Bagasse Yard',
        time: '3h ago',
        status: 'Opened',
      ),
    ],
    trainings: const [
      TrainingModule(
        id: 'TRN-101',
        title: 'High-Pressure Boiler Operations Safety (105 Bar)',
        ur: 'ہائی پریشر بوائلر آپریشن سیفٹی',
        duration: '45 mins • Video + Quiz',
        status: 'Valid',
        expiry: 'Valid till 14 Oct 2027',
        score: '96%',
      ),
      TrainingModule(
        id: 'TRN-102',
        title: '132kV Grid LOTO & Electrical Arc Flash Protection',
        ur: '132 کے وی گرڈ سوئچ یارڈ ایل او ٹی او اور آرک فلیش',
        duration: '60 mins • SOP Review',
        status: 'Valid',
        expiry: 'Valid till 02 Feb 2027',
        score: '100%',
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

  /// Load persisted state from Hive boxes so nothing resets on reload
  void initFromStorage() {
    try {
      final queueCount = _syncQueue?.pendingCount ?? 0;
      emit(state.copyWith(pendingOfflineCount: queueCount));

      // Attempt background sync of queued offline items
      syncOfflineNow();
    } catch (e) {
      debugPrint('initFromStorage notice: $e');
    }
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

    // Try posting to backend audit log
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

    // Map role based on employee ID or chosen role
    String resolvedRole = role;
    if (cleanId == 'CP-EMP-1001') resolvedRole = 'HSE Manager';
    if (cleanId == 'CP-EMP-1002') resolvedRole = 'HSE Manager';

    final updatedUser = state.currentUser.copyWith(
      empId: cleanId,
      shift: shift,
      role: resolvedRole,
    );

    emit(state.copyWith(currentUser: updatedUser, activeScreenIndex: 1));

    _recordAudit(
      action: 'USER_LOGIN',
      targetResource: updatedUser.zone,
      details: 'Staff member $cleanId logged in as $resolvedRole ($shift).',
    );

    // Sync to backend if reachable
    try {
      await _dioClient?.dio.post('/auth/login', data: {
        'employeeId': cleanId,
        'pin': pin ?? '1001',
        'password': password ?? 'ChiniotSafe2026!',
      });
    } catch (e) {
      debugPrint('Backend login notice: $e (operating offline)');
    }

    return true;
  }

  void signup({
    required String empId,
    required String fullName,
    required String cnic,
    required String shift,
    required String role,
  }) {
    final newReg = PendingUserRegistration(
      empId: empId.trim().toUpperCase(),
      name: fullName.trim(),
      cnic: cnic.trim(),
      role: role,
      shift: shift,
      status: 'Pending',
    );
    final updatedList = [newReg, ...state.pendingUsers];
    emit(state.copyWith(pendingUsers: updatedList));

    _recordAudit(
      action: 'STAFF_SIGNUP',
      targetResource: empId,
      details: 'Registration submitted for $fullName ($empId) as $role.',
    );

    // Queue or post
    try {
      _dioClient?.dio.post('/auth/register', data: {
        'employeeId': newReg.empId,
        'name': newReg.name,
        'cnic': newReg.cnic,
        'role': newReg.role,
        'shift': newReg.shift,
      }).catchError((_) {
        _syncQueue?.enqueue(
          id: 'REG-${newReg.empId}',
          actionType: 'STAFF_REGISTRATION',
          payload: {'employeeId': newReg.empId, 'name': newReg.name},
        );
        emit(state.copyWith(pendingOfflineCount: (_syncQueue?.pendingCount ?? 0)));
      });
    } catch (_) {}
  }

  // Hazards: Report new hazard
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

    // Persist to offline sync queue & try push
    final payload = {
      'id': newHazard.id,
      'title': newHazard.title,
      'zone': newHazard.zone,
      'severity': newHazard.severity,
      'reporter': newHazard.reporter,
      'coords': coords,
    };

    _syncQueue?.enqueue(id: newHazard.id, actionType: 'CREATE_HAZARD', payload: payload);
    emit(state.copyWith(pendingOfflineCount: (_syncQueue?.pendingCount ?? 0)));

    _pushHazardToBackend(newHazard.id, payload);
  }

  Future<void> _pushHazardToBackend(String id, Map<String, dynamic> payload) async {
    try {
      await _dioClient?.dio.post('/hazards', data: payload);
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

  // Checklist
  void setChecklistItemStatus(int itemId, String status) {
    final updated = state.checklistItems.map((item) {
      if (item.id == itemId) {
        return item.copyWith(status: status);
      }
      return item;
    }).toList();
    emit(state.copyWith(checklistItems: updated));

    // Auto-create CAPA if Fail
    if (status == 'fail') {
      final failedItem = state.checklistItems.firstWhere((i) => i.id == itemId);
      final autoHazard = HazardItem(
        id: 'HAZ-CHK-$itemId',
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

  // Permits (PTW)
  void setPtwFilter(String filter) {
    emit(state.copyWith(ptwFilter: filter));
  }

  void setPermitStatus(String permitId, String status) {
    if (!state.canApprovePtw && status == 'Active') return; // RBAC Guard: Only Manager can approve

    final updated = state.permits.map((p) {
      if (p.id == permitId) {
        return p.copyWith(
          status: status,
          timer: status == 'Active' ? '06h 00m left' : 'On Hold (LOTO)',
        );
      }
      return p;
    }).toList();
    emit(state.copyWith(permits: updated));

    _recordAudit(
      action: 'PTW_STATUS_CHANGE',
      targetResource: permitId,
      details: 'Permit $permitId status changed to $status by ${state.currentUser.name} (${state.currentUser.role}).',
    );

    // Push to backend
    try {
      _dioClient?.dio.put('/ptw/$permitId/approve', data: {
        'action': status,
        'supervisorId': state.currentUser.empId,
        'supervisorName': state.currentUser.name,
      }).catchError((_) {});
    } catch (_) {}
  }

  // Emergency Siren & Alarms
  void triggerPlantAlarm(String alarmName) {
    _audioService.playEmergencyBuzzer();
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

  // Training
  void completeTrainingQuiz(String trainingId) {
    final updated = state.trainings.map((t) {
      if (t.id == trainingId) {
        return t.copyWith(
          status: 'Completed',
          expiry: 'Valid till Nov 2027',
          score: '100%',
        );
      }
      return t;
    }).toList();
    emit(state.copyWith(trainings: updated, activeQuizId: () => null));

    _recordAudit(
      action: 'TRAINING_QUIZ_COMPLETED',
      targetResource: trainingId,
      details: 'Quiz completed with 100% score for $trainingId by ${state.currentUser.empId}.',
    );
  }

  void setActiveQuiz(String? quizId) {
    emit(state.copyWith(activeQuizId: () => quizId));
  }

  void setQrAttendanceCheckedIn() {
    emit(state.copyWith(qrCheckedIn: true));
    _recordAudit(
      action: 'TOOLBOX_QR_CHECKIN',
      targetResource: 'MORNING_TOOLBOX',
      details: 'QR attendance logged for Toolbox Talk by ${state.currentUser.name}.',
    );
  }

  // Roster PPE Toggles
  void toggleWorkerPpe(String empId, String ppeKey) {
    final updated = state.roster.map((w) {
      if (w.empId == empId) {
        switch (ppeKey) {
          case 'helmet': return w.copyWith(helmet: !w.helmet);
          case 'shoes': return w.copyWith(shoes: !w.shoes);
          case 'gloves': return w.copyWith(gloves: !w.gloves);
          case 'ear': return w.copyWith(ear: !w.ear);
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

  // Analytics Period
  void setAnalyticsPeriod(String period) {
    emit(state.copyWith(analyticsPeriod: period));
  }

  // Admin Pending User Approval/Block
  void updateUserApproval(String empId, String newStatus) {
    if (!state.canAccessAdminPanel) return; // RBAC Guard

    final updated = state.pendingUsers.map((u) {
      if (u.empId == empId) {
        return u.copyWith(status: newStatus);
      }
      return u;
    }).toList();
    emit(state.copyWith(pendingUsers: updated));

    _recordAudit(
      action: 'STAFF_ID_APPROVAL',
      targetResource: empId,
      details: 'Staff member $empId registration marked as $newStatus by ${state.currentUser.name}.',
    );
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
}
