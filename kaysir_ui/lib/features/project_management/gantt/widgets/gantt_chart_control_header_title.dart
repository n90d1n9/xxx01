import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

import '../services/gantt_chart_control_header_presentation_service.dart';

/// Responsive title block for the full-screen Gantt chart control header.
class GanttChartControlHeaderTitle extends StatelessWidget {
  const GanttChartControlHeaderTitle({required this.dateRange, super.key});

  final DateTimeRange dateRange;

  @override
  Widget build(BuildContext context) {
    final presentation = const GanttChartControlHeaderPresentationService()
        .presentationFor(dateRange: dateRange);

    return AppTextCluster(
      eyebrow: presentation.eyebrow,
      title: presentation.title,
      subtitle: presentation.subtitle,
      titleStyle: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
      subtitleMaxLines: 2,
    );
  }
}

@Preview(name: 'Gantt control header title')
Widget ganttChartControlHeaderTitlePreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: GanttChartControlHeaderTitle(
            dateRange: DateTimeRange(
              start: DateTime(2026, 5, 1),
              end: DateTime(2026, 6, 14),
            ),
          ),
        ),
      ),
    ),
  );
}
