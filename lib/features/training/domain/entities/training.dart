import 'package:equatable/equatable.dart';

enum ExpiryUrgency {
  valid,
  expiringIn30Days,
  expiringIn15Days,
  expiringIn7Days,
  expired;

  String get label {
    switch (this) {
      case ExpiryUrgency.valid:
        return 'Valid';
      case ExpiryUrgency.expiringIn30Days:
        return 'Expiring in < 30 Days';
      case ExpiryUrgency.expiringIn15Days:
        return 'Expiring in < 15 Days (Urgent)';
      case ExpiryUrgency.expiringIn7Days:
        return 'Expiring in < 7 Days (Critical)';
      case ExpiryUrgency.expired:
        return 'EXPIRED (Mandatory Recertification)';
    }
  }
}

class TrainingCourse extends Equatable {
  final String id;
  final String title;
  final String category;
  final String description;
  final int durationHours;
  final int validityDays;
  final String pdfDocUrl;
  final String videoUrl;

  const TrainingCourse({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.durationHours,
    required this.validityDays,
    required this.pdfDocUrl,
    required this.videoUrl,
  });

  @override
  List<Object?> get props => [id, title, category, description, durationHours, validityDays, pdfDocUrl, videoUrl];
}

class UserCertification extends Equatable {
  final String id;
  final String courseId;
  final String courseTitle;
  final String employeeId;
  final String employeeName;
  final DateTime issueDate;
  final DateTime expiryDate;
  final int scorePercentage;
  final String certificateNumber;

  const UserCertification({
    required this.id,
    required this.courseId,
    required this.courseTitle,
    required this.employeeId,
    required this.employeeName,
    required this.issueDate,
    required this.expiryDate,
    required this.scorePercentage,
    required this.certificateNumber,
  });

  int get daysUntilExpiry => expiryDate.difference(DateTime.now()).inDays;

  ExpiryUrgency get urgency {
    final days = daysUntilExpiry;
    if (days < 0) return ExpiryUrgency.expired;
    if (days <= 7) return ExpiryUrgency.expiringIn7Days;
    if (days <= 15) return ExpiryUrgency.expiringIn15Days;
    if (days <= 30) return ExpiryUrgency.expiringIn30Days;
    return ExpiryUrgency.valid;
  }

  @override
  List<Object?> get props => [
        id,
        courseId,
        courseTitle,
        employeeId,
        employeeName,
        issueDate,
        expiryDate,
        scorePercentage,
        certificateNumber,
      ];
}

