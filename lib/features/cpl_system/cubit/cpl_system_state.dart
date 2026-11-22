import 'package:equatable/equatable.dart';
import '../models/cpl_models.dart';

class CplSystemState extends Equatable {
  final String language; // 'en' or 'ur'
  final int activeScreenIndex; // 0 to 10
  final UserSession currentUser;
  final List<PlantZone> zones;
  final List<HazardItem> hazards;
  final int selectedLikelihood;
  final int selectedSeverity;
  final List<CapaItem> capas;
  final List<ChecklistAuditItem> checklistItems;
  final String checklistZone;
  final bool checklistSigned;
  final List<ChecklistTemplate> checklistTemplates;
  final String activeChecklistTemplateId;
  final String checklistCategoryFilter;
  final List<PtwItem> permits;
  final String ptwFilter;
  final String? activeAlarm;
  final List<EmailLogItem> emailLogs;
  final List<TrainingModule> trainings;
  final bool qrCheckedIn;
  final String? activeQuizId;
  final List<WorkerRosterItem> roster;
  final String analyticsPeriod; // '6M' or '1Y'
  final List<PendingUserRegistration> pendingUsers;
  final List<String> emailRecipients;
  final int pendingOfflineCount;
  final List<AuditLogItem> auditLogs;
  final String? lastAuthError;
  final String? lastAuthInfo;
  final String rosterShiftFilter;
  final String rosterAreaFilter;

  const CplSystemState({
    required this.language,
    required this.activeScreenIndex,
    required this.currentUser,
    required this.zones,
    required this.hazards,
    required this.selectedLikelihood,
    required this.selectedSeverity,
    required this.capas,
    required this.checklistItems,
    required this.checklistZone,
    required this.checklistSigned,
    this.checklistTemplates = const [],
    this.activeChecklistTemplateId = 'CPL-HSEFEIC-01',
    this.checklistCategoryFilter = 'All',
    required this.permits,
    required this.ptwFilter,
    this.activeAlarm,
    required this.emailLogs,
    required this.trainings,
    required this.qrCheckedIn,
    this.activeQuizId,
    required this.roster,
    required this.analyticsPeriod,
    required this.pendingUsers,
    required this.emailRecipients,
    this.pendingOfflineCount = 0,
    this.auditLogs = const [],
    this.lastAuthError,
    this.lastAuthInfo,
    this.rosterShiftFilter = 'All',
    this.rosterAreaFilter = 'All',
  });

  int get riskScore => selectedLikelihood * selectedSeverity;

  bool get isUrdu => language == 'ur';

  bool get isAuthenticated => currentUser.isNotEmpty;

  // Role-Based Access Control (RBAC) Permitted Actions
  bool get isManager {
    final r = currentUser.role.toLowerCase();
    return r == 'manager' ||
        r == 'admin' ||
        r == 'hse manager' ||
        r.contains('dy. manager') ||
        r.contains('plant manager') ||
        r.contains('general manager') ||
        r.contains('dgm') ||
        r.contains('shift manager');
  }

  bool get isInspector {
    final r = currentUser.role.toLowerCase();
    return r == 'inspector' ||
        r == 'safety officer' ||
        r.contains('fire fighter') ||
        r.contains('fireman') ||
        isManager;
  }

  bool get canApprovePtw => isManager;
  bool get canAccessAdminPanel => isManager;
  bool get canSignOffCapa => isInspector;

  String get riskBand {
    final score = riskScore;
    if (score >= 17) return 'Critical';
    if (score >= 10) return 'High';
    if (score >= 5) return 'Moderate';
    return 'Low';
  }

  ChecklistTemplate? get activeChecklistTemplate {
    if (checklistTemplates.isEmpty) return null;
    return checklistTemplates.firstWhere(
      (t) => t.id == activeChecklistTemplateId || t.docNo == activeChecklistTemplateId,
      orElse: () => checklistTemplates.first,
    );
  }

  List<String> get checklistCategories {
    final cats = <String>{'All'};
    for (var t in checklistTemplates) {
      if (t.category.isNotEmpty) cats.add(t.category);
    }
    return cats.toList();
  }

  List<ChecklistTemplate> get filteredChecklistTemplates {
    if (checklistCategoryFilter == 'All') return checklistTemplates;
    return checklistTemplates.where((t) => t.category == checklistCategoryFilter).toList();
  }

