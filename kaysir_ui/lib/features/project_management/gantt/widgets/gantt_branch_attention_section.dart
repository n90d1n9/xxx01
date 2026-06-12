import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/gantt_branch_focus_preview_service.dart';
import '../services/gantt_dependency_service.dart';
import '../services/gantt_schedule_health_service.dart';

class GanttBranchAttentionSection extends StatelessWidget {
  const GanttBranchAttentionSection({
    required this.preview,
    required this.isExpanded,
    required this.isDependencyFocused,
    required this.onToggleAttentionItems,
    required this.onToggleDependencyFocus,
    required this.onTaskSelected,
    super.key,
  });

  static const showAllAttentionButtonKey = ValueKey(
    'gantt-branch-focus-preview-show-all-attention-button',
  );
  static const showLessAttentionButtonKey = ValueKey(
    'gantt-branch-focus-preview-show-less-attention-button',
  );
  static const dependencyFocusButtonKey = ValueKey(
    'gantt-branch-focus-preview-dependency-focus-button',
  );

  static Key attentionItemKey(String taskId) {
    return ValueKey('gantt-branch-focus-preview-attention-$taskId');
  }

  final GanttBranchFocusPreview preview;
  final bool isExpanded;
  final bool isDependencyFocused;
  final VoidCallback? onToggleAttentionItems;
  final VoidCallback? onToggleDependencyFocus;
  final ValueChanged<String>? onTaskSelected;

  @override
  Widget build(BuildContext context) {
    if (preview.items.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Branch Attention',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            AppStatusPill(
              label:
                  isExpanded
                      ? 'All ${preview.items.length}'
                      : preview.items.length == 1
                      ? 'Top 1'
                      : 'Top ${preview.items.length}',
              icon: Icons.filter_list_rounded,
              color: colorScheme.onSurfaceVariant,
              maxWidth: 100,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (preview.hasDependencySummary) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (preview.dependencyAlertCount > 0)
                AppStatusPill(
                  label: preview.dependencyAlertCountLabel,
                  icon: Icons.report_problem_outlined,
                  color: GanttDependencyHealth.blocked.color(colorScheme),
                  maxWidth: 180,
                ),
              if (preview.waitingDependencyCount > 0)
                AppStatusPill(
                  label: preview.waitingDependencyCountLabel,
                  icon: Icons.pending_actions_outlined,
                  color: GanttDependencyHealth.waiting.color(colorScheme),
                  maxWidth: 150,
                ),
              if (onToggleDependencyFocus != null)
                Tooltip(
                  message:
                      isDependencyFocused
                          ? 'Show all branch attention items'
                          : 'Show only dependency attention items',
                  child: AppActionButton(
                    key: dependencyFocusButtonKey,
                    label:
                        isDependencyFocused
                            ? 'All Attention'
                            : 'Dependency Focus',
                    icon:
                        isDependencyFocused
                            ? Icons.filter_alt_off_outlined
                            : Icons.link_rounded,
                    compact: true,
                    height: 32,
                    variant: AppActionButtonVariant.text,
                    onPressed: onToggleDependencyFocus,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final item in preview.items) ...[
              _BranchAttentionTaskRow(
                item: item,
                onTaskSelected:
                    onTaskSelected == null
                        ? null
                        : () => onTaskSelected!(item.taskId),
              ),
              if (item != preview.items.last) const SizedBox(height: 6),
            ],
          ],
        ),
        if (preview.hasHiddenItems) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppStatusPill(
                label: preview.hiddenItemCountLabel,
                icon: Icons.more_horiz_rounded,
                color: colorScheme.onSurfaceVariant,
                maxWidth: 180,
              ),
              if (onToggleAttentionItems != null)
                Tooltip(
                  message:
                      isExpanded
                          ? 'Collapse branch attention list'
                          : 'Show every branch attention item',
                  child: AppActionButton(
                    key:
                        isExpanded
                            ? showLessAttentionButtonKey
                            : showAllAttentionButtonKey,
                    label: isExpanded ? 'Show Less' : 'Show All',
                    icon:
                        isExpanded
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                    compact: true,
                    height: 32,
                    variant: AppActionButtonVariant.text,
                    onPressed: onToggleAttentionItems,
                  ),
                ),
            ],
          ),
        ] else if (isExpanded && onToggleAttentionItems != null) ...[
          const SizedBox(height: 8),
          Tooltip(
            message: 'Collapse branch attention list',
            child: AppActionButton(
              key: showLessAttentionButtonKey,
              label: 'Show Less',
              icon: Icons.expand_less_rounded,
              compact: true,
              height: 32,
              variant: AppActionButtonVariant.text,
              onPressed: onToggleAttentionItems,
            ),
          ),
        ],
      ],
    );
  }
}

class _BranchAttentionTaskRow extends StatelessWidget {
  const _BranchAttentionTaskRow({
    required this.item,
    required this.onTaskSelected,
  });

  final GanttBranchFocusPreviewItem item;
  final VoidCallback? onTaskSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final healthColor = item.health.color(colorScheme);
    final dependencyColor = item.dependencyHealth.color(colorScheme);

    final row = AppInfoRow(
      key: GanttBranchAttentionSection.attentionItemKey(item.taskId),
      title: item.title,
      icon: item.health.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
      iconBoxSize: 30,
      iconSize: 16,
      iconGap: 9,
      iconBackgroundColor: healthColor.withValues(alpha: 0.12),
      iconForegroundColor: healthColor,
      backgroundColor: colorScheme.surface.withValues(alpha: 0.76),
      borderColor: colorScheme.outlineVariant.withValues(alpha: 0.72),
      titleStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w900,
      ),
      subtitle:
          item.hasDependencyAttention
              ? '${item.scheduleDetail} - ${item.dependencyDetail}'
              : item.scheduleDetail,
      subtitleMaxLines: item.hasDependencyAttention ? 2 : 1,
      onTap: onTaskSelected,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (item.hasDependencyAttention) ...[
            AppStatusPill(
              label: item.dependencyHealth.label,
              icon: item.dependencyHealth.icon,
              color: dependencyColor,
              maxWidth: 104,
            ),
            const SizedBox(width: 4),
          ],
          AppStatusPill(
            label: item.progressLabel,
            icon: Icons.trending_up_rounded,
            color: healthColor,
            maxWidth: 84,
          ),
          if (onTaskSelected != null) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ],
      ),
    );

    if (onTaskSelected == null) return row;

    return Tooltip(message: 'Inspect ${item.title}', child: row);
  }
}
