import 'package:flutter/material.dart';

// ─── Enums ────────────────────────────────────────────────────────────────────

enum TaskStatus {
  backlog, todo, inProgress, review, done, onHold, cancelled;
  String get label => switch (this) {
    TaskStatus.backlog => 'Backlog', TaskStatus.todo => 'To Do',
    TaskStatus.inProgress => 'In Progress', TaskStatus.review => 'Review',
    TaskStatus.done => 'Done', TaskStatus.onHold => 'On Hold',
    TaskStatus.cancelled => 'Cancelled',
  };
  Color get color => switch (this) {
    TaskStatus.backlog => const Color(0xFF6B7280), TaskStatus.todo => const Color(0xFF3B82F6),
    TaskStatus.inProgress => const Color(0xFFF59E0B), TaskStatus.review => const Color(0xFF8B5CF6),
    TaskStatus.done => const Color(0xFF10B981), TaskStatus.onHold => const Color(0xFFEF4444),
    TaskStatus.cancelled => const Color(0xFF475569),
  };
  IconData get icon => switch (this) {
    TaskStatus.backlog => Icons.inbox_outlined, TaskStatus.todo => Icons.radio_button_unchecked,
    TaskStatus.inProgress => Icons.pending_outlined, TaskStatus.review => Icons.rate_review_outlined,
    TaskStatus.done => Icons.check_circle_outline, TaskStatus.onHold => Icons.pause_circle_outline,
    TaskStatus.cancelled => Icons.cancel_outlined,
  };
}

enum TaskPriority {
  low, medium, high, urgent, critical;
  String get label => switch (this) {
    TaskPriority.low => 'Low', TaskPriority.medium => 'Medium',
    TaskPriority.high => 'High', TaskPriority.urgent => 'Urgent',
    TaskPriority.critical => 'Critical',
  };
  Color get color => switch (this) {
    TaskPriority.low => const Color(0xFF10B981), TaskPriority.medium => const Color(0xFF3B82F6),
    TaskPriority.high => const Color(0xFFF59E0B), TaskPriority.urgent => const Color(0xFFEF4444),
    TaskPriority.critical => const Color(0xFF7C3AED),
  };
  IconData get icon => switch (this) {
    TaskPriority.low => Icons.arrow_downward, TaskPriority.medium => Icons.remove,
    TaskPriority.high => Icons.arrow_upward, TaskPriority.urgent => Icons.priority_high,
    TaskPriority.critical => Icons.warning_amber_outlined,
  };
}

enum DependencyType {
  fs, ss, ff, sf;
  String get label => switch (this) { DependencyType.fs => 'FS', DependencyType.ss => 'SS', DependencyType.ff => 'FF', DependencyType.sf => 'SF' };
  String get fullLabel => switch (this) {
    DependencyType.fs => 'Finish → Start', DependencyType.ss => 'Start → Start',
    DependencyType.ff => 'Finish → Finish', DependencyType.sf => 'Start → Finish',
  };
}

enum RecurrenceFrequency { daily, weekly, biweekly, monthly }
enum SwimlanGroupBy { none, assignee, status, priority, label }
enum CustomFieldType { text, number, boolean, date, select }

enum RiskLevel {
  none, low, medium, high, critical;
  Color get color => switch (this) {
    RiskLevel.none => const Color(0xFF475569), RiskLevel.low => const Color(0xFF10B981),
    RiskLevel.medium => const Color(0xFFF59E0B), RiskLevel.high => const Color(0xFFEF4444),
    RiskLevel.critical => const Color(0xFF7C3AED),
  };
  String get label => switch (this) {
    RiskLevel.none => 'None', RiskLevel.low => 'Low', RiskLevel.medium => 'Medium',
    RiskLevel.high => 'High', RiskLevel.critical => 'Critical',
  };
}

// ─── NEW: Task Constraint ─────────────────────────────────────────────────────
enum TaskConstraint {
  asap,              // As Soon As Possible (default)
  alap,              // As Late As Possible
  mustStartOn,       // Must start on exact date
  mustFinishOn,      // Must finish on exact date
  startNoEarlierThan,
  finishNoLaterThan;

