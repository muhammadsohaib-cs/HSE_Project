import 'package:equatable/equatable.dart';
import '../../domain/entities/training.dart';

abstract class TrainingState extends Equatable {
  const TrainingState();
  @override
  List<Object?> get props => [];
}

class TrainingInitial extends TrainingState {}

class TrainingLoading extends TrainingState {}

class TrainingLoaded extends TrainingState {
  final List<TrainingCourse> courses;
  final List<UserCertification> certifications;

  const TrainingLoaded({
    required this.courses,
    required this.certifications,
  });

  List<UserCertification> get expiringSoon => certifications
      .where((c) => c.urgency != ExpiryUrgency.valid)
      .toList();

  @override
  List<Object?> get props => [courses, certifications];
}

class TrainingError extends TrainingState {
  final String message;
  const TrainingError(this.message);

  @override
  List<Object?> get props => [message];
}

class AttendanceLoggedSuccess extends TrainingState {
  final UserCertification certification;
  const AttendanceLoggedSuccess(this.certification);

  @override
  List<Object?> get props => [certification];
}

