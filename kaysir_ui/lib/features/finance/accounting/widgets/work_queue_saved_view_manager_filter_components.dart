import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../widgets/ui/app_search_field.dart';

/// Compact saved-view manager search field for larger custom-view lists.
class WorkQueueSavedViewManagerFilterField extends StatelessWidget {
  const WorkQueueSavedViewManagerFilterField({
    required this.controller,
    required this.resultCount,
    required this.totalCount,
    required this.onChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController controller;
  final int resultCount;
  final int totalCount;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasQuery = controller.text.trim().isNotEmpty;

    return Row(
      children: [
        Expanded(
          child: AppSearchField(
            key: const ValueKey(
              'accounting-work-queue-saved-view-manager-filter',
            ),
            controller: controller,
            hintText: 'Find queue view',
            tooltip: 'Search saved queue views',
            height: 42,
            onChanged: onChanged,
            trailing:
                hasQuery
                    ? IconButton(
                      key: const ValueKey(
                        'accounting-work-queue-saved-view-manager-filter-clear',
                      ),
                      tooltip: 'Clear view search',
                      visualDensity: VisualDensity.compact,
                      onPressed: onClear,
                      icon: const Icon(Icons.close_rounded, size: 18),
                    )
                    : null,
          ),
        ),
        const SizedBox(width: 10),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: Text(
              '$resultCount / $totalCount',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Empty state shown when saved-view manager search hides every custom view.
class WorkQueueSavedViewManagerFilterEmptyState extends StatelessWidget {
  const WorkQueueSavedViewManagerFilterEmptyState({
    required this.query,
    required this.onClear,
    super.key,
  });

  final String query;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      key: const ValueKey(
        'accounting-work-queue-saved-view-manager-filter-empty',
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.search_off_rounded, color: colorScheme.outline),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'No queue views match "$query".',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            TextButton(onPressed: onClear, child: const Text('Clear')),
          ],
        ),
      ),
    );
  }
}

@Preview(name: 'Work queue saved view manager filter')
Widget workQueueSavedViewManagerFilterComponentsPreview() {
  final controller = TextEditingController(text: 'approver');

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            WorkQueueSavedViewManagerFilterField(
              controller: controller,
              resultCount: 1,
              totalCount: 4,
              onChanged: (_) {},
              onClear: () {},
            ),
            const SizedBox(height: 12),
            WorkQueueSavedViewManagerFilterEmptyState(
              query: controller.text,
              onClear: () {},
            ),
          ],
        ),
      ),
    ),
  );
}
