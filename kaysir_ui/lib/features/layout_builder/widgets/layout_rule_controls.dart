import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/layout_rule_geometry.dart';
import 'component_inspector_controls.dart';

export '../models/layout_rule_geometry.dart' show LayoutRuleSnapStatus;

/// Shows a compact action button for layout-rule cleanup commands.
class LayoutRuleActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String tooltip;
  final VoidCallback? onPressed;

  const LayoutRuleActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: OutlinedButton.icon(
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 10),
        ),
        onPressed: onPressed,
      ),
    );
  }
}

/// Displays snap status chips and cleanup actions for layout-rule editors.
class LayoutRuleCleanupActions extends StatelessWidget {
  final bool canSnapSelection;
  final bool canSnapVisible;
  final LayoutRuleSnapStatus selectedStatus;
  final LayoutRuleSnapStatus visibleStatus;
  final VoidCallback onSnapSelection;
  final VoidCallback onSnapSelectionSize;
  final VoidCallback onSnapVisible;
  final VoidCallback onSnapVisibleSize;

  const LayoutRuleCleanupActions({
    super.key,
    required this.canSnapSelection,
    required this.canSnapVisible,
    required this.selectedStatus,
    required this.visibleStatus,
    required this.onSnapSelection,
    required this.onSnapSelectionSize,
    required this.onSnapVisible,
    required this.onSnapVisibleSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._layoutRuleStatusChips('Sel', selectedStatus),
            ..._layoutRuleStatusChips('All', visibleStatus),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            LayoutRuleActionButton(
              icon: Icons.center_focus_strong_outlined,
              label: 'Snap sel',
              tooltip: 'Snap selection to layout rules',
              onPressed: canSnapSelection ? onSnapSelection : null,
            ),
            LayoutRuleActionButton(
              icon: Icons.aspect_ratio_outlined,
              label: 'Size sel',
              tooltip: 'Snap selection size to layout rules',
              onPressed: canSnapSelection ? onSnapSelectionSize : null,
            ),
            LayoutRuleActionButton(
              icon: Icons.layers_outlined,
              label: 'Snap all',
              tooltip: 'Snap visible components to layout rules',
              onPressed: canSnapVisible ? onSnapVisible : null,
            ),
            LayoutRuleActionButton(
              icon: Icons.layers_clear_outlined,
              label: 'Size all',
              tooltip: 'Snap visible component sizes to layout rules',
              onPressed: canSnapVisible ? onSnapVisibleSize : null,
            ),
          ],
        ),
      ],
    );
  }
}

List<Widget> _layoutRuleStatusChips(
  String prefix,
  LayoutRuleSnapStatus status,
) {
  if (status.isAligned) {
    return [
      ComponentInspectorChip(
        icon: Icons.check_circle_outline,
        label: '$prefix aligned',
      ),
    ];
  }

  return [
    if (status.positionCount > 0)
      ComponentInspectorChip(
        icon: Icons.center_focus_strong_outlined,
        label: '$prefix ${status.positionCount} pos',
      ),
    if (status.sizeCount > 0)
      ComponentInspectorChip(
        icon: Icons.aspect_ratio_outlined,
        label: '$prefix ${status.sizeCount} size',
      ),
  ];
}

/// Shows directional nudge buttons for rule-based layout tracks.
class LayoutRuleNudgeControls extends StatelessWidget {
  final String columnUnitLabel;
  final String rowUnitLabel;
  final bool canMoveLeft;
  final bool canMoveRight;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onMoveLeft;
  final VoidCallback onMoveRight;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;

  const LayoutRuleNudgeControls({
    super.key,
    required this.columnUnitLabel,
    required this.rowUnitLabel,
    required this.canMoveLeft,
    required this.canMoveRight,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onMoveLeft,
    required this.onMoveRight,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _LayoutRuleNudgeButton(
          icon: Icons.keyboard_arrow_left,
          tooltip: 'Move left one $columnUnitLabel',
          onPressed: canMoveLeft ? onMoveLeft : null,
        ),
        _LayoutRuleNudgeButton(
          icon: Icons.keyboard_arrow_up,
          tooltip: 'Move up one $rowUnitLabel',
          onPressed: canMoveUp ? onMoveUp : null,
        ),
        _LayoutRuleNudgeButton(
          icon: Icons.keyboard_arrow_down,
          tooltip: 'Move down one $rowUnitLabel',
          onPressed: canMoveDown ? onMoveDown : null,
        ),
        _LayoutRuleNudgeButton(
          icon: Icons.keyboard_arrow_right,
          tooltip: 'Move right one $columnUnitLabel',
          onPressed: canMoveRight ? onMoveRight : null,
        ),
      ],
    );
  }
}

/// Renders a fixed-size icon button for one layout-rule nudge direction.
class _LayoutRuleNudgeButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _LayoutRuleNudgeButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton.outlined(
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints.tightFor(width: 34, height: 34),
        icon: Icon(icon, size: 20),
        onPressed: onPressed,
      ),
    );
  }
}

/// Renders reusable layout-rule controls for visual review.
@Preview(name: 'Layout rule controls')
Widget layoutRuleControlsPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 320,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutRuleNudgeControls(
                  columnUnitLabel: 'grid column',
                  rowUnitLabel: 'grid row',
                  canMoveLeft: true,
                  canMoveRight: true,
                  canMoveUp: false,
                  canMoveDown: true,
                  onMoveLeft: () {},
                  onMoveRight: () {},
                  onMoveUp: () {},
                  onMoveDown: () {},
                ),
                const SizedBox(height: 12),
                LayoutRuleCleanupActions(
                  canSnapSelection: true,
                  canSnapVisible: true,
                  selectedStatus: const LayoutRuleSnapStatus(
                    positionCount: 1,
                    sizeCount: 0,
                  ),
                  visibleStatus: const LayoutRuleSnapStatus(
                    positionCount: 0,
                    sizeCount: 2,
                  ),
                  onSnapSelection: () {},
                  onSnapSelectionSize: () {},
                  onSnapVisible: () {},
                  onSnapVisibleSize: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
