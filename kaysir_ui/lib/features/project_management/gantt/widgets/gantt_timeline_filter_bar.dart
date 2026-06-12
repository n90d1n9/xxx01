import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';

import '../../project/models/project_portfolio_item.dart';
import '../gantt_dashboard.dart' as gantt;
import '../services/gantt_timeline_filter_presentation_service.dart';
import '../services/gantt_timeline_range_preset_service.dart';
import '../states/gantt_chart_preferences_provider.dart';
import '../states/gantt_filter_provider.dart';
import '../states/gantt_timeline_range_preset_provider.dart';
import 'gantt_timeline_search_field.dart';

/// Filter bar for narrowing, searching, and navigating full-screen Gantt tasks.
class GanttTimelineFilterBar extends ConsumerWidget {
  const GanttTimelineFilterBar({
    required this.viewMode,
    required this.projects,
    required this.selectedProjectId,
    required this.searchController,
    required this.searchFocusNode,
    required this.statusFilter,
    required this.tasks,
    super.key,
  });

  static const compactLayoutKey = ValueKey('gantt-timeline-filter-compact');
  static const wideLayoutKey = ValueKey('gantt-timeline-filter-wide');

  final gantt.ViewMode viewMode;
  final List<ProjectPortfolioItem> projects;
  final String? selectedProjectId;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final GanttTaskStatusFilter statusFilter;
  final List<gantt.GanttTask> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rangePreset = ref.watch(ganttTimelineRangePresetProvider);
    final query = ref.watch(gantt.searchQueryProvider);
    final rangeSummaries = const GanttTimelineRangePresetService().summariesFor(
      tasks: tasks,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = ganttTimelineFilterUsesCompactLayout(
          constraints.maxWidth,
        );
        final searchPresentation = ganttTimelineFilterFieldPresentation(
          GanttTimelineFilterFieldRole.search,
        );
        final projectPresentation = ganttTimelineFilterFieldPresentation(
          GanttTimelineFilterFieldRole.project,
        );
        final statusPresentation = ganttTimelineFilterFieldPresentation(
          GanttTimelineFilterFieldRole.status,
        );
        final viewPresentation = ganttTimelineFilterFieldPresentation(
          GanttTimelineFilterFieldRole.view,
        );
        final rangePresentation = ganttTimelineFilterFieldPresentation(
          GanttTimelineFilterFieldRole.range,
        );
        final search = GanttTimelineSearchField(
          controller: searchController,
          focusNode: searchFocusNode,
          query: query,
          width: searchPresentation.widthFor(compact: isCompact),
          onChanged:
              (value) =>
                  ref.read(gantt.searchQueryProvider.notifier).state = value,
          onClear: () {
            searchController.clear();
            ref.read(gantt.searchQueryProvider.notifier).state = '';
            searchFocusNode.requestFocus();
          },
        );
        final project = AppSelectField<String>(
          label: projectPresentation.label,
          value: selectedProjectId ?? 'all',
          width: projectPresentation.widthFor(compact: isCompact),
          icon: projectPresentation.icon,
          options: [
            const AppSelectOption(value: 'all', label: 'All Projects'),
            for (final project in projects)
              AppSelectOption(value: project.id, label: project.name),
          ],
          onChanged:
              (value) =>
                  ref.read(ganttProjectFilterProvider.notifier).state =
                      value == 'all' ? null : value,
        );
        final status = AppSelectField<GanttTaskStatusFilter>(
          label: statusPresentation.label,
          value: statusFilter,
          width: statusPresentation.widthFor(compact: isCompact),
          icon: statusFilter.icon,
          options: [
            for (final status in GanttTaskStatusFilter.values)
              AppSelectOption(value: status, label: status.label),
          ],
          onChanged:
              (value) =>
                  ref.read(ganttTaskStatusFilterProvider.notifier).state =
                      value,
        );
        final mode = AppSelectField<gantt.ViewMode>(
          label: viewPresentation.label,
          value: viewMode,
          width: viewPresentation.widthFor(compact: isCompact),
          icon: viewPresentation.icon,
          options: [
            for (final mode in gantt.ViewMode.values)
              AppSelectOption(
                value: mode,
                label: ganttViewModePresentation(mode).label,
              ),
          ],
          onChanged:
              (value) =>
                  ref.read(gantt.viewModeProvider.notifier).state = value,
        );
        final range = AppSelectField<GanttTimelineRangePreset>(
          label: rangePresentation.label,
          value: rangePreset,
          width: rangePresentation.widthFor(compact: isCompact),
          icon: rangePreset.icon,
          options: [
            for (final summary in rangeSummaries)
              AppSelectOption(
                value: summary.preset,
                label: summary.optionLabel,
              ),
          ],
          onChanged: (value) => _applyRangePreset(ref, value),
        );

        if (isCompact) {
          return Column(
            key: compactLayoutKey,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              search,
              const SizedBox(height: 12),
              project,
              const SizedBox(height: 12),
              status,
              const SizedBox(height: 12),
              mode,
              const SizedBox(height: 12),
              range,
            ],
          );
        }

        return Wrap(
          key: wideLayoutKey,
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [search, project, status, mode, range],
        );
      },
    );
  }

  void _applyRangePreset(WidgetRef ref, GanttTimelineRangePreset preset) {
    final range = const GanttTimelineRangePresetService().rangeFor(
      preset: preset,
      tasks: tasks,
    );

    ref
        .read(ganttChartWorkspacePreferencesProvider.notifier)
        .setTimelineRangePreset(preset);
    ref.read(gantt.dateRangeProvider.notifier).state = range;
  }
}

@Preview(name: 'Gantt timeline filter bar')
Widget ganttTimelineFilterBarPreview() {
  return const ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(24),
          child: _GanttTimelineFilterBarPreviewHost(),
        ),
      ),
    ),
  );
}

/// Stateful preview wrapper that owns disposable filter bar input controllers.
class _GanttTimelineFilterBarPreviewHost extends StatefulWidget {
  const _GanttTimelineFilterBarPreviewHost();

  @override
  State<_GanttTimelineFilterBarPreviewHost> createState() =>
      _GanttTimelineFilterBarPreviewHostState();
}

/// Preview state that disposes local text and focus controllers correctly.
class _GanttTimelineFilterBarPreviewHostState
    extends State<_GanttTimelineFilterBarPreviewHost> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode(debugLabel: 'Gantt timeline filter preview');

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GanttTimelineFilterBar(
      viewMode: gantt.ViewMode.week,
      projects: [_previewProject],
      selectedProjectId: null,
      searchController: _controller,
      searchFocusNode: _focusNode,
      statusFilter: GanttTaskStatusFilter.all,
      tasks: [_previewTask],
    );
  }
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

final _previewTask = gantt.GanttTask(
  id: 'preview-discovery',
  title: 'Discovery',
  startDate: DateTime(2026, 5, 4),
  endDate: DateTime(2026, 5, 18),
  progress: 0.72,
  projectId: _previewProject.id,
);
