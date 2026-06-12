import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_search_field.dart';

class GanttTimelineSearchField extends StatelessWidget {
  const GanttTimelineSearchField({
    required this.controller,
    required this.focusNode,
    required this.query,
    required this.onChanged,
    required this.onClear,
    this.width,
    super.key,
  });

  static const clearButtonKey = ValueKey('gantt-timeline-search-clear-button');

  final TextEditingController controller;
  final FocusNode focusNode;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final hasQuery = query.trim().isNotEmpty;

    return AppSearchField(
      hintText: 'Search timeline tasks',
      controller: controller,
      focusNode: focusNode,
      width: width,
      trailing:
          hasQuery
              ? IconButton(
                key: clearButtonKey,
                tooltip: 'Clear timeline search',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded, size: 18),
              )
              : null,
      onChanged: onChanged,
    );
  }
}
