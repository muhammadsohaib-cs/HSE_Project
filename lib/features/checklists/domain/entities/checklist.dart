import 'package:equatable/equatable.dart';

enum ChecklistItemStatus {
  unanswered,
  pass,
  fail,
  na;

  static ChecklistItemStatus fromString(String val) {
    switch (val.toLowerCase()) {
      case 'pass':
        return ChecklistItemStatus.pass;
      case 'fail':
        return ChecklistItemStatus.fail;
      case 'na':
      case 'n/a':
        return ChecklistItemStatus.na;
      default:
        return ChecklistItemStatus.unanswered;
    }
  }
}

class ChecklistItem extends Equatable {
  final String id;
  final String title;
  final String category;
  final ChecklistItemStatus status;
  final String? deviationNotes;
  final String? deviationPhotoUrl;

  const ChecklistItem({
    required this.id,
    required this.title,
    required this.category,
    this.status = ChecklistItemStatus.unanswered,
    this.deviationNotes,
    this.deviationPhotoUrl,
  });

  ChecklistItem copyWith({
    String? id,
    String? title,
    String? category,
    ChecklistItemStatus? status,
    String? deviationNotes,
    String? deviationPhotoUrl,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      status: status ?? this.status,
      deviationNotes: deviationNotes ?? this.deviationNotes,
      deviationPhotoUrl: deviationPhotoUrl ?? this.deviationPhotoUrl,
    );
  }

  @override
  List<Object?> get props => [id, title, category, status, deviationNotes, deviationPhotoUrl];
}

class ChecklistAudit extends Equatable {
  final String id;
  final String templateId;
  final String title;
  final String plantUnit;
  final String shiftType;
  final String inspectorId;
  final String inspectorName;
  final List<ChecklistItem> items;
  final double completionRate;
  final bool isCompleted;
  final DateTime auditDate;

  const ChecklistAudit({
    required this.id,
    required this.templateId,
    required this.title,
    required this.plantUnit,
    required this.shiftType,
    required this.inspectorId,
    required this.inspectorName,
    required this.items,
    required this.completionRate,
    required this.isCompleted,
    required this.auditDate,
  });

  int get passCount => items.where((i) => i.status == ChecklistItemStatus.pass).length;
  int get failCount => items.where((i) => i.status == ChecklistItemStatus.fail).length;
  int get naCount => items.where((i) => i.status == ChecklistItemStatus.na).length;

  ChecklistAudit copyWith({
    String? id,
    String? templateId,
    String? title,
    String? plantUnit,
    String? shiftType,
    String? inspectorId,
    String? inspectorName,
    List<ChecklistItem>? items,
    double? completionRate,
    bool? isCompleted,
    DateTime? auditDate,
  }) {
    return ChecklistAudit(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      title: title ?? this.title,
      plantUnit: plantUnit ?? this.plantUnit,
      shiftType: shiftType ?? this.shiftType,
      inspectorId: inspectorId ?? this.inspectorId,
      inspectorName: inspectorName ?? this.inspectorName,
      items: items ?? this.items,
      completionRate: completionRate ?? this.completionRate,
      isCompleted: isCompleted ?? this.isCompleted,
      auditDate: auditDate ?? this.auditDate,
    );
  }

  @override
  List<Object?> get props => [
        id,
        templateId,
        title,
        plantUnit,
        shiftType,
        inspectorId,
        inspectorName,
        items,
        completionRate,
        isCompleted,
        auditDate,
      ];
}

class ChecklistTemplate extends Equatable {
  final String id;
  final String title;
  final String plantUnit;
  final String targetRole;
  final List<ChecklistItem> defaultItems;

  const ChecklistTemplate({
    required this.id,
    required this.title,
    required this.plantUnit,
    required this.targetRole,
    required this.defaultItems,
  });

  @override
  List<Object?> get props => [id, title, plantUnit, targetRole, defaultItems];
}

