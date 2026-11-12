import '../../domain/entities/checklist.dart';

class ChecklistItemModel extends ChecklistItem {
  const ChecklistItemModel({
    required super.id,
    required super.title,
    required super.category,
    super.status,
    super.deviationNotes,
    super.deviationPhotoUrl,
  });

  factory ChecklistItemModel.fromJson(Map<String, dynamic> json) {
    return ChecklistItemModel(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      status: ChecklistItemStatus.fromString(json['status'] as String? ?? ''),
      deviationNotes: json['deviation_notes'] as String?,
      deviationPhotoUrl: json['deviation_photo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'status': status.name,
    'deviation_notes': deviationNotes,
    'deviation_photo_url': deviationPhotoUrl,
  };

  factory ChecklistItemModel.fromEntity(ChecklistItem entity) {
    return ChecklistItemModel(
      id: entity.id,
      title: entity.title,
      category: entity.category,
      status: entity.status,
      deviationNotes: entity.deviationNotes,
      deviationPhotoUrl: entity.deviationPhotoUrl,
    );
  }
}

class ChecklistAuditModel extends ChecklistAudit {
  const ChecklistAuditModel({
    required super.id,
    required super.templateId,
    required super.title,
    required super.plantUnit,
    required super.shiftType,
    required super.inspectorId,
    required super.inspectorName,
    required super.items,
    required super.completionRate,
    required super.isCompleted,
    required super.auditDate,
  });

  factory ChecklistAuditModel.fromJson(Map<String, dynamic> json) {
    return ChecklistAuditModel(
      id: json['id'] as String,
      templateId: json['template_id'] as String,
      title: json['title'] as String,
      plantUnit: json['plant_unit'] as String,
      shiftType: json['shift_type'] as String,
      inspectorId: json['inspector_id'] as String,
      inspectorName: json['inspector_name'] as String,
      items: (json['items'] as List)
          .map((i) => ChecklistItemModel.fromJson(Map<String, dynamic>.from(i as Map)))
          .toList(),
      completionRate: (json['completion_rate'] as num).toDouble(),
      isCompleted: json['is_completed'] as bool? ?? false,
      auditDate: DateTime.parse(json['audit_date'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'template_id': templateId,
    'title': title,
    'plant_unit': plantUnit,
    'shift_type': shiftType,
    'inspector_id': inspectorId,
    'inspector_name': inspectorName,
    'items': items.map((i) => ChecklistItemModel.fromEntity(i).toJson()).toList(),
    'completion_rate': completionRate,
    'is_completed': isCompleted,
    'audit_date': auditDate.toIso8601String(),
  };

  factory ChecklistAuditModel.fromEntity(ChecklistAudit entity) {
    return ChecklistAuditModel(
      id: entity.id,
      templateId: entity.templateId,
      title: entity.title,
      plantUnit: entity.plantUnit,
      shiftType: entity.shiftType,
      inspectorId: entity.inspectorId,
      inspectorName: entity.inspectorName,
      items: entity.items,
      completionRate: entity.completionRate,
      isCompleted: entity.isCompleted,
      auditDate: entity.auditDate,
    );
  }
}

class ChecklistTemplateModel extends ChecklistTemplate {
  const ChecklistTemplateModel({
    required super.id,
    required super.title,
    required super.plantUnit,
    required super.targetRole,
    required super.defaultItems,
  });

  factory ChecklistTemplateModel.fromJson(Map<String, dynamic> json) {
    return ChecklistTemplateModel(
      id: json['id'] as String,
      title: json['title'] as String,
      plantUnit: json['plant_unit'] as String,
      targetRole: json['target_role'] as String,
      defaultItems: (json['default_items'] as List)
          .map((i) => ChecklistItemModel.fromJson(Map<String, dynamic>.from(i as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'plant_unit': plantUnit,
    'target_role': targetRole,
    'default_items': defaultItems.map((i) => ChecklistItemModel.fromEntity(i).toJson()).toList(),
  };
}

