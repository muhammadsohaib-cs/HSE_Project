import '../../../../core/platform/location_service.dart';
import '../../domain/entities/hazard.dart';

class HazardModel extends Hazard {
  const HazardModel({
    required super.id,
    required super.title,
    required super.description,
    required super.reporterId,
    required super.reporterName,
    required super.plantZone,
    required super.coordinates,
    required super.probability,
    required super.severity,
    required super.score,
    required super.status,
    required super.mediaUrls,
    super.assignedTo,
    super.correctiveAction,
    super.resolutionProofMediaUrl,
    super.supervisorSignOff,
    required super.createdAt,
    super.closedAt,
    super.isOfflineBuffered = false,
  });

  factory HazardModel.fromJson(Map<String, dynamic> json) {
    return HazardModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      reporterId: json['reporter_id'] as String,
      reporterName: json['reporter_name'] as String? ?? 'Plant Officer',
      plantZone: json['plant_zone'] as String,
      coordinates: PlantCoordinate.fromJson(Map<String, dynamic>.from(json['coordinates'] as Map)),
      probability: (json['probability'] as num).toInt(),
      severity: (json['severity'] as num).toInt(),
      score: (json['score'] as num).toInt(),
      status: CapaStatus.fromString(json['status'] as String),
      mediaUrls: List<String>.from(json['media_urls'] as List? ?? []),
      assignedTo: json['assigned_to'] as String?,
      correctiveAction: json['corrective_action'] as String?,
      resolutionProofMediaUrl: json['resolution_proof_media_url'] as String?,
      supervisorSignOff: json['supervisor_sign_off'] != null
          ? SupervisorSignOff.fromJson(Map<String, dynamic>.from(json['supervisor_sign_off'] as Map))
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      closedAt: json['closed_at'] != null ? DateTime.parse(json['closed_at'] as String) : null,
      isOfflineBuffered: json['is_offline_buffered'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'reporter_id': reporterId,
      'reporter_name': reporterName,
      'plant_zone': plantZone,
      'coordinates': coordinates.toJson(),
      'probability': probability,
      'severity': severity,
      'score': score,
      'status': status.name,
      'media_urls': mediaUrls,
      'assigned_to': assignedTo,
      'corrective_action': correctiveAction,
      'resolution_proof_media_url': resolutionProofMediaUrl,
      'supervisor_sign_off': supervisorSignOff?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'closed_at': closedAt?.toIso8601String(),
      'is_offline_buffered': isOfflineBuffered,
    };
  }

  factory HazardModel.fromEntity(Hazard entity) {
    return HazardModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      reporterId: entity.reporterId,
      reporterName: entity.reporterName,
      plantZone: entity.plantZone,
      coordinates: entity.coordinates,
      probability: entity.probability,
      severity: entity.severity,
      score: entity.score,
      status: entity.status,
      mediaUrls: entity.mediaUrls,
      assignedTo: entity.assignedTo,
      correctiveAction: entity.correctiveAction,
      resolutionProofMediaUrl: entity.resolutionProofMediaUrl,
      supervisorSignOff: entity.supervisorSignOff,
      createdAt: entity.createdAt,
      closedAt: entity.closedAt,
      isOfflineBuffered: entity.isOfflineBuffered,
    );
  }
}

