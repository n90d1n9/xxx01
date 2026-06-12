import 'package:flutter/material.dart';

import '../models/scrum_task.dart';
import '../models/scrum_task_priority.dart';
import '../models/scrum_task_status.dart';

List<ScrumTask> demoScrumTasks(DateTime now) {
  return [
    ScrumTask(
      id: 'task-auth-flow',
      title: 'Authentication flow polish',
      description:
          'Tighten login, password reset, empty states, and session handoff.',
      assignee: 'Alya',
      storyPoints: 5,
      createdAt: now.subtract(const Duration(days: 4)),
      dueAt: now.add(const Duration(days: 3)),
      status: ScrumTaskStatus.todo,
      priority: ScrumTaskPriority.high,
      label: 'Identity',
      accentColor: const Color(0xFF2563EB),
    ),
    ScrumTask(
      id: 'task-dashboard-signals',
      title: 'Dashboard signal cards',
      description:
          'Add focused KPI summaries for sprint health and release confidence.',
      assignee: 'Bima',
      storyPoints: 3,
      createdAt: now.subtract(const Duration(days: 3)),
      dueAt: now.add(const Duration(days: 5)),
      status: ScrumTaskStatus.inProgress,
      priority: ScrumTaskPriority.medium,
      label: 'Insight',
      accentColor: const Color(0xFF0891B2),
    ),
    ScrumTask(
      id: 'task-api-contracts',
      title: 'API contract review',
      description:
          'Validate task mutations, route payloads, and sync fallback behavior.',
      assignee: 'Citra',
      storyPoints: 8,
      createdAt: now.subtract(const Duration(days: 6)),
      dueAt: now.add(const Duration(days: 1)),
      status: ScrumTaskStatus.review,
      priority: ScrumTaskPriority.critical,
      label: 'Platform',
      accentColor: const Color(0xFFDC2626),
    ),
    ScrumTask(
      id: 'task-release-checklist',
      title: 'Release checklist automation',
      description:
          'Prepare readiness checks for build, route coverage, and smoke tests.',
      assignee: 'Damar',
      storyPoints: 5,
      createdAt: now.subtract(const Duration(days: 8)),
      status: ScrumTaskStatus.done,
      priority: ScrumTaskPriority.medium,
      label: 'Release',
      accentColor: const Color(0xFF16A34A),
    ),
    ScrumTask(
      id: 'task-mobile-density',
      title: 'Mobile board density pass',
      description:
          'Review column layout, tap targets, text wrapping, and card spacing.',
      assignee: 'Eka',
      storyPoints: 2,
      createdAt: now.subtract(const Duration(days: 2)),
      dueAt: now.add(const Duration(days: 6)),
      status: ScrumTaskStatus.backlog,
      priority: ScrumTaskPriority.low,
      label: 'UI',
      accentColor: const Color(0xFF7C3AED),
    ),
  ];
}
