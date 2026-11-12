import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/platform/location_service.dart';
import '../../../../core/utils/risk_calculator.dart';

enum CapaStatus {
  draft('Draft'),
  reported('Reported'),
  underReview('Under Review'),
  assigned('Assigned'),
  actionTaken('Action Taken'),
  verification('Verification'),
  closed('Closed');

  final String label;
  const CapaStatus(this.label);

  static CapaStatus fromString(String val) {
    return CapaStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase() || e.label.toLowerCase() == val.toLowerCase(),
      orElse: () => CapaStatus.reported,
    );
  }
}

class SupervisorSignOff extends Equatable {
  final String supervisorId;
  final String supervisorName;
  final String signatureHash;
  final String approvalNotes;
  final DateTime signedAt;

  const SupervisorSignOff({
    required this.supervisorId,
    required this.supervisorName,
    required this.signatureHash,
    required this.approvalNotes,
    required this.signedAt,
  });

  Map<String, dynamic> toJson() => {
    'supervisor_id': supervisorId,
    'supervisor_name': supervisorName,
    'signature_hash': signatureHash,
    'approval_notes': approvalNotes,
    'signed_at': signedAt.toIso8601String(),
  };

  factory SupervisorSignOff.fromJson(Map<String, dynamic> json) => SupervisorSignOff(
    supervisorId: json['supervisor_id'] as String,
    supervisorName: json['supervisor_name'] as String,
    signatureHash: json['signature_hash'] as String,
    approvalNotes: json['approval_notes'] as String,
    signedAt: DateTime.parse(json['signed_at'] as String),
  );

  @override
  List<Object?> get props => [supervisorId, supervisorName, signatureHash, approvalNotes, signedAt];
}

class Hazard extends Equatable {
  final String id;
  final String title;
  final String description;
  final String reporterId;
  final String reporterName;
  final String plantZone;
  final PlantCoordinate coordinates;
  final int probability; // 1-5
  final int severity; // 1-5
  final int score; // 1-25
  final CapaStatus status;
  final List<String> mediaUrls;
  final String? assignedTo;
  final String? correctiveAction;
  final String? resolutionProofMediaUrl;
  final SupervisorSignOff? supervisorSignOff;
  final DateTime createdAt;
  final DateTime? closedAt;
  final bool isOfflineBuffered;

  const Hazard({
    required this.id,
    required this.title,
    required this.description,
    required this.reporterId,
    required this.reporterName,
    required this.plantZone,
    required this.coordinates,
    required this.probability,
    required this.severity,
    required this.score,
    required this.status,
    required this.mediaUrls,
    this.assignedTo,
    this.correctiveAction,
    this.resolutionProofMediaUrl,
    this.supervisorSignOff,
    required this.createdAt,
    this.closedAt,
    this.isOfflineBuffered = false,
  });

  RiskBand get riskBand => RiskCalculator.getRiskBand(score);

  bool get isClosed => status == CapaStatus.closed;

  Hazard copyWith({
    String? id,
    String? title,
    String? description,
    String? reporterId,
    String? reporterName,
    String? plantZone,
    PlantCoordinate? coordinates,
    int? probability,
    int? severity,
    int? score,
    CapaStatus? status,
    List<String>? mediaUrls,
    String? assignedTo,
    String? correctiveAction,
    String? resolutionProofMediaUrl,
    SupervisorSignOff? supervisorSignOff,
    DateTime? createdAt,
    DateTime? closedAt,
    bool? isOfflineBuffered,
  }) {
    final p = probability ?? this.probability;
    final s = severity ?? this.severity;
    return Hazard(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      reporterId: reporterId ?? this.reporterId,
      reporterName: reporterName ?? this.reporterName,
      plantZone: plantZone ?? this.plantZone,
      coordinates: coordinates ?? this.coordinates,
      probability: p,
      severity: s,
      score: score ?? (p * s),
      status: status ?? this.status,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      assignedTo: assignedTo ?? this.assignedTo,
      correctiveAction: correctiveAction ?? this.correctiveAction,
      resolutionProofMediaUrl: resolutionProofMediaUrl ?? this.resolutionProofMediaUrl,
      supervisorSignOff: supervisorSignOff ?? this.supervisorSignOff,
      createdAt: createdAt ?? this.createdAt,
      closedAt: closedAt ?? this.closedAt,
      isOfflineBuffered: isOfflineBuffered ?? this.isOfflineBuffered,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        reporterId,
        plantZone,
        coordinates,
        probability,
        severity,
        score,
        status,
        mediaUrls,
        assignedTo,
        correctiveAction,
        resolutionProofMediaUrl,
        supervisorSignOff,
        createdAt,
        closedAt,
        isOfflineBuffered,
      ];
}

