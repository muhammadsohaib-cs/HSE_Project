import 'package:equatable/equatable.dart';

enum UserRole {
  worker('Worker', 'Field Worker / Technician'),
  inspector('Inspector', 'HSE Inspector / Officer'),
  manager('HSE Manager', 'Plant HSE Manager'),
  admin('Admin', 'Super Admin');

  final String title;
  final String description;
  const UserRole(this.title, this.description);

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'inspector':
      case 'hse inspector':
      case 'hse_inspector':
        return UserRole.inspector;
      case 'manager':
      case 'hse manager':
      case 'hse_manager':
        return UserRole.manager;
      case 'admin':
      case 'super admin':
      case 'super_admin':
        return UserRole.admin;
      default:
        return UserRole.worker;
    }
  }
}

class User extends Equatable {
  final String id;
  final String employeeId;
  final String name;
  final String email;
  final UserRole role;
  final String department;
  final String plantUnit;
  final bool isActive;

  const User({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    required this.plantUnit,
    this.isActive = true,
  });

  /// Validates standard Chiniot Power Employee ID format: CP-EMP-XXXX
  static bool isValidEmployeeId(String id) {
    final regex = RegExp(r'^CP-EMP-\d{4}$');
    return regex.hasMatch(id.trim().toUpperCase());
  }

  bool get canApproveCapa => role == UserRole.manager || role == UserRole.admin;
  bool get canTriggerBroadcastAlarm => role == UserRole.manager || role == UserRole.inspector || role == UserRole.admin;
  bool get canManageChecklistTemplates => role == UserRole.manager || role == UserRole.admin;
  bool get canAccessAdminPortal => role == UserRole.admin;

  @override
  List<Object?> get props => [
        id,
        employeeId,
        name,
        email,
        role,
        department,
        plantUnit,
        isActive,
      ];
}

