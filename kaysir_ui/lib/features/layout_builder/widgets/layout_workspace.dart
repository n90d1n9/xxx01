import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/component.dart';
import '../provider/layout_state_provider.dart';
import 'com_drop_target.dart';
import 'draggable_component.dart';
import 'grid_background.dart';

class AdvancedLayoutWorkspace extends ConsumerWidget {
  const AdvancedLayoutWorkspace({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layoutState = ref.watch(layoutStateProvider);

    return ComponentDropTarget(
      onDrop: (data, position) {
        if (data is ComponentType) {
          ref
              .read(layoutStateProvider.notifier)
              .addComponentFromTypeWithDropResolution(data, position);
        }
      },
      child: Stack(
        children: [
          const GridBackground(),
          for (final component in layoutState.components)
            DraggableComponent(
              key: ValueKey(component.id),
              component: component,
              isSelected: layoutState.selectedComponentIds.contains(
                component.id,
              ),
            ),
        ],
      ),
    );
  }
}
