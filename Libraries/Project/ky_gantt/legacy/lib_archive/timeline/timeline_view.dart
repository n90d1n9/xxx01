import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../task/task.dart';

class TimelineView extends StatefulWidget {
  final List<Task> tasks;
  final Function(Task) onTaskSelected;

  const TimelineView(
      {super.key,
      required this.tasks,
      required this.onTaskSelected,
      required Timeline timeline});

  @override
  TimelineViewState createState() => TimelineViewState();
}

class TimelineViewState extends State<TimelineView> {
  // View modes
  TimelineViewMode _currentViewMode = TimelineViewMode.week;

  @override
  Widget build(BuildContext context) {
    // Determine date range for entire project
    DateTime projectStart = _getProjectStartDate(widget.tasks);
    DateTime projectEnd = _getProjectEndDate(widget.tasks);

    return Column(
      children: [
        // View mode selector
        _buildViewModeSelector(),

        // Timeline header with dates
        _buildTimelineHeader(projectStart, projectEnd),

        // Expanded timeline view
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.tasks.length,
            itemBuilder: (context, index) {
              return _buildTimelineRow(widget.tasks[index], projectStart);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildViewModeSelector() {
    return ToggleButtons(
      isSelected: [
        _currentViewMode == TimelineViewMode.week,
        _currentViewMode == TimelineViewMode.month,
        _currentViewMode == TimelineViewMode.quarter
      ],
      onPressed: (index) {
        setState(() {
          switch (index) {
            case 0:
              _currentViewMode = TimelineViewMode.week;
              break;
            case 1:
              _currentViewMode = TimelineViewMode.month;
              break;
            case 2:
              _currentViewMode = TimelineViewMode.quarter;
              break;
          }
        });
      },
      children: const [Text('Week'), Text('Month'), Text('Quarter')],
    );
  }

  Widget _buildTimelineHeader(DateTime start, DateTime end) {
    return Row(
      children: _generateDateMarkers(start, end),
    );
  }

  Widget _buildTimelineRow(Task task, DateTime projectStart) {
    return Container(
      width: _calculateTaskWidth(task, projectStart),
      decoration: BoxDecoration(
          color: _getTaskColor(task),
          border: Border.all(color: Colors.black26)),
      child: Text(
        task.name!,
        style: const TextStyle(fontSize: 12),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  List<Widget> _generateDateMarkers(DateTime start, DateTime end) {
    List<Widget> markers = [];
    DateTime current = start;

    while (current.isBefore(end)) {
      markers.add(Text(
        _formatDateForView(current),
        style: const TextStyle(fontSize: 10),
      ));

      current = _incrementDateBasedOnView(current);
    }
    return markers;
  }

  // Utility methods
  DateTime _getProjectStartDate(List<Task> tasks) {
    return tasks
        .map((t) => t.startDate!)
        .reduce((a, b) => a.isBefore(b) ? a : b);
  }

  DateTime _getProjectEndDate(List<Task> tasks) {
    return tasks.map((t) => t.endDate!).reduce((a, b) => a.isAfter(b) ? a : b);
  }

  double _calculateTaskWidth(Task task, DateTime projectStart) {
    return task.startDate!.difference(projectStart).inDays.toDouble();
  }

  Color _getTaskColor(Task task) {
    if (task.progress! < 25) return Colors.red.shade100;
    if (task.progress! < 50) return Colors.orange.shade100;
    if (task.progress! < 75) return Colors.yellow.shade100;
    return Colors.green.shade100;
  }

  String _formatDateForView(DateTime date) {
    switch (_currentViewMode) {
      case TimelineViewMode.week:
        return DateFormat('EEE dd').format(date);
      case TimelineViewMode.month:
        return DateFormat('MMM').format(date);
      case TimelineViewMode.quarter:
        return 'Q${((date.month - 1) ~/ 3) + 1}';
    }
  }

  DateTime _incrementDateBasedOnView(DateTime current) {
    switch (_currentViewMode) {
      case TimelineViewMode.week:
        return current.add(const Duration(days: 7));
      case TimelineViewMode.month:
        return DateTime(current.year, current.month + 1);
      case TimelineViewMode.quarter:
        return DateTime(current.year, current.month + 3);
    }
  }
}

// Enum for view modes
enum TimelineViewMode { week, month, quarter }
