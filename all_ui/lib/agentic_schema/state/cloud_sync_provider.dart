import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';

import '../schema/workflow/workflow.dart';
import '../service/cloud_storage_service.dart';

final cloudSyncProvider =
    StateNotifierProvider<CloudSyncNotifier, CloudSyncState>((ref) {
      final service = CloudStorageService(
        apiBaseUrl: 'https://api.aiagent.com',
        apiKey: 'your-api-key',
      );
      return CloudSyncNotifier(service);
    });

class CloudSyncNotifier extends StateNotifier<CloudSyncState> {
  final CloudStorageService _service;
  Timer? _autoSyncTimer;

  CloudSyncNotifier(this._service) : super(CloudSyncState()) {
    _startAutoSync();
  }

  void _startAutoSync() {
    _autoSyncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => autoSync(),
    );
  }

  Future<void> saveToCloud(Workflow workflow) async {
    state = state.copyWith(isSyncing: true, error: null);

    try {
      await _service.saveWorkflow(workflow);
      state = state.copyWith(
        isSyncing: false,
        isSynced: true,
        lastSyncTime: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(isSyncing: false, error: e.toString());
    }
  }

  Future<Workflow?> loadFromCloud(String workflowId) async {
    state = state.copyWith(isSyncing: true, error: null);

    try {
      final workflow = await _service.loadWorkflow(workflowId);
      state = state.copyWith(isSyncing: false, isSynced: true);
      return workflow;
    } catch (e) {
      state = state.copyWith(isSyncing: false, error: e.toString());
      return null;
    }
  }

  Future<void> listCloudWorkflows() async {
    try {
      final workflows = await _service.listWorkflows();
      state = state.copyWith(cloudWorkflows: workflows);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> autoSync() async {
    // Auto-sync logic would check for changes and sync
  }

  void markDirty() {
    state = state.copyWith(isSynced: false);
  }

  @override
  void dispose() {
    _autoSyncTimer?.cancel();
    super.dispose();
  }
}

class CloudSyncState {
  final bool isSyncing;
  final bool isSynced;
  final DateTime? lastSyncTime;
  final String? error;
  final List<Map<String, dynamic>> cloudWorkflows;

  CloudSyncState({
    this.isSyncing = false,
    this.isSynced = false,
    this.lastSyncTime,
    this.error,
    this.cloudWorkflows = const [],
  });

  CloudSyncState copyWith({
    bool? isSyncing,
    bool? isSynced,
    DateTime? lastSyncTime,
    String? error,
    List<Map<String, dynamic>>? cloudWorkflows,
  }) {
    return CloudSyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      isSynced: isSynced ?? this.isSynced,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      error: error ?? this.error,
      cloudWorkflows: cloudWorkflows ?? this.cloudWorkflows,
    );
  }
}
