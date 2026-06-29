import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../states/canvas_transform_provider.dart';
import '../../states/connection_provider.dart';
import '../../states/provider.dart';
import '../../states/select_route_provider.dart';
import '../connection_painter.dart';

class CanvasConnections extends ConsumerWidget {
  const CanvasConnections({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(selectedRouteProvider);
    final transform = ref.watch(canvasTransformProvider);
    final selectedNodeId = ref.watch(selectedNodeIdProvider);
    final selectedNodeIds = ref.watch(selectedNodesProvider);

    if (route == null) return const SizedBox.shrink();

    return Positioned.fill(
      child: CustomPaint(
        painter: ConnectionPainter(
          nodes: route.nodes,
          selectedNodeId: selectedNodeId,
          selectedNodeIds: selectedNodeIds,
          transform: transform,
          routingMode: ref.watch(connectionRoutingModeProvider),
        ),
      ),
    );
  }
}
