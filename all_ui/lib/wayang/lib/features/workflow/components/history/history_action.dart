import 'package:flutter/widgets.dart';

import '../../model/workflow_connection.dart';
import '../../model/workflow_node.dart';
import '../../state/workflow_state.dart';

enum HistoryActionType {
  addNode,
  deleteNode,
  updateNodePosition,
  updateNodeConfig,
  updateNodeLabel,
  addConnection,
  deleteConnection,
  updateWorkflowName,
  clearWorkflow,
  importWorkflow,
}

abstract class HistoryAction {
  final HistoryActionType type;
  final Map<String, dynamic> data;
  final Object? previousData;

  HistoryAction._({required this.type, required this.data, this.previousData});

  WorkflowState apply(WorkflowState state);
  WorkflowState undo(WorkflowState state);
  WorkflowState redo(WorkflowState state) => apply(state);

  Map<String, dynamic> toJson() => {
    'type': type.index,
    'data': data,
    'previousData': previousData,
  };

  factory HistoryAction.fromJson(Map<String, dynamic> json) {
    final type = HistoryActionType.values[json['type'] as int];
    final data = json['data'] as Map<String, dynamic>;
    final prev = json['previousData'];

    switch (type) {
      case HistoryActionType.addNode:
        return AddNodeAction(WorkflowNode.fromJson(data));
      case HistoryActionType.deleteNode:
        return DeleteNodeAction(
          data['id'] as String,
          WorkflowNode.fromJson(prev as Map<String, dynamic>),
        );
      case HistoryActionType.updateNodePosition:
        return UpdateNodePositionAction._fromJson(
          data,
          prev as Map<String, dynamic>,
        );
      case HistoryActionType.updateNodeConfig:
        return UpdateNodeConfigAction._fromJson(data, prev);
      case HistoryActionType.updateNodeLabel:
        return UpdateNodeLabelAction._fromJson(data, prev);
      case HistoryActionType.addConnection:
        return AddConnectionAction(WorkflowConnection.fromJson(data));
      case HistoryActionType.deleteConnection:
        return DeleteConnectionAction(
          data['id'] as String,
          WorkflowConnection.fromJson(prev as Map<String, dynamic>),
        );
      case HistoryActionType.updateWorkflowName:
        return UpdateWorkflowNameAction._fromJson(data, prev);
      case HistoryActionType.clearWorkflow:
        return ClearWorkflowAction(prev as Map<String, dynamic>);
      case HistoryActionType.importWorkflow:
        return ImportWorkflowAction(
          importedData: data,
          previousState: prev as Map<String, dynamic>,
        );
      default:
        throw UnimplementedError(
          'HistoryActionType.$type is not supported in fromJson',
        );
    }
  }
}

class AddNodeAction extends HistoryAction {
  final WorkflowNode node;
  AddNodeAction(this.node)
    : super._(type: HistoryActionType.addNode, data: node.toJson());

  @override
  WorkflowState apply(WorkflowState state) =>
      state.copyWith(nodes: [...state.nodes, node]);

  @override
  WorkflowState undo(WorkflowState state) =>
      state.copyWith(nodes: state.nodes.where((n) => n.id != node.id).toList());
}

class DeleteNodeAction extends HistoryAction {
  final String nodeId;
  final WorkflowNode node;
  DeleteNodeAction(this.nodeId, this.node)
    : super._(
        type: HistoryActionType.deleteNode,
        data: {'id': nodeId},
        previousData: node.toJson(),
      );

  @override
  WorkflowState apply(WorkflowState state) =>
      state.copyWith(nodes: state.nodes.where((n) => n.id != nodeId).toList());

  @override
  WorkflowState undo(WorkflowState state) =>
      state.copyWith(nodes: [...state.nodes, node]);
}

class UpdateNodePositionAction extends HistoryAction {
  final String nodeId;
  final Offset newPosition;
  final Offset previousPosition;

  UpdateNodePositionAction(this.nodeId, this.previousPosition, this.newPosition)
    : super._(
        type: HistoryActionType.updateNodePosition,
        data: {
          'nodeId': nodeId,
          'newPosition': {'dx': newPosition.dx, 'dy': newPosition.dy},
        },
        previousData: {'dx': previousPosition.dx, 'dy': previousPosition.dy},
      );

  UpdateNodePositionAction._fromJson(
    Map<String, dynamic> data,
    Map<String, dynamic> prev,
  ) : nodeId = data['nodeId'] as String,
      newPosition = Offset(
        (data['newPosition'] as Map<String, dynamic>)['dx'] as double,
        (data['newPosition'] as Map<String, dynamic>)['dy'] as double,
      ),
      previousPosition = Offset(prev['dx'] as double, prev['dy'] as double),
      super._(
        type: HistoryActionType.updateNodePosition,
        data: data,
        previousData: prev,
      );

  @override
  WorkflowState apply(WorkflowState state) {
    if (!state.nodes.any((n) => n.id == nodeId)) return state;
    return state.copyWith(
      nodes: state.nodes
          .map((n) => n.id == nodeId ? n.copyWith(position: newPosition) : n)
          .toList(),
    );
  }

  @override
  WorkflowState undo(WorkflowState state) {
    if (!state.nodes.any((n) => n.id == nodeId)) return state;
    return state.copyWith(
      nodes: state.nodes
          .map(
            (n) => n.id == nodeId ? n.copyWith(position: previousPosition) : n,
          )
          .toList(),
    );
  }
}

