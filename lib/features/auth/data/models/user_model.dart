import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.employeeId,
    required super.name,
    required super.email,
    required super.role,
    required super.department,
    required super.plantUnit,
    super.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      employeeId: json['employee_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: UserRole.fromString(json['role'] as String),
      department: json['department'] as String? ?? 'General Operations',
      plantUnit: json['plant_unit'] as String? ?? 'Main Complex',
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'name': name,
      'email': email,
      'role': role.name,
      'department': department,
      'plant_unit': plantUnit,
      'is_active': isActive,
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      employeeId: user.employeeId,
      name: user.name,
      email: user.email,
      role: user.role,
      department: user.department,
      plantUnit: user.plantUnit,
      isActive: user.isActive,
    );
  }
}

