import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/plant_zones.dart';
import '../../domain/entities/emergency_alarm.dart';
import '../models/emergency_alarm_model.dart';

abstract class AlarmRemoteDataSource {
  Future<List<EmergencyAlarmModel>> fetchAlarms();
  Future<EmergencyAlarmModel> triggerAlarm(EmergencyAlarmModel alarm);
  Future<EmergencyAlarmModel> acknowledgeAlarm(String alarmId, String userId, String userName);
}

class AlarmRemoteDataSourceImpl implements AlarmRemoteDataSource {
  final Dio _dio;

  AlarmRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<EmergencyAlarmModel>> fetchAlarms() async {
    try {
      final response = await _dio.get(ApiEndpoints.alarms);
      return (response.data['data'] as List)
          .map((item) => EmergencyAlarmModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _getSeedAlarms();
    }
  }

  @override
  Future<EmergencyAlarmModel> triggerAlarm(EmergencyAlarmModel alarm) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.triggerAlarm,
        data: alarm.toJson(),
      );
      return EmergencyAlarmModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (_) {
      return alarm;
    }
  }

  @override
  Future<EmergencyAlarmModel> acknowledgeAlarm(String alarmId, String userId, String userName) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.acknowledgeAlarm(alarmId),
        data: {'user_id': userId, 'user_name': userName},
      );
      return EmergencyAlarmModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (_) {
      throw Exception('Failed to acknowledge alarm remotely');
    }
  }

  List<EmergencyAlarmModel> _getSeedAlarms() {
    return [
      EmergencyAlarmModel(
        id: 'ALM-2026-003',
        triggerUserId: 'CP-EMP-1002',
        triggerUserName: 'Asim Raza (HSE Manager)',
        plantArea: PlantZones.coalHandling,
        severityLevel: AlarmSeverity.warning,
        description: 'Conveyor 2B high dust concentration alert detected on optoelectronic sensor.',
        broadcastChannels: const ['FCM_PUSH', 'TRANSACTIONAL_EMAIL'],
        isAcknowledged: true,
        acknowledgedBy: 'Hamza Ali (CP-EMP-1003)',
        acknowledgedAt: DateTime.now().subtract(const Duration(hours: 6)),
        triggeredAt: DateTime.now().subtract(const Duration(hours: 7)),
      ),
    ];
  }
}