class UpdateNodeConfigAction extends HistoryAction {
  final String nodeId;
  final String key;
  final dynamic newValue;
  final dynamic previousValue;

  UpdateNodeConfigAction({
    required this.nodeId,
    required this.key,
    required this.newValue,
    required this.previousValue,
  }) : super._(
         type: HistoryActionType.updateNodeConfig,
         data: {'nodeId': nodeId, 'key': key, 'value': newValue},
         previousData: previousValue,
       );

  UpdateNodeConfigAction._fromJson(Map<String, dynamic> data, Object? prev)
    : nodeId = data['nodeId'] as String,
      key = data['key'] as String,
      newValue = data['value'],
      previousValue = prev,
      super._(
        type: HistoryActionType.updateNodeConfig,
        data: data,
        previousData: prev,
      );

  @override
  WorkflowState apply(WorkflowState state) {
    return state.copyWith(
      nodes: state.nodes.map((n) {
        if (n.id == nodeId) {
          final config = Map<String, dynamic>.from(n.config);
          config[key] = newValue;
          return n.copyWith(config: config);
        }
        return n;
      }).toList(),
    );
  }

  @override
  WorkflowState undo(WorkflowState state) {
    return state.copyWith(
      nodes: state.nodes.map((n) {
        if (n.id == nodeId) {
          final config = Map<String, dynamic>.from(n.config);
          config[key] = previousValue;
          return n.copyWith(config: config);
        }
        return n;
      }).toList(),
    );
  }
}

class UpdateNodeLabelAction extends HistoryAction {
  final String nodeId;
  final String newLabel;
  final String previousLabel;

  UpdateNodeLabelAction({
    required this.nodeId,
    required this.newLabel,
    required this.previousLabel,
  }) : super._(
         type: HistoryActionType.updateNodeLabel,
         data: {'nodeId': nodeId, 'label': newLabel},
         previousData: previousLabel,
       );

  UpdateNodeLabelAction._fromJson(Map<String, dynamic> data, Object? prev)
    : nodeId = data['nodeId'] as String,
      newLabel = data['label'] as String,
      previousLabel = prev as String,
      super._(
        type: HistoryActionType.updateNodeLabel,
        data: data,
        previousData: prev,
      );

  @override
  WorkflowState apply(WorkflowState state) {
    return state.copyWith(
      nodes: state.nodes
          .map((n) => n.id == nodeId ? n.copyWith(label: newLabel) : n)
          .toList(),
    );
  }

  @override
  WorkflowState undo(WorkflowState state) {
    return state.copyWith(
      nodes: state.nodes
          .map((n) => n.id == nodeId ? n.copyWith(label: previousLabel) : n)
          .toList(),
    );
  }
}

class AddConnectionAction extends HistoryAction {
  final WorkflowConnection connection;
  AddConnectionAction(this.connection)
    : super._(type: HistoryActionType.addConnection, data: connection.toJson());

  @override
  WorkflowState apply(WorkflowState state) =>
      state.copyWith(connections: [...state.connections, connection]);

  @override
  WorkflowState undo(WorkflowState state) => state.copyWith(
    connections: state.connections.where((c) => c.id != connection.id).toList(),
  );
}

class DeleteConnectionAction extends HistoryAction {
  final String connectionId;
  final WorkflowConnection connection;
  DeleteConnectionAction(this.connectionId, this.connection)
    : super._(
        type: HistoryActionType.deleteConnection,
        data: {'id': connectionId},
        previousData: connection.toJson(),
      );

  @override
  WorkflowState apply(WorkflowState state) => state.copyWith(
    connections: state.connections.where((c) => c.id != connectionId).toList(),
  );

  @override
  WorkflowState undo(WorkflowState state) =>
      state.copyWith(connections: [...state.connections, connection]);
}

class UpdateWorkflowNameAction extends HistoryAction {
  final String newName;
  final String previousName;

  UpdateWorkflowNameAction({required this.newName, required this.previousName})
    : super._(
        type: HistoryActionType.updateWorkflowName,
        data: {'name': newName},
        previousData: previousName,
      );

  UpdateWorkflowNameAction._fromJson(Map<String, dynamic> data, Object? prev)
    : newName = data['name'] as String,
      previousName = prev as String,
      super._(
        type: HistoryActionType.updateWorkflowName,
        data: data,
        previousData: prev,
      );

  @override
  WorkflowState apply(WorkflowState state) => state.copyWith(name: newName);

  @override
  WorkflowState undo(WorkflowState state) => state.copyWith(name: previousName);
}

class ClearWorkflowAction extends HistoryAction {
  final Map<String, dynamic> previousState;
  ClearWorkflowAction(this.previousState)
    : super._(
        type: HistoryActionType.clearWorkflow,
        data: {},
        previousData: previousState,
      );

  @override
  WorkflowState apply(WorkflowState state) =>
      WorkflowState(id: DateTime.now().millisecondsSinceEpoch.toString());

  @override
  WorkflowState undo(WorkflowState state) =>
      WorkflowState.fromJson(previousState);
}

class ImportWorkflowAction extends HistoryAction {
  final Map<String, dynamic> importedData;
  final Map<String, dynamic> previousState;
  ImportWorkflowAction({
    required this.importedData,
    required this.previousState,
  }) : super._(
         type: HistoryActionType.importWorkflow,
         data: importedData,
         previousData: previousState,
       );

  @override
  WorkflowState apply(WorkflowState state) =>
      WorkflowState.fromJson(importedData);

  @override
  WorkflowState undo(WorkflowState state) =>
      WorkflowState.fromJson(previousState);
}
