import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/platform/audio_service.dart';
import '../models/cpl_models.dart';
import 'cpl_system_state.dart';

class CplSystemCubit extends Cubit<CplSystemState> {
  final AudioAlarmService _audioService;

  CplSystemCubit({AudioAlarmService? audioService})
      : _audioService = audioService ?? AudioAlarmService(),
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
        time: '48m ago',
        coords: '31.7195° N, 72.9802° E',
      ),
      HazardItem(
        id: 'HAZ-305',
        title: 'Oil Drip Under Lube Pump B',
        zone: 'Steam Turbine Hall',
        severity: 'Medium',
        reporter: 'Usman Ghani (CPL-EMP-1015)',
        status: 'Open',
        time: '2h ago',
        coords: '31.7201° N, 72.9788° E',
      ),
    ],
    selectedLikelihood: 4,
    selectedSeverity: 4,
    capas: const [
      CapaItem(
        id: 'CAPA-114',
        title: 'Replace High-Temp Gasket on Boiler Valve FV-14',
        zone: 'Boiler House Unit-1',
        score: 16,
        level: 'High',
        owner: 'Engr. Kamran Siddiqui',
        due: 'Today, 17:00',
        signedOff: false,
      ),
      CapaItem(
        id: 'CAPA-112',
        title: 'Re-anchor Conveyor Side Guard & Emergency Pull-Cord',
        zone: 'Bagasse & Coal Yard',
        score: 20,
        level: 'Critical',
        owner: 'Zeeshan Ahmed',
        due: 'Immediate',
        signedOff: false,
      ),
      CapaItem(
        id: 'CAPA-109',
        title: 'Install Arc-Flash Warning Signage at Bay-3',
        zone: '132kV Grid Switchyard',
        score: 9,
        level: 'Moderate',
        owner: 'Usman Ghani',
        due: 'Tomorrow',
        signedOff: true,
      ),
    ],
    checklistZone: 'Boiler House Unit-1',
    checklistSigned: true,
    checklistItems: const [
      ChecklistAuditItem(
        id: 1,
        en: 'Boiler drum water level gauge & pressure relief valves clear',
        ur: 'بوائلر ڈرم واٹر لیول گیج اور پریشر والوز درست کام کر رہے ہیں',
        status: 'pass',
      ),
      ChecklistAuditItem(
        id: 2,
        en: 'Steam piping insulation intact with zero exposed hot surfaces',
        ur: 'سٹیم پائپوں کی انسولیشن مکمل ہے اور کوئی گرم حصہ کھلا نہیں',
        status: 'pass',
      ),
      ChecklistAuditItem(
        id: 3,
        en: 'Bagasse feeder chute fire-suppression water spray tested',
        ur: 'بگاس فیڈر شوٹ کا فائر سپریشن واٹر سپرے چیک کر لیا گیا ہے',
        status: 'fail',
      ),
      ChecklistAuditItem(
        id: 4,
        en: 'Emergency exit walkways & CO2 extinguishers unobstructed',
        ur: 'ایمرجنسی راستے اور آگ بجھانے والے سلنڈر بالکل صاف ہیں',
        status: 'pass',
      ),
    ],
    permits: const [
      PtwItem(
        id: 'PTW-CPL-412',
        type: 'Hot Work',
        title: 'Boiler Economizer Tube Welding',
        zone: 'Boiler House Unit-1',
        requester: 'Muhammad Tariq (CPL-EMP-1042)',
        status: 'Active',
        telemetry: 'O2: 20.9% • LEL: 0.0% • Temp: 38°C',
        timer: '03h 40m left',
        lotoTags: '4 Locks Applied',
      ),
      PtwItem(
        id: 'PTW-CPL-418',
        type: 'LOTO',
        title: '132kV Breaker Bay-2 Busbar Maintenance',
        zone: '132kV Grid Switchyard',
        requester: 'Usman Ghani (CPL-EMP-1015)',
        status: 'Pending',
        telemetry: '0.00 kV Verified • Earth Switch ON',
        timer: 'Awaiting HSE Manager',
        lotoTags: '7 LOTO Locks',
      ),
      PtwItem(
        id: 'PTW-CPL-421',
        type: 'Confined Space',
        title: 'Cooling Tower Basin Silt Cleaning',
        zone: 'Cooling Tower',
        requester: 'Zeeshan Ahmed (CPL-EMP-1088)',
        status: 'Active',
        telemetry: 'H2S: 0 ppm • CO: 0 ppm • Fan LOTO',
        timer: '05h 15m left',
        lotoTags: '3 Locks Applied',
      ),
    ],
    ptwFilter: 'All',
    emailLogs: const [
      EmailLogItem(
        id: 'EM-901',
        to: 'plant.manager@chiniotpower.com',
        subject: '[CPL-HSE] Shift-A Boiler Pressure & PTW Summary',
        time: '09:30 AM',
        status: 'Delivered',
      ),
      EmailLogItem(
        id: 'EM-902',
        to: 'hse.head@chiniotpower.com',
        subject: '[ALERT] High Priority Hazard #HAZ-309 Logged',
        time: '10:15 AM',
        status: 'Delivered',
      ),
      EmailLogItem(
        id: 'EM-903',
        to: 'rescue1122.chiniot@punjab.gov.pk',
        subject: '[STANDBY] Automated Emergency Gateway Link',
        time: 'Armed',
        status: 'Ready',
      ),
    ],
    trainings: const [
      TrainingModule(
        id: 'TRN-01',
        title: 'High-Pressure Boiler & Steam Safety',
        ur: 'بوائلر اور ہائی پریشر سٹیم سیفٹی',
        duration: '18 Min • Urdu Video',
        status: 'Completed',
        expiry: 'Valid till Dec 2027',
        score: '100%',
      ),
      TrainingModule(
        id: 'TRN-02',
        title: '132kV Electrical LOTO & Arc Flash',
        ur: 'ہائی وولٹیج لاک آؤٹ ٹیگ آؤٹ (LOTO)',
        duration: '25 Min • Urdu + EN',
        status: 'Due Soon',
        expiry: 'Expires in 9 Days',
        score: 'Quiz Pending',
      ),
      TrainingModule(
        id: 'TRN-03',
        title: 'Bagasse Dust Fire & Hydrant Drill',
        ur: 'بگاس آگ بجھانے اور ہائیڈرنٹ ٹریننگ',
        duration: '15 Min • Practical',
        status: 'Completed',
        expiry: 'Valid till Aug 2027',
        score: '95%',
      ),
    ],
    qrCheckedIn: true,
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
        ear: true,
      ),
      WorkerRosterItem(
        empId: 'CPL-EMP-1088',
        name: 'Zeeshan Ahmed',
        ur: 'ذیشان احمد',
        role: 'Boiler Operator',
        zone: 'Boiler House Unit-1',
        helmet: true,
        shoes: true,
        gloves: true,
        ear: false,
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
  );

  // Language Toggle
  void toggleLanguage() {
    final next = state.language == 'en' ? 'ur' : 'en';
    emit(state.copyWith(language: next));
  }

  // Navigation
  void setScreenIndex(int index) {
    emit(state.copyWith(activeScreenIndex: index));
  }

  // Auth
  void login({required String empId, required String shift, required String role}) {
    final updatedUser = state.currentUser.copyWith(
      empId: empId,
      shift: shift,
      role: role,
    );
    emit(state.copyWith(currentUser: updatedUser, activeScreenIndex: 1));
  }

  void signup({
    required String empId,
    required String fullName,
    required String cnic,
    required String shift,
    required String role,
  }) {
    final newReg = PendingUserRegistration(
      empId: empId,
      name: fullName,
      cnic: cnic,
      role: role,
      shift: shift,
      status: 'Pending',
    );
    final updatedList = [newReg, ...state.pendingUsers];
    emit(state.copyWith(pendingUsers: updatedList));
  }

  // Hazards
  void dispatchHazard({
    required String category,
    required String zone,
    required String severity,
    required String description,
    required String coords,
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
    );
    final updated = [newHazard, ...state.hazards];
    emit(state.copyWith(hazards: updated, activeScreenIndex: 1)); // Return to Dashboard
  }

  // Risk Matrix
  void selectRiskCell(int likelihood, int severity) {
    emit(state.copyWith(
      selectedLikelihood: likelihood,
      selectedSeverity: severity,
    ));
  }

  void toggleCapaSignOff(String capaId) {
    final updated = state.capas.map((c) {
      if (c.id == capaId) {
        return c.copyWith(signedOff: !c.signedOff);
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
  }

  void setChecklistZone(String zone) {
    emit(state.copyWith(checklistZone: zone));
  }

  void toggleChecklistSignature() {
    emit(state.copyWith(checklistSigned: !state.checklistSigned));
  }

  void addAdminChecklistItem(String en, String ur) {
    final newItem = ChecklistAuditItem(
      id: DateTime.now().millisecondsSinceEpoch,
      en: en,
      ur: ur,
      status: 'pass',
    );
    emit(state.copyWith(checklistItems: [...state.checklistItems, newItem]));
  }

  // Permits (PTW)
  void setPtwFilter(String filter) {
    emit(state.copyWith(ptwFilter: filter));
  }

  void setPermitStatus(String permitId, String status) {
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
  }

  // Emergency Siren & Alarms
  void triggerPlantAlarm(String alarmName) {
    _audioService.playEmergencyBuzzer();
    final newLog = EmailLogItem(
      id: 'EM-${905 + state.emailLogs.length}',
      to: 'all-shift-engineers@chiniotpower.com',
      subject: '[CRITICAL SIREN] $alarmName Triggered at Chiniot Plant!',
      time: 'Just now',
      status: 'Sent',
    );
    emit(state.copyWith(
      activeAlarm: () => alarmName,
      emailLogs: [newLog, ...state.emailLogs],
    ));
  }

  void clearPlantAlarm() {
    _audioService.stopBuzzer();
    emit(state.copyWith(activeAlarm: () => null));
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
  }

  void setActiveQuiz(String? quizId) {
    emit(state.copyWith(activeQuizId: () => quizId));
  }

  void setQrAttendanceCheckedIn() {
    emit(state.copyWith(qrCheckedIn: true));
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
  }

  // Analytics Period
  void setAnalyticsPeriod(String period) {
    emit(state.copyWith(analyticsPeriod: period));
  }

  // Admin Pending User Approval/Block
  void updateUserApproval(String empId, String newStatus) {
    final updated = state.pendingUsers.map((u) {
      if (u.empId == empId) {
        return u.copyWith(status: newStatus);
      }
      return u;
    }).toList();
    emit(state.copyWith(pendingUsers: updated));
  }
}
