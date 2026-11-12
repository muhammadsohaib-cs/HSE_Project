import 'dart:typed_data';
import '../../../../core/utils/pdf_generator.dart';
import '../../domain/entities/checklist.dart';
import '../../domain/repositories/checklist_repository.dart';
import '../datasources/checklist_local_data_source.dart';
import '../datasources/checklist_remote_data_source.dart';
import '../models/checklist_model.dart';

class ChecklistRepositoryImpl implements ChecklistRepository {
  final ChecklistRemoteDataSource _remoteDataSource;
  final ChecklistLocalDataSource _localDataSource;

  ChecklistRepositoryImpl({
    required ChecklistRemoteDataSource remoteDataSource,
    required ChecklistLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<List<ChecklistTemplate>> getTemplates() async {
    try {
      final remoteTemplates = await _remoteDataSource.fetchTemplates();
      await _localDataSource.cacheTemplates(remoteTemplates);
      return remoteTemplates;
    } catch (_) {
      final cached = await _localDataSource.getCachedTemplates();
      if (cached.isNotEmpty) return cached;
      return await _remoteDataSource.fetchTemplates();
    }
  }

  @override
  Future<List<ChecklistAudit>> getAudits({String? plantUnit, String? shiftType}) async {
    try {
      final remoteAudits = await _remoteDataSource.fetchAudits(
        plantUnit: plantUnit,
        shiftType: shiftType,
      );
      await _localDataSource.cacheAudits(remoteAudits);
      return remoteAudits;
    } catch (_) {
      final cached = await _localDataSource.getCachedAudits();
      var filtered = cached;
      if (plantUnit != null) {
        filtered = filtered.where((a) => a.plantUnit == plantUnit).toList();
      }
      if (shiftType != null) {
        filtered = filtered.where((a) => a.shiftType == shiftType).toList();
      }
      return filtered;
    }
  }

  @override
  Future<ChecklistAudit> submitAudit(ChecklistAudit audit) async {
    final model = ChecklistAuditModel.fromEntity(audit);
    await _localDataSource.cacheSingleAudit(model);
    try {
      return await _remoteDataSource.submitAudit(model);
    } catch (_) {
      return model;
    }
  }

  @override
  Future<Uint8List> exportShiftTurnoverPdf({
    required ChecklistAudit audit,
    required List<Map<String, String>> outstandingHazards,
  }) async {
    return await PdfReportGenerator.generateShiftTurnoverPdf(
      plantUnit: audit.plantUnit,
      shiftType: audit.shiftType,
      outgoingSupervisor: audit.inspectorName,
      checklistsCompleted: 1,
      hazardsIdentified: audit.failCount,
      criticalAlarmsCount: 0,
      openItems: audit.items
          .where((i) => i.status == ChecklistItemStatus.fail)
          .map((i) => {
                'zone': audit.plantUnit,
                'description': '${i.title}: ${i.deviationNotes ?? "Deviation reported"}',
                'risk': 'High',
                'action': 'Rectification Assigned',
              })
          .toList(),
    );
  }
}

