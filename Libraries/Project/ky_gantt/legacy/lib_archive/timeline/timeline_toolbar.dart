import 'package:flutter/material.dart';

import '../color/export_button.dart';
import '../filter/filter_button.dart';

class TimelineToolbar extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final onZoomIn;
  final toggleCriticalPath;
  final onZoomOut;

  final currentFilters;
  const TimelineToolbar(
      {super.key,
      required this.startDate,
      required this.endDate,
      this.onZoomIn,
      this.toggleCriticalPath,
      this.onZoomOut,
      this.currentFilters});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () =>
                onZoomIn //() => ganttState.setZoomLevel(ganttState.zoomLevel + 0.1),
            ),
        IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () =>
                onZoomOut //ganttState.setZoomLevel(ganttState.zoomLevel - 0.1),
            ),
        IconButton(
            icon: const Icon(Icons.route),
            onPressed: () => toggleCriticalPath //ganttState.toggleCriticalPath,
            ),
        FilterButton(
          onFilterChange: (FilterOptions) {},
          currentFilters: currentFilters,
        ),
        ExportButton(
          tasks: [],
          startDate: startDate,
          endDate: endDate,
        ),
      ],
    );
  }
}
