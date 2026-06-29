import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../schema/common/position.dart';
import '../schema/model/model_factory.dart';
import '../schema/node/node_template.dart';
import '../schema/workflow/workflow_node.dart';

class NodeTemplateNotifier extends StateNotifier<List<NodeTemplate>> {
  NodeTemplateNotifier() : super([]) {
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    // Load from storage
    state = [];
  }

  void addTemplate(NodeTemplate template) {
    state = [...state, template];
    _saveTemplates();
  }

  void removeTemplate(String id) {
    state = state.where((t) => t.id != id).toList();
    _saveTemplates();
  }

  Future<void> _saveTemplates() async {
    // Save to storage
  }

  WorkflowNode createNodeFromTemplate(NodeTemplate template, Offset position) {
    return ModelFactory.createNode(
      type: template.type,
      name: template.name,
      position: Position(x: position.dx, y: position.dy),
      description: template.description,
    );
  }
}

final nodeTemplateProvider =
    StateNotifierProvider<NodeTemplateNotifier, List<NodeTemplate>>(
      (ref) => NodeTemplateNotifier(),
    );
