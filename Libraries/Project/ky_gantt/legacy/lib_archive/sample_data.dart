import 'package:flutter/material.dart';
import '../models/task_model.dart';

class WbsCalculator {
  WbsCalculator._();
  static List<Task> assignWbsCodes(List<Task> tasks) {
    final taskMap = {for (final t in tasks) t.id: t};
    final ordered = _topologicalOrder(tasks, taskMap);
    final result = <Task>[];
    final counters = <String?, int>{};
    for (final task in ordered) {
      final parentId = task.parentId;
      final idx = (counters[parentId] ?? 0) + 1;
      counters[parentId] = idx;
      String wbs;
      if (parentId == null || !taskMap.containsKey(parentId)) {
        wbs = '$idx';
      } else {
        final parentTask = result.firstWhere((t) => t.id == parentId, orElse: () => task);
        wbs = '${parentTask.wbsCode ?? '0'}.$idx';
      }
      result.add(task.copyWith(wbsCode: wbs));
    }
    return result;
  }
  static List<Task> _topologicalOrder(List<Task> tasks, Map<String, Task> taskMap) {
    final result = <Task>[];
    final visited = <String>{};
    void visit(Task task) {
      if (visited.contains(task.id)) return;
      visited.add(task.id);
      result.add(task);
      for (final child in tasks.where((t) => t.parentId == task.id)) { visit(child); }
    }
    for (final root in tasks.where((t) => t.parentId == null || !taskMap.containsKey(t.parentId))) { visit(root); }
    return result;
  }
}

class SampleDataGenerator {
  SampleDataGenerator._();
  static const a1 = Assignee(id: 'a1', name: 'Alice Chen',   avatarColor: Color(0xFF6366F1));
  static const a2 = Assignee(id: 'a2', name: 'Bob Smith',    avatarColor: Color(0xFF10B981));
  static const a3 = Assignee(id: 'a3', name: 'Carol Davis',  avatarColor: Color(0xFFEC4899));
  static const a4 = Assignee(id: 'a4', name: 'Dan Lee',      avatarColor: Color(0xFF3B82F6));
  static const a5 = Assignee(id: 'a5', name: 'Eva Park',     avatarColor: Color(0xFF06B6D4));
  static const a6 = Assignee(id: 'a6', name: 'Frank Torres', avatarColor: Color(0xFFF59E0B));

  static List<Assignee> get allAssignees => [a1, a2, a3, a4, a5, a6];

  static List<Task> generate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final t = (String id, String title, DateTime start, DateTime end, {
      String? desc, TaskStatus status = TaskStatus.todo, TaskPriority priority = TaskPriority.medium,
      double progress = 0.0, Color? color, bool isMilestone = false, String? parentId,
      List<TaskDependency> deps = const [], List<Assignee> assignees = const [],
      List<String> labels = const [], double estimatedHours = 0, double actualHours = 0,
      List<ChecklistItem> checklist = const [], List<TaskComment> comments = const [],
      RiskLevel riskLevel = RiskLevel.none,
    }) => Task(
      id: id, title: title, description: desc, startDate: start, endDate: end,
      status: status, priority: priority, progress: progress, color: color,
      isMilestone: isMilestone, parentId: parentId, dependencies: deps,
      assignees: assignees, labels: labels, estimatedHours: estimatedHours,
      actualHours: actualHours, checklist: checklist, comments: comments,
      riskLevel: riskLevel,
      createdAt: now.subtract(const Duration(days: 15)), updatedAt: now,
    );

