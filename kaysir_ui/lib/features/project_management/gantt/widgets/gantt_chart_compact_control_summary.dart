import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/gantt_chart_compact_control_summary_presentation_service.dart';
import '../services/gantt_chart_compact_control_summary_service.dart';
import '../services/gantt_saved_view_service.dart';
import '../services/gantt_timeline_range_preset_service.dart';
import '../states/gantt_chart_display_provider.dart';
import '../states/gantt_chart_interaction_provider.dart';
import '../states/gantt_chart_preferences_provider.dart';
import '../states/gantt_filter_provider.dart';
import '../states/gantt_timeline_range_preset_provider.dart';

/// Collapsed summary of active full-screen Gantt chart controls.
class GanttChartCompactControlSummary extends ConsumerWidget {
  const GanttChartCompactControlSummary({super.key});

  static const summaryKey = ValueKey('gantt-chart-compact-control-summary');
  static const summarySemanticsKey = ValueKey(
    'gantt-chart-compact-control-summary-semantics',
  );
  static const wrappedLayoutKey = ValueKey(
    'gantt-chart-compact-control-summary-wrapped-layout',
  );
  static const scrollLayoutKey = ValueKey(
    'gantt-chart-compact-control-summary-scroll-layout',
  );

  static Key itemKey(GanttChartCompactControlSummaryRole role) {
    return ValueKey('gantt-chart-compact-control-summary-${role.name}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayPreferences = ref.watch(ganttChartDisplayPreferencesProvider);
    final interactionPreferences = ref.watch(
      ganttChartInteractionPreferencesProvider,
    );
    final timelineView = ref.watch(ganttTimelineViewProvider);
    final rangePreset = ref.watch(ganttTimelineRangePresetProvider);
    final summary = const GanttChartCompactControlSummaryService().summaryFor(
      displayPreferences: displayPreferences,
      interactionPreferences: interactionPreferences,
      timelineView: timelineView,
      rangePreset: rangePreset,
    );

    return GanttChartCompactControlSummaryView(summary: summary);
  }
}

class GanttChartCompactControlSummaryView extends StatelessWidget {
  const GanttChartCompactControlSummaryView({required this.summary, super.key});

  final GanttChartCompactControlSummarySnapshot summary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const pillPadding = EdgeInsets.symmetric(horizontal: 8, vertical: 3);

    return Semantics(
      key: GanttChartCompactControlSummary.summarySemanticsKey,
      container: true,
      label: summary.semanticsLabel,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: DecoratedBox(
          key: GanttChartCompactControlSummary.summaryKey,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final useWrappedLayout = constraints.maxWidth >= 720;
                final pills = [
                  for (final item in summary.items)
                    _CompactSummaryPill(item: item, padding: pillPadding),
                ];

                if (useWrappedLayout) {
                  return Wrap(
                    key: GanttChartCompactControlSummary.wrappedLayoutKey,
                    spacing: 10,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 260,
                          maxWidth: 340,
                        ),
                        child: _CompactSummaryLead(summary: summary),
                      ),
                      ...pills,
                    ],
                  );
                }

                return SingleChildScrollView(
                  key: GanttChartCompactControlSummary.scrollLayoutKey,
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 286,
                        child: _CompactSummaryLead(summary: summary),
                      ),
                      for (final pill in pills) ...[
                        const SizedBox(width: 10),
                        pill,
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactSummaryLead extends StatelessWidget {
  const _CompactSummaryLead({required this.summary});

  final GanttChartCompactControlSummarySnapshot summary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: Icon(
              Icons.tune_outlined,
              size: 17,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                summary.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                summary.headline,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompactSummaryPill extends StatelessWidget {
  const _CompactSummaryPill({required this.item, required this.padding});

  final GanttChartCompactControlSummaryItem item;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final presentation = ganttChartCompactControlSummaryRolePresentation(
      item.role,
    );

    return AppStatusPill(
      key: GanttChartCompactControlSummary.itemKey(item.role),
      label: item.label,
      tooltip: item.tooltip,
      icon: presentation.icon,
      color: _accentColor(colorScheme, presentation.accent),
      maxWidth: presentation.maxWidth,
      padding: padding,
    );
  }

  Color _accentColor(
    ColorScheme colorScheme,
    GanttChartCompactControlSummaryAccent accent,
  ) {
    switch (accent) {
      case GanttChartCompactControlSummaryAccent.primary:
        return colorScheme.primary;
      case GanttChartCompactControlSummaryAccent.secondary:
        return colorScheme.secondary;
      case GanttChartCompactControlSummaryAccent.tertiary:
        return colorScheme.tertiary;
    }
  }
}

@Preview(name: 'Gantt compact control summary')
Widget ganttChartCompactControlSummaryPreview() {
  final summary = const GanttChartCompactControlSummaryService().summaryFor(
    displayPreferences: GanttChartDisplayPreferences.initial,
    interactionPreferences: GanttChartInteractionPreferences.initial,
    timelineView: GanttTimelineViewPreset.all,
    rangePreset: GanttTimelineRangePreset.planningWindow,
  );

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: GanttChartCompactControlSummaryView(summary: summary),
      ),
    ),
  );
}