  String get label => switch (this) {
    TaskConstraint.asap => 'As Soon As Possible',
    TaskConstraint.alap => 'As Late As Possible',
    TaskConstraint.mustStartOn => 'Must Start On',
    TaskConstraint.mustFinishOn => 'Must Finish On',
    TaskConstraint.startNoEarlierThan => 'Start No Earlier Than',
    TaskConstraint.finishNoLaterThan => 'Finish No Later Than',
  };
  IconData get icon => switch (this) {
    TaskConstraint.asap => Icons.fast_forward, TaskConstraint.alap => Icons.fast_rewind,
    TaskConstraint.mustStartOn => Icons.lock_clock, TaskConstraint.mustFinishOn => Icons.lock_outline,
    TaskConstraint.startNoEarlierThan => Icons.arrow_forward, TaskConstraint.finishNoLaterThan => Icons.arrow_back,
  };
}

// ─── NEW: Audit Entry ─────────────────────────────────────────────────────────
class AuditEntry {
  final String id;
  final String taskId;
  final String taskTitle;
  final String field;
  final String? oldValue;
  final String? newValue;
  final String commandDescription;
  final DateTime timestamp;

  const AuditEntry({
    required this.id, required this.taskId, required this.taskTitle,
    required this.field, this.oldValue, this.newValue,
    required this.commandDescription, required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'taskId': taskId, 'taskTitle': taskTitle,
    'field': field, 'oldValue': oldValue, 'newValue': newValue,
    'commandDescription': commandDescription, 'timestamp': timestamp.toIso8601String(),
  };
}

// ─── NEW: Custom Field Definition ─────────────────────────────────────────────
class CustomFieldDef {
  final String id;
  final String name;
  final CustomFieldType type;
  final List<String> options;     // for 'select' type
  final dynamic defaultValue;
  final bool showInSidebar;
  final double sidebarWidth;

  const CustomFieldDef({
    required this.id, required this.name, required this.type,
    this.options = const [], this.defaultValue,
    this.showInSidebar = true, this.sidebarWidth = 80,
  });

  CustomFieldDef copyWith({String? name, bool? showInSidebar, double? sidebarWidth}) =>
      CustomFieldDef(id: id, name: name ?? this.name, type: type,
          options: options, defaultValue: defaultValue,
          showInSidebar: showInSidebar ?? this.showInSidebar,
          sidebarWidth: sidebarWidth ?? this.sidebarWidth);

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'type': type.index, 'options': options,
    'defaultValue': defaultValue?.toString(), 'showInSidebar': showInSidebar,
    'sidebarWidth': sidebarWidth,
  };
  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'type': type.index,
    'defaultValue': defaultValue, 'options': options,
    'showInSidebar': showInSidebar,
  };

  factory CustomFieldDef.fromJson(Map<String, dynamic> j) => CustomFieldDef(
    id: j['id'] as String, name: j['name'] as String,
    type: CustomFieldType.values[j['type'] as int],
    options: List<String>.from(j['options'] ?? []),
    defaultValue: j['defaultValue'],
    showInSidebar: j['showInSidebar'] as bool? ?? true,
    sidebarWidth: (j['sidebarWidth'] as num?)?.toDouble() ?? 80,
  );
}

// ─── Other supporting classes ─────────────────────────────────────────────────

class TaskDependency {
  final String predecessorId;
  final DependencyType type;
  final int lagDays;
  const TaskDependency({required this.predecessorId, this.type = DependencyType.fs, this.lagDays = 0});
  TaskDependency copyWith({String? predecessorId, DependencyType? type, int? lagDays}) =>
      TaskDependency(predecessorId: predecessorId ?? this.predecessorId, type: type ?? this.type, lagDays: lagDays ?? this.lagDays);
  Map<String, dynamic> toJson() => {'predecessorId': predecessorId, 'type': type.index, 'lagDays': lagDays};
  factory TaskDependency.fromJson(Map<String, dynamic> j) =>
      TaskDependency(predecessorId: j['predecessorId'] as String, type: DependencyType.values[j['type'] as int], lagDays: j['lagDays'] as int? ?? 0);
}

