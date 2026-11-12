import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../../../../core/storage/hive_boxes.dart';
import '../models/checklist_model.dart';

abstract class ChecklistLocalDataSource {
  Future<void> cacheTemplates(List<ChecklistTemplateModel> templates);
  Future<List<ChecklistTemplateModel>> getCachedTemplates();
  Future<void> cacheAudits(List<ChecklistAuditModel> audits);
  Future<void> cacheSingleAudit(ChecklistAuditModel audit);
  Future<List<ChecklistAuditModel>> getCachedAudits();
}

class ChecklistLocalDataSourceImpl implements ChecklistLocalDataSource {
  final Box _checklistsBox;
  final Box _templatesBox;

  ChecklistLocalDataSourceImpl({Box? checklistsBox, Box? templatesBox})
      : _checklistsBox = checklistsBox ?? Hive.box(HiveBoxes.checklistsBox),
        _templatesBox = templatesBox ?? Hive.box(HiveBoxes.checklistTemplatesBox);

  @override
  Future<void> cacheTemplates(List<ChecklistTemplateModel> templates) async {
    for (var t in templates) {
      await _templatesBox.put(t.id, jsonEncode(t.toJson()));
    }
  }

  @override
  Future<List<ChecklistTemplateModel>> getCachedTemplates() async {
    final list = <ChecklistTemplateModel>[];
    for (var key in _templatesBox.keys) {
      final val = _templatesBox.get(key);
      if (val != null) {
        try {
          final decoded = jsonDecode(val as String) as Map<String, dynamic>;
          list.add(ChecklistTemplateModel.fromJson(decoded));
        } catch (_) {}
      }
    }
    return list;
  }

  @override
  Future<void> cacheAudits(List<ChecklistAuditModel> audits) async {
    for (var a in audits) {
      await _checklistsBox.put(a.id, jsonEncode(a.toJson()));
    }
  }

  @override
  Future<void> cacheSingleAudit(ChecklistAuditModel audit) async {
    await _checklistsBox.put(audit.id, jsonEncode(audit.toJson()));
  }

  @override
  Future<List<ChecklistAuditModel>> getCachedAudits() async {
    final list = <ChecklistAuditModel>[];
    for (var key in _checklistsBox.keys) {
      final val = _checklistsBox.get(key);
      if (val != null) {
        try {
          final decoded = jsonDecode(val as String) as Map<String, dynamic>;
          list.add(ChecklistAuditModel.fromJson(decoded));
        } catch (_) {}
      }
    }
    list.sort((a, b) => b.auditDate.compareTo(a.auditDate));
    return list;
  }
}

