// State Management
import 'dart:convert';

import 'package:flutter_riverpod/legacy.dart';

import '../model/cel_context.dart';
import '../model/expression_node.dart';
import '../model/expression_state.dart';
import '../model/expression_template.dart';
import '../model/history_entry.dart';

final expressionProvider =
    StateNotifierProvider<ExpressionNotifier, ExpressionState>(
      (ref) => ExpressionNotifier(),
    );

class ExpressionNotifier extends StateNotifier<ExpressionState> {
  ExpressionNotifier() : super(ExpressionState()) {
    _initializeDefaults();
  }

  void _initializeDefaults() {
    // Initialize with default context
    final context = CELContext(
      variables: {'user': Object, 'request': Object, 'resource': Object},
      availableFunctions: [
        'size',
        'contains',
        'startsWith',
        'endsWith',
        'matches',
        'filter',
        'map',
        'exists',
        'all',
        'has',
      ],
    );

    final templates = [
      ExpressionTemplate(
        name: 'Age Check',
        description: 'Check if user is 18 or older',
        celExpression: 'user.age >= 18',
        category: 'Common',
      ),
      ExpressionTemplate(
        name: 'Email Validation',
        description: 'Check if email is valid',
        celExpression:
            'user.email.matches("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+\$")',
        category: 'Validation',
      ),
      ExpressionTemplate(
        name: 'Permission Check',
        description: 'Check if user has admin role',
        celExpression: 'user.roles.exists(r, r == "admin")',
        category: 'Authorization',
      ),
    ];

    state = state.copyWith(context: context, templates: templates);
  }

  void setRootNode(ExpressionNode node) {
    _addToHistory();
    state = state.copyWith(rootNode: node, redoStack: []);
    _syncScriptFromVisual();
    _validate();
  }

  void updateScript(String script) {
    state = state.copyWith(script: script);
    _validate();
  }

  void toggleMode() {
    if (state.isVisualMode) {
      _syncScriptFromVisual();
    }
    state = state.copyWith(isVisualMode: !state.isVisualMode);
  }

  void _syncScriptFromVisual() {
    if (state.rootNode != null) {
      state = state.copyWith(script: state.rootNode!.toCEL());
    }
  }

  void _validate() {
    if (state.rootNode != null) {
      final result = state.rootNode!.validate(state.context);
      state = state.copyWith(validationResult: result);
    }
  }

  void _addToHistory() {
    final entry = HistoryEntry(
      node: state.rootNode,
      script: state.script,
      timestamp: DateTime.now(),
    );
    final newStack = [...state.undoStack, entry];
    // Limit history to 50 entries
    if (newStack.length > 50) {
      newStack.removeAt(0);
    }
    state = state.copyWith(undoStack: newStack);
  }

  void undo() {
    if (state.undoStack.isEmpty) return;

    final currentEntry = HistoryEntry(
      node: state.rootNode,
      script: state.script,
      timestamp: DateTime.now(),
    );

    final lastEntry = state.undoStack.last;
    final newUndoStack = state.undoStack.sublist(0, state.undoStack.length - 1);
    final newRedoStack = [...state.redoStack, currentEntry];

    state = state.copyWith(
      rootNode: lastEntry.node,
      script: lastEntry.script,
      undoStack: newUndoStack,
      redoStack: newRedoStack,
    );
    _validate();
  }

  void redo() {
    if (state.redoStack.isEmpty) return;

    final currentEntry = HistoryEntry(
      node: state.rootNode,
      script: state.script,
      timestamp: DateTime.now(),
    );

    final nextEntry = state.redoStack.last;
    final newRedoStack = state.redoStack.sublist(0, state.redoStack.length - 1);
    final newUndoStack = [...state.undoStack, currentEntry];

    state = state.copyWith(
      rootNode: nextEntry.node,
      script: nextEntry.script,
      undoStack: newUndoStack,
      redoStack: newRedoStack,
    );
    _validate();
  }

  void selectNode(String? nodeId) {
    state = state.copyWith(selectedNodeId: nodeId);
  }

  void addChildNode(String parentId, ExpressionNode child) {
    if (state.rootNode == null) return;

    _addToHistory();

    ExpressionNode addChild(ExpressionNode node) {
      if (node.id == parentId) {
        return node.copyWith(children: [...node.children, child]);
      }
      return node.copyWith(children: node.children.map(addChild).toList());
    }

    state = state.copyWith(rootNode: addChild(state.rootNode!), redoStack: []);
    _syncScriptFromVisual();
    _validate();
  }

  void updateNode(String nodeId, ExpressionNode updatedNode) {
    if (state.rootNode == null) return;

    _addToHistory();

    ExpressionNode update(ExpressionNode node) {
      if (node.id == nodeId) {
        return updatedNode.copyWith(children: node.children);
      }
      return node.copyWith(children: node.children.map(update).toList());
    }

    state = state.copyWith(rootNode: update(state.rootNode!), redoStack: []);
    _syncScriptFromVisual();
    _validate();
  }

  void deleteNode(String nodeId) {
    if (state.rootNode?.id == nodeId) {
      _addToHistory();
      state = state.copyWith(rootNode: null, script: '', redoStack: []);
      return;
    }

    _addToHistory();

    ExpressionNode? deleteChild(ExpressionNode node) {
      final newChildren = node.children
          .where((c) => c.id != nodeId)
          .map((c) => deleteChild(c))
          .whereType<ExpressionNode>()
          .toList();

      return node.copyWith(children: newChildren);
    }

    if (state.rootNode != null) {
      state = state.copyWith(
        rootNode: deleteChild(state.rootNode!),
        redoStack: [],
      );
      _syncScriptFromVisual();
      _validate();
    }
  }

  void loadFromTemplate(ExpressionTemplate template) {
    _addToHistory();
    state = state.copyWith(script: template.celExpression, redoStack: []);
  }

  void exportToJson() {
    if (state.rootNode == null) return;
    final json = jsonEncode(state.rootNode!.toJson());
    // In real app, save to file or clipboard
    print('Export: $json');
  }

  void importFromJson(String jsonString) {
    try {
      _addToHistory();
      final json = jsonDecode(jsonString);
      final node = ExpressionNode.fromJson(json);
      state = state.copyWith(rootNode: node, redoStack: []);
      _syncScriptFromVisual();
      _validate();
    } catch (e) {
      print('Import error: $e');
    }
  }

  void updateContext(CELContext newContext) {
    state = state.copyWith(context: newContext);
    _validate();
  }
}
