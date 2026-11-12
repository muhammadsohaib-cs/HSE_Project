import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/checklist.dart';
import '../../domain/usecases/checklist_usecases.dart';
import 'checklist_state.dart';

class ChecklistCubit extends Cubit<ChecklistState> {
  final GetChecklistTemplatesUseCase _getTemplatesUseCase;
  final GetChecklistAuditsUseCase _getAuditsUseCase;
  final SubmitChecklistAuditUseCase _submitAuditUseCase;
  final ExportShiftTurnoverUseCase _exportShiftTurnoverUseCase;

  ChecklistCubit({
    required GetChecklistTemplatesUseCase getTemplatesUseCase,
    required GetChecklistAuditsUseCase getAuditsUseCase,
    required SubmitChecklistAuditUseCase submitAuditUseCase,
    required ExportShiftTurnoverUseCase exportShiftTurnoverUseCase,
  })  : _getTemplatesUseCase = getTemplatesUseCase,
        _getAuditsUseCase = getAuditsUseCase,
        _submitAuditUseCase = submitAuditUseCase,
        _exportShiftTurnoverUseCase = exportShiftTurnoverUseCase,
        super(ChecklistInitial());

  Future<void> loadChecklists() async {
    emit(ChecklistLoading());
    try {
      final templates = await _getTemplatesUseCase.execute();
      final audits = await _getAuditsUseCase.execute();
      emit(ChecklistLoaded(templates: templates, audits: audits));
    } catch (e) {
      emit(ChecklistError(e.toString()));
    }
  }

  Future<void> submitAudit(ChecklistAudit audit) async {
    try {
      final result = await _submitAuditUseCase.execute(audit);
      emit(ChecklistSubmittedSuccess(result));
      await loadChecklists();
    } catch (e) {
      emit(ChecklistError(e.toString().replaceAll('ValidationFailure: ', '')));
      await loadChecklists();
    }
  }

  Future<Uint8List> exportTurnoverPdf({
    required ChecklistAudit audit,
    required List<Map<String, String>> outstandingHazards,
  }) async {
    return await _exportShiftTurnoverUseCase.execute(
      audit: audit,
      outstandingHazards: outstandingHazards,
    );
  }
}

