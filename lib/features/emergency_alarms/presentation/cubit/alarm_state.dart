import 'package:equatable/equatable.dart';
import '../../domain/entities/emergency_alarm.dart';

abstract class AlarmState extends Equatable {
  const AlarmState();
  @override
  List<Object?> get props => [];
}

class AlarmInitial extends AlarmState {}

class AlarmLoading extends AlarmState {}

class AlarmLoaded extends AlarmState {
  final List<EmergencyAlarm> alarms;
  final EmergencyAlarm? activeCriticalAlarm; // For triggering desktop floating modal

  const AlarmLoaded({
    required this.alarms,
    this.activeCriticalAlarm,
  });

  AlarmLoaded copyWith({
    List<EmergencyAlarm>? alarms,
    EmergencyAlarm? Function()? activeCriticalAlarm,
  }) {
    return AlarmLoaded(
      alarms: alarms ?? this.alarms,
      activeCriticalAlarm: activeCriticalAlarm != null ? activeCriticalAlarm() : this.activeCriticalAlarm,
    );
  }

  @override
  List<Object?> get props => [alarms, activeCriticalAlarm];
}

class AlarmError extends AlarmState {
  final String message;
  const AlarmError(this.message);

  @override
  List<Object?> get props => [message];
}

class AlarmTriggerSuccess extends AlarmState {
  final EmergencyAlarm alarm;
  const AlarmTriggerSuccess(this.alarm);

  @override
  List<Object?> get props => [alarm];
}

