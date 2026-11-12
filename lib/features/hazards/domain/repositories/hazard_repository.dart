import '../entities/hazard.dart';

abstract class HazardRepository {
  Future<List<Hazard>> getHazards({
    String? plantZone,
    CapaStatus? status,
  });

  Future<Hazard> getHazardById(String id);

  Future<Hazard> reportHazard(Hazard hazard);

  Future<Hazard> updateCapaWorkflow({
    required String hazardId,
    required CapaStatus status,
    String? assignedTo,
    String? correctiveAction,
    String? resolutionProofMediaUrl,
    SupervisorSignOff? supervisorSignOff,
  });

  Future<int> syncOfflineQueue();

  Future<int> getPendingOfflineCount();
}

