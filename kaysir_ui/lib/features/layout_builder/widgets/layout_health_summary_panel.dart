import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/layout_health_summary.dart';

/// Displays Layout Health issues and rule-safe quick actions.
class LayoutHealthSummaryPanel extends StatelessWidget {
  final LayoutHealthSummary summary;
  final bool snapSelected;
  final bool convertSelected;
  final VoidCallback? onUseSnap;
  final VoidCallback? onUseConvert;
  final ValueChanged<Size>? onCanvasSizeSelected;
  final VoidCallback? onRepositionInsideCanvas;
  final VoidCallback? onSelectOffCanvas;
  final VoidCallback? onSelectExpandableOffCanvas;
  final VoidCallback? onSelectRepositionOffCanvas;
  final VoidCallback? onSelectOffRulePositions;
  final VoidCallback? onSelectOffRuleSizes;
  final VoidCallback? onSelectAutoGridConflicts;

  const LayoutHealthSummaryPanel({
    super.key,
    required this.summary,
    this.snapSelected = false,
    this.convertSelected = false,
    this.onUseSnap,
    this.onUseConvert,
    this.onCanvasSizeSelected,
    this.onRepositionInsideCanvas,
    this.onSelectOffCanvas,
    this.onSelectExpandableOffCanvas,
    this.onSelectRepositionOffCanvas,
    this.onSelectOffRulePositions,
    this.onSelectOffRuleSizes,
    this.onSelectAutoGridConflicts,
  });

