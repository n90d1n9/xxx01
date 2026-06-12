import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/legacy.dart';
import 'package:path_provider/path_provider.dart';
import '../models/task_model.dart';
import '../providers/gantt_providers.dart';

/// Full offline persistence for tasks, snapshots, and custom field defs.
/// Uses JSON files in the app documents directory — no codegen, no Hive package.
/// Design mirrors Hive's openBox<T> pattern but is pure Dart.
///
/// File layout:
///   <documents>/gantt_data/
///     tasks.json          — List<Task>
///     snapshots.json      — List<ProjectSnapshot>
///     custom_fields.json  — List<CustomFieldDef>
///     settings.json       — GanttViewSettings + GanttFilter  (already handled by PersistentSettings)

const _kDir = 'gantt_data';

class HivePersistenceService {
  // ─── Singleton ─────────────────────────────────────────────────────────────
  HivePersistenceService._();
  static final instance = HivePersistenceService._();

  // ─── Directory helper ──────────────────────────────────────────────────────
  static Future<Directory> _dir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/$_kDir');
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }

  static Future<File> _file(String name) async {
    final d = await _dir();
    return File('${d.path}/$name');
  }

  // ─── Tasks ─────────────────────────────────────────────────────────────────
  Future<List<Task>> loadTasks() async {
    try {
      final f = await _file('tasks.json');
      if (!f.existsSync()) return [];
      final raw = await f.readAsString();
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return list.map(Task.fromJson).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveTasks(List<Task> tasks) async {
    try {
      final f = await _file('tasks.json');
      await f.writeAsString(jsonEncode(tasks.map((t) => t.toJson()).toList()));
    } catch (_) {}
  }

  // ─── Snapshots ─────────────────────────────────────────────────────────────
  Future<List<ProjectSnapshot>> loadSnapshots() async {
    try {
      final f = await _file('snapshots.json');
      if (!f.existsSync()) return [];
      final list = (jsonDecode(await f.readAsString()) as List)
          .cast<Map<String, dynamic>>();
      return list.map(ProjectSnapshot.fromJson).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSnapshots(List<ProjectSnapshot> snaps) async {
    try {
      final f = await _file('snapshots.json');
      await f.writeAsString(jsonEncode(snaps.map((s) => s.toJson()).toList()));
    } catch (_) {}
  }

  // ─── Custom field defs ─────────────────────────────────────────────────────
  Future<List<CustomFieldDef>> loadCustomFieldDefs() async {
    try {
      final f = await _file('custom_fields.json');
      if (!f.existsSync()) return [];
      final list = (jsonDecode(await f.readAsString()) as List)
          .cast<Map<String, dynamic>>();
      return list.map(CustomFieldDef.fromJson).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCustomFieldDefs(List<CustomFieldDef> defs) async {
    try {
      final f = await _file('custom_fields.json');
      await f.writeAsString(jsonEncode(defs.map((d) => d.toJson()).toList()));
    } catch (_) {}
  }

  // ─── Import JSON (full project restore) ───────────────────────────────────
  /// Returns a list of tasks parsed from an exported JSON string.
  /// Compatible with GanttExporter.exportJson output.
  static List<Task> importFromJson(String json) {
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      final rawTasks =
          (map['tasks'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      return rawTasks.map(Task.fromJson).toList();
    } catch (_) {
      return [];
    }
  }

  // ─── Export stats ──────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> storageStats() async {
    final d = await _dir();
    final result = <String, dynamic>{};
    for (final f in d.listSync().whereType<File>()) {
      result[f.uri.pathSegments.last] =
          '${(f.lengthSync() / 1024).toStringAsFixed(1)} KB';
    }
    return result;
  }

  Future<void> clearAll() async {
    final d = await _dir();
    for (final f in d.listSync().whereType<File>()) {
      await f.delete();
    }
  }
}

// ─── Riverpod observer: auto-save on every task/snapshot/field mutation ────────

class DataPersistenceObserver extends ProviderObserver {
  static DateTime? _lastTaskSave;
  static DateTime? _lastSnapSave;
  static DateTime? _lastFieldSave;

  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    final now = DateTime.now();

    if (provider == tasksProvider && newValue is List<Task>) {
      if (_lastTaskSave == null ||
          now.difference(_lastTaskSave!) > const Duration(milliseconds: 600)) {
        _lastTaskSave = now;
        Future.microtask(
            () => HivePersistenceService.instance.saveTasks(newValue));
      }
    }

    if (provider == snapshotsProvider && newValue is List<ProjectSnapshot>) {
      if (_lastSnapSave == null ||
          now.difference(_lastSnapSave!) > const Duration(milliseconds: 300)) {
        _lastSnapSave = now;
        Future.microtask(
            () => HivePersistenceService.instance.saveSnapshots(newValue));
      }
    }

    if (provider == customFieldDefsProvider &&
        newValue is List<CustomFieldDef>) {
      if (_lastFieldSave == null ||
          now.difference(_lastFieldSave!) > const Duration(milliseconds: 300)) {
        _lastFieldSave = now;
        Future.microtask(() =>
            HivePersistenceService.instance.saveCustomFieldDefs(newValue));
      }
    }
  }
}
