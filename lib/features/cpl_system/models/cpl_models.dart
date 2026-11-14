import 'package:equatable/equatable.dart';

class UserSession extends Equatable {
  final String empId;
  final String name;
  final String urduName;
  final String role;
  final String shift;
  final String cnic;
  final String zone;

  const UserSession({
    required this.empId,
    required this.name,
    required this.urduName,
    required this.role,
    required this.shift,
    required this.cnic,
    required this.zone,
  });

  static const UserSession empty = UserSession(
    empId: '',
    name: '',
    urduName: '',
    role: '',
    shift: '',
    cnic: '',
    zone: '',
  );

  bool get isEmpty => empId.trim().isEmpty;
  bool get isNotEmpty => empId.trim().isNotEmpty;

  UserSession copyWith({
    String? empId,
    String? name,
    String? urduName,
    String? role,
    String? shift,
    String? cnic,
    String? zone,
  }) {
    return UserSession(
      empId: empId ?? this.empId,
      name: name ?? this.name,
      urduName: urduName ?? this.urduName,
      role: role ?? this.role,
      shift: shift ?? this.shift,
      cnic: cnic ?? this.cnic,
      zone: zone ?? this.zone,
    );
  }

  String get fullName => name;
  String get assignedZone => zone;

  Map<String, dynamic> toJson() => {
    'empId': empId,
    'fullName': name,
    'name': name,
    'urduName': urduName,
    'role': role,
    'shift': shift,
    'cnic': cnic,
    'assignedZone': zone,
    'zone': zone,
  };

  factory UserSession.fromJson(Map<String, dynamic> json) => UserSession(
    empId: (json['empId'] ?? json['employeeId'] ?? 'CPL-EMP-XXXX').toString().toUpperCase(),
    name: json['fullName'] ?? json['name'] ?? 'CPL Staff',
    urduName: json['urduName'] ?? json['fullName'] ?? json['name'] ?? 'سٹاف',
    role: json['role'] ?? 'Plant Worker',
    shift: json['shift'] ?? 'Shift A: Morning',
    cnic: json['cnic'] ?? '33202-0000000-0',
    zone: json['assignedZone'] ?? json['zone'] ?? json['plantZone'] ?? 'Boiler House Unit-1',
  );

  @override
  List<Object?> get props => [empId, name, urduName, role, shift, cnic, zone];
}

class PlantZone extends Equatable {
  final String id;
  final String name;
  final String ur;
  final String coords;
  final int workers;
  final String riskLevel;

  const PlantZone({
    required this.id,
    required this.name,
    required this.ur,
    required this.coords,
    required this.workers,
    this.riskLevel = 'High',
  });

  factory PlantZone.fromJson(Map<String, dynamic> json) => PlantZone(
        id: json['id']?.toString() ?? 'Z1',
        name: json['name']?.toString() ?? 'Boiler Area (Unit 1 & 2)',
        ur: json['ur']?.toString() ?? '',
        coords: json['coords']?.toString() ?? '31.7204° N, 72.9791° E',
        workers: json['workers'] is int ? json['workers'] as int : int.tryParse(json['workers']?.toString() ?? '0') ?? 0,
        riskLevel: json['riskLevel']?.toString() ?? 'High',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'ur': ur,
        'coords': coords,
        'workers': workers,
        'riskLevel': riskLevel,
      };

  @override
  List<Object?> get props => [id, name, ur, coords, workers, riskLevel];
}

class HazardItem extends Equatable {
  final String id;
  final String nmNumber;
  final String title;
  final String zone;
  final String severity;
  final String reporter;
  final String status;
  final String time;
  final String coords;
  final String observationType; // 'Unsafe Condition' | 'Unsafe Act'
  final String categoryType; // 'Safety' | 'ENV'
  final String responsibleTeam; // 'MMD' | 'EMD' | 'Civil' | 'Ops' | 'Fuel' | 'I&C' | 'Admin' | 'HSE'
  final String suggestion;
  final bool photoAttached;
  final bool voiceSaved;
  final String? photoUrl;
  final String? voiceNoteUrl;

