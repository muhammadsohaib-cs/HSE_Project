import 'package:equatable/equatable.dart';

enum AlarmSeverity {
  warning('Plant Warning', 'Notice to all plant area supervisors'),
  critical('Critical Emergency', 'Immediate response team mobilization'),
  evacuation('Catastrophic Evacuation', 'PLANT-WIDE IMMEDIATE EVACUATION ORDER');

  final String title;
  final String description;
  const AlarmSeverity(this.title, this.description);

  static AlarmSeverity fromString(String val) {
    switch (val.toLowerCase()) {
      case 'evacuation':
      case 'catastrophic evacuation':
        return AlarmSeverity.evacuation;
      case 'critical':
      case 'critical emergency':
        return AlarmSeverity.critical;
      default:
        return AlarmSeverity.warning;
    }
  }
}

class EmergencyAlarm extends Equatable {
  final String id;
  final String triggerUserId;
  final String triggerUserName;
  final String plantArea;
  final AlarmSeverity severityLevel;
  final String description;
  final List<String> broadcastChannels; // ['FCM_PUSH', 'TRANSACTIONAL_EMAIL', 'DESKTOP_SIREN']
  final bool isAcknowledged;
  final String? acknowledgedBy;
  final DateTime? acknowledgedAt;
  final DateTime triggeredAt;

  const EmergencyAlarm({
    required this.id,
    required this.triggerUserId,
    required this.triggerUserName,
    required this.plantArea,
    required this.severityLevel,
    required this.description,
    required this.broadcastChannels,
    this.isAcknowledged = false,
    this.acknowledgedBy,
    this.acknowledgedAt,
    required this.triggeredAt,
  });

  EmergencyAlarm copyWith({
    String? id,
    String? triggerUserId,
    String? triggerUserName,
    String? plantArea,
    AlarmSeverity? severityLevel,
    String? description,
    List<String>? broadcastChannels,
    bool? isAcknowledged,
    String? acknowledgedBy,
    DateTime? acknowledgedAt,
    DateTime? triggeredAt,
  }) {
    return EmergencyAlarm(
      id: id ?? this.id,
      triggerUserId: triggerUserId ?? this.triggerUserId,
      triggerUserName: triggerUserName ?? this.triggerUserName,
      plantArea: plantArea ?? this.plantArea,
      severityLevel: severityLevel ?? this.severityLevel,
      description: description ?? this.description,
      broadcastChannels: broadcastChannels ?? this.broadcastChannels,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      triggeredAt: triggeredAt ?? this.triggeredAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        triggerUserId,
        plantArea,
        severityLevel,
        description,
        broadcastChannels,
        isAcknowledged,
        acknowledgedBy,
        acknowledgedAt,
        triggeredAt,
      ];
}