class TaskBaseline {
  final DateTime startDate;
  final DateTime endDate;
  final double progress;
  final DateTime capturedAt;
  final String label;
  const TaskBaseline({required this.startDate, required this.endDate, required this.progress, required this.capturedAt, this.label = 'Baseline'});
  int get durationDays => endDate.difference(startDate).inDays + 1;
  Map<String, dynamic> toJson() => {'startDate': startDate.toIso8601String(), 'endDate': endDate.toIso8601String(), 'progress': progress, 'capturedAt': capturedAt.toIso8601String(), 'label': label};
  factory TaskBaseline.fromJson(Map<String, dynamic> j) => TaskBaseline(startDate: DateTime.parse(j['startDate'] as String), endDate: DateTime.parse(j['endDate'] as String), progress: (j['progress'] as num).toDouble(), capturedAt: DateTime.parse(j['capturedAt'] as String), label: j['label'] as String? ?? 'Baseline');
}

class TimeEntry {
  final String id;
  final String userId;
  final String userName;
  final DateTime date;
  final double hours;
  final String? note;
  const TimeEntry({required this.id, required this.userId, required this.userName, required this.date, required this.hours, this.note});
  Map<String, dynamic> toJson() => {'id': id, 'userId': userId, 'userName': userName, 'date': date.toIso8601String(), 'hours': hours, 'note': note};
  factory TimeEntry.fromJson(Map<String, dynamic> j) => TimeEntry(id: j['id'] as String, userId: j['userId'] as String, userName: j['userName'] as String, date: DateTime.parse(j['date'] as String), hours: (j['hours'] as num).toDouble(), note: j['note'] as String?);
}

class RecurrenceRule {
  final RecurrenceFrequency frequency;
  final int interval;
  final DateTime? endDate;
  final int? count;
  const RecurrenceRule({required this.frequency, this.interval = 1, this.endDate, this.count});
  Map<String, dynamic> toJson() => {'frequency': frequency.index, 'interval': interval, 'endDate': endDate?.toIso8601String(), 'count': count};
  factory RecurrenceRule.fromJson(Map<String, dynamic> j) => RecurrenceRule(frequency: RecurrenceFrequency.values[j['frequency'] as int], interval: j['interval'] as int? ?? 1, endDate: j['endDate'] != null ? DateTime.parse(j['endDate'] as String) : null, count: j['count'] as int?);
}

class Assignee {
  final String id;
  final String name;
  final String? avatarUrl;
  final Color avatarColor;
  final double allocatedHoursPerDay;
  const Assignee({required this.id, required this.name, this.avatarUrl, this.avatarColor = const Color(0xFF6366F1), this.allocatedHoursPerDay = 8.0});
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
  Assignee copyWith({String? id, String? name, String? avatarUrl, Color? avatarColor, double? allocatedHoursPerDay}) =>
      Assignee(id: id ?? this.id, name: name ?? this.name, avatarUrl: avatarUrl ?? this.avatarUrl, avatarColor: avatarColor ?? this.avatarColor, allocatedHoursPerDay: allocatedHoursPerDay ?? this.allocatedHoursPerDay);
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'avatarUrl': avatarUrl, 'avatarColor': avatarColor.value, 'allocatedHoursPerDay': allocatedHoursPerDay};
  factory Assignee.fromJson(Map<String, dynamic> j) => Assignee(id: j['id'] as String, name: j['name'] as String, avatarUrl: j['avatarUrl'] as String?, avatarColor: Color(j['avatarColor'] as int), allocatedHoursPerDay: (j['allocatedHoursPerDay'] as num?)?.toDouble() ?? 8.0);
}

