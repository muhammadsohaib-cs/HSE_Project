import '../entities/emergency_alarm.dart';

abstract class AlarmRepository {
  Future<List<EmergencyAlarm>> getAlarms();
  Future<EmergencyAlarm> triggerAlarm(EmergencyAlarm alarm);
  Future<EmergencyAlarm> acknowledgeAlarm({
    required String alarmId,
    required String userId,
    required String userName,
  });
}

