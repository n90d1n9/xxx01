import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../models/scrum_task_status.dart';
import '../scrum_board_palette.dart';

/// Status chip group that filters the visible board lanes with live counts.
class ScrumBoardStatusFilters extends StatelessWidget {
  const ScrumBoardStatusFilters({
    super.key,
    required this.statuses,
    required this.statusCounts,
    required this.selectedStatus,
    required this.statusLabelFor,
    required this.onStatusChanged,
  });

  final List<ScrumTaskStatus> statuses;
  final Map<ScrumTaskStatus, int> statusCounts;
  final ScrumTaskStatus? selectedStatus;
  final String Function(ScrumTaskStatus status) statusLabelFor;
  final ValueChanged<ScrumTaskStatus?> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final allCount = statuses.fold<int>(
      0,
      (total, status) => total + (statusCounts[status] ?? 0),
    );

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Tooltip(
          message: _statusCountTooltip('All', allCount),
          child: ChoiceChip(
            label: _StatusFilterLabel(label: 'All', count: allCount),
            selected: selectedStatus == null,
            onSelected: (_) => onStatusChanged(null),
          ),
        ),
        for (final status in statuses)
          Tooltip(
            message: _statusCountTooltip(
              statusLabelFor(status),
              statusCounts[status] ?? 0,
            ),
            child: ChoiceChip(
              label: _StatusFilterLabel(
                label: statusLabelFor(status),
                count: statusCounts[status] ?? 0,
              ),
              selected: selectedStatus == status,
              onSelected: (_) => onStatusChanged(status),
            ),
          ),
      ],
    );
  }
}

/// Preview for status chips with representative lane counts.
@Preview(
  group: 'Ky Scrumboard',
  name: 'Status filter chips',
  size: Size(680, 120),
)
Widget scrumBoardStatusFiltersPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: ScrumBoardStatusFilters(
          statuses: const [
            ScrumTaskStatus.backlog,
            ScrumTaskStatus.todo,
            ScrumTaskStatus.inProgress,
            ScrumTaskStatus.review,
            ScrumTaskStatus.done,
          ],
          statusCounts: const {
            ScrumTaskStatus.backlog: 4,
            ScrumTaskStatus.todo: 8,
            ScrumTaskStatus.inProgress: 3,
            ScrumTaskStatus.review: 2,
            ScrumTaskStatus.done: 12,
          },
          selectedStatus: ScrumTaskStatus.inProgress,
          statusLabelFor: (status) => status.label,
          onStatusChanged: (_) {},
        ),
      ),
    ),
  );
}

/// Label content for a status filter chip and its numeric badge.
class _StatusFilterLabel extends StatelessWidget {
  const _StatusFilterLabel({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        const SizedBox(width: 6),
        Container(
          constraints: const BoxConstraints(minWidth: 20),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ScrumBoardPalette.ink.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$count',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: ScrumBoardPalette.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

String _statusCountTooltip(String label, int count) {
  if (count == 1) return '$label: 1 task';
  return '$label: $count tasks';
}
