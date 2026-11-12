import '../entities/emergency_alarm.dart';
import '../repositories/alarm_repository.dart';
import '../../../../core/errors/failures.dart';

class GetAlarmsUseCase {
  final AlarmRepository repository;
  GetAlarmsUseCase(this.repository);

  Future<List<EmergencyAlarm>> execute() async => await repository.getAlarms();
}

class TriggerAlarmUseCase {
  final AlarmRepository repository;
  TriggerAlarmUseCase(this.repository);

  Future<EmergencyAlarm> execute(EmergencyAlarm alarm) async {
    if (alarm.description.trim().isEmpty) {
      throw const ValidationFailure('Emergency alarm broadcast requires an incident explanation');
    }
    return await repository.triggerAlarm(alarm);
  }
}

class AcknowledgeAlarmUseCase {
  final AlarmRepository repository;
  AcknowledgeAlarmUseCase(this.repository);

  Future<EmergencyAlarm> execute({
    required String alarmId,
    required String userId,
    required String userName,
  }) async {
    return await repository.acknowledgeAlarm(
      alarmId: alarmId,
      userId: userId,
      userName: userName,
    );
  }
}

