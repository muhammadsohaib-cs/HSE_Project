import '../../domain/entities/training.dart';
import '../../domain/repositories/training_repository.dart';
import '../datasources/training_local_data_source.dart';
import '../datasources/training_remote_data_source.dart';

class TrainingRepositoryImpl implements TrainingRepository {
  final TrainingRemoteDataSource _remoteDataSource;
  final TrainingLocalDataSource _localDataSource;

  TrainingRepositoryImpl({
    required TrainingRemoteDataSource remoteDataSource,
    required TrainingLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<List<TrainingCourse>> getCourses() async {
    try {
      final remoteCourses = await _remoteDataSource.fetchCourses();
      await _localDataSource.cacheCourses(remoteCourses);
      return remoteCourses;
    } catch (_) {
      final cached = await _localDataSource.getCachedCourses();
      if (cached.isNotEmpty) return cached;
      return await _remoteDataSource.fetchCourses();
    }
  }

  @override
  Future<List<UserCertification>> getMyCertifications(String employeeId) async {
    try {
      final remoteCerts = await _remoteDataSource.fetchCertificates(employeeId);
      await _localDataSource.cacheCertificates(remoteCerts);
      return remoteCerts;
    } catch (_) {
      final cached = await _localDataSource.getCachedCertificates();
      if (cached.isNotEmpty) return cached;
      return await _remoteDataSource.fetchCertificates(employeeId);
    }
  }

  @override
  Future<UserCertification> logAttendance({
    required String courseId,
    required String employeeId,
    required String employeeName,
  }) async {
    return await _remoteDataSource.recordAttendance(courseId, employeeId, employeeName);
  }
}

