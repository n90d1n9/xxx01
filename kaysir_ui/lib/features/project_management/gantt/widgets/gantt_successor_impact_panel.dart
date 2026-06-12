import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_filter_chip_group.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/gantt_dependency_service.dart';
import '../services/gantt_successor_impact_service.dart';

enum GanttSuccessorImpactViewFilter { all, attention }

extension GanttSuccessorImpactViewFilterPresentation
    on GanttSuccessorImpactViewFilter {
  String get label {
    switch (this) {
      case GanttSuccessorImpactViewFilter.all:
        return 'All';
      case GanttSuccessorImpactViewFilter.attention:
        return 'Attention';
    }
  }

  IconData get icon {
    switch (this) {
      case GanttSuccessorImpactViewFilter.all:
        return Icons.view_timeline_outlined;
      case GanttSuccessorImpactViewFilter.attention:
        return Icons.priority_high_rounded;
    }
  }
}

class GanttSuccessorImpactPanel extends StatefulWidget {
  const GanttSuccessorImpactPanel({
    required this.summary,
    this.maxItems = 3,
    this.showEmptyState = false,
    this.showViewFilter = true,
    this.initialViewFilter = GanttSuccessorImpactViewFilter.all,
    this.onTaskSelected,
    super.key,
  });

  static Key inspectTaskButtonKey(String taskId) {
    return ValueKey('gantt-successor-impact-inspect-$taskId');
  }

  static const overflowToggleButtonKey = ValueKey(
    'gantt-successor-impact-overflow-toggle',
  );

  final GanttSuccessorImpactSummary summary;
  final int maxItems;
  final bool showEmptyState;
  final bool showViewFilter;
  final GanttSuccessorImpactViewFilter initialViewFilter;
  final ValueChanged<String>? onTaskSelected;

  @override
  State<GanttSuccessorImpactPanel> createState() =>
      _GanttSuccessorImpactPanelState();
}

class _GanttSuccessorImpactPanelState extends State<GanttSuccessorImpactPanel> {
  var _showAll = false;
  late var _viewFilter = widget.initialViewFilter;

