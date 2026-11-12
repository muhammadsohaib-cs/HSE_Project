import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../../core/storage/hive_boxes.dart';
import '../models/emergency_alarm_model.dart';

abstract class AlarmLocalDataSource {
  Future<void> cacheAlarms(List<EmergencyAlarmModel> alarms);
  Future<void> cacheSingleAlarm(EmergencyAlarmModel alarm);
  Future<List<EmergencyAlarmModel>> getCachedAlarms();
}

class AlarmLocalDataSourceImpl implements AlarmLocalDataSource {
  final Box _alarmsBox;

  AlarmLocalDataSourceImpl({Box? alarmsBox})
      : _alarmsBox = alarmsBox ?? Hive.box(HiveBoxes.alarmsBox);

  @override
  Future<void> cacheAlarms(List<EmergencyAlarmModel> alarms) async {
    for (var a in alarms) {
      await _alarmsBox.put(a.id, jsonEncode(a.toJson()));
    }
  }

  @override
  Future<void> cacheSingleAlarm(EmergencyAlarmModel alarm) async {
    await _alarmsBox.put(alarm.id, jsonEncode(alarm.toJson()));
  }

  @override
  Future<List<EmergencyAlarmModel>> getCachedAlarms() async {
    final list = <EmergencyAlarmModel>[];
    for (var key in _alarmsBox.keys) {
      final val = _alarmsBox.get(key);
      if (val != null) {
        try {
          final decoded = jsonDecode(val as String) as Map<String, dynamic>;
          list.add(EmergencyAlarmModel.fromJson(decoded));
        } catch (_) {}
      }
    }
    list.sort((a, b) => b.triggeredAt.compareTo(a.triggeredAt));
    return list;
  }
}