class TaskAttachment {
  final String id;
  final String name;
  final String url;
  final int? sizeBytes;
  final DateTime uploadedAt;
  const TaskAttachment({required this.id, required this.name, required this.url, this.sizeBytes, required this.uploadedAt});
  String get sizeLabel { if (sizeBytes == null) return ''; if (sizeBytes! < 1024) return '${sizeBytes}B'; if (sizeBytes! < 1048576) return '${(sizeBytes! / 1024).toStringAsFixed(1)}KB'; return '${(sizeBytes! / 1048576).toStringAsFixed(1)}MB'; }
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'url': url, 'sizeBytes': sizeBytes, 'uploadedAt': uploadedAt.toIso8601String()};
  factory TaskAttachment.fromJson(Map<String, dynamic> j) => TaskAttachment(id: j['id'] as String, name: j['name'] as String, url: j['url'] as String, sizeBytes: j['sizeBytes'] as int?, uploadedAt: DateTime.parse(j['uploadedAt'] as String));
}

class TaskComment {
  final String id;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime timestamp;
  final bool isEdited;
  const TaskComment({required this.id, required this.authorId, required this.authorName, required this.content, required this.timestamp, this.isEdited = false});
  TaskComment copyWith({String? content, bool? isEdited}) => TaskComment(id: id, authorId: authorId, authorName: authorName, content: content ?? this.content, timestamp: timestamp, isEdited: isEdited ?? this.isEdited);
  Map<String, dynamic> toJson() => {'id': id, 'authorId': authorId, 'authorName': authorName, 'content': content, 'timestamp': timestamp.toIso8601String(), 'isEdited': isEdited};
  factory TaskComment.fromJson(Map<String, dynamic> j) => TaskComment(id: j['id'] as String, authorId: j['authorId'] as String, authorName: j['authorName'] as String, content: j['content'] as String, timestamp: DateTime.parse(j['timestamp'] as String), isEdited: j['isEdited'] as bool? ?? false);
}

class ChecklistItem {
  final String id;
  final String text;
  final bool isCompleted;
  const ChecklistItem({required this.id, required this.text, this.isCompleted = false});
  ChecklistItem copyWith({String? text, bool? isCompleted}) => ChecklistItem(id: id, text: text ?? this.text, isCompleted: isCompleted ?? this.isCompleted);
  Map<String, dynamic> toJson() => {'id': id, 'text': text, 'isCompleted': isCompleted};
  factory ChecklistItem.fromJson(Map<String, dynamic> j) => ChecklistItem(id: j['id'] as String, text: j['text'] as String, isCompleted: j['isCompleted'] as bool? ?? false);
}

// ─── Task ─────────────────────────────────────────────────────────────────────

