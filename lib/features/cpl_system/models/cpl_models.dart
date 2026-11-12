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

  Map<String, dynamic> toJson() => {
    'empId': empId,
    'name': name,
    'urduName': urduName,
    'role': role,
    'shift': shift,
    'cnic': cnic,
    'zone': zone,
  };

  factory UserSession.fromJson(Map<String, dynamic> json) => UserSession(
    empId: json['empId'] ?? json['employeeId'] ?? 'CPL-EMP-XXXX',
    name: json['name'] ?? 'CPL Staff',
    urduName: json['urduName'] ?? json['name'] ?? 'سٹاف',
    role: json['role'] ?? 'Plant Worker',
    shift: json['shift'] ?? 'Shift A: Morning (06:00 - 14:00)',
    cnic: json['cnic'] ?? '33202-0000000-0',
    zone: json['zone'] ?? json['plantZone'] ?? 'Boiler House Unit-1',
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

  const PlantZone({
    required this.id,
    required this.name,
    required this.ur,
    required this.coords,
    required this.workers,
  });

  @override
  List<Object?> get props => [id, name, ur, coords, workers];
}

class HazardItem extends Equatable {
  final String id;
  final String title;
  final String zone;
  final String severity;
  final String reporter;
  final String status;
  final String time;
  final String coords;
  final bool photoAttached;
  final bool voiceSaved;
  final String? photoUrl;
  final String? voiceNoteUrl;

  const HazardItem({
    required this.id,
    required this.title,
    required this.zone,
    required this.severity,
    required this.reporter,
    required this.status,
    required this.time,
    required this.coords,
    this.photoAttached = true,
    this.voiceSaved = true,
    this.photoUrl,
    this.voiceNoteUrl,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'zone': zone,
    'severity': severity,
    'reporter': reporter,
    'status': status,
    'time': time,
    'coords': coords,
    'photoAttached': photoAttached,
    'voiceSaved': voiceSaved,
    'photoUrl': photoUrl,
    'voiceNoteUrl': voiceNoteUrl,
  };

  factory HazardItem.fromJson(Map<String, dynamic> json) => HazardItem(
    id: json['id'] as String? ?? 'HAZ-${DateTime.now().millisecondsSinceEpoch}',
    title: json['title'] as String? ?? 'Safety Hazard',
    zone: json['zone'] as String? ?? 'Boiler House Unit-1',
    severity: json['severity'] as String? ?? 'Moderate',
    reporter: json['reporter'] as String? ?? 'Plant Worker',
    status: json['status'] as String? ?? 'Open',
    time: json['time'] as String? ?? 'Just now',
    coords: json['coords'] as String? ?? '31.7204° N, 72.9791° E',
    photoAttached: json['photoAttached'] as bool? ?? (json['photoUrl'] != null),
    voiceSaved: json['voiceSaved'] as bool? ?? (json['voiceNoteUrl'] != null),
    photoUrl: json['photoUrl'] as String?,
    voiceNoteUrl: json['voiceNoteUrl'] as String?,
  );

  @override
  List<Object?> get props => [id, title, zone, severity, reporter, status, time, coords, photoAttached, voiceSaved, photoUrl, voiceNoteUrl];
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

  const TrainingModule({
    required this.id,
    required this.title,
    required this.ur,
    required this.duration,
    required this.status,
    required this.expiry,
    required this.score,
  });

  TrainingModule copyWith({String? status, String? expiry, String? score}) {
    return TrainingModule(
      id: id,
      title: title,
      ur: ur,
      duration: duration,
      status: status ?? this.status,
      expiry: expiry ?? this.expiry,
      score: score ?? this.score,
    );
  }

  @override
  List<Object?> get props => [id, title, ur, duration, status, expiry, score];
}

class WorkerRosterItem extends Equatable {
  final String empId;
  final String name;
  final String ur;
  final String role;
  final String zone;
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
    required this.helmet,
    required this.shoes,
    required this.gloves,
    required this.ear,
  });

  WorkerRosterItem copyWith({
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
      helmet: helmet ?? this.helmet,
      shoes: shoes ?? this.shoes,
      gloves: gloves ?? this.gloves,
      ear: ear ?? this.ear,
    );
  }

  bool get isFullPpe => helmet && shoes && gloves && ear;

  @override
  List<Object?> get props => [empId, name, ur, role, zone, helmet, shoes, gloves, ear];
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
    empId: json['empId'] ?? json['employeeId'] ?? '',
    name: json['name'] ?? '',
    cnic: json['cnic'] ?? '',
    role: json['role'] ?? 'Plant Worker',
    shift: json['shift'] ?? 'Shift A',
    status: json['status'] ?? 'Pending',
    pin: json['pin']?.toString(),
    zone: json['zone'] ?? json['plantZone'] ?? 'Boiler House Unit-1',
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
