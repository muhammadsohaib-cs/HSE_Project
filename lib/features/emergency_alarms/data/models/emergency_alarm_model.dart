import '../../domain/entities/emergency_alarm.dart';

class EmergencyAlarmModel extends EmergencyAlarm {
  const EmergencyAlarmModel({
    required super.id,
    required super.triggerUserId,
    required super.triggerUserName,
    required super.plantArea,
    required super.severityLevel,
    required super.description,
    required super.broadcastChannels,
    super.isAcknowledged = false,
    super.acknowledgedBy,
    super.acknowledgedAt,
    required super.triggeredAt,
  });

  factory EmergencyAlarmModel.fromJson(Map<String, dynamic> json) {
    return EmergencyAlarmModel(
      id: json['id'] as String,
      triggerUserId: json['trigger_user_id'] as String,
      triggerUserName: json['trigger_user_name'] as String? ?? 'Plant Officer',
      plantArea: json['plant_area'] as String,
      severityLevel: AlarmSeverity.fromString(json['severity_level'] as String),
      description: json['description'] as String,
      broadcastChannels: List<String>.from(json['broadcast_channels'] as List? ?? ['FCM_PUSH', 'TRANSACTIONAL_EMAIL']),
      isAcknowledged: json['is_acknowledged'] as bool? ?? false,
      acknowledgedBy: json['acknowledged_by'] as String?,
      acknowledgedAt: json['acknowledged_at'] != null ? DateTime.parse(json['acknowledged_at'] as String) : null,
      triggeredAt: DateTime.parse(json['triggered_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'trigger_user_id': triggerUserId,
    'trigger_user_name': triggerUserName,
    'plant_area': plantArea,
    'severity_level': severityLevel.name,
    'description': description,
    'broadcast_channels': broadcastChannels,
    'is_acknowledged': isAcknowledged,
    'acknowledged_by': acknowledgedBy,
    'acknowledged_at': acknowledgedAt?.toIso8601String(),
    'triggered_at': triggeredAt.toIso8601String(),
  };

  factory EmergencyAlarmModel.fromEntity(EmergencyAlarm entity) {
    return EmergencyAlarmModel(
      id: entity.id,
      triggerUserId: entity.triggerUserId,
      triggerUserName: entity.triggerUserName,
      plantArea: entity.plantArea,
      severityLevel: entity.severityLevel,
      description: entity.description,
      broadcastChannels: entity.broadcastChannels,
      isAcknowledged: entity.isAcknowledged,
      acknowledgedBy: entity.acknowledgedBy,
      acknowledgedAt: entity.acknowledgedAt,
      triggeredAt: entity.triggeredAt,
    );
  }
}