  @override
  Widget build(BuildContext context) {
    final canSnap =
        summary.editableComponentCount > 0 &&
        summary.offRulePositionCount > 0 &&
        onUseSnap != null;
    final canConvert =
        summary.editableComponentCount > 0 &&
        (summary.offRuleSizeCount > 0 || summary.autoGridConflictCount > 0) &&
        onUseConvert != null;
    final canExpandCanvas =
        summary.canExpandCanvas && onCanvasSizeSelected != null;
    final canReposition =
        summary.hasRepositionableOffCanvas && onRepositionInsideCanvas != null;
    final canSelectOffCanvas =
        summary.hasSelectableOffCanvas && onSelectOffCanvas != null;
    final canSelectExpandableOffCanvas =
        summary.hasSelectableExpandableOffCanvas &&
        onSelectExpandableOffCanvas != null;
    final canSelectRepositionOffCanvas =
        summary.hasSelectableRepositionOffCanvas &&
        onSelectRepositionOffCanvas != null;
    final canSelectOffRulePositions =
        summary.hasSelectableOffRulePositions &&
        onSelectOffRulePositions != null;
    final canSelectOffRuleSizes =
        summary.hasSelectableOffRuleSizes && onSelectOffRuleSizes != null;
    final canSelectAutoGridConflicts =
        summary.hasSelectableAutoGridConflicts &&
        onSelectAutoGridConflicts != null;
    final repositionOffsetLabel = summary.repositionOffsetLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _HealthSectionLabel(
          icon: Icons.health_and_safety_outlined,
          label: 'Layout health',
        ),
        const SizedBox(height: 8),
        _LayoutHealthStatusBanner(summary: summary),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (!summary.hasIssues)
              const _HealthMetricChip(
                icon: Icons.check_circle_outline,
                label: 'No layout issues',
              ),
            if (summary.offCanvasCount > 0)
              _HealthMetricChip(
                icon: Icons.crop_free_outlined,
                label: _healthCountLabel(
                  summary.offCanvasCount,
                  'off canvas',
                  'off canvas',
                ),
              ),
            if (summary.hasExpandableOffCanvas)
              _HealthMetricChip(
                icon: Icons.fit_screen_outlined,
                label: _healthCountLabel(
                  summary.expandableOffCanvasCount,
                  'right/bottom overflow',
                  'right/bottom overflow',
                ),
              ),
            if (summary.hasRepositionOffCanvas)
              _HealthMetricChip(
                icon: Icons.open_with,
                label: _healthCountLabel(
                  summary.repositionOffCanvasCount,
                  'left/top outside',
                  'left/top outside',
                ),
              ),
            if (summary.offRulePositionCount > 0)
              _HealthMetricChip(
                icon: Icons.route_outlined,
                label: _healthCountLabel(
                  summary.offRulePositionCount,
                  'off position rule',
                ),
              ),
            if (summary.offRuleSizeCount > 0)
              _HealthMetricChip(
                icon: Icons.aspect_ratio,
                label: _healthCountLabel(
                  summary.offRuleSizeCount,
                  'off size rule',
                ),
              ),
            if (summary.autoGridConflictCount > 0)
              _HealthMetricChip(
                icon: Icons.warning_amber_outlined,
                label: _healthCountLabel(
                  summary.autoGridConflictCount,
                  'Auto Grid conflict detected',
                  'Auto Grid conflicts detected',
                ),
              ),
          ],
        ),
        if (summary.hasRepairScopeNotes) ...[
          const SizedBox(height: 8),
          _HealthRepairScopeNotice(summary: summary),
        ],
        if (canSnap ||
            canConvert ||
            canExpandCanvas ||
            canReposition ||
            canSelectOffCanvas ||
            canSelectExpandableOffCanvas ||
            canSelectRepositionOffCanvas ||
            canSelectOffRulePositions ||
            canSelectOffRuleSizes ||
            canSelectAutoGridConflicts) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (canSelectOffRulePositions)
                Tooltip(
                  message:
                      'Select ${_healthCountLabel(summary.offRulePositionCount, 'off position rule')}',
                  child: OutlinedButton.icon(
                    onPressed: onSelectOffRulePositions,
                    icon: const Icon(Icons.route_outlined, size: 16),
                    label: const Text('Select Position'),
                  ),
                ),
              if (canSelectOffRuleSizes)
                Tooltip(
                  message:
                      'Select ${_healthCountLabel(summary.offRuleSizeCount, 'off size rule')}',
                  child: OutlinedButton.icon(
                    onPressed: onSelectOffRuleSizes,
                    icon: const Icon(Icons.aspect_ratio, size: 16),
                    label: const Text('Select Size'),
                  ),
                ),
              if (canSelectAutoGridConflicts)
                Tooltip(
                  message:
                      'Select ${_healthCountLabel(summary.autoGridConflictCount, 'Auto Grid conflict detected', 'Auto Grid conflicts detected')}',
                  child: OutlinedButton.icon(
                    onPressed: onSelectAutoGridConflicts,
                    icon: const Icon(Icons.warning_amber_outlined, size: 16),
                    label: const Text('Select Conflicts'),
                  ),
                ),
              if (canSelectRepositionOffCanvas)
                Tooltip(
                  message:
                      'Select ${_healthCountLabel(summary.repositionOffCanvasCount, 'left/top outside', 'left/top outside')}',
                  child: OutlinedButton.icon(
                    onPressed: onSelectRepositionOffCanvas,
                    icon: const Icon(Icons.open_with, size: 16),
                    label: const Text('Select Left/Top'),
                  ),
                ),
              if (canSelectExpandableOffCanvas)
                Tooltip(
                  message:
                      'Select ${_healthCountLabel(summary.expandableOffCanvasCount, 'right/bottom overflow', 'right/bottom overflow')}',
                  child: OutlinedButton.icon(
                    onPressed: onSelectExpandableOffCanvas,
                    icon: const Icon(Icons.fit_screen_outlined, size: 16),
                    label: const Text('Select Overflow'),
                  ),
                ),
              if (canSelectOffCanvas)
                Tooltip(
                  message:
                      'Select ${_healthCountLabel(summary.offCanvasCount, 'off canvas', 'off canvas')}',
                  child: OutlinedButton.icon(
                    onPressed: onSelectOffCanvas,
                    icon: const Icon(Icons.select_all_outlined, size: 16),
                    label: const Text('Select Off Canvas'),
                  ),
                ),
              if (canReposition)
                Tooltip(
                  message:
                      repositionOffsetLabel == null
                          ? 'Move editable components inside the canvas'
                          : 'Move editable components by $repositionOffsetLabel',
                  child: OutlinedButton.icon(
                    onPressed: onRepositionInsideCanvas,
                    icon: const Icon(
                      Icons.center_focus_strong_outlined,
                      size: 16,
                    ),
                    label: Text(
                      repositionOffsetLabel == null
                          ? 'Reposition Inside Canvas'
                          : 'Reposition $repositionOffsetLabel',
                    ),
                  ),
                ),
              if (canExpandCanvas)
                OutlinedButton.icon(
                  onPressed:
                      () => onCanvasSizeSelected!(summary.expandedCanvasSize!),
                  icon: const Icon(Icons.fit_screen_outlined, size: 16),
                  label: Text(
                    'Expand Canvas to ${summary.expandedCanvasSizeLabel}',
                  ),
                ),
              if (canSnap)
                OutlinedButton.icon(
                  onPressed: snapSelected ? null : onUseSnap,
                  icon: const Icon(Icons.grid_goldenratio, size: 16),
                  label: Text(snapSelected ? 'Snap selected' : 'Use Snap'),
                ),
              if (canConvert)
                OutlinedButton.icon(
                  onPressed: convertSelected ? null : onUseConvert,
                  icon: const Icon(Icons.auto_fix_high_outlined, size: 16),
                  label: Text(
                    convertSelected ? 'Convert selected' : 'Use Convert',
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Explains which components quick repairs can and cannot affect.
class _HealthRepairScopeNotice extends StatelessWidget {
  final LayoutHealthSummary summary;

  const _HealthRepairScopeNotice({required this.summary});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _layoutHealthRepairScopeLabel(summary),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows the overall Layout Health state before the detailed issue chips.
class _LayoutHealthStatusBanner extends StatelessWidget {
  final LayoutHealthSummary summary;

  const _LayoutHealthStatusBanner({required this.summary});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = summary.hasIssues ? colorScheme.error : colorScheme.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              summary.hasIssues
                  ? Icons.report_problem_outlined
                  : Icons.check_circle_outline,
              size: 18,
              color: color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    summary.statusLabel,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _layoutHealthScopeLabel(summary),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Displays a compact icon and count label for a health metric.
class _HealthMetricChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HealthMetricChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}

/// Displays an icon-led section label for Layout Health content.
class _HealthSectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HealthSectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelLarge),
      ],
    );
  }
}

