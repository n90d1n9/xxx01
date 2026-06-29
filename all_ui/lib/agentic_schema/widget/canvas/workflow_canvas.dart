import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../schema/node/node_type.dart';
import '../../schema/workflow/workflow_node.dart';
import '../../state/canvas_provider.dart';
import '../../state/collaboration_provider.dart';
import '../../state/ui_provider.dart';
import '../../state/workflow/workflow_provider.dart';
import '../../state/workflow/workflow_state.dart';
import '../collaboration/collaborative_cursor_overlay.dart';
import '../edge_widget.dart';
import 'canvas_context_menu.dart';
import 'canvas_painter.dart';
import '../connection_line.dart';
import '../node/node_widget.dart';

class WorkflowCanvas extends ConsumerStatefulWidget {
  const WorkflowCanvas({super.key});

  @override
  ConsumerState<WorkflowCanvas> createState() => _WorkflowCanvasState();
}

class _WorkflowCanvasState extends ConsumerState<WorkflowCanvas> {
  Offset? _dragStart;
  Offset? _selectionStart;
  Rect? _currentSelectionRect;
  bool _isDraggingCanvas = false;
  bool _isSelecting = false;
  final Map<String, StreamSubscription> _nodeSubscriptions = {};
  Timer? _autoScrollTimer;
  Offset? _autoScrollDelta;
  Offset? _lastTapPosition; // Track last tap position

