import 'package:flutter/material.dart';
import 'package:ky_builder_shared/ky_builder_shared.dart';

import 'website_builder_controller.dart';

class WebsiteBuilderToolbar extends StatelessWidget {
  final WebsiteBuilderController controller;

  const WebsiteBuilderToolbar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final config = controller.canvasConfig;
    return KyBuilderSurface(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            KyBuilderMetricStrip(
              metrics: [
                KyBuilderMetricItem(
                  icon: Icons.widgets_outlined,
                  value: '${controller.componentCount}',
                  label: 'components',
                ),
                KyBuilderMetricItem(
                  icon: Icons.crop_free,
                  value:
                      '${config.canvasWidth.round()} x ${config.canvasHeight.round()}',
                  label: 'canvas',
                ),
              ],
            ),
            const SizedBox(width: 12),
            IconButton(
              tooltip: 'Undo',
              onPressed: controller.canUndo ? controller.undo : null,
              icon: const Icon(Icons.undo),
            ),
            IconButton(
              tooltip: 'Redo',
              onPressed: controller.canRedo ? controller.redo : null,
              icon: const Icon(Icons.redo),
            ),
            const SizedBox(width: 16),
            KyBuilderSegmentedSelector<BuilderBreakpoint>(
              options: [
                for (final breakpoint in BuilderBreakpoint.values)
                  KyBuilderSegmentOption(
                    value: breakpoint,
                    icon: _breakpointIcon(breakpoint),
                    label: breakpoint.label,
                  ),
              ],
              selectedValue: controller.currentBreakpoint,
              onChanged: controller.setBreakpoint,
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 190,
              child: DropdownButtonFormField<BuilderLayoutMechanism>(
                initialValue: config.layoutMechanism,
                isDense: true,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Layout',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final mechanism in BuilderLayoutMechanism.values)
                    DropdownMenuItem(
                      value: mechanism,
                      child: Text(mechanism.label),
                    ),
                ],
                onChanged: (mechanism) {
                  if (mechanism != null) {
                    controller.setLayoutMechanism(mechanism);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            _ToolbarSwitch(
              icon: config.showGrid ? Icons.grid_on : Icons.grid_off,
              label: 'Grid',
              value: config.showGrid,
              onChanged: controller.setShowGrid,
            ),
            const SizedBox(width: 8),
            _ToolbarSwitch(
              icon:
                  config.snapToGrid ? Icons.grid_goldenratio : Icons.open_with,
              label: 'Snap',
              value: config.snapToGrid,
              onChanged: controller.setSnapToGrid,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarSwitch extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToolbarSwitch({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: () => onChanged(!value),
    );
  }
}

IconData _breakpointIcon(BuilderBreakpoint breakpoint) {
  return switch (breakpoint) {
    BuilderBreakpoint.mobile => Icons.phone_android,
    BuilderBreakpoint.tablet => Icons.tablet_mac,
    BuilderBreakpoint.desktop => Icons.desktop_windows,
    BuilderBreakpoint.wide => Icons.tv,
  };
}
