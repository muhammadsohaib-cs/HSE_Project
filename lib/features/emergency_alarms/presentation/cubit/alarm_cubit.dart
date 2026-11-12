import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/platform/audio_service.dart';
import '../../domain/entities/emergency_alarm.dart';
import '../../domain/usecases/alarm_usecases.dart';
import 'alarm_state.dart';

class AlarmCubit extends Cubit<AlarmState> {
  final GetAlarmsUseCase _getAlarmsUseCase;
  final TriggerAlarmUseCase _triggerAlarmUseCase;
  final AcknowledgeAlarmUseCase _acknowledgeAlarmUseCase;
  final AudioAlarmService _audioAlarmService;

  AlarmCubit({
    required GetAlarmsUseCase getAlarmsUseCase,
    required TriggerAlarmUseCase triggerAlarmUseCase,
    required AcknowledgeAlarmUseCase acknowledgeAlarmUseCase,
    AudioAlarmService? audioAlarmService,
  })  : _getAlarmsUseCase = getAlarmsUseCase,
        _triggerAlarmUseCase = triggerAlarmUseCase,
        _acknowledgeAlarmUseCase = acknowledgeAlarmUseCase,
        _audioAlarmService = audioAlarmService ?? AudioAlarmService(),
        super(AlarmInitial());

  Future<void> loadAlarms() async {
    emit(AlarmLoading());
    try {
      final alarms = await _getAlarmsUseCase.execute();
      final active = alarms.cast<EmergencyAlarm?>().firstWhere(
            (a) => a != null && !a.isAcknowledged && a.severityLevel != AlarmSeverity.warning,
            orElse: () => null,
          );

      if (active != null) {
        await _audioAlarmService.playEmergencyBuzzer();
      }

      emit(AlarmLoaded(alarms: alarms, activeCriticalAlarm: active));
    } catch (e) {
      emit(AlarmError(e.toString()));
    }
  }

  Future<void> dispatchAlarm(EmergencyAlarm alarm) async {
    try {
      final triggered = await _triggerAlarmUseCase.execute(alarm);

      // Start audible buzzer if critical or evacuation
      if (triggered.severityLevel != AlarmSeverity.warning) {
        await _audioAlarmService.playEmergencyBuzzer();
      }

      emit(AlarmTriggerSuccess(triggered));
      await loadAlarms();
    } catch (e) {
      emit(AlarmError(e.toString().replaceAll('ValidationFailure: ', '')));
      await loadAlarms();
    }
  }

  Future<void> acknowledgeAlarm(String alarmId, String userId, String userName) async {
    try {
      await _acknowledgeAlarmUseCase.execute(
        alarmId: alarmId,
        userId: userId,
        userName: userName,
      );
      // Silence audible buzzer
      await _audioAlarmService.stopBuzzer();
      await loadAlarms();
    } catch (e) {
      await _audioAlarmService.stopBuzzer();
      await loadAlarms();
    }
  }

  Future<void> silenceBuzzer() async {
    await _audioAlarmService.stopBuzzer();
  }
}

