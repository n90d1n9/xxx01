import 'package:flutter/material.dart';
import '../models/task_model.dart';
import 'date_utils.dart';

// ─── WBS Calculator ───────────────────────────────────────────────────────────

class WbsCalculator {
  WbsCalculator._();

  static List<Task> assignWbsCodes(List<Task> tasks) {
    final taskMap = {for (final t in tasks) t.id: t};
    final updated = <String, String>{};

    // Get root-level tasks in order
    final roots = tasks.where((t) => t.parentId == null || !taskMap.containsKey(t.parentId)).toList();
    int rootIdx = 1;
    for (final root in roots) {
      _assign(root, '$rootIdx', tasks, taskMap, updated);
      rootIdx++;
    }

    return tasks.map((t) => updated.containsKey(t.id) ? t.copyWith(wbsCode: updated[t.id]) : t).toList();
  }

  static void _assign(Task task, String prefix, List<Task> all, Map<String, Task> map, Map<String, String> out) {
    out[task.id] = prefix;
    final children = all.where((t) => t.parentId == task.id).toList();
    int idx = 1;
    for (final child in children) {
      _assign(child, '$prefix.$idx', all, map, out);
      idx++;
    }
  }
}

// ─── Sample Data Generator ───────────────────────────────────────────────────

class SampleDataGenerator {
  SampleDataGenerator._();

  static final _assignees = [
    Assignee(id: 'a1', name: 'Alex Chen', avatarColor: const Color(0xFF6366F1), allocatedHoursPerDay: 8),
    Assignee(id: 'a2', name: 'Sarah Kim', avatarColor: const Color(0xFF10B981), allocatedHoursPerDay: 8),
    Assignee(id: 'a3', name: 'Marcus Davis', avatarColor: const Color(0xFFF59E0B), allocatedHoursPerDay: 6),
    Assignee(id: 'a4', name: 'Priya Patel', avatarColor: const Color(0xFFEF4444), allocatedHoursPerDay: 8),
    Assignee(id: 'a5', name: 'Jordan Lee', avatarColor: const Color(0xFF8B5CF6), allocatedHoursPerDay: 4),
    Assignee(id: 'a6', name: 'Fatima Hassan', avatarColor: const Color(0xFF06B6D4), allocatedHoursPerDay: 8),
  ];

