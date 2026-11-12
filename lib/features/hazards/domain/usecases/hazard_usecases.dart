import '../entities/hazard.dart';
import '../repositories/hazard_repository.dart';
import '../../../../core/errors/failures.dart';

class GetHazardsUseCase {
  final HazardRepository repository;
  GetHazardsUseCase(this.repository);

  Future<List<Hazard>> execute({String? plantZone, CapaStatus? status}) async {
    return await repository.getHazards(plantZone: plantZone, status: status);
  }
}

class ReportHazardUseCase {
  final HazardRepository repository;
  ReportHazardUseCase(this.repository);

  Future<Hazard> execute(Hazard hazard) async {
    if (hazard.title.trim().isEmpty) {
      throw const ValidationFailure('Hazard title cannot be empty');
    }
    if (hazard.description.trim().isEmpty) {
      throw const ValidationFailure('Hazard description cannot be empty');
    }
    if (hazard.plantZone.trim().isEmpty) {
      throw const ValidationFailure('Plant Zone selection is required');
    }
    return await repository.reportHazard(hazard);
  }
}

class UpdateCapaStatusUseCase {
  final HazardRepository repository;
  UpdateCapaStatusUseCase(this.repository);

  Future<Hazard> execute({
    required String hazardId,
    required CapaStatus targetStatus,
    String? assignedTo,
    String? correctiveAction,
    String? resolutionProofMediaUrl,
    SupervisorSignOff? supervisorSignOff,
  }) async {
    // Business rule: Closure requires both resolution proof photo and supervisor sign-off
    if (targetStatus == CapaStatus.closed) {
      if (resolutionProofMediaUrl == null || resolutionProofMediaUrl.isEmpty) {
        throw const ValidationFailure('Resolution evidence photo is mandatory before hazard closure');
      }
      if (supervisorSignOff == null) {
        throw const ValidationFailure('Supervisory digital approval is mandatory for hazard closure');
      }
    }

    return await repository.updateCapaWorkflow(
      hazardId: hazardId,
      status: targetStatus,
      assignedTo: assignedTo,
      correctiveAction: correctiveAction,
      resolutionProofMediaUrl: resolutionProofMediaUrl,
      supervisorSignOff: supervisorSignOff,
    );
  }
}

class SyncOfflineHazardsUseCase {
  final HazardRepository repository;
  SyncOfflineHazardsUseCase(this.repository);

  Future<int> execute() async => await repository.syncOfflineQueue();
}

