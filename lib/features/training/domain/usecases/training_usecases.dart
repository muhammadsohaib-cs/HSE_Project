import '../entities/training.dart';
import '../repositories/training_repository.dart';

class GetCoursesUseCase {
  final TrainingRepository repository;
  GetCoursesUseCase(this.repository);

  Future<List<TrainingCourse>> execute() async => await repository.getCourses();
}

class GetCertificationsUseCase {
  final TrainingRepository repository;
  GetCertificationsUseCase(this.repository);

  Future<List<UserCertification>> execute(String employeeId) async {
    return await repository.getMyCertifications(employeeId);
  }
}

class LogAttendanceUseCase {
  final TrainingRepository repository;
  LogAttendanceUseCase(this.repository);

  Future<UserCertification> execute({
    required String courseId,
    required String employeeId,
    required String employeeName,
  }) async {
    return await repository.logAttendance(
      courseId: courseId,
      employeeId: employeeId,
      employeeName: employeeName,
    );
  }
}

