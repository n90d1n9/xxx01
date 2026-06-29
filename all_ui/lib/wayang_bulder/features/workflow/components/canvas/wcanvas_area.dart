import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/config.dart';
import '../../../../theme/theme_provider.dart';
import '../../model/workflow_connection.dart';
import '../../state/connection_provider.dart';
//import '../node/widget/node_card/node_card.dart';
import '../node/model/schema/node_type_config.dart';
import '../../state/workflow_state.dart';
import '../../state/workflow_provider.dart';
import '../connection/widget/connection_painter.dart';
import '../connection/widget/connection_preview_painter.dart';
import '../../service/cancel_connection_intent.dart';
import '../grid/dot_grid_painter.dart';
import '../grid/grid_painter.dart';
import '../minimap/minimap_widget.dart';
import '../node/widget/node_card/node_card.dart';

class WorkflowCanvas extends ConsumerStatefulWidget {
  const WorkflowCanvas({super.key});

  @override
  ConsumerState<WorkflowCanvas> createState() => _WorkflowCanvasState();
}

class _WorkflowCanvasState extends ConsumerState<WorkflowCanvas> {
  Offset? _dragStart;
  Offset? _mousePosition;
  final TransformationController _transformController =
      TransformationController();

  String? _selectedConnectionId;

  @override
  Widget build(BuildContext context) {
    final workflowState = ref.watch(workflowProvider);
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.escape): CancelConnectionIntent(),
      },
      child: Actions(
        actions: {
          CancelConnectionIntent: CallbackAction<CancelConnectionIntent>(
            onInvoke: (intent) {
              ref.read(connectingFromNodeProvider.notifier).state = null;
              ref.read(connectingFromPortProvider.notifier).state = null;
              ref.read(workflowProvider.notifier).clearConnectionDrag();
              return null;
            },
          ),
        },
        child: MouseRegion(
          onHover: (event) {
            setState(() {
              // Used local position
              _mousePosition = event.localPosition;
            });

            // ✅ Convert to canvas coordinates (unscaled, unpanned)
            final canvasMouse =
                (event.position / workflowState.zoom) -
                workflowState.canvasOffset;

            String? hoveredNodeId;
            String? hoveredPortId;
            const double snapDistance = 20.0; // in canvas units (not screen!)

            for (final node in workflowState.nodes) {
              if (node.id == ref.watch(connectingFromNodeProvider)) continue;

              for (int i = 0; i < node.inputs.length; i++) {
                final port = node.inputs[i];
                final portY =
                    kNodeCardHeaderHeight +
                    kNodeCardInternalPadding +
                    (i * kNodeCardPortSpacing);
                final portPos = node.position + Offset(0, portY); // ← LEFT side

                if ((portPos - canvasMouse).distance < snapDistance) {
                  hoveredNodeId = node.id;
                  hoveredPortId = port.id;
                  break;
                }
              }
              if (hoveredNodeId != null) break;
            }

            ref
                .read(workflowProvider.notifier)
                .setHoveredInputPort(hoveredNodeId, hoveredPortId);
          },

          child: GestureDetector(
            onPanStart: (details) {
              if (ref.read(connectingFromNodeProvider.notifier).state == null &&
                  !ref.watch(draggingNodeProvider)) {
                _dragStart = details.globalPosition;
              }
            },
            onPanUpdate: (details) {
              if (_dragStart != null &&
                  ref.read(connectingFromNodeProvider.notifier).state == null &&
                  !ref.watch(draggingNodeProvider)) {
                final delta = details.globalPosition - _dragStart!;
                ref
                    .read(workflowProvider.notifier)
                    .updateCanvasOffset(workflowState.canvasOffset + delta);
                _dragStart = details.globalPosition;
              }
            },
            onTap: () {
              ref.read(workflowProvider.notifier).selectNode(null);

              // Cancel pending connection
              ref.read(connectingFromNodeProvider.notifier).state = null;
              ref.read(connectingFromPortProvider.notifier).state = null;
            },
            onPanEnd: (_) {
              _dragStart = null;
            },
            child: SizedBox.expand(
              // 👈 Ensures full size
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Get visible area in logical units (screen pixels / zoom)
                  final visibleLogicalWidth =
                      constraints.maxWidth / workflowState.zoom;
                  final visibleLogicalHeight =
                      constraints.maxHeight / workflowState.zoom;
                  final visibleSize = Size(
                    visibleLogicalWidth,
                    visibleLogicalHeight,
                  );

                  return Stack(
                    children: [
                      canvas(workflowState),

                      if (ref.watch(connectingFromNodeProvider) != null &&
                          _mousePosition != null)
                        CustomPaint(
                          painter: ConnectionPreviewPainter(
                            workflowState: workflowState,
                            fromNodeId: ref.watch(connectingFromNodeProvider)!,
                            fromPortId: ref.watch(connectingFromPortProvider)!,
                            mousePosition: _mousePosition!,
                          ),
                        ),
                      Positioned(
                        right: 20,
                        bottom: 20,
                        child: MinimapWidget(
                          nodes: workflowState.nodes,
                          connections: workflowState.connections,
                          canvasOffset: workflowState.canvasOffset,
                          zoom: workflowState.zoom,
                          canvasSize:
                              visibleSize, // Or compute actual canvas size if needed
                          onNavigate: (Offset newOffset) {
                            ref
                                .read(workflowProvider.notifier)
                                .updateCanvasOffset(newOffset);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget canvas(WorkflowState workflowState) {
    return DragTarget<NodeConfig>(
      onAcceptWithDetails: (nodeType) {
        final box = context.findRenderObject() as RenderBox?;
        final renderBox = context.findRenderObject() as RenderBox;
        final localPos = renderBox.globalToLocal(nodeType.offset);
        final matrix = _transformController.value;
        final scale = matrix.getMaxScaleOnAxis();
        final translation = matrix.getTranslation();

        final canvasPos =
            (localPos - Offset(translation.x, translation.y)) / scale;

        /*  _addComponent(
              type: nodeType.data,
              position: canvasState.snapToGrid
                  ? _snapToGrid(canvasPos, canvasState.gridSize)
                  : canvasPos,
            );
 */

        if (box != null) {
          final position = Offset(400, 300) - workflowState.canvasOffset;
          ref
              .read(workflowProvider.notifier)
              .addNode(nodeType.data.type, position);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final theme = ref.watch(themeProvider);
        return CustomPaint(
          size: Size.infinite,
          painter: theme.gridType == GridType.dot
              ? DottedGridPainter(
                  dotSpacing: theme.canvas.gridSpacing,
                  dotRadius: 1,
                  dotColor: theme.canvas.gridColor,
                )
              : GridPainter(
                  offset: workflowState.canvasOffset,
                  zoom: workflowState.zoom,
                  gridSpacing: theme.canvas.gridSpacing,
                  gridColor: theme.canvas.gridColor,
                ),
          child: Stack(
            children: [
              CustomPaint(
                painter: ConnectionsPainter(
                  workflowState: workflowState,
                  lineType: ConnectionLineType.curved,
                ),
                child: Container(),
              ),
              ...workflowState.nodes.map(
                (node) => NodeCard(node: node, workflowState: workflowState),
              ),

              // End Arrow of connection painter
              /*  if (widget.lineType != ConnectionLineType.straight)
              ConnectionArrow(
                scale: widget.scale,
                start: widget.start,
                end: widget.end,
                color: _lineColor,
                controlPoint1: control1,
                controlPoint2: control2,
                lineType: widget.lineType,
              ), */
            ],
          ),
        );
      },
    );
  }
}
