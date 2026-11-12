import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../../../../core/storage/hive_boxes.dart';
import '../../../../core/storage/offline_sync_queue.dart';
import '../models/hazard_model.dart';

abstract class HazardLocalDataSource {
  Future<void> cacheHazards(List<HazardModel> hazards);
  Future<void> cacheSingleHazard(HazardModel hazard);
  Future<List<HazardModel>> getCachedHazards();
  Future<HazardModel?> getCachedHazardById(String id);
  Future<void> enqueueOfflineHazard(HazardModel hazard);
  Future<List<SyncQueueItem>> getOfflineQueueItems();
  Future<void> removeOfflineItem(String id);
  Future<int> getPendingQueueCount();
}

class HazardLocalDataSourceImpl implements HazardLocalDataSource {
  final Box _hazardsBox;
  final OfflineSyncQueue _syncQueue;

  HazardLocalDataSourceImpl({
    Box? hazardsBox,
    OfflineSyncQueue? syncQueue,
  })  : _hazardsBox = hazardsBox ?? Hive.box(HiveBoxes.hazardsBox),
        _syncQueue = syncQueue ?? OfflineSyncQueue();

  @override
  Future<void> cacheHazards(List<HazardModel> hazards) async {
    for (var h in hazards) {
      await _hazardsBox.put(h.id, jsonEncode(h.toJson()));
    }
  }

  @override
  Future<void> cacheSingleHazard(HazardModel hazard) async {
    await _hazardsBox.put(hazard.id, jsonEncode(hazard.toJson()));
  }

  @override
  Future<List<HazardModel>> getCachedHazards() async {
    final list = <HazardModel>[];
    for (var key in _hazardsBox.keys) {
      final val = _hazardsBox.get(key);
      if (val != null) {
        try {
          final decoded = jsonDecode(val as String) as Map<String, dynamic>;
          list.add(HazardModel.fromJson(decoded));
        } catch (e) {
          debugPrint('Error decoding cached hazard: $e');
        }
      }
    }
    // Sort descending by created_at
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<HazardModel?> getCachedHazardById(String id) async {
    final val = _hazardsBox.get(id);
    if (val == null) return null;
    try {
      final decoded = jsonDecode(val as String) as Map<String, dynamic>;
      return HazardModel.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> enqueueOfflineHazard(HazardModel hazard) async {
    // Cache locally marked as buffered
    final buffered = HazardModel.fromEntity(hazard.copyWith(isOfflineBuffered: true));
    await cacheSingleHazard(buffered);

    // Queue for sync
    await _syncQueue.enqueue(
      id: hazard.id,
      actionType: 'CREATE_HAZARD',
      payload: hazard.toJson(),
    );
  }

  @override
  Future<List<SyncQueueItem>> getOfflineQueueItems() async {
    return _syncQueue.getQueuedItems();
  }

  @override
  Future<void> removeOfflineItem(String id) async {
    await _syncQueue.markSynced(id);
  }

  @override
  Future<int> getPendingQueueCount() async {
    return _syncQueue.pendingCount;
  }
}