String _healthCountLabel(int count, String singular, [String? plural]) {
  final pluralLabel =
      plural ??
      (singular == 'off canvas'
          ? singular
          : singular.endsWith('y')
          ? '${singular.substring(0, singular.length - 1)}ies'
          : '${singular}s');

  return '$count ${count == 1 ? singular : pluralLabel}';
}

String _layoutHealthScopeLabel(LayoutHealthSummary summary) {
  final parts = <String>[
    _healthCountLabel(summary.editableComponentCount, 'editable component'),
    if (summary.lockedComponentCount > 0)
      _healthCountLabel(summary.lockedComponentCount, 'locked component'),
    if (summary.hiddenComponentCount > 0)
      _healthCountLabel(summary.hiddenComponentCount, 'hidden component'),
  ];

  return parts.join(' - ');
}

String _layoutHealthRepairScopeLabel(LayoutHealthSummary summary) {
  final parts = <String>[
    'Quick fixes affect ${_healthCountLabel(summary.editableComponentCount, 'editable component')}.',
  ];
  final skippedLabels = <String>[
    if (summary.lockedComponentCount > 0)
      _healthCountLabel(summary.lockedComponentCount, 'locked component'),
    if (summary.hiddenComponentCount > 0)
      _healthCountLabel(summary.hiddenComponentCount, 'hidden component'),
  ];

  if (skippedLabels.isNotEmpty) {
    parts.add('Skips ${_joinWithAnd(skippedLabels)}.');
  }

  final lockedOutsideCount = summary.lockedRepositionOffCanvasCount;
  if (lockedOutsideCount > 0) {
    final noun =
        lockedOutsideCount == 1
            ? 'locked left/top outside component'
            : 'locked left/top outside components';
    final verb = lockedOutsideCount == 1 ? 'needs' : 'need';
    parts.add('$lockedOutsideCount $noun $verb unlocking.');
  }

  return parts.join(' ');
}

String _joinWithAnd(List<String> labels) {
  if (labels.length <= 1) return labels.join();
  return '${labels.take(labels.length - 1).join(', ')} and ${labels.last}';
}

@Preview(name: 'Layout health summary panel')
Widget layoutHealthSummaryPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 420,
          child: LayoutHealthSummaryPanel(
            summary: const LayoutHealthSummary(
              visibleComponentCount: 5,
              editableComponentCount: 4,
              lockedComponentCount: 1,
              hiddenComponentCount: 2,
              offCanvasCount: 2,
              expandableOffCanvasCount: 1,
              repositionOffCanvasCount: 1,
              repositionableOffCanvasCount: 1,
              offRulePositionCount: 3,
              offRuleSizeCount: 2,
              autoGridConflictCount: 1,
              offCanvasComponentIds: ['left-top', 'right-bottom'],
              expandableOffCanvasComponentIds: ['right-bottom'],
              repositionOffCanvasComponentIds: ['left-top'],
              offRulePositionComponentIds: ['left-top', 'right-bottom'],
              offRuleSizeComponentIds: ['left-top'],
              autoGridConflictComponentIds: ['right-bottom'],
              expandedCanvasSize: Size(1280, 820),
              repositionOffset: Offset(24, 12),
            ),
            onRepositionInsideCanvas: _previewLayoutHealthAction,
            onSelectOffCanvas: _previewLayoutHealthAction,
            onSelectExpandableOffCanvas: _previewLayoutHealthAction,
            onSelectRepositionOffCanvas: _previewLayoutHealthAction,
            onSelectOffRulePositions: _previewLayoutHealthAction,
            onSelectOffRuleSizes: _previewLayoutHealthAction,
            onSelectAutoGridConflicts: _previewLayoutHealthAction,
          ),
        ),
      ),
    ),
  );
}

void _previewLayoutHealthAction() {}
