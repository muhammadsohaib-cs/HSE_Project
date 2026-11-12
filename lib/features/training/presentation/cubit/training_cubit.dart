import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/training_usecases.dart';
import 'training_state.dart';

class TrainingCubit extends Cubit<TrainingState> {
  final GetCoursesUseCase _getCoursesUseCase;
  final GetCertificationsUseCase _getCertificationsUseCase;
  final LogAttendanceUseCase _logAttendanceUseCase;

  TrainingCubit({
    required GetCoursesUseCase getCoursesUseCase,
    required GetCertificationsUseCase getCertificationsUseCase,
    required LogAttendanceUseCase logAttendanceUseCase,
  })  : _getCoursesUseCase = getCoursesUseCase,
        _getCertificationsUseCase = getCertificationsUseCase,
        _logAttendanceUseCase = logAttendanceUseCase,
        super(TrainingInitial());

  Future<void> loadTrainingData(String employeeId) async {
    emit(TrainingLoading());
    try {
      final courses = await _getCoursesUseCase.execute();
      final certs = await _getCertificationsUseCase.execute(employeeId);
      emit(TrainingLoaded(courses: courses, certifications: certs));
    } catch (e) {
      emit(TrainingError(e.toString()));
    }
  }

  Future<void> recordAttendance({
    required String courseId,
    required String employeeId,
    required String employeeName,
  }) async {
    try {
      final newCert = await _logAttendanceUseCase.execute(
        courseId: courseId,
        employeeId: employeeId,
        employeeName: employeeName,
      );
      emit(AttendanceLoggedSuccess(newCert));
      await loadTrainingData(employeeId);
    } catch (e) {
      emit(TrainingError(e.toString()));
      await loadTrainingData(employeeId);
    }
  }
}

