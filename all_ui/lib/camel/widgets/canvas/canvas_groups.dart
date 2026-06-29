import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../states/canvas_transform_provider.dart';
import '../../states/node_group_provider.dart';
import '../../states/select_route_provider.dart';
import 'group_visual.dart';

class CanvasGroups extends ConsumerWidget {
  const CanvasGroups({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(selectedRouteProvider);
    final transform = ref.watch(canvasTransformProvider);
    final groups = ref.watch(nodeGroupsProvider);
    final selectedGroupId = ref.watch(selectedGroupIdProvider);

    if (route == null) return const SizedBox.shrink();

    return Stack(
      children:
          groups
              .map(
                (group) => GroupVisual(
                  group: group,
                  route: route,
                  transform: transform,
                  isSelected: selectedGroupId == group.id,
                ),
              )
              .toList(),
    );
  }
}
