import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/hazard.dart';
import '../../domain/repositories/hazard_repository.dart';
import '../../domain/usecases/hazard_usecases.dart';
import 'hazard_state.dart';

class HazardCubit extends Cubit<HazardState> {
  final GetHazardsUseCase _getHazardsUseCase;
  final ReportHazardUseCase _reportHazardUseCase;
  final UpdateCapaStatusUseCase _updateCapaStatusUseCase;
  final SyncOfflineHazardsUseCase _syncOfflineHazardsUseCase;
  final HazardRepository _repository;

  HazardCubit({
    required GetHazardsUseCase getHazardsUseCase,
    required ReportHazardUseCase reportHazardUseCase,
    required UpdateCapaStatusUseCase updateCapaStatusUseCase,
    required SyncOfflineHazardsUseCase syncOfflineHazardsUseCase,
    required HazardRepository repository,
  })  : _getHazardsUseCase = getHazardsUseCase,
        _reportHazardUseCase = reportHazardUseCase,
        _updateCapaStatusUseCase = updateCapaStatusUseCase,
        _syncOfflineHazardsUseCase = syncOfflineHazardsUseCase,
        _repository = repository,
        super(HazardInitial());

  Future<void> loadHazards({String? plantZone, CapaStatus? status}) async {
    emit(HazardLoading());
    try {
      final hazards = await _getHazardsUseCase.execute(
        plantZone: plantZone,
        status: status,
      );
      final pendingCount = await _repository.getPendingOfflineCount();
      emit(HazardLoaded(
        hazards: hazards,
        selectedZone: plantZone,
        selectedStatus: status,
        pendingOfflineCount: pendingCount,
      ));
    } catch (e) {
      emit(HazardError(e.toString()));
    }
  }

  Future<void> filterHazards({String? plantZone, CapaStatus? status}) async {
    await loadHazards(plantZone: plantZone, status: status);
  }

  Future<void> reportHazard(Hazard hazard) async {
    try {
      await _reportHazardUseCase.execute(hazard);
      await loadHazards();
    } catch (e) {
      emit(HazardError(e.toString().replaceAll('ValidationFailure: ', '')));
    }
  }

  Future<void> advanceCapaStatus({
    required String hazardId,
    required CapaStatus targetStatus,
    String? assignedTo,
    String? correctiveAction,
    String? resolutionProofMediaUrl,
    SupervisorSignOff? supervisorSignOff,
  }) async {
    try {
      await _updateCapaStatusUseCase.execute(
        hazardId: hazardId,
        targetStatus: targetStatus,
        assignedTo: assignedTo,
        correctiveAction: correctiveAction,
        resolutionProofMediaUrl: resolutionProofMediaUrl,
        supervisorSignOff: supervisorSignOff,
      );
      await loadHazards();
    } catch (e) {
      emit(HazardError(e.toString().replaceAll('ValidationFailure: ', '')));
      await loadHazards();
    }
  }

  Future<void> syncOfflineBuffer() async {
    if (state is HazardLoaded) {
      final current = state as HazardLoaded;
      emit(current.copyWith(isSyncing: true));
      try {
        final count = await _syncOfflineHazardsUseCase.execute();
        await loadHazards(
          plantZone: current.selectedZone,
          status: current.selectedStatus,
        );
      } catch (e) {
        emit(HazardError('Offline sync error: $e'));
        await loadHazards();
      }
    }
  }
}

