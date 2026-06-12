import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';
import 'package:kaysir/widgets/ui/app_surface.dart';

import '../gantt_dashboard.dart' as gantt;
import '../services/gantt_branch_focus_preview_service.dart';
import '../services/gantt_branch_focus_summary_service.dart';
import 'gantt_branch_attention_section.dart';

class GanttBranchFocusPreviewPanel extends StatefulWidget {
  const GanttBranchFocusPreviewPanel({
    required this.task,
    this.dependencyTasks = const [],
    this.today,
    this.attentionItemLimit = GanttBranchFocusPreviewService.defaultMaxItems,
    this.onFocusBranch,
    this.onTaskSelected,
    super.key,
  });

  static const focusBranchButtonKey = ValueKey(
    'gantt-branch-focus-preview-focus-button',
  );
  static const showAllAttentionButtonKey =
      GanttBranchAttentionSection.showAllAttentionButtonKey;
  static const showLessAttentionButtonKey =
      GanttBranchAttentionSection.showLessAttentionButtonKey;
  static const dependencyFocusButtonKey =
      GanttBranchAttentionSection.dependencyFocusButtonKey;

  static Key attentionItemKey(String taskId) {
    return GanttBranchAttentionSection.attentionItemKey(taskId);
  }

  final gantt.GanttTask task;
  final List<gantt.GanttTask> dependencyTasks;
  final DateTime? today;
  final int attentionItemLimit;
  final VoidCallback? onFocusBranch;
  final ValueChanged<String>? onTaskSelected;

  @override
  State<GanttBranchFocusPreviewPanel> createState() =>
      _GanttBranchFocusPreviewPanelState();
}

class _GanttBranchFocusPreviewPanelState
    extends State<GanttBranchFocusPreviewPanel> {
  bool _showAllAttentionItems = false;
  bool _dependencyFocusOnly = false;

  @override
  Widget build(BuildContext context) {
    if (widget.task.subtasks.isEmpty) return const SizedBox.shrink();

    final summary = const GanttBranchFocusSummaryService().summaryFor(
      widget.task,
      today: widget.today,
    );
    if (summary == null) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final dependencyPool =
        widget.dependencyTasks.isEmpty ? null : widget.dependencyTasks;
    final service = const GanttBranchFocusPreviewService();
    final attentionLens =
        _dependencyFocusOnly
            ? GanttBranchAttentionLens.dependency
            : GanttBranchAttentionLens.all;
    final collapsedPreview = service.previewFor(
      widget.task,
      today: widget.today,
      maxItems: widget.attentionItemLimit,
      dependencyTasks: dependencyPool,
      lens: attentionLens,
    );
    final preview =
        _showAllAttentionItems && collapsedPreview.hasHiddenItems
            ? service.previewFor(
              widget.task,
              today: widget.today,
              maxItems: collapsedPreview.totalItemCount,
              dependencyTasks: dependencyPool,
              lens: attentionLens,
            )
            : collapsedPreview;
    final canToggleAttentionItems =
        collapsedPreview.hasHiddenItems || _showAllAttentionItems;

    return AppSurface(
      padding: const EdgeInsets.all(14),
      backgroundColor: colorScheme.secondaryContainer.withValues(alpha: 0.18),
      borderColor: colorScheme.secondary.withValues(alpha: 0.22),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 540;
          final summaryContent = _BranchPreviewSummary(
            summary: summary,
            preview: preview,
            isAttentionExpanded: _showAllAttentionItems,
            isDependencyFocused: _dependencyFocusOnly,
            accentColor: colorScheme.secondary,
            onToggleAttentionItems:
                canToggleAttentionItems ? _toggleAttentionItems : null,
            onToggleDependencyFocus:
                preview.hasDependencySummary ? _toggleDependencyFocus : null,
            onTaskSelected: widget.onTaskSelected,
          );
          final action = AppActionButton(
            key: GanttBranchFocusPreviewPanel.focusBranchButtonKey,
            label: 'Focus Branch',
            icon: Icons.account_tree_outlined,
            compact: true,
            variant: AppActionButtonVariant.secondary,
            onPressed: widget.onFocusBranch,
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                summaryContent,
                const SizedBox(height: 12),
                Align(alignment: Alignment.centerLeft, child: action),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: summaryContent),
              const SizedBox(width: 16),
              action,
            ],
          );
        },
      ),
    );
  }

  void _toggleAttentionItems() {
    setState(() {
      _showAllAttentionItems = !_showAllAttentionItems;
    });
  }

  void _toggleDependencyFocus() {
    setState(() {
      _dependencyFocusOnly = !_dependencyFocusOnly;
      _showAllAttentionItems = false;
    });
  }
}

class _BranchPreviewSummary extends StatelessWidget {
  const _BranchPreviewSummary({
    required this.summary,
    required this.preview,
    required this.isAttentionExpanded,
    required this.isDependencyFocused,
    required this.accentColor,
    required this.onToggleAttentionItems,
    required this.onToggleDependencyFocus,
    required this.onTaskSelected,
  });

  final GanttBranchFocusSummary summary;
  final GanttBranchFocusPreview preview;
  final bool isAttentionExpanded;
  final bool isDependencyFocused;
  final Color accentColor;
  final VoidCallback? onToggleAttentionItems;
  final VoidCallback? onToggleDependencyFocus;
  final ValueChanged<String>? onTaskSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(Icons.account_tree_outlined, size: 20, color: accentColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Branch Preview',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          summary.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            AppStatusPill(
              label: summary.taskCountLabel,
              icon: Icons.format_list_bulleted_rounded,
              color: accentColor,
              maxWidth: 120,
            ),
            AppStatusPill(
              label: summary.progressLabel,
              icon: Icons.trending_up_rounded,
              color: colorScheme.primary,
              maxWidth: 120,
            ),
            AppStatusPill(
              label: summary.completedLabel,
              icon: Icons.check_circle_outline,
              color: Colors.green.shade700,
              maxWidth: 120,
            ),
            AppStatusPill(
              label: summary.dateRangeLabel,
              icon: Icons.date_range_outlined,
              color: colorScheme.tertiary,
              maxWidth: 150,
            ),
            if (summary.riskTaskCount > 0)
              AppStatusPill(
                label: summary.riskLabel,
                icon: Icons.warning_amber_rounded,
                color: colorScheme.error,
                maxWidth: 120,
              ),
          ],
        ),
        if (preview.items.isNotEmpty) ...[
          const SizedBox(height: 12),
          GanttBranchAttentionSection(
            preview: preview,
            isExpanded: isAttentionExpanded,
            isDependencyFocused: isDependencyFocused,
            onToggleAttentionItems: onToggleAttentionItems,
            onToggleDependencyFocus: onToggleDependencyFocus,
            onTaskSelected: onTaskSelected,
          ),
        ],
      ],
    );
  }
}
