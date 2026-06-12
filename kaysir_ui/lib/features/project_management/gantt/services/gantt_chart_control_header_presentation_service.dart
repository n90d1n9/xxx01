import 'package:flutter/material.dart';

/// Presentation copy for the full-screen Gantt chart control header.
class GanttChartControlHeaderPresentation {
  const GanttChartControlHeaderPresentation({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.dateRangeLabel,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final String dateRangeLabel;
}

/// Builds user-facing copy for the full-screen Gantt chart control header.
class GanttChartControlHeaderPresentationService {
  const GanttChartControlHeaderPresentationService();

  static const eyebrow = 'Timeline Planning';
  static const title = 'Full Gantt Chart';

  GanttChartControlHeaderPresentation presentationFor({
    required DateTimeRange dateRange,
  }) {
    final rangeLabel = dateRangeLabelFor(dateRange);

    return GanttChartControlHeaderPresentation(
      eyebrow: eyebrow,
      title: title,
      subtitle: 'Interactive schedule canvas for $rangeLabel.',
      dateRangeLabel: rangeLabel,
    );
  }

  String dateRangeLabelFor(DateTimeRange dateRange) {
    final start = dateRange.start;
    final end = dateRange.end;

    if (start.year == end.year && start.month == end.month) {
      return '${_monthLabel(start.month)} ${start.day}-${end.day}';
    }

    if (start.year == end.year) {
      return '${_monthDayLabel(start)} - ${_monthDayLabel(end)}';
    }

    return '${_monthDayYearLabel(start)} - ${_monthDayYearLabel(end)}';
  }

  String _monthDayLabel(DateTime date) {
    return '${_monthLabel(date.month)} ${date.day}';
  }

  String _monthDayYearLabel(DateTime date) {
    return '${_monthDayLabel(date)}, ${date.year}';
  }

  String _monthLabel(int month) {
    return _monthLabels[month - 1];
  }
}

const _monthLabels = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
