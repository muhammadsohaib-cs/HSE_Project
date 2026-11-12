import 'dart:typed_data';
import '../entities/checklist.dart';
import '../repositories/checklist_repository.dart';
import '../../../../core/errors/failures.dart';

class GetChecklistTemplatesUseCase {
  final ChecklistRepository repository;
  GetChecklistTemplatesUseCase(this.repository);

  Future<List<ChecklistTemplate>> execute() async {
    return await repository.getTemplates();
  }
}

class GetChecklistAuditsUseCase {
  final ChecklistRepository repository;
  GetChecklistAuditsUseCase(this.repository);

  Future<List<ChecklistAudit>> execute({String? plantUnit, String? shiftType}) async {
    return await repository.getAudits(plantUnit: plantUnit, shiftType: shiftType);
  }
}

class SubmitChecklistAuditUseCase {
  final ChecklistRepository repository;
  SubmitChecklistAuditUseCase(this.repository);

  Future<ChecklistAudit> execute(ChecklistAudit audit) async {
    // Validation: Any item marked 'Fail' must have deviation notes
    for (final item in audit.items) {
      if (item.status == ChecklistItemStatus.fail) {
        if (item.deviationNotes == null || item.deviationNotes!.trim().isEmpty) {
          throw ValidationFailure('Deviation notes are mandatory for failed item: "${item.title}"');
        }
      }
    }

    final totalAnswered = audit.items.where((i) => i.status != ChecklistItemStatus.unanswered).length;
    final rate = (totalAnswered / audit.items.length) * 100.0;

    final completeAudit = audit.copyWith(
      completionRate: double.parse(rate.toStringAsFixed(1)),
      isCompleted: rate >= 100.0,
      auditDate: DateTime.now(),
    );

    return await repository.submitAudit(completeAudit);
  }
}

class ExportShiftTurnoverUseCase {
  final ChecklistRepository repository;
  ExportShiftTurnoverUseCase(this.repository);

  Future<Uint8List> execute({
    required ChecklistAudit audit,
    required List<Map<String, String>> outstandingHazards,
  }) async {
    return await repository.exportShiftTurnoverPdf(
      audit: audit,
      outstandingHazards: outstandingHazards,
    );
  }
}

