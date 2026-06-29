import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter_riverpod/legacy.dart';

import '../model/field_config.dart';
import 'form_field_provider.dart';

final autoSaveManagerProvider =
    StateNotifierProvider<AutoSaveManager, AutoSaveState>((ref) {
      final manager = AutoSaveManager();

      // Start auto-save with 30 second interval
      manager.startAutoSave(const Duration(seconds: 30), () {
        final fields = ref.read(formFieldsProvider);
        StorageManager.saveAutoSave(fields);
      });

      return manager;
    });

class AutoSaveManager extends StateNotifier<AutoSaveState> {
  AutoSaveManager() : super(AutoSaveState());
  Timer? _autoSaveTimer;

  void startAutoSave(Duration interval, VoidCallback onSave) {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(interval, (_) {
      onSave();
      state = state.copyWith(
        lastSaved: DateTime.now(),
        isSaving: false,
        hasUnsavedChanges: false,
      );
    });
  }

  void stopAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
  }

  void markDirty() {
    state = state.copyWith(hasUnsavedChanges: true);
  }

  void markSaving() {
    state = state.copyWith(isSaving: true);
  }

  void markSaved() {
    state = state.copyWith(
      lastSaved: DateTime.now(),
      isSaving: false,
      hasUnsavedChanges: false,
    );
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }
}

class AutoSaveState {
  final DateTime? lastSaved;
  final bool isSaving;
  final bool hasUnsavedChanges;
  final bool isEnabled;

  AutoSaveState({
    this.lastSaved,
    this.isSaving = false,
    this.hasUnsavedChanges = false,
    this.isEnabled = true,
  });

  AutoSaveState copyWith({
    DateTime? lastSaved,
    bool? isSaving,
    bool? hasUnsavedChanges,
    bool? isEnabled,
  }) {
    return AutoSaveState(
      lastSaved: lastSaved ?? this.lastSaved,
      isSaving: isSaving ?? this.isSaving,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  String get saveStatus {
    if (isSaving) return 'Saving...';
    if (hasUnsavedChanges) return 'Unsaved changes';
    if (lastSaved != null) {
      final diff = DateTime.now().difference(lastSaved!);
      if (diff.inSeconds < 60) return 'Saved ${diff.inSeconds}s ago';
      if (diff.inMinutes < 60) return 'Saved ${diff.inMinutes}m ago';
      return 'Saved ${diff.inHours}h ago';
    }
    return 'Not saved';
  }
}

// Storage Manager (simulated - in real app would use shared_preferences or similar)
class StorageManager {
  static const String _formDataKey = 'form_builder_data';
  static const String _autoSaveKey = 'form_builder_autosave';
  static const int _maxVersions = 10;

  // Simulated storage
  static final Map<String, String> _storage = {};

  static Future<void> save(String key, String data) async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate async
    _storage[key] = data;
  }

  static Future<String?> load(String key) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _storage[key];
  }

  static Future<void> saveFormData(List<FieldConfig> fields) async {
    final data = {
      'fields': fields.map((f) => f.toJson()).toList(),
      'timestamp': DateTime.now().toIso8601String(),
      'version': 1,
    };
    await save(_formDataKey, jsonEncode(data));
  }

  static Future<void> saveAutoSave(List<FieldConfig> fields) async {
    final data = {
      'fields': fields.map((f) => f.toJson()).toList(),
      'timestamp': DateTime.now().toIso8601String(),
    };
    await save(_autoSaveKey, jsonEncode(data));

    // Save to versions list
    await _saveVersion(fields);
  }

  static Future<void> _saveVersion(List<FieldConfig> fields) async {
    final versionsData = await load('versions');
    List<Map<String, dynamic>> versions = [];

    if (versionsData != null) {
      final decoded = jsonDecode(versionsData) as List;
      versions = decoded.cast<Map<String, dynamic>>();
    }

    versions.insert(0, {
      'fields': fields.map((f) => f.toJson()).toList(),
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Keep only last N versions
    if (versions.length > _maxVersions) {
      versions = versions.sublist(0, _maxVersions);
    }

    await save('versions', jsonEncode(versions));
  }

  static Future<Map<String, dynamic>?> loadAutoSave() async {
    final data = await load(_autoSaveKey);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>> loadVersions() async {
    final data = await load('versions');
    if (data != null) {
      final decoded = jsonDecode(data) as List;
      return decoded.cast<Map<String, dynamic>>();
    }
    return [];
  }

  static Future<void> clearAutoSave() async {
    _storage.remove(_autoSaveKey);
  }
}
