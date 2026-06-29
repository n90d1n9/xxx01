import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/node_card.dart';
import '../../models/node.dart';
import '../../models/canvas_transform.dart';
import '../../models/node_group.dart';
import '../../states/canvas_transform_provider.dart';
import '../../states/node_group_provider.dart';
import '../../states/node_route_provider.dart';
import '../../states/provider.dart';
import '../../states/select_route_provider.dart';
import 'canvas_controller.dart';

class CanvasGestureHandler extends ConsumerWidget {
  final CanvasController controller;
  final Widget child;

  const CanvasGestureHandler({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transform = ref.watch(canvasTransformProvider);
    final route = ref.watch(selectedRouteProvider);
    final groups = ref.watch(nodeGroupsProvider);
    final selectedGroupId = ref.watch(selectedGroupIdProvider);

    return Focus(
      onKeyEvent: (node, event) => _handleKeyEvent(event, ref),
      child: GestureDetector(
        onScaleStart:
            (details) =>
                _handleScaleStart(details, transform, route, groups, ref),
        onScaleUpdate:
            (details) => _handleScaleUpdate(
              details,
              transform,
              selectedGroupId,
              route,
              ref,
            ),
        onScaleEnd: (details) => _handleScaleEnd(ref),
        onTap: () => _handleTap(ref),
        onDoubleTap: () => _handleDoubleTap(transform, groups, ref),
        behavior: HitTestBehavior.opaque,
        child: Listener(
          onPointerSignal: (event) => _handlePointerSignal(event, ref),
          child: child,
        ),
      ),
    );
  }

  KeyEventResult _handleKeyEvent(KeyEvent event, WidgetRef ref) {
    // Use HardwareKeyboard to check modifier keys
    final isControlPressed = HardwareKeyboard.instance.isControlPressed;
    final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;

    controller.updateModifierKeys(isControlPressed, isShiftPressed);

    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        _handleEscape(ref);
        return KeyEventResult.handled;
      } else if (isControlPressed &&
          event.logicalKey == LogicalKeyboardKey.keyA) {
        _handleSelectAll(ref);
        return KeyEventResult.handled;
      } else if (isControlPressed &&
          event.logicalKey == LogicalKeyboardKey.keyG) {
        _handleSelectGroup(ref);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _handleScaleStart(
    ScaleStartDetails details,
    CanvasTransform transform,
    WNode? route,
    List<NodeGroup> groups,
    WidgetRef ref,
  ) {
    controller.updateScaleState(1.0, details.localFocalPoint);
    controller.updatePanState(details.localFocalPoint);

    final canvasPos = _screenToCanvas(details.localFocalPoint, transform);

    if (route != null) {
      final clickedGroup = _getGroupAtPosition(canvasPos, groups, route.nodes);
      if (clickedGroup != null) {
        _handleGroupInteraction(clickedGroup, canvasPos, ref);
      } else if (controller.isShiftPressed) {
        controller.startSelection(canvasPos);
      } else {
        final clickedNode = _getNodeAtPosition(canvasPos, route.nodes);
        if (clickedNode != null && clickedNode.groupId != null) {
          _handleGroupNodeClick(clickedNode, ref);
        }
      }
    }
  }

  void _handleScaleUpdate(
    ScaleUpdateDetails details,
    CanvasTransform transform,
    String? selectedGroupId,
    WNode? route,
    WidgetRef ref,
  ) {
    if (controller.isGroupDragging &&
        selectedGroupId != null &&
        route != null) {
      _handleGroupDrag(details, transform, selectedGroupId, route, ref);
    } else if (controller.isSelecting) {
      controller.updateSelection(
        _screenToCanvas(details.localFocalPoint, transform),
      );
    } else if (details.scale != 1.0) {
      _handleZoom(details, ref);
    } else {
      _handlePan(details, ref);
    }
  }

  void _handleScaleEnd(WidgetRef ref) {
    if (controller.isGroupDragging) {
      controller.endGroupDrag();
    } else if (controller.isSelecting &&
        controller.selectionStart != null &&
        controller.selectionEnd != null) {
      _selectNodesInRectangle(ref);
    }
    controller.endSelection();
  }

  void _handleTap(WidgetRef ref) {
    if (!controller.isSelecting && !controller.isGroupDragging) {
      if (!controller.isCtrlPressed && !controller.isShiftPressed) {
        ref.read(selectedNodeIdProvider.notifier).state = null;
        ref.read(selectedNodesProvider.notifier).state = {};
        ref.read(selectedGroupIdProvider.notifier).state = null;
      }
    }
  }

  void _handleDoubleTap(
    CanvasTransform transform,
    List<NodeGroup> groups,
    WidgetRef ref,
  ) {
    final canvasPos = _screenToCanvas(controller.currentFocalPoint, transform);
    final clickedGroup = _getGroupAtPosition(
      canvasPos,
      groups,
      ref.read(selectedRouteProvider)?.nodes ?? [],
    );
    if (clickedGroup != null) {
      ref.read(routesProvider.notifier).selectGroup(clickedGroup.id);
    }
  }

  void _handlePointerSignal(PointerSignalEvent event, WidgetRef ref) {
    if (event is PointerScrollEvent) {
      final delta = event.scrollDelta.dy > 0 ? -0.05 : 0.05;
      ref
          .read(canvasTransformProvider.notifier)
          .zoom(delta, event.localPosition);
    }
  }

  void _handleEscape(WidgetRef ref) {
    ref.read(selectedNodeIdProvider.notifier).state = null;
    ref.read(selectedNodesProvider.notifier).state = {};
    ref.read(selectedGroupIdProvider.notifier).state = null;
  }

  void _handleSelectAll(WidgetRef ref) {
    final route = ref.read(selectedRouteProvider);
    final selectedGroupId = ref.read(selectedGroupIdProvider);
    final groups = ref.read(nodeGroupsProvider);

    if (route != null) {
      if (selectedGroupId != null) {
        final group = groups.firstWhere((g) => g.id == selectedGroupId);
        ref.read(selectedNodesProvider.notifier).state = group.nodeIds.toSet();
      } else {
        ref.read(selectedNodesProvider.notifier).state =
            route.nodes.map((n) => n.id).toSet();
      }
    }
  }

  void _handleSelectGroup(WidgetRef ref) {
    final selectedNodeIds = ref.read(selectedNodesProvider);
    final route = ref.read(selectedRouteProvider);

    if (selectedNodeIds.isNotEmpty && route != null) {
      final firstSelectedNode = route.nodes.firstWhere(
        (n) => selectedNodeIds.contains(n.id),
        orElse: () => route.nodes.first,
      );

      if (firstSelectedNode.groupId != null) {
        ref
            .read(routesProvider.notifier)
            .selectGroup(firstSelectedNode.groupId!);
      }
    }
  }

  void _handleGroupInteraction(
    NodeGroup group,
    Offset canvasPos,
    WidgetRef ref,
  ) {
    controller.startGroupDrag(canvasPos);

    if (controller.isCtrlPressed || controller.isShiftPressed) {
      _addGroupToSelection(group, ref);
    } else {
      ref.read(routesProvider.notifier).selectGroup(group.id);
    }
  }

  void _handleGroupDrag(
    ScaleUpdateDetails details,
    CanvasTransform transform,
    String selectedGroupId,
    WNode route,
    WidgetRef ref,
  ) {
    final currentCanvasPos = _screenToCanvas(
      details.localFocalPoint,
      transform,
    );
    final delta =
        (currentCanvasPos - controller.groupDragStart!) / transform.scale;

    if (delta.distance > 1.0) {
      ref
          .read(routesProvider.notifier)
          .moveGroup(route.id, selectedGroupId, delta);
      controller.updateGroupDrag(currentCanvasPos);
    }
  }

  void _handleZoom(ScaleUpdateDetails details, WidgetRef ref) {
    final scaleDelta = details.scale - controller.currentScale;
    if (scaleDelta.abs() > 0.01) {
      ref
          .read(canvasTransformProvider.notifier)
          .zoom(scaleDelta * 0.5, details.localFocalPoint);
      controller.updateScaleState(details.scale, details.localFocalPoint);
    }
  }

  void _handlePan(ScaleUpdateDetails details, WidgetRef ref) {
    final panDelta = details.localFocalPoint - controller.lastPanOffset;
    ref.read(canvasTransformProvider.notifier).pan(panDelta);
    controller.updatePanState(details.localFocalPoint);
  }

  void _handleGroupNodeClick(NodeCard node, WidgetRef ref) {
    if (controller.isCtrlPressed || controller.isShiftPressed) {
      final group = ref
          .read(nodeGroupsProvider)
          .firstWhere(
            (g) => g.id == node.groupId,
            orElse:
                () => NodeGroup(
                  id: '',
                  name: '',
                  color: Colors.transparent,
                  nodeIds: [],
                ),
          );

      if (group.nodeIds.isNotEmpty) {
        _addGroupToSelection(group, ref);
      }
    } else {
      ref.read(routesProvider.notifier).selectGroup(node.groupId!);
    }
  }

  void _addGroupToSelection(NodeGroup group, WidgetRef ref) {
    final currentSelection = ref.read(selectedNodesProvider);
    final newSelection = Set<String>.from(currentSelection)
      ..addAll(group.nodeIds);
    ref.read(selectedNodesProvider.notifier).state = newSelection;
  }

  void _selectNodesInRectangle(WidgetRef ref) {
    final route = ref.read(selectedRouteProvider);
    if (route == null ||
        controller.selectionStart == null ||
        controller.selectionEnd == null)
      return;

    final rect = Rect.fromPoints(
      controller.selectionStart!,
      controller.selectionEnd!,
    );
    final selectedIds =
        route.nodes
            .where((node) => rect.contains(node.position))
            .map((node) => node.id)
            .toSet();

    ref.read(selectedNodesProvider.notifier).state = selectedIds;
  }

  NodeCard? _getNodeAtPosition(Offset canvasPos, List<NodeCard> nodes) {
    for (final node in nodes) {
      final nodeRect = Rect.fromCenter(
        center: node.position,
        width: 120,
        height: 80,
      );
      if (nodeRect.contains(canvasPos)) {
        return node;
      }
    }
    return null;
  }

  NodeGroup? _getGroupAtPosition(
    Offset canvasPos,
    List<NodeGroup> groups,
    List<NodeCard> nodes,
  ) {
    for (final group in groups) {
      final groupNodes =
          nodes.where((n) => group.nodeIds.contains(n.id)).toList();
      if (groupNodes.isEmpty) continue;

      final bounds = group.calculateBounds(groupNodes);
      final headerRect = Rect.fromLTWH(
        bounds.left - 10,
        bounds.top - 30,
        bounds.width + 20,
        24,
      );

      if (headerRect.contains(canvasPos)) {
        return group;
      }
    }
    return null;
  }

  Offset _screenToCanvas(Offset screenPos, CanvasTransform transform) {
    return (screenPos - transform.offset) / transform.scale;
  }
}
