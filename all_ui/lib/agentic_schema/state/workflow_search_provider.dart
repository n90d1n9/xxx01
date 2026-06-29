import 'package:flutter_riverpod/legacy.dart';

import '../model/workflow_search_result.dart';
import '../schema/workflow/workflow.dart';
import '../schema/workflow/workflow_node.dart';

class WorkflowSearchNotifier extends StateNotifier<WorkflowSearchState> {
  WorkflowSearchNotifier() : super(WorkflowSearchState());

  Future<void> search(String query, List<Workflow> allWorkflows) async {
    if (query.trim().isEmpty) {
      state = WorkflowSearchState();
      return;
    }

    state = state.copyWith(isSearching: true, query: query);

    await Future.delayed(const Duration(milliseconds: 300));

    final results = <WorkflowSearchResult>[];
    final q = query.toLowerCase();

    for (final workflow in allWorkflows) {
      final matchingNodes = <WorkflowNode>[];
      double relevance = 0.0;

      // Search in workflow name
      if (workflow.name.toLowerCase().contains(q)) {
        relevance += 10.0;
      }

      // Search in workflow description
      if (workflow.description?.toLowerCase().contains(q) ?? false) {
        relevance += 5.0;
      }

      // Search in nodes
      for (final node in workflow.nodes) {
        if (node.name.toLowerCase().contains(q)) {
          matchingNodes.add(node);
          relevance += 3.0;
        }
        if (node.description?.toLowerCase().contains(q) ?? false) {
          matchingNodes.add(node);
          relevance += 2.0;
        }
      }

      if (relevance > 0) {
        results.add(
          WorkflowSearchResult(
            workflow: workflow,
            matchingNodes: matchingNodes,
            relevance: relevance,
          ),
        );
      }
    }

    // Sort by relevance
    results.sort((a, b) => b.relevance.compareTo(a.relevance));

    state = state.copyWith(results: results, isSearching: false);
  }
}

final workflowSearchProvider =
    StateNotifierProvider<WorkflowSearchNotifier, WorkflowSearchState>(
      (ref) => WorkflowSearchNotifier(),
    );

class WorkflowSearchState {
  final String query;
  final List<WorkflowSearchResult> results;
  final bool isSearching;

  WorkflowSearchState({
    this.query = '',
    this.results = const [],
    this.isSearching = false,
  });

  WorkflowSearchState copyWith({
    String? query,
    List<WorkflowSearchResult>? results,
    bool? isSearching,
  }) {
    return WorkflowSearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}