  int _currentMouseButtons = 0;

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _cleanupNodeSubscriptions();
    super.dispose();
  }

  void _cleanupNodeSubscriptions() {
    for (final subscription in _nodeSubscriptions.values) {
      subscription.cancel();
    }
    _nodeSubscriptions.clear();
  }

  @override
  Widget build(BuildContext context) {
    final workflowState = ref.watch(workflowProvider);
    final canvasState = ref.watch(canvasProvider);
    final collaborationState =
        workflowState.currentWorkflow != null
            ? ref.watch(
              collaborationProvider(workflowState.currentWorkflow!.id),
            )
            : null;

    return Listener(
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          // Handle zoom with scroll
          final scaleChange = pointerSignal.scrollDelta.dy * -0.001;
          ref
              .read(canvasProvider.notifier)
              .zoom(scaleChange, pointerSignal.localPosition);
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (details) {
          _lastTapPosition = details.localPosition; // Store position
          _handleCanvasTap(details, workflowState);
        },
        onDoubleTap: () {
          // Use the stored tap position for double tap
          if (_lastTapPosition != null) {
            _handleCanvasDoubleTap(_lastTapPosition!, workflowState);
          }
        },
        onLongPressStart: (details) {
          _handleLongPressStart(details, workflowState);
        },
        onPanStart: (details) {
          _handlePanStart(details);
        },
        onPanUpdate: (details) {
          _handlePanUpdate(details, context);
        },
        onPanEnd: (details) {
          _handlePanEnd();
        },
        onPanCancel: () {
          _handlePanEnd();
        },
        child: DragTarget<NodeType>(
          onWillAccept: (data) => true,
          onAccept: (nodeType) {
            _handleNodeDrop(nodeType, canvasState);
          },
          onLeave: (data) {
            // Visual feedback when drag leaves canvas
          },
          builder: (context, candidateData, rejectedData) {
            return Stack(
              children: [
                // Background with grid
                _CanvasBackground(canvasState: canvasState),

                // Main content
                ClipRect(
                  child: CustomPaint(
                    painter: CanvasPainter(
                      nodes: workflowState.currentWorkflow?.nodes ?? [],
                      edges: workflowState.currentWorkflow?.edges ?? [],
                      selectedNodes: workflowState.selectedNodes,
                      canvasState: canvasState,
                      selectionRect: _currentSelectionRect,
                      connectingFromNode: workflowState.connectingFromNode,
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Edges (behind nodes)
                        ..._buildEdges(workflowState, canvasState),

                        // Nodes
                        ..._buildNodes(workflowState, canvasState),

                        // Connection line while connecting
                        if (workflowState.isConnecting)
                          ConnectionLine(
                            canvasState: canvasState,
                            startNodeId: workflowState.connectingFromNode!,
                            startHandleId: workflowState.connectingFromHandle,
                          ),

                        // Selection rectangle
                        if (_currentSelectionRect != null)
                          _SelectionOverlay(
                            selectionRect: _currentSelectionRect!,
                          ),

                        // Collaborative cursors
                        if (collaborationState != null)
                          CollaborativeCursorsOverlay(),

                        // Drop indicator for drag & drop
                        if (candidateData.isNotEmpty)
                          _DropIndicator(canvasState: canvasState),
                      ],
                    ),
                  ),
                ),

                // Canvas controls overlay
                _CanvasControls(canvasState: canvasState),
              ],
            );
          },
        ),
      ),
    );
  }

  void _handleCanvasTap(TapDownDetails details, WorkflowState workflowState) {
    final canvasNotifier = ref.read(canvasProvider.notifier);
    final screenPos = details.localPosition;
    final canvasPos = canvasNotifier.screenToCanvas(screenPos);

    // Update cursor position for collaboration
    ref.read(workflowProvider.notifier).updateCursorPosition(canvasPos);

    // Clear selection if tapping on empty space
    final tappedNode = _findNodeAtPosition(canvasPos, workflowState);
    if (tappedNode == null) {
      ref.read(workflowProvider.notifier).clearSelection();
    }
  }

  void _handleCanvasDoubleTap(
    Offset localPosition,
    WorkflowState workflowState,
  ) {
    final canvasNotifier = ref.read(canvasProvider.notifier);
    final screenPos = localPosition;
    final canvasPos = canvasNotifier.screenToCanvas(screenPos);

    // Convert to global position for the menu
    final box = context.findRenderObject() as RenderBox;
    final globalPosition = box.localToGlobal(localPosition);

    // Quick add node on double tap
    _showQuickAddMenu(globalPosition, canvasPos);
  }

  void _handleLongPressStart(
    LongPressStartDetails details,
    WorkflowState workflowState,
  ) {
    final canvasNotifier = ref.read(canvasProvider.notifier);
    final screenPos = details.localPosition;
    final canvasPos = canvasNotifier.screenToCanvas(screenPos);

    // Show context menu
    _showContextMenu(details.globalPosition, canvasPos, workflowState);
  }

  void _handlePanStart(DragStartDetails details) {
    final workflowState = ref.read(workflowProvider);
    final canvasPos = ref
        .read(canvasProvider.notifier)
        .screenToCanvas(details.localPosition);

    // Update cursor position
    ref.read(workflowProvider.notifier).updateCursorPosition(canvasPos);

    // Check if this is from a mouse event and get button information
    if (details.kind == PointerDeviceKind.mouse) {
      // For mouse events, we need to check the global pointer state
      final pointer = details.globalPosition;
      final buttons = _getMouseButtons();

      if (buttons == kMiddleMouseButton) {
        // Canvas panning
        _dragStart = details.localPosition;
        _isDraggingCanvas = true;
        _updateCursor(SystemMouseCursors.grabbing);
      } else if (buttons == kPrimaryMouseButton) {
        // Box selection
        _selectionStart = details.localPosition;
        _isSelecting = true;
        _updateCursor(SystemMouseCursors.cell);
      }
    } else {
      // Touch device - start selection by default
      _selectionStart = details.localPosition;
      _isSelecting = true;
    }
  }

  int _getMouseButtons() {
    // You can use PlatformDispatcher.instance to get mouse button state
    // or track it manually using Listener widget
    return _currentMouseButtons;
  }

  void _handlePanUpdate(DragUpdateDetails details, BuildContext context) {
    if (_isDraggingCanvas) {
      // Pan the canvas
      ref.read(canvasProvider.notifier).pan(details.delta);
      _checkAutoScroll(details.localPosition, context.size!);
    } else if (_isSelecting) {
      // Update selection rectangle
      final rect = Rect.fromPoints(_selectionStart!, details.localPosition);
      setState(() => _currentSelectionRect = rect);
      _checkAutoScroll(details.localPosition, context.size!);
    }
  }

  void _handlePanEnd() {
    if (_isSelecting && _currentSelectionRect != null) {
      _performBoxSelection();
    }

    _resetInteractionState();
    _stopAutoScroll();
    _updateCursor(SystemMouseCursors.basic);
  }

  void _resetInteractionState() {
    _dragStart = null;
    _selectionStart = null;
    _currentSelectionRect = null;
    _isDraggingCanvas = false;
    _isSelecting = false;
  }

  void _checkAutoScroll(Offset localPosition, Size canvasSize) {
    const scrollMargin = 50.0;
    const scrollSpeed = 10.0;

    Offset? scrollDelta;

    if (localPosition.dx < scrollMargin) {
      scrollDelta = Offset(scrollSpeed, 0);
    } else if (localPosition.dx > canvasSize.width - scrollMargin) {
      scrollDelta = Offset(-scrollSpeed, 0);
    }

    if (localPosition.dy < scrollMargin) {
      scrollDelta = (scrollDelta ?? Offset.zero) + Offset(0, scrollSpeed);
    } else if (localPosition.dy > canvasSize.height - scrollMargin) {
      scrollDelta = (scrollDelta ?? Offset.zero) + Offset(0, -scrollSpeed);
    }

    if (scrollDelta != null) {
      _startAutoScroll(scrollDelta);
    } else {
      _stopAutoScroll();
    }
  }

  void _startAutoScroll(Offset delta) {
    _autoScrollDelta = delta;
    _autoScrollTimer ??= Timer.periodic(const Duration(milliseconds: 16), (
      timer,
    ) {
      if (_autoScrollDelta != null) {
        ref.read(canvasProvider.notifier).pan(_autoScrollDelta!);
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
    _autoScrollDelta = null;
  }

  void _updateCursor(MouseCursor cursor) {
    // In Flutter, cursor is typically handled by MouseRegion widgets
    // You can manage this through a state variable and use it in build method
    // Or use SystemChannels to change cursor globally (not recommended)

    // Better approach: Use a provider to track cursor state
    ref.read(uiProvider.notifier).setCursor(cursor);
  }

  void _performBoxSelection() {
    if (_currentSelectionRect == null) return;

    final canvasState = ref.read(canvasProvider);
    final workflowNotifier = ref.read(workflowProvider.notifier);
    final workflowState = ref.read(workflowProvider);

    // Convert screen selection rect to canvas coordinates
    final canvasStart = canvasState.screenToCanvas(
      _currentSelectionRect!.topLeft,
    );
    final canvasEnd = canvasState.screenToCanvas(
      _currentSelectionRect!.bottomRight,
    );

    // Create normalized rect (ensure topLeft is actually top-left and bottomRight is bottom-right)
    final canvasRect = Rect.fromLTRB(
      math.min(canvasStart.dx, canvasEnd.dx),
      math.min(canvasStart.dy, canvasEnd.dy),
      math.max(canvasStart.dx, canvasEnd.dx),
      math.max(canvasStart.dy, canvasEnd.dy),
    );

    // Find nodes within selection rectangle
    final selectedNodeIds = <String>[];
    for (final node in workflowState.currentWorkflow?.nodes ?? []) {
      // Use actual node dimensions for more accurate selection
      final nodeRect = _getNodeBoundingBox(node);

      // Check if node overlaps selection
      if (canvasRect.overlaps(nodeRect)) {
        selectedNodeIds.add(node.id);
      }
    }

    if (selectedNodeIds.isNotEmpty) {
      workflowNotifier.selectMultipleNodes(selectedNodeIds);
    } else {
      // Clear selection if no nodes were selected
      workflowNotifier.clearSelection();
    }
  }

  Rect _getNodeBoundingBox(WorkflowNode node) {
    const nodeWidth = 200.0;
    const nodeHeight = 100.0;
    return Rect.fromLTWH(
      node.position.x - nodeWidth / 2, // Center-based positioning
      node.position.y - nodeHeight / 2,
      nodeWidth,
      nodeHeight,
    );
  }

  void _handleNodeDrop(NodeType nodeType, CanvasState canvasState) {
    final dropPos = _getDropPosition();
    if (dropPos != null) {
      ref.read(workflowProvider.notifier).addNode(nodeType, dropPos);
    }
  }

  Offset? _getDropPosition() {
    // Get the current cursor position in canvas coordinates
    // This would need to track the latest cursor position
    return null; // Implement based on your cursor tracking
  }

  WorkflowNode? _findNodeAtPosition(
    Offset canvasPos,
    WorkflowState workflowState,
  ) {
    for (final node in workflowState.currentWorkflow?.nodes ?? []) {
      final nodeRect = Rect.fromCenter(
        center: Offset(node.position.x, node.position.y),
        width: 120,
        height: 80,
      );
      if (nodeRect.contains(canvasPos)) {
        return node;
      }
    }
    return null;
  }

  List<Widget> _buildEdges(
    WorkflowState workflowState,
    CanvasState canvasState,
  ) {
    return (workflowState.currentWorkflow?.edges ?? []).map((edge) {
      return EdgeWidget(
        key: ValueKey(edge.id),
        edge: edge,
        canvasState: canvasState,
        isSelected: workflowState.selectedEdges.any((e) => e.id == edge.id),
      );
    }).toList();
  }

  List<Widget> _buildNodes(
    WorkflowState workflowState,
    CanvasState canvasState,
  ) {
    return (workflowState.currentWorkflow?.nodes ?? []).map((node) {
      return NodeWidget(
        key: ValueKey(node.id),
        node: node,
        isSelected: workflowState.selectedNodes.any((n) => n.id == node.id),
        canvasState: canvasState,
        onInteraction: (interaction) {
          // Handle node interactions for collaboration
          _handleNodeInteraction(node, interaction);
        },
      );
    }).toList();
  }

  void _handleNodeInteraction(WorkflowNode node, NodeInteraction interaction) {
    final workflowNotifier = ref.read(workflowProvider.notifier);
    final workflowState = ref.read(workflowProvider);
    final collaborationNotifier =
        workflowState.currentWorkflow != null
            ? ref.read(
              collaborationProvider(workflowState.currentWorkflow!.id).notifier,
            )
            : null;

    switch (interaction) {
      case NodeInteraction.selected:
        collaborationNotifier?.updateSelection([node.id]);
        break;

      case NodeInteraction.moved:
        collaborationNotifier?.notifyNodeMoved(node.id, node.position);
        break;

      case NodeInteraction.updated:
        collaborationNotifier?.notifyNodeUpdated(node.id, {});
        break;

      case NodeInteraction.duplicated:
        final duplicatedNode = workflowState.currentWorkflow?.nodes.firstWhere(
          (n) => n.id == node.id,
        );
        if (duplicatedNode != null) {
          collaborationNotifier?.notifyNodeAdded(duplicatedNode);
        }
        break;

      case NodeInteraction.deleted:
        collaborationNotifier?.notifyNodeDeleted(node.id);
        break;

      case NodeInteraction.edited:
        collaborationNotifier?.notifyNodeUpdated(node.id, {});
        break;

      case NodeInteraction.connectionHandleTapped:
        // Collaboration doesn't need special handling for connection taps
        break;

      case NodeInteraction.dragStart:
        collaborationNotifier?.updateSelection([node.id]);
        break;

      case NodeInteraction.dragEnd:
        // Final position update is handled by NodeInteraction.moved
        break;

      case NodeInteraction.tapDown:
      case NodeInteraction.tapCancel:
      case NodeInteraction.dragCancel:
        // These are transient states, no collaboration needed
        break;
    }
  }

  void _showQuickAddMenu(Offset globalPosition, Offset canvasPosition) {
    showMenu(
      context: context,
      position: RelativeRect.fromSize(
        Rect.fromPoints(globalPosition, globalPosition),
        MediaQuery.of(context).size,
      ),
      items: [
        PopupMenuItem(
          value: NodeType.llm,
          child: const ListTile(
            leading: Icon(Icons.smart_toy),
            title: Text('Add AI Agent'),
            subtitle: Text('LLM-powered conversation'),
          ),
          onTap: () {
            ref
                .read(workflowProvider.notifier)
                .addNode(NodeType.llm, canvasPosition);
          },
        ),
        PopupMenuItem(
          value: NodeType.tool,
          child: const ListTile(
            leading: Icon(Icons.build),
            title: Text('Add Tool'),
            subtitle: Text('External API or function'),
          ),
          onTap: () {
            ref
                .read(workflowProvider.notifier)
                .addNode(NodeType.tool, canvasPosition);
          },
        ),
        PopupMenuItem(
          value: NodeType.decision,
          child: const ListTile(
            leading: Icon(Icons.brightness_1), //Icons.decision),
            title: Text('Add Decision'),
            subtitle: Text('Conditional logic'),
          ),
          onTap: () {
            ref
                .read(workflowProvider.notifier)
                .addNode(NodeType.decision, canvasPosition);
          },
        ),
      ],
    );
  }

  /*   void _showContextMenu(
    Offset globalPosition,
    Offset canvasPosition,
    WorkflowState workflowState,
  ) {
    final tappedNode = _findNodeAtPosition(canvasPosition, workflowState);

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder:
          (context) => CanvasContextMenu(
            position: globalPosition,
            targetNode: tappedNode,
            canvasPosition: canvasPosition,
          ),
    );
  }
 */

  void _showContextMenu(
    Offset globalPosition,
    Offset canvasPosition,
    WorkflowState workflowState,
  ) {
    final tappedNode = _findNodeAtPosition(canvasPosition, workflowState);

    showMenu(
      context: context,
      position: RelativeRect.fromSize(
        Rect.fromPoints(globalPosition, globalPosition),
        MediaQuery.of(context).size,
      ),
      items: <PopupMenuEntry>[
        if (tappedNode != null) ...[
          PopupMenuItem(
            child: const ListTile(
              leading: Icon(Icons.content_copy),
              title: Text('Duplicate'),
            ),
            onTap: () {
              ref.read(workflowProvider.notifier).duplicateNode(tappedNode.id);
            },
          ),
          PopupMenuItem(
            child: const ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
            onTap: () {
              ref.read(workflowProvider.notifier).deleteNode(tappedNode.id);
            },
          ),
          const PopupMenuDivider(),
        ],
        PopupMenuItem(
          child: const ListTile(
            leading: Icon(Icons.add),
            title: Text('Add Node Here'),
          ),
          onTap: () {
            _showQuickAddMenu(globalPosition, canvasPosition);
          },
        ),
        PopupMenuItem(
          child: const ListTile(
            leading: Icon(Icons.zoom_out_map),
            title: Text('Fit to View'),
          ),
          onTap: () {
            ref
                .read(canvasProvider.notifier)
                .fitToView(workflowState.currentWorkflow?.nodes ?? []);
          },
        ),
      ],
    );
  }
}

class _CanvasBackground extends ConsumerWidget {
  final CanvasState canvasState;

  const _CanvasBackground({required this.canvasState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned.fill(
      child: CustomPaint(painter: _GridPainter(canvasState: canvasState)),
    );
  }
}

class _GridPainter extends CustomPainter {
  final CanvasState canvasState;

  _GridPainter({required this.canvasState});

  @override
  void paint(Canvas canvas, Size size) {
    final gridSize = 20.0 * canvasState.zoom; // Use 'zoom' instead of 'scale'
    final paint =
        Paint()
          ..color = Colors.grey.shade200
          ..strokeWidth = 0.5;

    // Draw grid
    for (var x = 0.0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw origin marker
    final originPaint =
        Paint()
          ..color = Colors.blue.shade300
          ..strokeWidth = 2;
    final origin = canvasState.canvasToScreen(Offset.zero);
    canvas.drawCircle(origin, 3, originPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _SelectionOverlay extends StatelessWidget {
  final Rect selectionRect;

  const _SelectionOverlay({required this.selectionRect});

  @override
  Widget build(BuildContext context) {
    return Positioned.fromRect(
      rect: selectionRect,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          border: Border.all(color: Colors.blue, width: 1.0),
        ),
      ),
    );
  }
}

class _DropIndicator extends ConsumerWidget {
  final CanvasState canvasState;

  const _DropIndicator({required this.canvasState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.blue.withOpacity(0.5),
            width: 2.0,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: const Center(
          child: Icon(Icons.add_circle_outline, size: 48, color: Colors.blue),
        ),
      ),
    );
  }
}

class _CanvasControls extends ConsumerWidget {
  final CanvasState canvasState;

  const _CanvasControls({required this.canvasState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
      bottom: 16,
      right: 16,
      child: Column(
        children: [
          FloatingActionButton.small(
            heroTag: null,
            onPressed: () {
              ref.read(canvasProvider.notifier).zoom(0.1, Offset.zero);
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: null,
            onPressed: () {
              ref.read(canvasProvider.notifier).zoom(-0.1, Offset.zero);
            },
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: null,
            onPressed: () {
              final workflowState = ref.read(workflowProvider);
              ref
                  .read(canvasProvider.notifier)
                  .fitToView(workflowState.currentWorkflow?.nodes ?? []);
            },
            child: const Icon(Icons.fit_screen),
          ),
        ],
      ),
    );
  }
}

enum NodeInteraction {
  selected,
  moved,
  updated,
  duplicated,
  deleted,
  edited,
  connectionHandleTapped,
  dragCancel,
  dragEnd,
  tapDown,
  tapCancel,
  dragStart,
}