    final tasks = [
      t('t1','Project Kickoff & Planning', today.subtract(const Duration(days:10)), today.subtract(const Duration(days:8)),
        desc:'Define scope, objectives, and stakeholder alignment', status:TaskStatus.done,
        priority:TaskPriority.critical, progress:1.0, color:const Color(0xFF6366F1),
        assignees:[a1,a2], estimatedHours:24, actualHours:20, labels:['planning','kickoff'],
        checklist:[ChecklistItem(id:'c1',text:'Stakeholder meeting',isCompleted:true),ChecklistItem(id:'c2',text:'Scope document',isCompleted:true),ChecklistItem(id:'c3',text:'Risk assessment',isCompleted:true)],
        comments:[TaskComment(id:'cm1',authorId:'a1',authorName:'Alice Chen',content:'Kickoff was successful. All stakeholders aligned.',timestamp:now.subtract(const Duration(hours:48)))],
      ),
      t('t2','Requirements Analysis', today.subtract(const Duration(days:8)), today.subtract(const Duration(days:2)),
        desc:'Gather and document functional requirements', status:TaskStatus.done,
        priority:TaskPriority.high, progress:1.0, color:const Color(0xFF0EA5E9),
        deps:[const TaskDependency(predecessorId:'t1')], assignees:[a1], estimatedHours:40, actualHours:45, labels:['analysis'],
      ),
      t('t2a','User Stories', today.subtract(const Duration(days:8)), today.subtract(const Duration(days:5)),
        status:TaskStatus.done, priority:TaskPriority.medium, progress:1.0, parentId:'t2', assignees:[a1], estimatedHours:16, actualHours:14,
      ),
      t('t2b','Technical Requirements', today.subtract(const Duration(days:5)), today.subtract(const Duration(days:2)),
        status:TaskStatus.done, priority:TaskPriority.medium, progress:1.0, parentId:'t2', assignees:[a2], estimatedHours:24, actualHours:31,
      ),
      t('t3','UI/UX Design', today.subtract(const Duration(days:3)), today.add(const Duration(days:7)),
        desc:'Wireframes, prototypes, and design system', status:TaskStatus.inProgress,
        priority:TaskPriority.high, progress:0.45, color:const Color(0xFFEC4899),
        deps:[const TaskDependency(predecessorId:'t2')], assignees:[a3], estimatedHours:80, actualHours:36,
        labels:['design','ux'], riskLevel:RiskLevel.medium,
      ),
      t('t3a','Wireframes', today.subtract(const Duration(days:3)), today.add(const Duration(days:1)),
        status:TaskStatus.inProgress, priority:TaskPriority.medium, progress:0.8, parentId:'t3', assignees:[a3], estimatedHours:32, actualHours:30,
      ),
      t('t3b','Design System & Components', today.add(const Duration(days:1)), today.add(const Duration(days:7)),
        status:TaskStatus.todo, priority:TaskPriority.medium, parentId:'t3',
        deps:[const TaskDependency(predecessorId:'t3a')], assignees:[a3], estimatedHours:48,
      ),
      t('t4','Backend Architecture', today.add(const Duration(days:1)), today.add(const Duration(days:12)),
        desc:'Database schema, API design, microservices setup', status:TaskStatus.inProgress,
        priority:TaskPriority.high, progress:0.2, color:const Color(0xFF3B82F6),
        deps:[const TaskDependency(predecessorId:'t2')], assignees:[a2,a4], estimatedHours:120, actualHours:24,
        labels:['backend','architecture'], riskLevel:RiskLevel.low,
      ),
      t('t4a','Database Schema', today.add(const Duration(days:1)), today.add(const Duration(days:5)),
        status:TaskStatus.inProgress, priority:TaskPriority.high, progress:0.4, parentId:'t4', assignees:[a2], estimatedHours:40, actualHours:16,
      ),
      t('t4b','REST API Design', today.add(const Duration(days:3)), today.add(const Duration(days:8)),
        status:TaskStatus.todo, priority:TaskPriority.medium, parentId:'t4',
        deps:[const TaskDependency(predecessorId:'t4a')], assignees:[a4], estimatedHours:48,
      ),
      t('t4c','Authentication Service', today.add(const Duration(days:6)), today.add(const Duration(days:12)),
        status:TaskStatus.todo, priority:TaskPriority.high, parentId:'t4',
        deps:[const TaskDependency(predecessorId:'t4b')], assignees:[a2], estimatedHours:32,
      ),
      t('t5','Frontend Development', today.add(const Duration(days:8)), today.add(const Duration(days:24)),
        desc:'Implement UI components and integrate APIs', status:TaskStatus.backlog,
        priority:TaskPriority.high, color:const Color(0xFF06B6D4),
        deps:[TaskDependency(predecessorId:'t3',type:DependencyType.ss,lagDays:3),const TaskDependency(predecessorId:'t4b')],
        assignees:[a3,a5], estimatedHours:160, labels:['frontend'],
      ),
      t('t5a','Component Library', today.add(const Duration(days:8)), today.add(const Duration(days:14)),
        status:TaskStatus.backlog, priority:TaskPriority.medium, parentId:'t5', assignees:[a5], estimatedHours:48,
      ),
      t('t5b','API Integration', today.add(const Duration(days:14)), today.add(const Duration(days:20)),
        status:TaskStatus.backlog, priority:TaskPriority.high, parentId:'t5',
        deps:[const TaskDependency(predecessorId:'t5a'),const TaskDependency(predecessorId:'t4b')], assignees:[a5], estimatedHours:56,
      ),
      t('t5c','E2E Testing', today.add(const Duration(days:20)), today.add(const Duration(days:24)),
        status:TaskStatus.backlog, priority:TaskPriority.medium, parentId:'t5',
        deps:[const TaskDependency(predecessorId:'t5b')], assignees:[a3], estimatedHours:32,
      ),
      t('t6','Quality Assurance', today.add(const Duration(days:22)), today.add(const Duration(days:28)),
        status:TaskStatus.backlog, priority:TaskPriority.medium, color:const Color(0xFF8B5CF6),
        deps:[const TaskDependency(predecessorId:'t5')], assignees:[a2,a6], estimatedHours:48, labels:['testing','qa'],
      ),
      t('t6a','Integration Testing', today.add(const Duration(days:22)), today.add(const Duration(days:25)),
        status:TaskStatus.backlog, priority:TaskPriority.medium, parentId:'t6', assignees:[a2], estimatedHours:24,
      ),
      t('t6b','Performance Testing', today.add(const Duration(days:24)), today.add(const Duration(days:28)),
        status:TaskStatus.backlog, priority:TaskPriority.high, parentId:'t6', assignees:[a6], estimatedHours:24, riskLevel:RiskLevel.medium,
      ),
      t('t7','🚀 MVP Launch', today.add(const Duration(days:29)), today.add(const Duration(days:29)),
        desc:'Production deployment and go-live', status:TaskStatus.backlog,
        priority:TaskPriority.critical, color:const Color(0xFFEF4444), isMilestone:true,
        deps:[const TaskDependency(predecessorId:'t6')], assignees:[a1], labels:['milestone','launch'],
      ),
      t('t8','Post-launch Monitoring', today.add(const Duration(days:30)), today.add(const Duration(days:36)),
        status:TaskStatus.backlog, priority:TaskPriority.medium, color:const Color(0xFF14B8A6),
        deps:[const TaskDependency(predecessorId:'t7')], assignees:[a2,a4], estimatedHours:40, labels:['monitoring','devops'],
      ),
    ];

    // Apply baselines to done/in-progress tasks
    final baselineDate = today.subtract(const Duration(days:14));
    final withBaselines = tasks.map((task) {
      if (task.status == TaskStatus.done || task.status == TaskStatus.inProgress) {
        return task.copyWith(
          baseline: TaskBaseline(
            startDate: task.startDate.subtract(const Duration(days:1)),
            endDate: task.endDate.add(const Duration(days:2)),
            progress: task.progress * 0.7,
            capturedAt: baselineDate,
            label: 'Sprint 1 Baseline',
          ),
        );
      }
      return task;
    }).toList();

    return WbsCalculator.assignWbsCodes(withBaselines);
  }
}
