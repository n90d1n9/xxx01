import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../models/management_pack_field_visibility_mode.dart';

/// Compact controls for expanding or condensing product management field groups.
class ProductManagementPackGroupCommandStrip extends StatelessWidget {
  const ProductManagementPackGroupCommandStrip({
    super.key,
    required this.expandedGroupCount,
    required this.totalGroupCount,
    required this.lockedOpenGroupCount,
    required this.visibleFieldCount,
    required this.totalFieldCount,
    required this.visibilityMode,
    required this.onVisibilityModeChanged,
    this.onExpandAll,
    this.onCollapseReady,
  });

  final int expandedGroupCount;
  final int totalGroupCount;
  final int lockedOpenGroupCount;
  final int visibleFieldCount;
  final int totalFieldCount;
  final ProductManagementPackFieldVisibilityMode visibilityMode;
  final ValueChanged<ProductManagementPackFieldVisibilityMode>
  onVisibilityModeChanged;
  final VoidCallback? onExpandAll;
  final VoidCallback? onCollapseReady;

  @override
  Widget build(BuildContext context) {
    if (totalGroupCount <= 0) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final pinnedLabel =
        lockedOpenGroupCount == 1
            ? '1 review group pinned open'
            : '$lockedOpenGroupCount review groups pinned open';
    final content = Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        AppStatusPill(
          label: '$expandedGroupCount/$totalGroupCount groups open',
          color: colorScheme.primary,
          icon: Icons.unfold_more_rounded,
          maxWidth: 170,
        ),
        AppStatusPill(
          label: '$visibleFieldCount/$totalFieldCount fields shown',
          color: colorScheme.secondary,
          icon: Icons.filter_list_rounded,
          maxWidth: 180,
        ),
        if (lockedOpenGroupCount > 0)
          AppStatusPill(
            label: pinnedLabel,
            color: colorScheme.error,
            icon: Icons.push_pin_rounded,
            maxWidth: 230,
          ),
      ],
    );
    final actions = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Tooltip(
          message: 'Expand all pack field groups',
          child: OutlinedButton.icon(
            onPressed: onExpandAll,
            icon: const Icon(Icons.unfold_more_rounded),
            label: const Text('Expand all'),
          ),
        ),
        Tooltip(
          message: 'Collapse optional and ready groups',
          child: OutlinedButton.icon(
            onPressed: onCollapseReady,
            icon: const Icon(Icons.unfold_less_rounded),
            label: const Text('Collapse ready'),
          ),
        ),
      ],
    );
    final modeControl =
        SegmentedButton<ProductManagementPackFieldVisibilityMode>(
          showSelectedIcon: false,
          segments: [
            for (final mode in ProductManagementPackFieldVisibilityMode.values)
              ButtonSegment(
                value: mode,
                icon: Icon(_visibilityModeIcon(mode)),
                label: Text(mode.label),
                tooltip: mode.tooltip,
              ),
          ],
          selected: {visibilityMode},
          onSelectionChanged: (values) => onVisibilityModeChanged(values.first),
        );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          colorScheme.primary.withValues(alpha: 0.04),
          colorScheme.surface,
        ),
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 980) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  content,
                  const SizedBox(height: 10),
                  modeControl,
                  const SizedBox(height: 10),
                  actions,
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: content),
                const SizedBox(width: 12),
                modeControl,
                const SizedBox(width: 12),
                actions,
              ],
            );
          },
        ),
      ),
    );
  }
}

@Preview(name: 'Management pack group command strip')
Widget productManagementPackGroupCommandStripPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 720,
          child: ProductManagementPackGroupCommandStrip(
            expandedGroupCount: 2,
            totalGroupCount: 6,
            lockedOpenGroupCount: 1,
            visibleFieldCount: 3,
            totalFieldCount: 7,
            visibilityMode: ProductManagementPackFieldVisibilityMode.all,
            onVisibilityModeChanged: (_) {},
            onExpandAll: () {},
            onCollapseReady: () {},
          ),
        ),
      ),
    ),
  );
}

IconData _visibilityModeIcon(ProductManagementPackFieldVisibilityMode mode) {
  return switch (mode) {
    ProductManagementPackFieldVisibilityMode.all => Icons.view_list_rounded,
    ProductManagementPackFieldVisibilityMode.requiredOnly => Icons.rule_rounded,
  };
}
