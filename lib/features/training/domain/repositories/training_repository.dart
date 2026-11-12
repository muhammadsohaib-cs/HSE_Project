import '../entities/training.dart';

abstract class TrainingRepository {
  Future<List<TrainingCourse>> getCourses();
  Future<List<UserCertification>> getMyCertifications(String employeeId);
  Future<UserCertification> logAttendance({
    required String courseId,
    required String employeeId,
    required String employeeName,
  });
}

