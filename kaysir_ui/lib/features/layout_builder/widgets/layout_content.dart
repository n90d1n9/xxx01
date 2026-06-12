import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/layout_state_provider.dart';
import '../provider/responsive_preview_provider.dart';
import 'grid_overlay.dart';
import 'resp_comp_wrap.dart';

class LayoutContent extends ConsumerWidget {
  const LayoutContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layoutState = ref.watch(layoutStateProvider);
    final previewState = ref.watch(responsivePreviewProvider);

    return Stack(
      children: [
        if (layoutState.gridSettings.enabled)
          GridOverlay(
            config: layoutState.config,
            opacity: layoutState.gridSettings.opacity,
          ),
        ...layoutState.components.map(
          (component) => ResponsiveComponentWrapper(
            key: ValueKey(component.id),
            component: component,
            previewMode: previewState.currentDevice,
          ),
        ),
      ],
    );
  }
}