class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final TaskStatus status;
  final TaskPriority priority;
  final double progress;
  final Color? color;
  final bool isMilestone;
  final String? parentId;
  final String? wbsCode;
  final List<TaskDependency> dependencies;
  final List<Assignee> assignees;
  final List<TaskAttachment> attachments;
  final List<TaskComment> comments;
  final List<ChecklistItem> checklist;
  final List<String> labels;
  final bool isExpanded;
  final DateTime? reminderDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double estimatedHours;
  final double actualHours;
  final List<TimeEntry> timeEntries;
  final TaskBaseline? baseline;
  final RecurrenceRule? recurrence;
  final String? recurrenceParentId;
  final RiskLevel riskLevel;
  final Map<String, dynamic> customFields;
  final bool isLocked;
  final String? lockedByUserId;

  // NEW fields
  final TaskConstraint constraint;
  final DateTime? constraintDate;      // used for mustStartOn, mustFinishOn, etc.
  final bool autoSchedule;             // whether this task participates in auto-scheduling
  final double optimisticDays;         // Monte Carlo 3-point estimate
  final double pessimisticDays;        // Monte Carlo 3-point estimate
  final String? swimlaneGroup;         // override group label for swimlane view

  const Task({
    required this.id, required this.title, this.description,
    required this.startDate, required this.endDate,
    this.status = TaskStatus.todo, this.priority = TaskPriority.medium,
    this.progress = 0.0, this.color, this.isMilestone = false,
    this.parentId, this.wbsCode, this.dependencies = const [],
    this.assignees = const [], this.attachments = const [],
    this.comments = const [], this.checklist = const [],
    this.labels = const [], this.isExpanded = true, this.reminderDate,
    required this.createdAt, required this.updatedAt,
    this.estimatedHours = 0.0, this.actualHours = 0.0,
    this.timeEntries = const [], this.baseline, this.recurrence,
    this.recurrenceParentId, this.riskLevel = RiskLevel.none,
    this.customFields = const {}, this.isLocked = false, this.lockedByUserId,
    // New
    this.constraint = TaskConstraint.asap, this.constraintDate,
    this.autoSchedule = true,
    this.optimisticDays = 0, this.pessimisticDays = 0,
    this.swimlaneGroup,
  });

  int get durationDays => endDate.difference(startDate).inDays.abs() + 1;
  bool get isOverdue => endDate.isBefore(DateTime.now()) && status != TaskStatus.done;
  Color get displayColor => color ?? priority.color;
  double get checklistProgress => checklist.isEmpty ? 0 : checklist.where((c) => c.isCompleted).length / checklist.length;
  int get slipDays => baseline == null ? 0 : endDate.difference(baseline!.endDate).inDays;
  double get hoursVariance => actualHours - estimatedHours;
  List<String> get dependencyIds => dependencies.map((d) => d.predecessorId).toList();
  bool get isRecurring => recurrence != null;
  bool get isRecurringInstance => recurrenceParentId != null;
  // Effective most/least optimistic for Monte Carlo
  double get likelyDays => durationDays.toDouble();
  double get mcOptimistic => optimisticDays > 0 ? optimisticDays : likelyDays * 0.8;
  double get mcPessimistic => pessimisticDays > 0 ? pessimisticDays : likelyDays * 1.3;

  Task copyWith({
    String? id, String? title, String? description,
    DateTime? startDate, DateTime? endDate, TaskStatus? status,
    TaskPriority? priority, double? progress, Color? color,
    bool? isMilestone, String? parentId, String? wbsCode,
    List<TaskDependency>? dependencies, List<Assignee>? assignees,
    List<TaskAttachment>? attachments, List<TaskComment>? comments,
    List<ChecklistItem>? checklist, List<String>? labels,
    bool? isExpanded, DateTime? reminderDate,
    DateTime? createdAt, DateTime? updatedAt,
    double? estimatedHours, double? actualHours,
    List<TimeEntry>? timeEntries, TaskBaseline? baseline,
    RecurrenceRule? recurrence, String? recurrenceParentId,
    RiskLevel? riskLevel, Map<String, dynamic>? customFields,
    bool? isLocked, String? lockedByUserId,
    TaskConstraint? constraint, DateTime? constraintDate,
    bool? autoSchedule, double? optimisticDays, double? pessimisticDays,
    String? swimlaneGroup,
  }) => Task(
    id: id ?? this.id, title: title ?? this.title, description: description ?? this.description,
    startDate: startDate ?? this.startDate, endDate: endDate ?? this.endDate,
    status: status ?? this.status, priority: priority ?? this.priority,
    progress: progress ?? this.progress, color: color ?? this.color,
    isMilestone: isMilestone ?? this.isMilestone, parentId: parentId ?? this.parentId,
    wbsCode: wbsCode ?? this.wbsCode, dependencies: dependencies ?? this.dependencies,
    assignees: assignees ?? this.assignees, attachments: attachments ?? this.attachments,
    comments: comments ?? this.comments, checklist: checklist ?? this.checklist,
    labels: labels ?? this.labels, isExpanded: isExpanded ?? this.isExpanded,
    reminderDate: reminderDate ?? this.reminderDate,
    createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
    estimatedHours: estimatedHours ?? this.estimatedHours, actualHours: actualHours ?? this.actualHours,
    timeEntries: timeEntries ?? this.timeEntries, baseline: baseline ?? this.baseline,
    recurrence: recurrence ?? this.recurrence, recurrenceParentId: recurrenceParentId ?? this.recurrenceParentId,
    riskLevel: riskLevel ?? this.riskLevel, customFields: customFields ?? this.customFields,
    isLocked: isLocked ?? this.isLocked, lockedByUserId: lockedByUserId ?? this.lockedByUserId,
    constraint: constraint ?? this.constraint, constraintDate: constraintDate ?? this.constraintDate,
    autoSchedule: autoSchedule ?? this.autoSchedule,
    optimisticDays: optimisticDays ?? this.optimisticDays,
    pessimisticDays: pessimisticDays ?? this.pessimisticDays,
    swimlaneGroup: swimlaneGroup ?? this.swimlaneGroup,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'description': description,
    'startDate': startDate.toIso8601String(), 'endDate': endDate.toIso8601String(),
    'status': status.index, 'priority': priority.index, 'progress': progress,
    'color': color?.value, 'isMilestone': isMilestone, 'parentId': parentId, 'wbsCode': wbsCode,
    'dependencies': dependencies.map((d) => d.toJson()).toList(),
    'assignees': assignees.map((a) => a.toJson()).toList(),
    'attachments': attachments.map((a) => a.toJson()).toList(),
    'comments': comments.map((c) => c.toJson()).toList(),
    'checklist': checklist.map((c) => c.toJson()).toList(),
    'labels': labels, 'isExpanded': isExpanded, 'reminderDate': reminderDate?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(), 'updatedAt': updatedAt.toIso8601String(),
    'estimatedHours': estimatedHours, 'actualHours': actualHours,
    'timeEntries': timeEntries.map((t) => t.toJson()).toList(),
    'baseline': baseline?.toJson(), 'recurrence': recurrence?.toJson(),
    'recurrenceParentId': recurrenceParentId,
    'riskLevel': riskLevel.index, 'customFields': customFields,
    'isLocked': isLocked, 'lockedByUserId': lockedByUserId,
    'constraint': constraint.index, 'constraintDate': constraintDate?.toIso8601String(),
    'autoSchedule': autoSchedule,
    'optimisticDays': optimisticDays, 'pessimisticDays': pessimisticDays,
    'swimlaneGroup': swimlaneGroup,
  };

  factory Task.fromJson(Map<String, dynamic> j) => Task(
    id: j['id'] as String, title: j['title'] as String, description: j['description'] as String?,
    startDate: DateTime.parse(j['startDate'] as String), endDate: DateTime.parse(j['endDate'] as String),
    status: TaskStatus.values[j['status'] as int], priority: TaskPriority.values[j['priority'] as int],
    progress: (j['progress'] as num).toDouble(),
    color: j['color'] != null ? Color(j['color'] as int) : null,
    isMilestone: j['isMilestone'] as bool? ?? false, parentId: j['parentId'] as String?, wbsCode: j['wbsCode'] as String?,
    dependencies: (j['dependencies'] as List<dynamic>?)?.map((d) => TaskDependency.fromJson(d as Map<String, dynamic>)).toList() ?? [],
    assignees: (j['assignees'] as List<dynamic>?)?.map((a) => Assignee.fromJson(a as Map<String, dynamic>)).toList() ?? [],
    attachments: (j['attachments'] as List<dynamic>?)?.map((a) => TaskAttachment.fromJson(a as Map<String, dynamic>)).toList() ?? [],
    comments: (j['comments'] as List<dynamic>?)?.map((c) => TaskComment.fromJson(c as Map<String, dynamic>)).toList() ?? [],
    checklist: (j['checklist'] as List<dynamic>?)?.map((c) => ChecklistItem.fromJson(c as Map<String, dynamic>)).toList() ?? [],
    labels: List<String>.from(j['labels'] ?? []), isExpanded: j['isExpanded'] as bool? ?? true,
    reminderDate: j['reminderDate'] != null ? DateTime.parse(j['reminderDate'] as String) : null,
    createdAt: DateTime.parse(j['createdAt'] as String), updatedAt: DateTime.parse(j['updatedAt'] as String),
    estimatedHours: (j['estimatedHours'] as num?)?.toDouble() ?? 0.0, actualHours: (j['actualHours'] as num?)?.toDouble() ?? 0.0,
    timeEntries: (j['timeEntries'] as List<dynamic>?)?.map((t) => TimeEntry.fromJson(t as Map<String, dynamic>)).toList() ?? [],
    baseline: j['baseline'] != null ? TaskBaseline.fromJson(j['baseline'] as Map<String, dynamic>) : null,
    recurrence: j['recurrence'] != null ? RecurrenceRule.fromJson(j['recurrence'] as Map<String, dynamic>) : null,
    recurrenceParentId: j['recurrenceParentId'] as String?,
    riskLevel: RiskLevel.values[j['riskLevel'] as int? ?? 0],
    customFields: Map<String, dynamic>.from(j['customFields'] ?? {}),
    isLocked: j['isLocked'] as bool? ?? false, lockedByUserId: j['lockedByUserId'] as String?,
    constraint: TaskConstraint.values[j['constraint'] as int? ?? 0],
    constraintDate: j['constraintDate'] != null ? DateTime.parse(j['constraintDate'] as String) : null,
    autoSchedule: j['autoSchedule'] as bool? ?? true,
    optimisticDays: (j['optimisticDays'] as num?)?.toDouble() ?? 0,
    pessimisticDays: (j['pessimisticDays'] as num?)?.toDouble() ?? 0,
    swimlaneGroup: j['swimlaneGroup'] as String?,
  );
}