  CplSystemState copyWith({
    String? language,
    int? activeScreenIndex,
    UserSession? currentUser,
    List<PlantZone>? zones,
    List<HazardItem>? hazards,
    int? selectedLikelihood,
    int? selectedSeverity,
    List<CapaItem>? capas,
    List<ChecklistAuditItem>? checklistItems,
    String? checklistZone,
    bool? checklistSigned,
    List<ChecklistTemplate>? checklistTemplates,
    String? activeChecklistTemplateId,
    String? checklistCategoryFilter,
    List<PtwItem>? permits,
    String? ptwFilter,
    String? Function()? activeAlarm,
    List<EmailLogItem>? emailLogs,
    List<TrainingModule>? trainings,
    bool? qrCheckedIn,
    String? Function()? activeQuizId,
    List<WorkerRosterItem>? roster,
    String? analyticsPeriod,
    List<PendingUserRegistration>? pendingUsers,
    List<String>? emailRecipients,
    int? pendingOfflineCount,
    List<AuditLogItem>? auditLogs,
    String? Function()? lastAuthError,
    String? Function()? lastAuthInfo,
    String? rosterShiftFilter,
    String? rosterAreaFilter,
  }) {
    return CplSystemState(
      language: language ?? this.language,
      activeScreenIndex: activeScreenIndex ?? this.activeScreenIndex,
      currentUser: currentUser ?? this.currentUser,
      zones: zones ?? this.zones,
      hazards: hazards ?? this.hazards,
      selectedLikelihood: selectedLikelihood ?? this.selectedLikelihood,
      selectedSeverity: selectedSeverity ?? this.selectedSeverity,
      capas: capas ?? this.capas,
      checklistItems: checklistItems ?? this.checklistItems,
      checklistZone: checklistZone ?? this.checklistZone,
      checklistSigned: checklistSigned ?? this.checklistSigned,
      checklistTemplates: checklistTemplates ?? this.checklistTemplates,
      activeChecklistTemplateId: activeChecklistTemplateId ?? this.activeChecklistTemplateId,
      checklistCategoryFilter: checklistCategoryFilter ?? this.checklistCategoryFilter,
      permits: permits ?? this.permits,
      ptwFilter: ptwFilter ?? this.ptwFilter,
      activeAlarm: activeAlarm != null ? activeAlarm() : this.activeAlarm,
      emailLogs: emailLogs ?? this.emailLogs,
      trainings: trainings ?? this.trainings,
      qrCheckedIn: qrCheckedIn ?? this.qrCheckedIn,
      activeQuizId: activeQuizId != null ? activeQuizId() : this.activeQuizId,
      roster: roster ?? this.roster,
      analyticsPeriod: analyticsPeriod ?? this.analyticsPeriod,
      pendingUsers: pendingUsers ?? this.pendingUsers,
      emailRecipients: emailRecipients ?? this.emailRecipients,
      pendingOfflineCount: pendingOfflineCount ?? this.pendingOfflineCount,
      auditLogs: auditLogs ?? this.auditLogs,
      lastAuthError: lastAuthError != null ? lastAuthError() : this.lastAuthError,
      lastAuthInfo: lastAuthInfo != null ? lastAuthInfo() : this.lastAuthInfo,
      rosterShiftFilter: rosterShiftFilter ?? this.rosterShiftFilter,
      rosterAreaFilter: rosterAreaFilter ?? this.rosterAreaFilter,
    );
  }

  @override
  List<Object?> get props => [
        language,
        activeScreenIndex,
        currentUser,
        zones,
        hazards,
        selectedLikelihood,
        selectedSeverity,
        capas,
        checklistItems,
        checklistZone,
        checklistSigned,
        checklistTemplates,
        activeChecklistTemplateId,
        checklistCategoryFilter,
        permits,
        ptwFilter,
        activeAlarm,
        emailLogs,
        trainings,
        qrCheckedIn,
        activeQuizId,
        roster,
        analyticsPeriod,
        pendingUsers,
        emailRecipients,
        pendingOfflineCount,
        auditLogs,
        lastAuthError,
        lastAuthInfo,
        rosterShiftFilter,
        rosterAreaFilter,
      ];
}
