import '../../domain/entities/training.dart';

class TrainingCourseModel extends TrainingCourse {
  const TrainingCourseModel({
    required super.id,
    required super.title,
    required super.category,
    required super.description,
    required super.durationHours,
    required super.validityDays,
    required super.pdfDocUrl,
    required super.videoUrl,
  });

  factory TrainingCourseModel.fromJson(Map<String, dynamic> json) {
    return TrainingCourseModel(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      durationHours: (json['duration_hours'] as num).toInt(),
      validityDays: (json['validity_days'] as num).toInt(),
      pdfDocUrl: json['pdf_doc_url'] as String,
      videoUrl: json['video_url'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'description': description,
    'duration_hours': durationHours,
    'validity_days': validityDays,
    'pdf_doc_url': pdfDocUrl,
    'video_url': videoUrl,
  };
}

class UserCertificationModel extends UserCertification {
  const UserCertificationModel({
    required super.id,
    required super.courseId,
    required super.courseTitle,
    required super.employeeId,
    required super.employeeName,
    required super.issueDate,
    required super.expiryDate,
    required super.scorePercentage,
    required super.certificateNumber,
  });

  factory UserCertificationModel.fromJson(Map<String, dynamic> json) {
    return UserCertificationModel(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      courseTitle: json['course_title'] as String,
      employeeId: json['employee_id'] as String,
      employeeName: json['employee_name'] as String,
      issueDate: DateTime.parse(json['issue_date'] as String),
      expiryDate: DateTime.parse(json['expiry_date'] as String),
      scorePercentage: (json['score_percentage'] as num).toInt(),
      certificateNumber: json['certificate_number'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'course_id': courseId,
    'course_title': courseTitle,
    'employee_id': employeeId,
    'employee_name': employeeName,
    'issue_date': issueDate.toIso8601String(),
    'expiry_date': expiryDate.toIso8601String(),
    'score_percentage': scorePercentage,
    'certificate_number': certificateNumber,
  };

  factory UserCertificationModel.fromEntity(UserCertification entity) {
    return UserCertificationModel(
      id: entity.id,
      courseId: entity.courseId,
      courseTitle: entity.courseTitle,
      employeeId: entity.employeeId,
      employeeName: entity.employeeName,
      issueDate: entity.issueDate,
      expiryDate: entity.expiryDate,
      scorePercentage: entity.scorePercentage,
      certificateNumber: entity.certificateNumber,
    );
  }
}

