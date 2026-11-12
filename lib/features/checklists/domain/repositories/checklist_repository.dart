import 'dart:typed_data';
import '../entities/checklist.dart';

abstract class ChecklistRepository {
  Future<List<ChecklistTemplate>> getTemplates();
  Future<List<ChecklistAudit>> getAudits({String? plantUnit, String? shiftType});
  Future<ChecklistAudit> submitAudit(ChecklistAudit audit);
  Future<Uint8List> exportShiftTurnoverPdf({
    required ChecklistAudit audit,
    required List<Map<String, String>> outstandingHazards,
  });
}

