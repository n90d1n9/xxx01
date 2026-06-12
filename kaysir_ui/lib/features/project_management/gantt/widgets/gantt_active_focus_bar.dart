import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../../project/models/project_portfolio_item.dart';
import '../services/gantt_active_focus_bar_presentation_service.dart';
import '../services/gantt_active_focus_summary_service.dart';
import '../services/gantt_branch_focus_summary_service.dart';
import '../services/gantt_saved_view_service.dart';
import '../services/gantt_timeline_range_preset_service.dart';
import '../services/gantt_timeline_saved_view_presentation_service.dart';
import '../states/gantt_filter_provider.dart';
import 'gantt_clearable_focus_pill.dart';

/// Filter summary bar for clearing the active Gantt timeline focus.
class GanttActiveFocusBar extends StatelessWidget {
  const GanttActiveFocusBar({
    required this.query,
    required this.selectedProject,
    required this.statusFilter,
    required this.viewPreset,
    required this.rangePreset,
    required this.onClear,
    this.onClearProject,
    this.onClearBranchFocus,
    this.onClearViewPreset,
    this.onClearRangePreset,
    this.onClearStatus,
    this.onClearQuery,
    this.branchFocusTitle,
    this.branchFocusSummary,
    this.visibleTaskCount,
    this.totalTaskCount,
    super.key,
  });

  final String query;
  final ProjectPortfolioItem? selectedProject;
  final GanttTaskStatusFilter statusFilter;
  final GanttTimelineViewPreset viewPreset;
  final GanttTimelineRangePreset rangePreset;
  final VoidCallback onClear;
  final VoidCallback? onClearProject;
  final VoidCallback? onClearBranchFocus;
  final VoidCallback? onClearViewPreset;
  final VoidCallback? onClearRangePreset;
  final VoidCallback? onClearStatus;
  final VoidCallback? onClearQuery;
  final String? branchFocusTitle;
  final GanttBranchFocusSummary? branchFocusSummary;
  final int? visibleTaskCount;
  final int? totalTaskCount;

  static const clearProjectButtonKey = ganttActiveFocusClearProjectButtonKey;
  static const clearBranchButtonKey = ganttActiveFocusClearBranchButtonKey;
  static const clearViewButtonKey = ganttActiveFocusClearViewButtonKey;
  static const clearRangeButtonKey = ganttActiveFocusClearRangeButtonKey;
  static const clearStatusButtonKey = ganttActiveFocusClearStatusButtonKey;
  static const clearQueryButtonKey = ganttActiveFocusClearQueryButtonKey;

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = query.trim();
    final normalizedBranchFocusTitle = branchFocusTitle?.trim();
    final hasBranchFocus =
        normalizedBranchFocusTitle != null &&
        normalizedBranchFocusTitle.isNotEmpty;
    final viewPresentation = ganttTimelineSavedViewPresentation(viewPreset);
    final summary = const GanttActiveFocusSummaryService().summaryFor(
      query: normalizedQuery,
      hasProjectFocus: selectedProject != null,
      hasBranchFocus: hasBranchFocus,
      statusFilter: statusFilter,
      viewPreset: viewPreset,
      rangePreset: rangePreset,
      visibleTaskCount: visibleTaskCount,
      totalTaskCount: totalTaskCount,
    );

    if (!summary.hasFocus) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final presentationService = const GanttActiveFocusBarPresentationService();
    const layout = GanttActiveFocusBarPresentationService.layout;
    const header = GanttActiveFocusBarPresentationService.header;

