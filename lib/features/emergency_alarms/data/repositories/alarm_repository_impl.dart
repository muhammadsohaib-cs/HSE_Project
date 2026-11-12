import '../../domain/entities/emergency_alarm.dart';
import '../../domain/repositories/alarm_repository.dart';
import '../datasources/alarm_local_data_source.dart';
import '../datasources/alarm_remote_data_source.dart';
import '../models/emergency_alarm_model.dart';

class AlarmRepositoryImpl implements AlarmRepository {
  final AlarmRemoteDataSource _remoteDataSource;
  final AlarmLocalDataSource _localDataSource;

  AlarmRepositoryImpl({
    required AlarmRemoteDataSource remoteDataSource,
    required AlarmLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<List<EmergencyAlarm>> getAlarms() async {
    try {
      final remoteList = await _remoteDataSource.fetchAlarms();
      await _localDataSource.cacheAlarms(remoteList);
      return remoteList;
    } catch (_) {
      return await _localDataSource.getCachedAlarms();
    }
  }

  @override
  Future<EmergencyAlarm> triggerAlarm(EmergencyAlarm alarm) async {
    final model = EmergencyAlarmModel.fromEntity(alarm);
    await _localDataSource.cacheSingleAlarm(model);
    try {
      return await _remoteDataSource.triggerAlarm(model);
    } catch (_) {
      return model;
    }
  }

  @override
  Future<EmergencyAlarm> acknowledgeAlarm({
    required String alarmId,
    required String userId,
    required String userName,
  }) async {
    final cachedAlarms = await _localDataSource.getCachedAlarms();
    final match = cachedAlarms.firstWhere(
      (a) => a.id == alarmId,
      orElse: () => EmergencyAlarmModel(
        id: alarmId,
        triggerUserId: userId,
        triggerUserName: userName,
        plantArea: 'Main Plant',
        severityLevel: AlarmSeverity.warning,
        description: 'Plant Alarm',
        broadcastChannels: const ['FCM_PUSH'],
        triggeredAt: DateTime.now(),
      ),
    );

    final acknowledged = match.copyWith(
      isAcknowledged: true,
      acknowledgedBy: '$userName ($userId)',
      acknowledgedAt: DateTime.now(),
    );

    await _localDataSource.cacheSingleAlarm(EmergencyAlarmModel.fromEntity(acknowledged));

    try {
      await _remoteDataSource.acknowledgeAlarm(alarmId, userId, userName);
    } catch (_) {}

    return acknowledged;
  }
}

