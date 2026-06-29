import 'package:flutter/material.dart';

import '../states/task_state.dart';

class GanttToolbar extends StatelessWidget {
  final ViewMode viewMode;
  final double zoomLevel;
  final void Function()? onPressedToday;
  final void Function(String)? onSearchChanged;
  final void Function(ViewMode)? onChanged;
  final void Function(double)? onZoomChanged;
  const GanttToolbar({
    super.key,
    required this.viewMode,
    this.zoomLevel = 1.0,
    this.onSearchChanged,
    this.onPressedToday,
    this.onChanged,
    this.onZoomChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (value) => onSearchChanged!(value),
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<ViewMode>(
                value: viewMode,
                items:
                    ViewMode.values.map((mode) {
                      return DropdownMenuItem(
                        value: mode,
                        child: Text(mode.toString().split('.').last),
                      );
                    }).toList(),
                onChanged: (value) {
                  onChanged!(value!);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Zoom:'),
              Expanded(
                child: Slider(
                  value: zoomLevel,
                  min: 0.5,
                  max: 2.0,
                  divisions: 6,
                  label: zoomLevel.toStringAsFixed(1),
                  onChanged: (value) {
                    onZoomChanged!(value);
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.today),
                onPressed: () {
                  onPressedToday!();
                },
                tooltip: 'Jump to today',
              ),
              IconButton(
                icon: const Icon(Icons.file_download),
                onPressed: () {
                  // Export functionality here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Exporting chart data...')),
                  );
                },
                tooltip: 'Export',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
