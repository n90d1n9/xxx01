import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/legacy.dart';

import '../model/workflow_version.dart';
import '../schema/workflow/workflow.dart';
import 'version_controller_state.dart';

class VersionControlNotifier extends StateNotifier<VersionControlState> {
  final String workflowId;

  VersionControlNotifier(this.workflowId) : super(VersionControlState()) {
    _loadVersions();
  }

  Future<void> _loadVersions() async {
    // Load from persistent storage
    // This is a placeholder
    state = state.copyWith(versions: []);
  }

  Future<void> commit(Workflow workflow, String message, String author) async {
    final version = WorkflowVersion(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      workflowId: workflowId,
      timestamp: DateTime.now(),
      author: author,
      message: message,
      snapshot: workflow,
      changes: _calculateChanges(workflow),
    );

    state = state.copyWith(
      versions: [...state.versions, version],
      currentVersion: version,
      hasUnsavedChanges: false,
    );

    await _saveVersion(version);
  }

  Future<void> _saveVersion(WorkflowVersion version) async {
    // Save to persistent storage
    final file = File('versions/${version.workflowId}/${version.id}.json');
    await file.parent.create(recursive: true);
    await file.writeAsString(json.encode(version.toJson()));
  }

  Map<String, dynamic> _calculateChanges(Workflow workflow) {
    if (state.currentVersion == null) {
      return {'type': 'initial', 'nodeCount': workflow.nodes.length};
    }

    final previous = state.currentVersion!.snapshot;
    final changes = <String, dynamic>{};

    // Calculate node changes
    final addedNodes = workflow.nodes
        .where((n) => !previous.nodes.any((pn) => pn.id == n.id))
        .length;
    final removedNodes = previous.nodes
        .where((n) => !workflow.nodes.any((wn) => wn.id == n.id))
        .length;
    final modifiedNodes = workflow.nodes
        .where(
          (n) => previous.nodes.any((pn) => pn.id == n.id && pn.name != n.name),
        )
        .length;

    changes['nodes'] = {
      'added': addedNodes,
      'removed': removedNodes,
      'modified': modifiedNodes,
    };

    // Calculate edge changes
    final addedEdges = (workflow.edges ?? [])
        .where((e) => !(previous.edges ?? []).any((pe) => pe.id == e.id))
        .length;
    final removedEdges = (previous.edges ?? [])
        .where((e) => !(workflow.edges ?? []).any((we) => we.id == e.id))
        .length;

    changes['edges'] = {'added': addedEdges, 'removed': removedEdges};

    return changes;
  }

  Future<Workflow> checkout(String versionId) async {
    final version = state.versions.firstWhere((v) => v.id == versionId);
    state = state.copyWith(currentVersion: version);
    return version.snapshot;
  }

  Future<List<WorkflowVersion>> getHistory() async {
    return state.versions;
  }

  Future<Map<String, dynamic>> diff(
    String versionId1,
    String versionId2,
  ) async {
    final v1 = state.versions.firstWhere((v) => v.id == versionId1);
    final v2 = state.versions.firstWhere((v) => v.id == versionId2);

    return _calculateDiff(v1.snapshot, v2.snapshot);
  }

  Map<String, dynamic> _calculateDiff(Workflow w1, Workflow w2) {
    return {
      'nodeChanges': {
        'added': w2.nodes
            .where((n) => !w1.nodes.any((n1) => n1.id == n.id))
            .length,
        'removed': w1.nodes
            .where((n) => !w2.nodes.any((n2) => n2.id == n.id))
            .length,
      },
      'edgeChanges': {
        'added': (w2.edges ?? [])
            .where((e) => !(w1.edges ?? []).any((e1) => e1.id == e.id))
            .length,
        'removed': (w1.edges ?? [])
            .where((e) => !(w2.edges ?? []).any((e2) => e2.id == e.id))
            .length,
      },
    };
  }

  void markDirty() {
    state = state.copyWith(hasUnsavedChanges: true);
  }
}