    return Padding(
      padding: EdgeInsets.only(top: layout.topPadding),
      child: Wrap(
        spacing: layout.spacing,
        runSpacing: layout.runSpacing,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: header.minWidth,
              maxWidth: header.maxWidth,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(header.icon, size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        header.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        summary.headline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (summary.resultLabel != null)
            _statusPill(
              presentation: presentationService.chipPresentationFor(
                GanttActiveFocusChipRole.result,
              ),
              label: summary.resultLabel!,
              tooltip:
                  summary.filteredOutLabel == null
                      ? 'Visible tasks after current focus'
                      : '${summary.filteredOutLabel} by the current focus',
              colorScheme: colorScheme,
            ),
          if (selectedProject != null)
            _clearablePill(
              presentation: presentationService.chipPresentationFor(
                GanttActiveFocusChipRole.project,
              ),
              label: selectedProject!.name,
              colorScheme: colorScheme,
              onClear: onClearProject,
            ),
          if (hasBranchFocus)
            _clearablePill(
              presentation: presentationService.chipPresentationFor(
                GanttActiveFocusChipRole.branch,
              ),
              label: 'Branch: $normalizedBranchFocusTitle',
              colorScheme: colorScheme,
              onClear: onClearBranchFocus,
            ),
          if (branchFocusSummary != null) ...[
            _statusPill(
              presentation: presentationService.chipPresentationFor(
                GanttActiveFocusChipRole.branchTaskCount,
              ),
              label: branchFocusSummary!.taskCountLabel,
              colorScheme: colorScheme,
            ),
            _statusPill(
              presentation: presentationService.chipPresentationFor(
                GanttActiveFocusChipRole.branchProgress,
              ),
              label: branchFocusSummary!.progressLabel,
              colorScheme: colorScheme,
            ),
            _statusPill(
              presentation: presentationService.chipPresentationFor(
                GanttActiveFocusChipRole.branchDateRange,
              ),
              label: branchFocusSummary!.dateRangeLabel,
              colorScheme: colorScheme,
            ),
            if (branchFocusSummary!.riskTaskCount > 0)
              _statusPill(
                presentation: presentationService.chipPresentationFor(
                  GanttActiveFocusChipRole.branchRisk,
                ),
                label: branchFocusSummary!.riskLabel,
                colorScheme: colorScheme,
              ),
          ],
          if (viewPreset != GanttTimelineViewPreset.all)
            _clearablePill(
              presentation: presentationService.chipPresentationFor(
                GanttActiveFocusChipRole.view,
              ),
              label: viewPresentation.label,
              icon: viewPresentation.icon,
              colorScheme: colorScheme,
              onClear: onClearViewPreset,
            ),
          if (rangePreset != GanttTimelineRangePreset.planningWindow)
            _clearablePill(
              presentation: presentationService.chipPresentationFor(
                GanttActiveFocusChipRole.range,
              ),
              label: rangePreset.label,
              icon: rangePreset.icon,
              colorScheme: colorScheme,
              onClear: onClearRangePreset,
            ),
          if (statusFilter != GanttTaskStatusFilter.all)
            _clearablePill(
              presentation: presentationService.chipPresentationFor(
                GanttActiveFocusChipRole.status,
              ),
              label: statusFilter.label,
              icon: statusFilter.icon,
              colorScheme: colorScheme,
              color: statusFilter.color(colorScheme),
              onClear: onClearStatus,
            ),
          if (normalizedQuery.isNotEmpty)
            _clearablePill(
              presentation: presentationService.chipPresentationFor(
                GanttActiveFocusChipRole.query,
              ),
              label: '"$normalizedQuery"',
              colorScheme: colorScheme,
              onClear: onClearQuery,
            ),
          AppActionButton(
            label: 'Clear Filters',
            icon: Icons.filter_alt_off_outlined,
            compact: true,
            variant: AppActionButtonVariant.secondary,
            onPressed: onClear,
          ),
        ],
      ),
    );
  }

  Widget _statusPill({
    required GanttActiveFocusChipPresentation presentation,
    required String label,
    required ColorScheme colorScheme,
    String? tooltip,
    IconData? icon,
    Color? color,
  }) {
    return AppStatusPill(
      label: label,
      tooltip: tooltip,
      icon: icon ?? presentation.icon!,
      color: color ?? presentation.colorFor(colorScheme),
      maxWidth: presentation.maxWidth,
    );
  }

  Widget _clearablePill({
    required GanttActiveFocusChipPresentation presentation,
    required String label,
    required ColorScheme colorScheme,
    required VoidCallback? onClear,
    IconData? icon,
    Color? color,
  }) {
    final resolvedColor = color ?? presentation.colorFor(colorScheme);
    final resolvedIcon = icon ?? presentation.icon!;

    if (onClear == null) {
      return AppStatusPill(
        label: label,
        icon: resolvedIcon,
        color: resolvedColor,
        maxWidth: presentation.maxWidth,
      );
    }

    return GanttClearableFocusPill(
      label: label,
      icon: resolvedIcon,
      color: resolvedColor,
      onClear: onClear,
      clearButtonKey: presentation.clearButtonKey,
      clearTooltip: presentation.clearTooltip,
      maxWidth: presentation.maxWidth,
    );
  }
}

@Preview(name: 'Gantt active focus bar')
Widget ganttActiveFocusBarPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: GanttActiveFocusBar(
          query: 'release',
          selectedProject: _previewProject,
          branchFocusTitle: _previewBranchSummary.title,
          branchFocusSummary: _previewBranchSummary,
          statusFilter: GanttTaskStatusFilter.inProgress,
          viewPreset: GanttTimelineViewPreset.dependencyWatch,
          rangePreset: GanttTimelineRangePreset.attentionWindow,
          visibleTaskCount: 3,
          totalTaskCount: 9,
          onClear: () {},
        ),
      ),
    ),
  );
}

final _previewProject = ProjectPortfolioItem(
  id: 'preview-commerce',
  name: 'Commerce Relaunch',
  owner: 'Maya Santoso',
  client: 'Nusantara Retail',
  startDate: DateTime(2026, 5),
  endDate: DateTime(2026, 8),
  progress: 0.62,
  budgetUsed: 0.54,
  health: ProjectHealth.onTrack,
  milestones: const [],
);

final _previewBranchSummary = GanttBranchFocusSummary(
  taskId: 'preview-launch',
  title: 'Launch Readiness',
  taskCount: 6,
  completedTaskCount: 3,
  riskTaskCount: 1,
  averageProgress: 0.58,
  startDate: DateTime(2026, 5, 6),
  endDate: DateTime(2026, 6, 12),
);
