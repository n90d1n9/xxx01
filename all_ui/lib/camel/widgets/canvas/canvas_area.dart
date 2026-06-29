import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/node_card.dart';
import '../../models/canvas_transform.dart';
import '../../models/component_template.dart';
import '../../states/canvas_transform_provider.dart';
import '../../states/canvas_zoom_indicator.dart';
import '../../states/provider.dart';
import '../../states/node_route_provider.dart';
import '../../states/select_route_provider.dart';
import 'canvas_background.dart';
import 'canvas_connection.dart';
import 'canvas_connectiong_message.dart';
import 'canvas_controller.dart';
import 'canvas_contruction_overlay.dart';
import 'canvas_dropzone_indicator.dart';
import 'canvas_gesture_handler.dart';
import 'canvas_grid.dart';
import 'canvas_groups.dart';
import 'canvas_keyboard_shortcut_overlay.dart';
import 'canvas_minimap.dart';
import 'canvas_nodes.dart';
import 'canvas_performance_overlay.dart';
import 'canvas_selection_info.dart';
import 'canvas_selection_overlay.dart';
import 'canvas_shortcut.dart';
import 'empty_route_state.dart';

class CanvasArea extends ConsumerStatefulWidget {
  const CanvasArea({super.key});

  @override
  ConsumerState<CanvasArea> createState() => _CanvasAreaState();
}

class _CanvasAreaState extends ConsumerState<CanvasArea> {
  final GlobalKey _canvasKey = GlobalKey();
  final FocusNode _focusNode = FocusNode();
  final _canvasController = CanvasController();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _canvasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final route = ref.watch(selectedRouteProvider);

    if (route == null) {
      return const EmptyRouteState();
    }

    return CanvasShortcuts(
      focusNode: _focusNode,
      child: CanvasGestureHandler(
        controller: _canvasController,
        child: DragTarget<ComponentTemplate>(
          onAcceptWithDetails: (details) => _handleComponentDrop(details, ref),
          builder: (context, candidateData, rejectedData) {
            return Stack(
              key: _canvasKey,
              children: [
                const CanvasBackground(),
                const CanvasGrid(),
                const CanvasConnections(),
                const CanvasNodes(),
                const CanvasGroups(),
                const CanvasSelectionOverlay(),
                const CanvasMiniMap(),
                const CanvasInstructionsOverlay(),
                const CanvasDropZoneIndicator(),
                const CanvasConnectingMessage(),
                const CanvasZoomIndicator(),
                const CanvasSelectionInfo(),
                const CanvasPerformanceOverlay(),
                const CanvasKeyboardShortcutOverlay(),
              ],
            );
          },
        ),
      ),
    );
  }

  void _handleComponentDrop(
    DragTargetDetails<ComponentTemplate> details,
    WidgetRef ref,
  ) {
    final route = ref.read(selectedRouteProvider);
    final transform = ref.read(canvasTransformProvider);
    final snapToGrid = ref.read(snapToGridProvider);

    if (route == null) return;

    final renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.offset);
    var canvasPosition = _screenToCanvas(localPosition, transform);

    // Apply snap to grid
    if (snapToGrid) {
      final gridSpacing = 20.0;
      canvasPosition = Offset(
        (canvasPosition.dx / gridSpacing).round() * gridSpacing,
        (canvasPosition.dy / gridSpacing).round() * gridSpacing,
      );
    }

    final node = NodeCard(
      id:
          DateTime.now().millisecondsSinceEpoch.toString() +
          math.Random().nextInt(10000).toString(),
      type: details.data.id,
      name: details.data.name,
      icon: details.data.icon,
      color: details.data.color,
      position: canvasPosition,
      config: Map.from(details.data.defaultConfig),
    );

    ref.read(routesProvider.notifier).addNodeToRoute(route.id, node);
  }

  Offset _screenToCanvas(Offset screenPos, CanvasTransform transform) {
    return (screenPos - transform.offset) / transform.scale;
  }
}
