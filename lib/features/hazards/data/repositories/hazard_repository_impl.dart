import '../../domain/entities/hazard.dart';
import '../../domain/repositories/hazard_repository.dart';
import '../datasources/hazard_local_data_source.dart';
import '../datasources/hazard_remote_data_source.dart';
import '../models/hazard_model.dart';

class HazardRepositoryImpl implements HazardRepository {
  final HazardRemoteDataSource _remoteDataSource;
  final HazardLocalDataSource _localDataSource;

  HazardRepositoryImpl({
    required HazardRemoteDataSource remoteDataSource,
    required HazardLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<List<Hazard>> getHazards({String? plantZone, CapaStatus? status}) async {
    try {
      final remoteList = await _remoteDataSource.fetchHazards(
        plantZone: plantZone,
        status: status,
      );
      await _localDataSource.cacheHazards(remoteList);
      return remoteList;
    } catch (_) {
      final cached = await _localDataSource.getCachedHazards();
      var filtered = cached;
      if (plantZone != null) {
        filtered = filtered.where((h) => h.plantZone == plantZone).toList();
      }
      if (status != null) {
        filtered = filtered.where((h) => h.status == status).toList();
      }
      return filtered;
    }
  }

  @override
  Future<Hazard> getHazardById(String id) async {
    final cached = await _localDataSource.getCachedHazardById(id);
    if (cached != null) return cached;
    final all = await getHazards();
    return all.firstWhere((h) => h.id == id);
  }

  @override
  Future<Hazard> reportHazard(Hazard hazard) async {
    final model = HazardModel.fromEntity(hazard);
    try {
      final created = await _remoteDataSource.createHazard(model);
      await _localDataSource.cacheSingleHazard(created);
      return created;
    } catch (e) {
      // Offline mode: buffer in Hive sync queue
      await _localDataSource.enqueueOfflineHazard(model);
      return model.copyWith(isOfflineBuffered: true);
    }
  }

  @override
  Future<Hazard> updateCapaWorkflow({
    required String hazardId,
    required CapaStatus status,
    String? assignedTo,
    String? correctiveAction,
    String? resolutionProofMediaUrl,
    SupervisorSignOff? supervisorSignOff,
  }) async {
    final current = await getHazardById(hazardId);
    final updated = current.copyWith(
      status: status,
      assignedTo: assignedTo,
      correctiveAction: correctiveAction,
      resolutionProofMediaUrl: resolutionProofMediaUrl,
      supervisorSignOff: supervisorSignOff,
      closedAt: status == CapaStatus.closed ? DateTime.now() : null,
    );

    final model = HazardModel.fromEntity(updated);
    await _localDataSource.cacheSingleHazard(model);

    try {
      await _remoteDataSource.updateCapaWorkflow({
        'hazard_id': hazardId,
        'status': status.name,
        'assigned_to': assignedTo,
        'corrective_action': correctiveAction,
        'resolution_proof_media_url': resolutionProofMediaUrl,
        'supervisor_sign_off': supervisorSignOff?.toJson(),
      });
    } catch (_) {
      // If offline, enqueue update
    }

    return updated;
  }

  @override
  Future<int> syncOfflineQueue() async {
    final queueItems = await _localDataSource.getOfflineQueueItems();
    if (queueItems.isEmpty) return 0;

    final payloads = queueItems.map((e) => e.payload).toList();
    final syncedIds = await _remoteDataSource.syncBatch(payloads);

    for (final id in syncedIds) {
      await _localDataSource.removeOfflineItem(id);
      final cached = await _localDataSource.getCachedHazardById(id);
      if (cached != null) {
        await _localDataSource.cacheSingleHazard(
          HazardModel.fromEntity(cached.copyWith(isOfflineBuffered: false)),
        );
      }
    }

    return syncedIds.length;
  }

  @override
  Future<int> getPendingOfflineCount() async {
    return await _localDataSource.getPendingQueueCount();
  }
}

