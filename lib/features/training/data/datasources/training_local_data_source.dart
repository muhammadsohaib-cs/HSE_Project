import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../../core/storage/hive_boxes.dart';
import '../models/training_model.dart';

abstract class TrainingLocalDataSource {
  Future<void> cacheCourses(List<TrainingCourseModel> courses);
  Future<List<TrainingCourseModel>> getCachedCourses();
  Future<void> cacheCertificates(List<UserCertificationModel> certs);
  Future<List<UserCertificationModel>> getCachedCertificates();
}

class TrainingLocalDataSourceImpl implements TrainingLocalDataSource {
  final Box _box;

  TrainingLocalDataSourceImpl({Box? box}) : _box = box ?? Hive.box(HiveBoxes.trainingsBox);

  @override
  Future<void> cacheCourses(List<TrainingCourseModel> courses) async {
    final jsonList = courses.map((c) => c.toJson()).toList();
    await _box.put('courses_cache', jsonEncode(jsonList));
  }

  @override
  Future<List<TrainingCourseModel>> getCachedCourses() async {
    final raw = _box.get('courses_cache');
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw as String) as List;
      return decoded.map((e) => TrainingCourseModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> cacheCertificates(List<UserCertificationModel> certs) async {
    final jsonList = certs.map((c) => c.toJson()).toList();
    await _box.put('certificates_cache', jsonEncode(jsonList));
  }

  @override
  Future<List<UserCertificationModel>> getCachedCertificates() async {
    final raw = _box.get('certificates_cache');
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw as String) as List;
      return decoded.map((e) => UserCertificationModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (_) {
      return [];
    }
  }
}