  const HazardItem({
    required this.id,
    this.nmNumber = '',
    required this.title,
    required this.zone,
    required this.severity,
    required this.reporter,
    required this.status,
    required this.time,
    required this.coords,
    this.observationType = 'Unsafe Condition',
    this.categoryType = 'Safety',
    this.responsibleTeam = 'MMD',
    this.suggestion = '',
    this.photoAttached = true,
    this.voiceSaved = true,
    this.photoUrl,
    this.voiceNoteUrl,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nmNumber': nmNumber.isNotEmpty ? nmNumber : id,
    'title': title,
    'zone': zone,
    'severity': severity,
    'reporter': reporter,
    'status': status,
    'time': time,
    'coords': coords,
    'observationType': observationType,
    'categoryType': categoryType,
    'responsibleTeam': responsibleTeam,
    'suggestion': suggestion,
    'photoAttached': photoAttached,
    'voiceSaved': voiceSaved,
    'photoUrl': photoUrl,
    'voiceNoteUrl': voiceNoteUrl,
  };

  factory HazardItem.fromJson(Map<String, dynamic> json) {
    final resolvedId = (json['id'] ?? json['nmNumber'] ?? '26-CPL-${DateTime.now().millisecondsSinceEpoch % 1000}').toString();
    return HazardItem(
      id: resolvedId,
      nmNumber: (json['nmNumber'] ?? resolvedId).toString(),
      title: json['title'] as String? ?? 'Safety Observation',
      zone: json['zone'] as String? ?? 'Boiler Area (Unit 1 & 2)',
      severity: json['severity'] as String? ?? 'Moderate',
      reporter: json['reporter'] as String? ?? 'CPL Staff',
      status: json['status'] as String? ?? 'Open',
      time: json['time'] as String? ?? 'Just now',
      coords: json['coords'] as String? ?? '31.7204° N, 72.9791° E',
      observationType: json['observationType'] as String? ?? 'Unsafe Condition',
      categoryType: json['categoryType'] as String? ?? 'Safety',
      responsibleTeam: json['responsibleTeam'] as String? ?? 'MMD',
      suggestion: (json['suggestion'] ?? json['correctiveAction'] ?? '').toString(),
      photoAttached: json['photoAttached'] as bool? ?? (json['photoUrl'] != null),
      voiceSaved: json['voiceSaved'] as bool? ?? (json['voiceNoteUrl'] != null),
      photoUrl: json['photoUrl'] as String?,
      voiceNoteUrl: json['voiceNoteUrl'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nmNumber,
        title,
        zone,
        severity,
        reporter,
        status,
        time,
        coords,
        observationType,
        categoryType,
        responsibleTeam,
        suggestion,
        photoAttached,
        voiceSaved,
        photoUrl,
        voiceNoteUrl,
      ];
}

class CapaItem extends Equatable {
  final String id;
  final String title;
  final String zone;
  final int score;
  final String level;
  final String owner;
  final String due;
  final bool signedOff;

  const CapaItem({
    required this.id,
    required this.title,
    required this.zone,
    required this.score,
    required this.level,
    required this.owner,
    required this.due,
    this.signedOff = false,
  });

  CapaItem copyWith({bool? signedOff}) {
    return CapaItem(
      id: id,
      title: title,
      zone: zone,
      score: score,
      level: level,
      owner: owner,
      due: due,
      signedOff: signedOff ?? this.signedOff,
    );
  }

  @override
  List<Object?> get props => [id, title, zone, score, level, owner, due, signedOff];
}

class ChecklistAuditItem extends Equatable {
  final int id;
  final String en;
  final String ur;
  final String status; // 'pass', 'fail', 'na'

  const ChecklistAuditItem({
    required this.id,
    required this.en,
    required this.ur,
    this.status = 'pass',
  });

  ChecklistAuditItem copyWith({String? status}) {
    return ChecklistAuditItem(
      id: id,
      en: en,
      ur: ur,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [id, en, ur, status];
}

class PtwItem extends Equatable {
  final String id;
  final String type;
  final String title;
  final String zone;
  final String requester;
  final String status; // 'Active', 'Pending', 'Hold'
  final String telemetry;
  final String timer;
  final String lotoTags;

  const PtwItem({
    required this.id,
    required this.type,
    required this.title,
    required this.zone,
    required this.requester,
    required this.status,
    required this.telemetry,
    required this.timer,
    required this.lotoTags,
  });

  PtwItem copyWith({String? status, String? timer}) {
    return PtwItem(
      id: id,
      type: type,
      title: title,
      zone: zone,
      requester: requester,
      status: status ?? this.status,
      telemetry: telemetry,
      timer: timer ?? this.timer,
      lotoTags: lotoTags,
    );
  }

  @override
  List<Object?> get props => [id, type, title, zone, requester, status, telemetry, timer, lotoTags];
}

class EmailLogItem extends Equatable {
  final String id;
  final String to;
  final String subject;
  final String time;
  final String status;

  const EmailLogItem({
    required this.id,
    required this.to,
    required this.subject,
    required this.time,
    required this.status,
  });

  @override
  List<Object?> get props => [id, to, subject, time, status];
}

class TrainingModule extends Equatable {
  final String id;
  final String title;
  final String ur;
  final String duration;
  final String status;
  final String expiry;
  final String score;
  final String shiftGroup;
  final String leadTrainer;

  const TrainingModule({
    required this.id,
    required this.title,
    required this.ur,
    required this.duration,
    required this.status,
    required this.expiry,
    required this.score,
    this.shiftGroup = 'All Shifts',
    this.leadTrainer = 'Sumaira Rafique [3648]',
  });

  TrainingModule copyWith({
    String? status,
    String? expiry,
    String? score,
    String? shiftGroup,
    String? leadTrainer,
  }) {
    return TrainingModule(
      id: id,
      title: title,
      ur: ur,
      duration: duration,
      status: status ?? this.status,
      expiry: expiry ?? this.expiry,
      score: score ?? this.score,
      shiftGroup: shiftGroup ?? this.shiftGroup,
      leadTrainer: leadTrainer ?? this.leadTrainer,
    );
  }

  @override
  List<Object?> get props => [id, title, ur, duration, status, expiry, score, shiftGroup, leadTrainer];
}

class WorkerRosterItem extends Equatable {
  final String empId;
  final String name;
  final String ur;
  final String role;
  final String zone;
  final String shift; // 'Shift A', 'Shift B', 'Shift C', 'Shift D', 'General'
  final String designation; // 'SM', 'DSM', 'ASM', 'CRO', 'Sr PO', 'PO', 'APO', 'Shift Chemist', 'Sr. Fireman', 'Helper', 'HSE / Fire Fighter'
  final String attendanceStatus; // 'D', 'N', 'G', 'R', 'L', 'GH', 'SWP'
  final int nightsPerformed;
  final bool helmet;
  final bool shoes;
  final bool gloves;
  final bool ear;

  const WorkerRosterItem({
    required this.empId,
    required this.name,
    required this.ur,
    required this.role,
    required this.zone,
    this.shift = 'Shift A',
    this.designation = 'PO',
    this.attendanceStatus = 'D',
    this.nightsPerformed = 7,
    required this.helmet,
    required this.shoes,
    required this.gloves,
    required this.ear,
  });

  WorkerRosterItem copyWith({
    String? shift,
    String? designation,
    String? attendanceStatus,
    int? nightsPerformed,
    bool? helmet,
    bool? shoes,
    bool? gloves,
    bool? ear,
  }) {
    return WorkerRosterItem(
      empId: empId,
      name: name,
      ur: ur,
      role: role,
      zone: zone,
      shift: shift ?? this.shift,
      designation: designation ?? this.designation,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
      nightsPerformed: nightsPerformed ?? this.nightsPerformed,
      helmet: helmet ?? this.helmet,
      shoes: shoes ?? this.shoes,
      gloves: gloves ?? this.gloves,
      ear: ear ?? this.ear,
    );
  }

  factory WorkerRosterItem.fromJson(Map<String, dynamic> json) => WorkerRosterItem(
        empId: (json['empId'] ?? 'CPL-EMP-0000').toString(),
        name: (json['name'] ?? '').toString(),
        ur: (json['ur'] ?? json['name'] ?? '').toString(),
        role: (json['role'] ?? 'Plant Worker').toString(),
        zone: (json['zone'] ?? 'Boiler Area (Unit 1 & 2)').toString(),
        shift: (json['shift'] ?? 'Shift A').toString(),
        designation: (json['designation'] ?? json['role'] ?? 'PO').toString(),
        attendanceStatus: (json['attendanceStatus'] ?? 'D').toString(),
        nightsPerformed: json['nightsPerformed'] is int
            ? json['nightsPerformed'] as int
            : int.tryParse(json['nightsPerformed']?.toString() ?? '7') ?? 7,
        helmet: json['helmet'] as bool? ?? true,
        shoes: json['shoes'] as bool? ?? true,
        gloves: json['gloves'] as bool? ?? true,
        ear: json['ear'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'empId': empId,
        'name': name,
        'ur': ur,
        'role': role,
        'zone': zone,
        'shift': shift,
        'designation': designation,
        'attendanceStatus': attendanceStatus,
        'nightsPerformed': nightsPerformed,
        'helmet': helmet,
        'shoes': shoes,
        'gloves': gloves,
        'ear': ear,
      };

  bool get isFullPpe => helmet && shoes && gloves && ear;

  @override
  List<Object?> get props => [
        empId,
        name,
        ur,
        role,
        zone,
        shift,
        designation,
        attendanceStatus,
        nightsPerformed,
        helmet,
        shoes,
        gloves,
        ear,
      ];
}

class PendingUserRegistration extends Equatable {
  final String empId;
  final String name;
  final String cnic;
  final String role;
  final String shift;
  final String status; // 'Pending', 'Approved', 'Blocked'
  final String? pin;
  final String? zone;

  const PendingUserRegistration({
    required this.empId,
    required this.name,
    required this.cnic,
    required this.role,
    required this.shift,
    required this.status,
    this.pin,
    this.zone,
  });

  PendingUserRegistration copyWith({
    String? status,
    String? pin,
    String? zone,
    String? name,
    String? role,
    String? shift,
  }) {
    return PendingUserRegistration(
      empId: empId,
      name: name ?? this.name,
      cnic: cnic,
      role: role ?? this.role,
      shift: shift ?? this.shift,
      status: status ?? this.status,
      pin: pin ?? this.pin,
      zone: zone ?? this.zone,
    );
  }

  Map<String, dynamic> toJson() => {
    'empId': empId,
    'name': name,
    'cnic': cnic,
    'role': role,
    'shift': shift,
    'status': status,
    'pin': pin,
    'zone': zone,
  };

  factory PendingUserRegistration.fromJson(Map<String, dynamic> json) => PendingUserRegistration(
    empId: (json['empId'] ?? json['employeeId'] ?? '').toString().toUpperCase(),
    name: json['fullName'] ?? json['name'] ?? '',
    cnic: json['cnic'] ?? '',
    role: json['role'] ?? 'Plant Worker',
    shift: json['shift'] ?? 'Shift A',
    status: json['status'] ?? 'Pending',
    pin: json['pin']?.toString(),
    zone: json['assignedZone'] ?? json['zone'] ?? json['plantZone'] ?? 'Boiler House Unit-1',
  );

  @override
  List<Object?> get props => [empId, name, cnic, role, shift, status, pin, zone];
}

class AuditLogItem extends Equatable {
  final String id;
  final String actorId;
  final String actorRole;
  final String action;
  final String targetResource;
  final String timestamp;
  final String coords;
  final String details;

  const AuditLogItem({
    required this.id,
    required this.actorId,
    required this.actorRole,
    required this.action,
    required this.targetResource,
    required this.timestamp,
    required this.coords,
    required this.details,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'actorId': actorId,
    'actorRole': actorRole,
    'action': action,
    'targetResource': targetResource,
    'timestamp': timestamp,
    'coords': coords,
    'details': details,
  };

  factory AuditLogItem.fromJson(Map<String, dynamic> json) => AuditLogItem(
    id: json['id'] as String? ?? '',
    actorId: json['actorId'] as String? ?? '',
    actorRole: json['actorRole'] as String? ?? '',
    action: json['action'] as String? ?? '',
    targetResource: json['targetResource'] as String? ?? '',
    timestamp: json['timestamp'] as String? ?? '',
    coords: json['coords'] as String? ?? '',
    details: json['details'] is String ? json['details'] as String : (json['details']?.toString() ?? ''),
  );

  @override
  List<Object?> get props => [id, actorId, actorRole, action, targetResource, timestamp, coords, details];
}