// ─── Project Snapshot ─────────────────────────────────────────────────────────
class ProjectSnapshot {
  final String id;
  final String label;
  final DateTime capturedAt;
  final List<Task> tasks;
  final String? notes;

  const ProjectSnapshot({
    required this.id, required this.label,
    required this.capturedAt, required this.tasks, this.notes,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'label': label,
    'capturedAt': capturedAt.toIso8601String(),
    'tasks': tasks.map((t) => t.toJson()).toList(),
    'notes': notes,
  };
  Map<String, dynamic> toJson() => {
    'id': id, 'label': label, 'notes': notes,
    'capturedAt': capturedAt.toIso8601String(),
    'tasks': tasks.map((t) => t.toJson()).toList(),
  };

  factory ProjectSnapshot.fromJson(Map<String, dynamic> j) => ProjectSnapshot(
    id: j['id'] as String, label: j['label'] as String,
    capturedAt: DateTime.parse(j['capturedAt'] as String),
    tasks: (j['tasks'] as List).map((t) => Task.fromJson(t as Map<String, dynamic>)).toList(),
    notes: j['notes'] as String?,
  );
}

// ─── View Settings ────────────────────────────────────────────────────────────
enum GanttViewMode { day, week, month, quarter }

class GanttViewSettings {
  final GanttViewMode viewMode;
  final double dayWidth;
  final double rowHeight;
  final double headerHeight;
  final double subHeaderHeight;
  final double sidebarWidth;
  final bool showWeekends;
  final bool showCriticalPath;
  final bool showDependencies;
  final bool showProgress;
  final bool showToday;
  final bool showBaseline;
  final bool showResourceHistogram;
  final bool showWbsCodes;
  final SwimlanGroupBy swimlaneGroupBy;
  final Set<int> weekendDays;
  final bool autoScheduleEnabled;     // NEW: toggle auto-scheduling propagation
  final bool showCustomFieldColumns;  // NEW: toggle custom field sidebar columns

