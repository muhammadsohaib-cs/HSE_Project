import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'hive_boxes.dart';

class SyncQueueItem {
  final String id;
  final String actionType; // 'CREATE_HAZARD', 'UPDATE_CAPA', 'SUBMIT_CHECKLIST'
  final Map<String, dynamic> payload;
  final DateTime queuedAt;
  final int retryCount;

  SyncQueueItem({
    required this.id,
    required this.actionType,
    required this.payload,
    required this.queuedAt,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'actionType': actionType,
    'payload': payload,
    'queuedAt': queuedAt.toIso8601String(),
    'retryCount': retryCount,
  };

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) => SyncQueueItem(
    id: json['id'] as String,
    actionType: json['actionType'] as String,
    payload: Map<String, dynamic>.from(json['payload'] as Map),
    queuedAt: DateTime.parse(json['queuedAt'] as String),
    retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
  );
}

class OfflineSyncQueue {
  final Box _queueBox;

  OfflineSyncQueue({Box? queueBox})
      : _queueBox = queueBox ?? Hive.box(HiveBoxes.offlineSyncQueueBox);

  /// Enqueue an action when network is unreachable
  Future<void> enqueue({
    required String id,
    required String actionType,
    required Map<String, dynamic> payload,
  }) async {
    final item = SyncQueueItem(
      id: id,
      actionType: actionType,
      payload: payload,
      queuedAt: DateTime.now(),
    );
    await _queueBox.put(id, jsonEncode(item.toJson()));
    debugPrint('Offline item enqueued: $id ($actionType). Queue size: ${_queueBox.length}');
  }

  /// Returns all queued items sorted by queuedAt
  List<SyncQueueItem> getQueuedItems() {
    final items = <SyncQueueItem>[];
    for (var key in _queueBox.keys) {
      final raw = _queueBox.get(key);
      if (raw != null) {
        try {
          final decoded = jsonDecode(raw as String);
          items.add(SyncQueueItem.fromJson(decoded));
        } catch (e) {
          debugPrint('Failed to decode sync queue item $key: $e');
        }
      }
    }
    items.sort((a, b) => a.queuedAt.compareTo(b.queuedAt));
    return items;
  }

  /// Remove item after successful sync
  Future<void> markSynced(String id) async {
    await _queueBox.delete(id);
    debugPrint('Offline item synced and cleared: $id');
  }

  /// Count of items pending sync
  int get pendingCount => _queueBox.length;

  /// Clear all
  Future<void> clear() async => await _queueBox.clear();
}

