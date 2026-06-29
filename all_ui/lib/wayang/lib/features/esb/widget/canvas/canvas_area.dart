import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/component_type.dart';
import '../../model/connection.dart';
import '../../model/integration_component.dart';
import '../../states/canvas_stae_provider.dart';
import '../../states/current_route_notifier.dart';
import '../../states/selected_component_provider.dart';
import '../component_widget.dart';
import '../connection/connection_painter.dart';
import '../minimap_widget.dart';
import 'grid_painter.dart';

class CanvasArea extends ConsumerStatefulWidget {
  const CanvasArea({super.key});

  @override
  ConsumerState<CanvasArea> createState() => _CanvasAreaState();
}

class _CanvasAreaState extends ConsumerState<CanvasArea> {
  String? _connectingFromId;
  Offset? _connectionEndPoint;
  final TransformationController _transformController =
      TransformationController();

  @override
  Widget build(BuildContext context) {
    final route = ref.watch(currentRouteProvider);
    final canvasState = ref.watch(canvasStateProvider);
    if (route == null) return const SizedBox();

    return Stack(
      children: [
        DragTarget<ComponentType>(
          onAcceptWithDetails: (details) {
            final renderBox = context.findRenderObject() as RenderBox;
            final localPos = renderBox.globalToLocal(details.offset);
            final matrix = _transformController.value;
            final scale = matrix.getMaxScaleOnAxis();
            final translation = matrix.getTranslation();

            final canvasPos =
                (localPos - Offset(translation.x, translation.y)) / scale;

            _addComponent(
              type: details.data,
              position: canvasState.snapToGrid
                  ? _snapToGrid(canvasPos, canvasState.gridSize)
                  : canvasPos,
            );
          },
          builder: (context, candidateData, rejectedData) {
            return GestureDetector(
              onTapUp: (details) {
                ref.read(selectedComponentProvider.notifier).clear();
              },
              child: InteractiveViewer(
                transformationController: _transformController,
                boundaryMargin: const EdgeInsets.all(2000),
                minScale: 0.5,
                maxScale: 2.0,
                constrained: false,
                child: SizedBox(
                  width: 4000,
                  height: 4000,
                  child: Stack(
                    children: [
                      // Grid background
                      if (canvasState.gridVisible)
                        CustomPaint(
                          size: const Size(4000, 4000),
                          painter: GridPainter(gridSize: canvasState.gridSize),
                        ),

                      // Connections
                      CustomPaint(
                        size: const Size(4000, 4000),
                        painter: ConnectionsPainter(
                          route.components,
                          route.connections,
                          _connectingFromId,
                          _connectionEndPoint,
                        ),
                      ),

                      // Components
                      ...route.components.map(
                        (c) => ComponentWidget(
                          key: ValueKey(c.id),
                          component: c,
                          isSelected: ref
                              .watch(selectedComponentProvider)
                              .contains(c.id),
                          onPositionChanged: (offset) =>
                              _updateComponentPosition(c, offset),
                          onTap: (isMulti) => _selectComponent(c.id, isMulti),
                          onConnectStart: () {
                            setState(() {
                              _connectingFromId = c.id;
                            });
                          },
                          onConnectEnd: (toId) => _createConnection(toId),
                          onConnectDrag: (position) {
                            setState(() {
                              _connectionEndPoint = position;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        // Minimap
        if (canvasState.minimapVisible)
          Positioned(
            right: 16,
            bottom: 16,
            child: MinimapWidget(
              components: route.components,
              connections: route.connections,
            ),
          ),
      ],
    );
  }

  Offset _snapToGrid(Offset position, double gridSize) {
    return Offset(
      (position.dx / gridSize).round() * gridSize,
      (position.dy / gridSize).round() * gridSize,
    );
  }

  void _addComponent({required ComponentType type, required Offset position}) {
    final component = IntegrationComponent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      label: type.name[0].toUpperCase() + type.name.substring(1),
      properties: _getDefaultProperties(type),
      position: position,
    );
    ref.read(currentRouteProvider.notifier).addComponent(component);
  }

  Map<String, dynamic> _getDefaultProperties(ComponentType type) {
    switch (type) {
      case ComponentType.from:
        return {'uri': 'direct:start'};
      case ComponentType.to:
        return {'uri': 'direct:end'};
      case ComponentType.log:
        return {'message': 'Processing: \${body}'};
      case ComponentType.delay:
        return {'delay': '1000'};
      case ComponentType.throttle:
        return {'maximumRequests': '10', 'timePeriodMillis': '1000'};
      default:
        return {};
    }
  }

  void _updateComponentPosition(IntegrationComponent component, Offset offset) {
    final canvasState = ref.read(canvasStateProvider);
    final finalOffset = canvasState.snapToGrid
        ? _snapToGrid(offset, canvasState.gridSize)
        : offset;

    ref
        .read(currentRouteProvider.notifier)
        .updateComponent(component.copyWith(position: finalOffset));
  }

  void _selectComponent(String id, bool isMulti) {
    if (isMulti) {
      ref.read(selectedComponentProvider.notifier).toggle(id);
    } else {
      ref.read(selectedComponentProvider.notifier).select(id);
    }
  }

  void _createConnection(String toId) {
    if (_connectingFromId != null && _connectingFromId != toId) {
      final connection = Connection(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fromId: _connectingFromId!,
        toId: toId,
      );
      ref.read(currentRouteProvider.notifier).addConnection(connection);
    }
    setState(() {
      _connectingFromId = null;
      _connectionEndPoint = null;
    });
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }
}