  const GanttViewSettings({
    this.viewMode = GanttViewMode.week, this.dayWidth = 32.0, this.rowHeight = 48.0,
    this.headerHeight = 36.0, this.subHeaderHeight = 28.0, this.sidebarWidth = 300.0,
    this.showWeekends = true, this.showCriticalPath = false, this.showDependencies = true,
    this.showProgress = true, this.showToday = true, this.showBaseline = false,
    this.showResourceHistogram = false, this.showWbsCodes = true,
    this.swimlaneGroupBy = SwimlanGroupBy.none,
    this.weekendDays = const {DateTime.saturday, DateTime.sunday},
    this.autoScheduleEnabled = false,
    this.showCustomFieldColumns = false,
  });

  GanttViewSettings copyWith({
    GanttViewMode? viewMode, double? dayWidth, double? rowHeight,
    double? headerHeight, double? subHeaderHeight, double? sidebarWidth,
    bool? showWeekends, bool? showCriticalPath, bool? showDependencies,
    bool? showProgress, bool? showToday, bool? showBaseline,
    bool? showResourceHistogram, bool? showWbsCodes,
    SwimlanGroupBy? swimlaneGroupBy, Set<int>? weekendDays,
    bool? autoScheduleEnabled, bool? showCustomFieldColumns,
  }) => GanttViewSettings(
    viewMode: viewMode ?? this.viewMode, dayWidth: dayWidth ?? this.dayWidth,
    rowHeight: rowHeight ?? this.rowHeight, headerHeight: headerHeight ?? this.headerHeight,
    subHeaderHeight: subHeaderHeight ?? this.subHeaderHeight, sidebarWidth: sidebarWidth ?? this.sidebarWidth,
    showWeekends: showWeekends ?? this.showWeekends, showCriticalPath: showCriticalPath ?? this.showCriticalPath,
    showDependencies: showDependencies ?? this.showDependencies, showProgress: showProgress ?? this.showProgress,
    showToday: showToday ?? this.showToday, showBaseline: showBaseline ?? this.showBaseline,
    showResourceHistogram: showResourceHistogram ?? this.showResourceHistogram,
    showWbsCodes: showWbsCodes ?? this.showWbsCodes,
    swimlaneGroupBy: swimlaneGroupBy ?? this.swimlaneGroupBy, weekendDays: weekendDays ?? this.weekendDays,
    autoScheduleEnabled: autoScheduleEnabled ?? this.autoScheduleEnabled,
    showCustomFieldColumns: showCustomFieldColumns ?? this.showCustomFieldColumns,
  );
}

// ─── Filter ───────────────────────────────────────────────────────────────────
class GanttFilter {
  final String searchQuery;
  final Set<TaskStatus> statuses;
  final Set<TaskPriority> priorities;
  final DateTime? startDateFrom;
  final DateTime? startDateTo;
  final String? assigneeId;
  final Set<RiskLevel> riskLevels;
  final Set<String> labels;

