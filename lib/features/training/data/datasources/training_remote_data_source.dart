import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/training_model.dart';

abstract class TrainingRemoteDataSource {
  Future<List<TrainingCourseModel>> fetchCourses();
  Future<List<UserCertificationModel>> fetchCertificates(String employeeId);
  Future<UserCertificationModel> recordAttendance(String courseId, String employeeId, String employeeName);
}

class TrainingRemoteDataSourceImpl implements TrainingRemoteDataSource {
  final Dio _dio;

  TrainingRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<TrainingCourseModel>> fetchCourses() async {
    try {
      final response = await _dio.get(ApiEndpoints.trainings);
      return (response.data['data'] as List)
          .map((item) => TrainingCourseModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _getSeedCourses();
    }
  }

  @override
  Future<List<UserCertificationModel>> fetchCertificates(String employeeId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.userCertifications,
        queryParameters: {'employee_id': employeeId},
      );
      return (response.data['data'] as List)
          .map((item) => UserCertificationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _getSeedCertificates(employeeId);
    }
  }

  @override
  Future<UserCertificationModel> recordAttendance(String courseId, String employeeId, String employeeName) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.trainingAttendance(courseId),
        data: {'employee_id': employeeId, 'employee_name': employeeName},
      );
      return UserCertificationModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (_) {
      return UserCertificationModel(
        id: 'CERT-${DateTime.now().millisecondsSinceEpoch}',
        courseId: courseId,
        courseTitle: 'Safety Induction Completion',
        employeeId: employeeId,
        employeeName: employeeName,
        issueDate: DateTime.now(),
        expiryDate: DateTime.now().add(const Duration(days: 365)),
        scorePercentage: 96,
        certificateNumber: 'CP-CERT-2026-${DateTime.now().millisecond}',
      );
    }
  }

  List<TrainingCourseModel> _getSeedCourses() {
    return const [
      TrainingCourseModel(
        id: 'TRN-001',
        title: 'Lockout/Tagout (LOTO) Energy Isolation Standard',
        category: 'Mechanical & Electrical Safety',
        description: 'Comprehensive protocol for isolating high-pressure steam, fuel gas, and high voltage switchgear prior to maintenance.',
        durationHours: 8,
        validityDays: 365,
        pdfDocUrl: 'https://docs.chiniotpower.com/hse/loto_standard_v2.pdf',
        videoUrl: 'https://videos.chiniotpower.com/loto_walkthrough.mp4',
      ),
      TrainingCourseModel(
        id: 'TRN-002',
        title: 'Confined Space Entry & Atmospheric Monitoring',
        category: 'Permit to Work (PTW)',
        description: 'Atmospheric oxygen, toxic gas, and combustible vapor testing procedures before entry into boiler drums and turbine condensers.',
        durationHours: 6,
        validityDays: 180,
        pdfDocUrl: 'https://docs.chiniotpower.com/hse/confined_space_guide.pdf',
        videoUrl: 'https://videos.chiniotpower.com/confined_space_safety.mp4',
      ),
      TrainingCourseModel(
        id: 'TRN-003',
        title: 'Chemical & Corrosive Media Handling Protocols',
        category: 'Hazardous Materials (HAZMAT)',
        description: 'Safe handling of hydrochloric acid, caustic soda, hydrazine, and chlorine in Water Treatment Plant (WTP).',
        durationHours: 4,
        validityDays: 365,
        pdfDocUrl: 'https://docs.chiniotpower.com/hse/chemical_msds_compendium.pdf',
        videoUrl: 'https://videos.chiniotpower.com/hazmat_spill_response.mp4',
      ),
      TrainingCourseModel(
        id: 'TRN-004',
        title: '132kV Substation High Voltage Clearance & Grounding',
        category: 'Electrical Safety',
        description: 'Strict adherence to minimum approach distances, earth rod application, and electrical work permit sign-offs.',
        durationHours: 12,
        validityDays: 365,
        pdfDocUrl: 'https://docs.chiniotpower.com/hse/hv_safety_rules.pdf',
        videoUrl: 'https://videos.chiniotpower.com/substation_clearance.mp4',
      ),
      TrainingCourseModel(
        id: 'TRN-005',
        title: 'Annual Industrial Fire Fighting & Muster Evacuation',
        category: 'Emergency Preparedness',
        description: 'CO2 fixed flooding system operation, fire hose drill, and primary muster point assembly verification.',
        durationHours: 4,
        validityDays: 180,
        pdfDocUrl: 'https://docs.chiniotpower.com/hse/fire_evacuation_map.pdf',
        videoUrl: 'https://videos.chiniotpower.com/fire_drill_demo.mp4',
      ),
    ];
  }

  List<UserCertificationModel> _getSeedCertificates(String empId) {
    return [
      UserCertificationModel(
        id: 'CERT-001',
        courseId: 'TRN-001',
        courseTitle: 'Lockout/Tagout (LOTO) Energy Isolation Standard',
        employeeId: empId,
        employeeName: 'HSE Operator',
        issueDate: DateTime.now().subtract(const Duration(days: 359)),
        expiryDate: DateTime.now().add(const Duration(days: 6)), // CRITICAL: < 7 days!
        scorePercentage: 94,
        certificateNumber: 'CP-LOTO-2025-081',
      ),
      UserCertificationModel(
        id: 'CERT-002',
        courseId: 'TRN-002',
        courseTitle: 'Confined Space Entry & Atmospheric Monitoring',
        employeeId: empId,
        employeeName: 'HSE Operator',
        issueDate: DateTime.now().subtract(const Duration(days: 166)),
        expiryDate: DateTime.now().add(const Duration(days: 14)), // URGENT: < 15 days!
        scorePercentage: 98,
        certificateNumber: 'CP-CONF-2025-112',
      ),
      UserCertificationModel(
        id: 'CERT-003',
        courseId: 'TRN-004',
        courseTitle: '132kV Substation High Voltage Clearance & Grounding',
        employeeId: empId,
        employeeName: 'HSE Operator',
        issueDate: DateTime.now().subtract(const Duration(days: 90)),
        expiryDate: DateTime.now().add(const Duration(days: 275)), // Valid
        scorePercentage: 100,
        certificateNumber: 'CP-HV-2026-004',
      ),
    ];
  }
}