  @override
  void didUpdateWidget(GanttSuccessorImpactPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.summary != widget.summary) {
      _showAll = false;
    }
    if (oldWidget.initialViewFilter != widget.initialViewFilter &&
        _viewFilter == oldWidget.initialViewFilter) {
      _viewFilter = widget.initialViewFilter;
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;

    final colorScheme = Theme.of(context).colorScheme;
    final signalColor = summary.signal.color(colorScheme);
    if (!summary.hasImpact) {
      if (!widget.showEmptyState) return const SizedBox.shrink();

      return AppInfoRow(
        title: 'No Downstream Impact',
        subtitle: summary.summaryText,
        icon: Icons.done_all_rounded,
        iconStyle: AppInfoRowIconStyle.badge,
        contained: true,
        iconBackgroundColor: signalColor.withValues(alpha: 0.12),
        iconForegroundColor: signalColor,
        titleMaxLines: 1,
        subtitleMaxLines: 2,
        trailing: AppStatusPill(
          label: 'Clear',
          icon: Icons.check_circle_outline,
          color: Colors.green.shade700,
          maxWidth: 96,
        ),
      );
    }

    final prioritizedItems = summary.prioritizedItems;
    final canFilterAttention =
        widget.showViewFilter &&
        summary.attentionCount > 0 &&
        summary.attentionCount < summary.totalCount;
    final effectiveFilter =
        canFilterAttention ? _viewFilter : GanttSuccessorImpactViewFilter.all;
    final filteredItems =
        effectiveFilter == GanttSuccessorImpactViewFilter.attention
            ? prioritizedItems.where((item) => item.needsAttention).toList()
            : prioritizedItems;
    final itemLimit = widget.maxItems <= 0 ? 0 : widget.maxItems;
    final hasOverflow = filteredItems.length > itemLimit;
    final visibleItems =
        _showAll || !hasOverflow
            ? filteredItems
            : filteredItems.take(itemLimit).toList();
    final hiddenCount = filteredItems.length - visibleItems.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInfoRow(
          title: 'Downstream Impact',
          subtitle: summary.summaryText,
          icon: Icons.call_split_outlined,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: signalColor.withValues(alpha: 0.12),
          iconForegroundColor: signalColor,
          titleMaxLines: 1,
          subtitleMaxLines: 2,
          trailing: AppStatusPill(
            label: summary.impactLabel,
            icon: Icons.hub_outlined,
            color: signalColor,
            maxWidth: 132,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            AppStatusPill(
              label:
                  summary.directCount == 1
                      ? '1 direct'
                      : '${summary.directCount} direct',
              icon: Icons.near_me_outlined,
              color: colorScheme.primary,
              maxWidth: 130,
            ),
            if (summary.indirectCount > 0)
              AppStatusPill(
                label:
                    summary.indirectCount == 1
                        ? '1 indirect'
                        : '${summary.indirectCount} indirect',
                icon: Icons.account_tree_outlined,
                color: colorScheme.tertiary,
                maxWidth: 142,
              ),
            AppStatusPill(
              label:
                  summary.scheduleConflictCount == 0
                      ? 'No conflicts'
                      : summary.scheduleConflictCount == 1
                      ? '1 conflict'
                      : '${summary.scheduleConflictCount} conflicts',
              icon:
                  summary.scheduleConflictCount == 0
                      ? Icons.verified_outlined
                      : Icons.warning_amber_rounded,
              color:
                  summary.scheduleConflictCount == 0
                      ? Colors.green.shade700
                      : colorScheme.error,
              maxWidth: 144,
            ),
          ],
        ),
        if (canFilterAttention) ...[
          const SizedBox(height: 10),
          AppFilterChipGroup<GanttSuccessorImpactViewFilter>(
            value: effectiveFilter,
            options: [
              AppFilterChipOption(
                value: GanttSuccessorImpactViewFilter.all,
                label: GanttSuccessorImpactViewFilter.all.label,
                icon: GanttSuccessorImpactViewFilter.all.icon,
                count: summary.totalCount,
              ),
              AppFilterChipOption(
                value: GanttSuccessorImpactViewFilter.attention,
                label: GanttSuccessorImpactViewFilter.attention.label,
                icon: GanttSuccessorImpactViewFilter.attention.icon,
                count: summary.attentionCount,
              ),
            ],
            onChanged: (filter) {
              setState(() {
                _viewFilter = filter;
                _showAll = false;
              });
            },
          ),
        ],
        const SizedBox(height: 10),
        for (var index = 0; index < visibleItems.length; index++) ...[
          _SuccessorImpactRow(
            item: visibleItems[index],
            onTaskSelected:
                widget.onTaskSelected == null
                    ? null
                    : () => widget.onTaskSelected!(visibleItems[index].task.id),
          ),
          if (index != visibleItems.length - 1) const SizedBox(height: 8),
        ],
        if (hasOverflow) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: AppActionButton(
              key: GanttSuccessorImpactPanel.overflowToggleButtonKey,
              label:
                  _showAll
                      ? 'Show Less'
                      : hiddenCount == 1
                      ? 'Show 1 More'
                      : 'Show $hiddenCount More',
              icon:
                  _showAll
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
              compact: true,
              variant: AppActionButtonVariant.text,
              onPressed: () => setState(() => _showAll = !_showAll),
            ),
          ),
        ],
      ],
    );
  }
}

class _SuccessorImpactRow extends StatelessWidget {
  const _SuccessorImpactRow({required this.item, required this.onTaskSelected});

  final GanttSuccessorImpactItem item;
  final VoidCallback? onTaskSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final rowColor =
        item.hasScheduleConflict
            ? colorScheme.error
            : item.insight.health.color(colorScheme);

    return AppInfoRow(
      title: item.task.title,
      subtitle: item.detail,
      icon:
          item.hasScheduleConflict
              ? Icons.warning_amber_rounded
              : item.insight.health.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: rowColor.withValues(alpha: 0.12),
      iconForegroundColor: rowColor,
      titleMaxLines: 1,
      subtitleMaxLines: 2,
      trailing: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AppStatusPill(
            label: item.relationshipLabel,
            icon:
                item.isDirect
                    ? Icons.near_me_outlined
                    : Icons.account_tree_outlined,
            color: item.isDirect ? colorScheme.primary : colorScheme.tertiary,
            maxWidth: 112,
          ),
          if (onTaskSelected != null)
            AppActionButton(
              key: GanttSuccessorImpactPanel.inspectTaskButtonKey(item.task.id),
              label: 'Inspect',
              icon: Icons.manage_search_outlined,
              compact: true,
              variant: AppActionButtonVariant.secondary,
              onPressed: onTaskSelected,
            ),
        ],
      ),
    );
  }
}
