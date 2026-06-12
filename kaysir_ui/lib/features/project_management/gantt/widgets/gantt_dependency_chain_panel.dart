import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_filter_chip_group.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../gantt_dashboard.dart' as gantt;
import '../services/gantt_dependency_chain_service.dart';

enum GanttDependencyChainViewFilter { all, attention }

extension GanttDependencyChainViewFilterPresentation
    on GanttDependencyChainViewFilter {
  String get label {
    switch (this) {
      case GanttDependencyChainViewFilter.all:
        return 'All';
      case GanttDependencyChainViewFilter.attention:
        return 'Attention';
    }
  }

  IconData get icon {
    switch (this) {
      case GanttDependencyChainViewFilter.all:
        return Icons.account_tree_outlined;
      case GanttDependencyChainViewFilter.attention:
        return Icons.priority_high_rounded;
    }
  }
}

class GanttDependencyChainPanel extends StatefulWidget {
  const GanttDependencyChainPanel({
    required this.task,
    required this.dependencyTasks,
    this.maxNodes = 4,
    this.showEmptyState = false,
    this.showViewFilter = true,
    this.initialViewFilter = GanttDependencyChainViewFilter.all,
    this.onTaskSelected,
    this.today,
    super.key,
  });

  static Key inspectTaskButtonKey(String taskId) {
    return ValueKey('gantt-dependency-chain-inspect-$taskId');
  }

  static const overflowToggleButtonKey = ValueKey(
    'gantt-dependency-chain-overflow-toggle',
  );

  final gantt.GanttTask task;
  final List<gantt.GanttTask> dependencyTasks;
  final int maxNodes;
  final bool showEmptyState;
  final bool showViewFilter;
  final GanttDependencyChainViewFilter initialViewFilter;
  final ValueChanged<String>? onTaskSelected;
  final DateTime? today;

  @override
  State<GanttDependencyChainPanel> createState() =>
      _GanttDependencyChainPanelState();
}

class _GanttDependencyChainPanelState extends State<GanttDependencyChainPanel> {
  var _showAll = false;
  late var _viewFilter = widget.initialViewFilter;