  const GanttFilter({
    this.searchQuery = '', this.statuses = const {}, this.priorities = const {},
    this.startDateFrom, this.startDateTo, this.assigneeId,
    this.riskLevels = const {}, this.labels = const {},
  });

  bool get isActive => searchQuery.isNotEmpty || statuses.isNotEmpty || priorities.isNotEmpty ||
      startDateFrom != null || startDateTo != null || assigneeId != null || riskLevels.isNotEmpty || labels.isNotEmpty;

  int get activeCount {
    int n = 0;
    if (searchQuery.isNotEmpty) n++;
    if (statuses.isNotEmpty) n++;
    if (priorities.isNotEmpty) n++;
    if (startDateFrom != null || startDateTo != null) n++;
    if (assigneeId != null) n++;
    if (riskLevels.isNotEmpty) n++;
    if (labels.isNotEmpty) n++;
    return n;
  }

  GanttFilter copyWith({
    String? searchQuery, Set<TaskStatus>? statuses, Set<TaskPriority>? priorities,
    DateTime? startDateFrom, DateTime? startDateTo, String? assigneeId,
    Set<RiskLevel>? riskLevels, Set<String>? labels,
  }) => GanttFilter(
    searchQuery: searchQuery ?? this.searchQuery, statuses: statuses ?? this.statuses,
    priorities: priorities ?? this.priorities, startDateFrom: startDateFrom ?? this.startDateFrom,
    startDateTo: startDateTo ?? this.startDateTo, assigneeId: assigneeId ?? this.assigneeId,
    riskLevels: riskLevels ?? this.riskLevels, labels: labels ?? this.labels,
  );
}
