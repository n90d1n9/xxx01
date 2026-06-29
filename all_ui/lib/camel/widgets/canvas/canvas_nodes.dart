import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/canvas_transform.dart';
import '../../states/canvas_transform_provider.dart';
import '../../states/node_group_provider.dart';
import '../../states/provider.dart';
import '../../states/select_route_provider.dart';
import '../node_widget.dart';

class CanvasNodes extends ConsumerWidget {
  const CanvasNodes({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(selectedRouteProvider);
    final transform = ref.watch(canvasTransformProvider);
    final selectedNodeIds = ref.watch(selectedNodesProvider);
    final selectedGroupId = ref.watch(selectedGroupIdProvider);
    final connectingNodeId = ref.watch(connectingNodeIdProvider);

    if (route == null) return const SizedBox.shrink();

    return Stack(
      children:
          route.nodes.map((node) {
            final screenPos = _canvasToScreen(node.position, transform);
            final isInSelectedGroup =
                selectedGroupId != null && node.groupId == selectedGroupId;
            final isIndividuallySelected = selectedNodeIds.contains(node.id);
            final isSelected = isIndividuallySelected || isInSelectedGroup;

            return Positioned(
              left: screenPos.dx - 60,
              top: screenPos.dy - 40,
              child: Transform.scale(
                scale: transform.scale,
                child: NodeWidget(
                  node: node,
                  routeId: route.id,
                  isSelected: isSelected,
                  isConnecting: node.id == connectingNodeId,
                  isGroupSelected: isInSelectedGroup && !isIndividuallySelected,
                ),
              ),
            );
          }).toList(),
    );
  }

  Offset _canvasToScreen(Offset canvasPos, CanvasTransform transform) {
    return canvasPos * transform.scale + transform.offset;
  }
}