  @override
  void didUpdateWidget(GanttDependencyChainPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.id != widget.task.id ||
        oldWidget.dependencyTasks != widget.dependencyTasks) {
      _showAll = false;
    }
    if (oldWidget.initialViewFilter != widget.initialViewFilter &&
        _viewFilter == oldWidget.initialViewFilter) {
      _viewFilter = widget.initialViewFilter;
    }
  }

  @override
  Widget build(BuildContext context) {
    final chain = buildGanttDependencyChain(
      task: widget.task,
      dependencyTasks: widget.dependencyTasks,
      today: widget.today,
    );

    final colorScheme = Theme.of(context).colorScheme;
    final chainColor = chain.state.color(colorScheme);
    if (!chain.hasDependencies) {
      if (!widget.showEmptyState) return const SizedBox.shrink();

      return AppInfoRow(
        title: 'No Upstream Dependencies',
        subtitle: chain.summary,
        icon: Icons.link_off_rounded,
        iconStyle: AppInfoRowIconStyle.badge,
        contained: true,
        iconBackgroundColor: chainColor.withValues(alpha: 0.12),
        iconForegroundColor: chainColor,
        titleMaxLines: 1,
        subtitleMaxLines: 2,
        trailing: AppStatusPill(
          label: 'Independent',
          icon: Icons.check_circle_outline,
          color: Colors.green.shade700,
          maxWidth: 124,
        ),
      );
    }

    final canFilterAttention =
        widget.showViewFilter &&
        chain.attentionCount > 0 &&
        chain.attentionCount < chain.totalCount;
    final effectiveFilter =
        canFilterAttention ? _viewFilter : GanttDependencyChainViewFilter.all;
    final filteredNodes =
        effectiveFilter == GanttDependencyChainViewFilter.attention
            ? chain.nodes.where((node) => node.needsAttention).toList()
            : chain.nodes;
    final nodeLimit = widget.maxNodes <= 0 ? 0 : widget.maxNodes;
    final hasOverflow = filteredNodes.length > nodeLimit;
    final visibleNodes =
        _showAll || !hasOverflow
            ? filteredNodes
            : filteredNodes.take(nodeLimit);
    final hiddenCount = filteredNodes.length - visibleNodes.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInfoRow(
          title: 'Dependency Chain',
          subtitle: chain.summary,
          icon: Icons.account_tree_outlined,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: chainColor.withValues(alpha: 0.12),
          iconForegroundColor: chainColor,
          titleMaxLines: 1,
          subtitleMaxLines: 2,
          trailing: AppStatusPill(
            label: chain.state.label,
            icon: chain.state.icon,
            color: chainColor,
            maxWidth: 120,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            AppStatusPill(
              label: chain.predecessorCountLabel,
              icon: Icons.route_outlined,
              color: colorScheme.primary,
              maxWidth: 156,
            ),
            AppStatusPill(
              label: chain.attentionCountLabel,
              icon:
                  chain.attentionCount == 0
                      ? Icons.verified_outlined
                      : Icons.priority_high_rounded,
              color:
                  chain.attentionCount == 0
                      ? Colors.green.shade700
                      : chainColor,
              maxWidth: 178,
            ),
            if (chain.readyCount > 0)
              AppStatusPill(
                label: chain.readyCountLabel,
                icon: Icons.check_circle_outline,
                color: Colors.green.shade700,
                maxWidth: 112,
              ),
          ],
        ),
        if (canFilterAttention) ...[
          const SizedBox(height: 10),
          AppFilterChipGroup<GanttDependencyChainViewFilter>(
            value: effectiveFilter,
            options: [
              AppFilterChipOption(
                value: GanttDependencyChainViewFilter.all,
                label: GanttDependencyChainViewFilter.all.label,
                icon: GanttDependencyChainViewFilter.all.icon,
                count: chain.totalCount,
              ),
              AppFilterChipOption(
                value: GanttDependencyChainViewFilter.attention,
                label: GanttDependencyChainViewFilter.attention.label,
                icon: GanttDependencyChainViewFilter.attention.icon,
                count: chain.attentionCount,
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
        for (var index = 0; index < visibleNodes.length; index++) ...[
          _DependencyChainNodeRow(
            node: visibleNodes.elementAt(index),
            onTaskSelected:
                widget.onTaskSelected == null
                    ? null
                    : () => widget.onTaskSelected!(
                      visibleNodes.elementAt(index).taskId,
                    ),
          ),
          if (index != visibleNodes.length - 1) const SizedBox(height: 8),
        ],
        if (hasOverflow) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: AppActionButton(
              key: GanttDependencyChainPanel.overflowToggleButtonKey,
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

class _DependencyChainNodeRow extends StatelessWidget {
  const _DependencyChainNodeRow({
    required this.node,
    required this.onTaskSelected,
  });

  final GanttDependencyChainNode node;
  final VoidCallback? onTaskSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final nodeColor = node.state.color(colorScheme);

    return Padding(
      padding: EdgeInsets.only(left: (node.depth - 1) * 12),
      child: AppInfoRow(
        title: node.title,
        subtitle: node.detail,
        icon: node.state.icon,
        iconStyle: AppInfoRowIconStyle.badge,
        contained: true,
        iconBackgroundColor: nodeColor.withValues(alpha: 0.12),
        iconForegroundColor: nodeColor,
        titleMaxLines: 1,
        subtitleMaxLines: 2,
        trailing: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 220),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppStatusPill(
                label: node.positionLabel,
                icon: Icons.route_outlined,
                color: colorScheme.primary,
                tooltip: node.positionTooltip,
                maxWidth: 118,
              ),
              AppStatusPill(
                label: node.state.label,
                icon: node.state.icon,
                color: nodeColor,
                maxWidth: 108,
              ),
              if (onTaskSelected != null && node.task != null)
                AppActionButton(
                  key: GanttDependencyChainPanel.inspectTaskButtonKey(
                    node.taskId,
                  ),
                  label: 'Inspect',
                  icon: Icons.manage_search_outlined,
                  compact: true,
                  variant: AppActionButtonVariant.secondary,
                  onPressed: onTaskSelected,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