  static List<Task> generate() {
    final now = DateTime.now();
    final base = GanttDateUtils.dateOnly(now).subtract(const Duration(days: 45));

    final tasks = <Task>[
      // ── Phase 1: Discovery ─────────────────────────────────────────────
      Task(
        id: 'p1', title: 'Discovery & Planning', parentId: null,
        startDate: base, endDate: base.add(const Duration(days: 20)),
        status: TaskStatus.done, priority: TaskPriority.high,
        progress: 1.0, assignees: [_assignees[0], _assignees[1]],
        labels: ['phase'], estimatedHours: 80, actualHours: 76,
        createdAt: base.subtract(const Duration(days: 5)), updatedAt: base.add(const Duration(days: 20)),
        baseline: TaskBaseline(startDate: base, endDate: base.add(const Duration(days: 18)), progress: 0.0, capturedAt: base, label: 'v1.0 Baseline'),
      ),
      Task(
        id: 't1', title: 'Project Kickoff Meeting', parentId: 'p1',
        startDate: base, endDate: base.add(const Duration(days: 1)),
        status: TaskStatus.done, priority: TaskPriority.high,
        progress: 1.0, assignees: _assignees.take(4).toList(),
        labels: ['meeting'], estimatedHours: 8, actualHours: 8,
        isMilestone: false,
        createdAt: base, updatedAt: base.add(const Duration(days: 1)),
      ),
      Task(
        id: 't2', title: 'Stakeholder Requirements Gathering', parentId: 'p1',
        startDate: base.add(const Duration(days: 2)), endDate: base.add(const Duration(days: 10)),
        status: TaskStatus.done, priority: TaskPriority.critical,
        progress: 1.0, assignees: [_assignees[0], _assignees[3]],
        labels: ['requirements'], estimatedHours: 32, actualHours: 38,
        checklist: [
          ChecklistItem(id: 'c1', text: 'Interview stakeholders', isCompleted: true),
          ChecklistItem(id: 'c2', text: 'Document user stories', isCompleted: true),
          ChecklistItem(id: 'c3', text: 'Prioritize backlog', isCompleted: true),
        ],
        dependencies: const [TaskDependency(predecessorId: 't1', type: DependencyType.fs)],
        createdAt: base, updatedAt: base.add(const Duration(days: 10)),
        baseline: TaskBaseline(startDate: base.add(const Duration(days: 2)), endDate: base.add(const Duration(days: 9)), progress: 0.0, capturedAt: base, label: 'v1.0 Baseline'),
      ),
      Task(
        id: 't3', title: 'Technical Architecture Review', parentId: 'p1',
        startDate: base.add(const Duration(days: 11)), endDate: base.add(const Duration(days: 17)),
        status: TaskStatus.done, priority: TaskPriority.high,
        progress: 1.0, assignees: [_assignees[1], _assignees[2]],
        labels: ['architecture'], estimatedHours: 24, actualHours: 22,
        riskLevel: RiskLevel.low,
        dependencies: const [TaskDependency(predecessorId: 't2', type: DependencyType.fs)],
        createdAt: base, updatedAt: base.add(const Duration(days: 17)),
      ),
      Task(
        id: 'm1', title: 'Discovery Phase Complete', parentId: 'p1',
        startDate: base.add(const Duration(days: 20)), endDate: base.add(const Duration(days: 20)),
        status: TaskStatus.done, priority: TaskPriority.high,
        progress: 1.0, isMilestone: true,
        assignees: [_assignees[0]],
        dependencies: const [TaskDependency(predecessorId: 't3', type: DependencyType.fs)],
        createdAt: base, updatedAt: base.add(const Duration(days: 20)),
      ),

      // ── Phase 2: Design ────────────────────────────────────────────────
      Task(
        id: 'p2', title: 'UX / Design', parentId: null,
        startDate: base.add(const Duration(days: 21)), endDate: base.add(const Duration(days: 45)),
        status: TaskStatus.done, priority: TaskPriority.high,
        progress: 1.0, assignees: [_assignees[1], _assignees[4]],
        labels: ['phase'], estimatedHours: 96, actualHours: 100,
        createdAt: base, updatedAt: base.add(const Duration(days: 45)),
      ),
      Task(
        id: 't4', title: 'Wireframe Prototyping', parentId: 'p2',
        startDate: base.add(const Duration(days: 21)), endDate: base.add(const Duration(days: 31)),
        status: TaskStatus.done, priority: TaskPriority.medium,
        progress: 1.0, assignees: [_assignees[1]],
        labels: ['design', 'ux'], estimatedHours: 40, actualHours: 44,
        dependencies: const [TaskDependency(predecessorId: 'm1', type: DependencyType.fs)],
        createdAt: base, updatedAt: base.add(const Duration(days: 31)),
      ),
      Task(
        id: 't5', title: 'Design System Creation', parentId: 'p2',
        startDate: base.add(const Duration(days: 28)), endDate: base.add(const Duration(days: 40)),
        status: TaskStatus.done, priority: TaskPriority.medium,
        progress: 1.0, assignees: [_assignees[1], _assignees[4]],
        labels: ['design'], estimatedHours: 48, actualHours: 45,
        riskLevel: RiskLevel.low,
        dependencies: const [TaskDependency(predecessorId: 't4', type: DependencyType.ss, lagDays: 7)],
        createdAt: base, updatedAt: base.add(const Duration(days: 40)),
      ),
      Task(
        id: 't6', title: 'Design Review & Approval', parentId: 'p2',
        startDate: base.add(const Duration(days: 41)), endDate: base.add(const Duration(days: 45)),
        status: TaskStatus.done, priority: TaskPriority.medium,
        progress: 1.0, assignees: [_assignees[0], _assignees[1]],
        labels: ['review'], estimatedHours: 16, actualHours: 12,
        dependencies: const [TaskDependency(predecessorId: 't5', type: DependencyType.fs)],
        createdAt: base, updatedAt: base.add(const Duration(days: 45)),
      ),

      // ── Phase 3: Development ───────────────────────────────────────────
      Task(
        id: 'p3', title: 'Backend Development', parentId: null,
        startDate: base.add(const Duration(days: 42)), endDate: base.add(const Duration(days: 90)),
        status: TaskStatus.inProgress, priority: TaskPriority.critical,
        progress: 0.55, assignees: [_assignees[2], _assignees[3]],
        labels: ['phase', 'backend'], estimatedHours: 200, actualHours: 110,
        riskLevel: RiskLevel.medium,
        createdAt: base, updatedAt: now,
      ),
      Task(
        id: 't7', title: 'Database Schema Design', parentId: 'p3',
        startDate: base.add(const Duration(days: 42)), endDate: base.add(const Duration(days: 52)),
        status: TaskStatus.done, priority: TaskPriority.high,
        progress: 1.0, assignees: [_assignees[2]],
        labels: ['backend', 'database'], estimatedHours: 32, actualHours: 35,
        dependencies: const [TaskDependency(predecessorId: 't6', type: DependencyType.fs)],
        createdAt: base, updatedAt: base.add(const Duration(days: 52)),
      ),
      Task(
        id: 't8', title: 'REST API Development', parentId: 'p3',
        startDate: base.add(const Duration(days: 53)), endDate: now.add(const Duration(days: 14)),
        status: TaskStatus.inProgress, priority: TaskPriority.critical,
        progress: 0.6, assignees: [_assignees[2], _assignees[3]],
        labels: ['backend', 'api'], estimatedHours: 120, actualHours: 72,
        riskLevel: RiskLevel.medium,
        checklist: [
          ChecklistItem(id: 'c4', text: 'Auth endpoints', isCompleted: true),
          ChecklistItem(id: 'c5', text: 'CRUD for core entities', isCompleted: true),
          ChecklistItem(id: 'c6', text: 'WebSocket events', isCompleted: false),
          ChecklistItem(id: 'c7', text: 'Rate limiting & security', isCompleted: false),
        ],
        dependencies: const [TaskDependency(predecessorId: 't7', type: DependencyType.fs)],
        timeEntries: [
          TimeEntry(id: 'te1', userId: 'a3', userName: 'Marcus Davis', date: now.subtract(const Duration(days: 5)), hours: 8),
          TimeEntry(id: 'te2', userId: 'a4', userName: 'Priya Patel', date: now.subtract(const Duration(days: 3)), hours: 7.5),
          TimeEntry(id: 'te3', userId: 'a3', userName: 'Marcus Davis', date: now.subtract(const Duration(days: 1)), hours: 8),
        ],
        createdAt: base, updatedAt: now,
      ),
      Task(
        id: 't9', title: 'Unit & Integration Tests', parentId: 'p3',
        startDate: now.add(const Duration(days: 10)), endDate: now.add(const Duration(days: 28)),
        status: TaskStatus.todo, priority: TaskPriority.high,
        progress: 0.0, assignees: [_assignees[3]],
        labels: ['testing', 'backend'], estimatedHours: 48, actualHours: 0,
        dependencies: const [TaskDependency(predecessorId: 't8', type: DependencyType.fs)],
        createdAt: base, updatedAt: now,
      ),

      // ── Phase 4: Frontend ──────────────────────────────────────────────
      Task(
        id: 'p4', title: 'Frontend Development', parentId: null,
        startDate: base.add(const Duration(days: 46)), endDate: now.add(const Duration(days: 30)),
        status: TaskStatus.inProgress, priority: TaskPriority.high,
        progress: 0.4, assignees: [_assignees[4], _assignees[5]],
        labels: ['phase', 'frontend'], estimatedHours: 160, actualHours: 64,
        riskLevel: RiskLevel.low,
        createdAt: base, updatedAt: now,
      ),
      Task(
        id: 't10', title: 'Component Library Setup', parentId: 'p4',
        startDate: base.add(const Duration(days: 46)), endDate: base.add(const Duration(days: 58)),
        status: TaskStatus.done, priority: TaskPriority.medium,
        progress: 1.0, assignees: [_assignees[4]],
        labels: ['frontend', 'design-system'], estimatedHours: 32, actualHours: 30,
        dependencies: const [TaskDependency(predecessorId: 't5', type: DependencyType.fs)],
        createdAt: base, updatedAt: base.add(const Duration(days: 58)),
      ),
      Task(
        id: 't11', title: 'Core UI Screens', parentId: 'p4',
        startDate: base.add(const Duration(days: 59)), endDate: now.add(const Duration(days: 7)),
        status: TaskStatus.inProgress, priority: TaskPriority.high,
        progress: 0.5, assignees: [_assignees[4], _assignees[5]],
        labels: ['frontend', 'ui'], estimatedHours: 80, actualHours: 40,
        riskLevel: RiskLevel.low,
        checklist: [
          ChecklistItem(id: 'c8', text: 'Dashboard', isCompleted: true),
          ChecklistItem(id: 'c9', text: 'Settings page', isCompleted: true),
          ChecklistItem(id: 'c10', text: 'Reports screen', isCompleted: false),
          ChecklistItem(id: 'c11', text: 'Mobile responsive', isCompleted: false),
        ],
        dependencies: const [TaskDependency(predecessorId: 't10', type: DependencyType.fs)],
        createdAt: base, updatedAt: now,
      ),
      Task(
        id: 't12', title: 'API Integration', parentId: 'p4',
        startDate: now.add(const Duration(days: 5)), endDate: now.add(const Duration(days: 22)),
        status: TaskStatus.todo, priority: TaskPriority.high,
        progress: 0.0, assignees: [_assignees[5]],
        labels: ['frontend', 'integration'], estimatedHours: 48, actualHours: 0,
        dependencies: const [
          TaskDependency(predecessorId: 't8', type: DependencyType.fs),
          TaskDependency(predecessorId: 't11', type: DependencyType.ss),
        ],
        createdAt: base, updatedAt: now,
      ),

      // ── Phase 5: QA ────────────────────────────────────────────────────
      Task(
        id: 'p5', title: 'Quality Assurance', parentId: null,
        startDate: now.add(const Duration(days: 20)), endDate: now.add(const Duration(days: 52)),
        status: TaskStatus.backlog, priority: TaskPriority.high,
        progress: 0.0, assignees: [_assignees[3]],
        labels: ['phase', 'qa'], estimatedHours: 80, actualHours: 0,
        createdAt: base, updatedAt: now,
      ),
      Task(
        id: 't13', title: 'End-to-End Testing', parentId: 'p5',
        startDate: now.add(const Duration(days: 20)), endDate: now.add(const Duration(days: 35)),
        status: TaskStatus.backlog, priority: TaskPriority.high,
        progress: 0.0, assignees: [_assignees[3]],
        labels: ['qa', 'testing'], estimatedHours: 40, actualHours: 0,
        riskLevel: RiskLevel.medium,
        dependencies: const [TaskDependency(predecessorId: 't9', type: DependencyType.fs)],
        createdAt: base, updatedAt: now,
      ),
      Task(
        id: 't14', title: 'Performance & Load Testing', parentId: 'p5',
        startDate: now.add(const Duration(days: 35)), endDate: now.add(const Duration(days: 45)),
        status: TaskStatus.backlog, priority: TaskPriority.medium,
        progress: 0.0, assignees: [_assignees[2], _assignees[3]],
        labels: ['qa', 'performance'], estimatedHours: 24, actualHours: 0,
        riskLevel: RiskLevel.high,
        dependencies: const [TaskDependency(predecessorId: 't13', type: DependencyType.fs)],
        createdAt: base, updatedAt: now,
      ),
      Task(
        id: 't15', title: 'UAT Sign-off', parentId: 'p5',
        startDate: now.add(const Duration(days: 46)), endDate: now.add(const Duration(days: 52)),
        status: TaskStatus.backlog, priority: TaskPriority.high,
        progress: 0.0, assignees: _assignees.take(3).toList(),
        labels: ['qa', 'sign-off'], estimatedHours: 16, actualHours: 0,
        dependencies: const [TaskDependency(predecessorId: 't14', type: DependencyType.fs)],
        createdAt: base, updatedAt: now,
      ),

      // ── Phase 6: Launch ────────────────────────────────────────────────
      Task(
        id: 'p6', title: 'Launch & Go-Live', parentId: null,
        startDate: now.add(const Duration(days: 53)), endDate: now.add(const Duration(days: 65)),
        status: TaskStatus.backlog, priority: TaskPriority.critical,
        progress: 0.0, assignees: _assignees.toList(),
        labels: ['phase', 'launch'], estimatedHours: 40, actualHours: 0,
        riskLevel: RiskLevel.high,
        createdAt: base, updatedAt: now,
      ),
      Task(
        id: 't16', title: 'Production Deployment', parentId: 'p6',
        startDate: now.add(const Duration(days: 53)), endDate: now.add(const Duration(days: 55)),
        status: TaskStatus.backlog, priority: TaskPriority.critical,
        progress: 0.0, assignees: [_assignees[2], _assignees[3]],
        labels: ['devops', 'launch'], estimatedHours: 16, actualHours: 0,
        riskLevel: RiskLevel.critical,
        dependencies: const [TaskDependency(predecessorId: 't15', type: DependencyType.fs)],
        createdAt: base, updatedAt: now,
      ),
      Task(
        id: 'm2', title: '🚀 MVP Launch', parentId: 'p6',
        startDate: now.add(const Duration(days: 56)), endDate: now.add(const Duration(days: 56)),
        status: TaskStatus.backlog, priority: TaskPriority.critical,
        progress: 0.0, isMilestone: true,
        assignees: [_assignees[0]],
        dependencies: const [TaskDependency(predecessorId: 't16', type: DependencyType.fs)],
        createdAt: base, updatedAt: now,
        color: const Color(0xFF10B981),
      ),
      Task(
        id: 't17', title: 'Post-launch Monitoring', parentId: 'p6',
        startDate: now.add(const Duration(days: 57)), endDate: now.add(const Duration(days: 65)),
        status: TaskStatus.backlog, priority: TaskPriority.high,
        progress: 0.0, assignees: [_assignees[2], _assignees[5]],
        labels: ['monitoring', 'devops'], estimatedHours: 24, actualHours: 0,
        dependencies: const [TaskDependency(predecessorId: 'm2', type: DependencyType.fs)],
        createdAt: base, updatedAt: now,
      ),
    ];

    // Add some comments to in-progress tasks
    final commented = tasks.map((t) {
      if (t.id == 't8') {
        return t.copyWith(comments: [
          TaskComment(id: 'cmt1', authorId: 'a3', authorName: 'Marcus Davis', content: 'WebSocket implementation is more complex than estimated, may need extra 2 days.', timestamp: now.subtract(const Duration(days: 2))),
          TaskComment(id: 'cmt2', authorId: 'a4', authorName: 'Priya Patel', content: 'Agreed. Let\'s pair on it tomorrow morning.', timestamp: now.subtract(const Duration(days: 1))),
        ]);
      }
      if (t.id == 't11') {
        return t.copyWith(comments: [
          TaskComment(id: 'cmt3', authorId: 'a5', authorName: 'Jordan Lee', content: 'Reports screen design has been finalized, starting implementation.', timestamp: now.subtract(const Duration(hours: 5))),
        ]);
      }
      return t;
    }).toList();

    return WbsCalculator.assignWbsCodes(commented);
  }
}
