import 'package:flutter/foundation.dart';

import 'scrum_board_filter.dart';
import 'scrum_task_priority.dart';
import 'scrum_task_sort.dart';
import 'scrum_task_status.dart';

const defaultScrumBoardViewPresets = [
  ScrumBoardViewPreset(
    id: 'all-work',
    label: 'All work',
    description: 'Show every visible lane in lane order.',
    filter: ScrumBoardFilter(),
  ),
  ScrumBoardViewPreset(
    id: 'critical',
    label: 'Critical',
    description: 'Focus on critical work first.',
    filter: ScrumBoardFilter(
      priorities: {ScrumTaskPriority.critical},
      sort: ScrumTaskSort.priority,
    ),
  ),
  ScrumBoardViewPreset(
    id: 'due-first',
    label: 'Due first',
    description: 'Prioritize tasks with the nearest due dates.',
    filter: ScrumBoardFilter(sort: ScrumTaskSort.dueDate),
  ),
  ScrumBoardViewPreset(
    id: 'completed',
    label: 'Completed',
    description: 'Review recently completed work.',
    filter: ScrumBoardFilter(
      status: ScrumTaskStatus.done,
      sort: ScrumTaskSort.newest,
    ),
  ),
];

@immutable
class ScrumBoardViewPreset {
  const ScrumBoardViewPreset({
    required this.id,
    required this.label,
    required this.filter,
    this.description = '',
  });

  final String id;
  final String label;
  final ScrumBoardFilter filter;
  final String description;

  bool matches(ScrumBoardFilter currentFilter) {
    return filter.hasSameCriteria(currentFilter);
  }
}
