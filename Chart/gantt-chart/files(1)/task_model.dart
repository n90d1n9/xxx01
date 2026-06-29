import 'package:flutter/material.dart';

// ─── Enums ───────────────────────────────────────────────────────────────────

enum TaskStatus {
  backlog,
  todo,
  inProgress,
  review,
  done,
  onHold,
  cancelled;

  String get label {
    switch (this) {
      case TaskStatus.backlog:
        return 'Backlog';
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.review:
        return 'Review';
      case TaskStatus.done:
        return 'Done';
      case TaskStatus.onHold:
        return 'On Hold';
      case TaskStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case TaskStatus.backlog:
        return const Color(0xFF6B7280);
      case TaskStatus.todo:
        return const Color(0xFF3B82F6);
      case TaskStatus.inProgress:
        return const Color(0xFFF59E0B);
      case TaskStatus.review:
        return const Color(0xFF8B5CF6);
      case TaskStatus.done:
        return const Color(0xFF10B981);
      case TaskStatus.onHold:
        return const Color(0xFFEF4444);
      case TaskStatus.cancelled:
        return const Color(0xFF9CA3AF);
    }
  }

  IconData get icon {
    switch (this) {
      case TaskStatus.backlog:
        return Icons.inbox_outlined;
      case TaskStatus.todo:
        return Icons.radio_button_unchecked;
      case TaskStatus.inProgress:
        return Icons.pending_outlined;
      case TaskStatus.review:
        return Icons.rate_review_outlined;
      case TaskStatus.done:
        return Icons.check_circle_outline;
      case TaskStatus.onHold:
        return Icons.pause_circle_outline;
      case TaskStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }
}

enum TaskPriority {
  low,
  medium,
  high,
  urgent,
  critical;

  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
      case TaskPriority.critical:
        return 'Critical';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.low:
        return const Color(0xFF10B981);
      case TaskPriority.medium:
        return const Color(0xFF3B82F6);
      case TaskPriority.high:
        return const Color(0xFFF59E0B);
      case TaskPriority.urgent:
        return const Color(0xFFEF4444);
      case TaskPriority.critical:
        return const Color(0xFF7C3AED);
    }
  }

  IconData get icon {
    switch (this) {
      case TaskPriority.low:
        return Icons.arrow_downward;
      case TaskPriority.medium:
        return Icons.remove;
      case TaskPriority.high:
        return Icons.arrow_upward;
      case TaskPriority.urgent:
        return Icons.priority_high;
      case TaskPriority.critical:
        return Icons.report_problem_outlined;
    }
  }
}

// ─── Assignee ────────────────────────────────────────────────────────────────

class Assignee {
  final String id;
  final String name;
  final String? avatarUrl;
  final Color avatarColor;

  const Assignee({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.avatarColor = const Color(0xFF6366F1),
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Assignee copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    Color? avatarColor,
  }) {
    return Assignee(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarColor: avatarColor ?? this.avatarColor,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatarUrl': avatarUrl,
        'avatarColor': avatarColor.value,
      };

  factory Assignee.fromJson(Map<String, dynamic> json) => Assignee(
        id: json['id'] as String,
        name: json['name'] as String,
        avatarUrl: json['avatarUrl'] as String?,
        avatarColor: Color(json['avatarColor'] as int),
      );
}

// ─── Attachment ───────────────────────────────────────────────────────────────

enum AttachmentType { file, image, link, document }

class TaskAttachment {
  final String id;
  final String name;
  final AttachmentType type;
  final String url;
  final int? sizeBytes;
  final DateTime uploadedAt;

  const TaskAttachment({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    this.sizeBytes,
    required this.uploadedAt,
  });

  String get sizeLabel {
    if (sizeBytes == null) return '';
    if (sizeBytes! < 1024) return '${sizeBytes}B';
    if (sizeBytes! < 1024 * 1024) return '${(sizeBytes! / 1024).toStringAsFixed(1)}KB';
    return '${(sizeBytes! / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.index,
        'url': url,
        'sizeBytes': sizeBytes,
        'uploadedAt': uploadedAt.toIso8601String(),
      };

  factory TaskAttachment.fromJson(Map<String, dynamic> json) => TaskAttachment(
        id: json['id'] as String,
        name: json['name'] as String,
        type: AttachmentType.values[json['type'] as int],
        url: json['url'] as String,
        sizeBytes: json['sizeBytes'] as int?,
        uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      );
}

// ─── Comment ──────────────────────────────────────────────────────────────────

class TaskComment {
  final String id;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime timestamp;
  final bool isEdited;

  const TaskComment({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.timestamp,
    this.isEdited = false,
  });

  TaskComment copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? content,
    DateTime? timestamp,
    bool? isEdited,
  }) {
    return TaskComment(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isEdited: isEdited ?? this.isEdited,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorId': authorId,
        'authorName': authorName,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'isEdited': isEdited,
      };

  factory TaskComment.fromJson(Map<String, dynamic> json) => TaskComment(
        id: json['id'] as String,
        authorId: json['authorId'] as String,
        authorName: json['authorName'] as String,
        content: json['content'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        isEdited: json['isEdited'] as bool? ?? false,
      );
}

// ─── Task Model ───────────────────────────────────────────────────────────────

class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final TaskStatus status;
  final TaskPriority priority;
  final double progress; // 0.0 – 1.0
  final Color? color;
  final bool isMilestone;
  final String? parentId;
  final List<String> dependencyIds; // IDs of tasks this task depends on
  final List<Assignee> assignees;
  final List<TaskAttachment> attachments;
  final List<TaskComment> comments;
  final List<String> labels;
  final bool isExpanded;
  final DateTime? reminderDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.startDate,
    required this.endDate,
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.medium,
    this.progress = 0.0,
    this.color,
    this.isMilestone = false,
    this.parentId,
    this.dependencyIds = const [],
    this.assignees = const [],
    this.attachments = const [],
    this.comments = const [],
    this.labels = const [],
    this.isExpanded = true,
    this.reminderDate,
    required this.createdAt,
    required this.updatedAt,
  });

  int get durationDays => endDate.difference(startDate).inDays.abs() + 1;

  bool get isOverdue =>
      endDate.isBefore(DateTime.now()) && status != TaskStatus.done;

  bool get isToday {
    final now = DateTime.now();
    return startDate.year == now.year &&
        startDate.month == now.month &&
        startDate.day == now.day;
  }

  Color get displayColor => color ?? priority.color;

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    TaskStatus? status,
    TaskPriority? priority,
    double? progress,
    Color? color,
    bool? isMilestone,
    String? parentId,
    List<String>? dependencyIds,
    List<Assignee>? assignees,
    List<TaskAttachment>? attachments,
    List<TaskComment>? comments,
    List<String>? labels,
    bool? isExpanded,
    DateTime? reminderDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      progress: progress ?? this.progress,
      color: color ?? this.color,
      isMilestone: isMilestone ?? this.isMilestone,
      parentId: parentId ?? this.parentId,
      dependencyIds: dependencyIds ?? this.dependencyIds,
      assignees: assignees ?? this.assignees,
      attachments: attachments ?? this.attachments,
      comments: comments ?? this.comments,
      labels: labels ?? this.labels,
      isExpanded: isExpanded ?? this.isExpanded,
      reminderDate: reminderDate ?? this.reminderDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'status': status.index,
        'priority': priority.index,
        'progress': progress,
        'color': color?.value,
        'isMilestone': isMilestone,
        'parentId': parentId,
        'dependencyIds': dependencyIds,
        'assignees': assignees.map((a) => a.toJson()).toList(),
        'attachments': attachments.map((a) => a.toJson()).toList(),
        'comments': comments.map((c) => c.toJson()).toList(),
        'labels': labels,
        'isExpanded': isExpanded,
        'reminderDate': reminderDate?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
        status: TaskStatus.values[json['status'] as int],
        priority: TaskPriority.values[json['priority'] as int],
        progress: (json['progress'] as num).toDouble(),
        color: json['color'] != null ? Color(json['color'] as int) : null,
        isMilestone: json['isMilestone'] as bool? ?? false,
        parentId: json['parentId'] as String?,
        dependencyIds: List<String>.from(json['dependencyIds'] ?? []),
        assignees: (json['assignees'] as List<dynamic>?)
                ?.map((a) => Assignee.fromJson(a as Map<String, dynamic>))
                .toList() ??
            [],
        attachments: (json['attachments'] as List<dynamic>?)
                ?.map((a) => TaskAttachment.fromJson(a as Map<String, dynamic>))
                .toList() ??
            [],
        comments: (json['comments'] as List<dynamic>?)
                ?.map((c) => TaskComment.fromJson(c as Map<String, dynamic>))
                .toList() ??
            [],
        labels: List<String>.from(json['labels'] ?? []),
        isExpanded: json['isExpanded'] as bool? ?? true,
        reminderDate: json['reminderDate'] != null
            ? DateTime.parse(json['reminderDate'] as String)
            : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}

// ─── Filter Model ─────────────────────────────────────────────────────────────

class GanttFilter {
  final String? searchQuery;
  final Set<TaskStatus> statuses;
  final Set<TaskPriority> priorities;
  final DateTime? startDateFrom;
  final DateTime? startDateTo;
  final String? assigneeId;

  const GanttFilter({
    this.searchQuery,
    this.statuses = const {},
    this.priorities = const {},
    this.startDateFrom,
    this.startDateTo,
    this.assigneeId,
  });

  bool get isActive =>
      (searchQuery?.isNotEmpty ?? false) ||
      statuses.isNotEmpty ||
      priorities.isNotEmpty ||
      startDateFrom != null ||
      startDateTo != null ||
      assigneeId != null;

  int get activeCount {
    int n = 0;
    if (searchQuery?.isNotEmpty ?? false) n++;
    if (statuses.isNotEmpty) n++;
    if (priorities.isNotEmpty) n++;
    if (startDateFrom != null || startDateTo != null) n++;
    if (assigneeId != null) n++;
    return n;
  }

  GanttFilter copyWith({
    String? searchQuery,
    Set<TaskStatus>? statuses,
    Set<TaskPriority>? priorities,
    DateTime? startDateFrom,
    DateTime? startDateTo,
    String? assigneeId,
  }) {
    return GanttFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      statuses: statuses ?? this.statuses,
      priorities: priorities ?? this.priorities,
      startDateFrom: startDateFrom ?? this.startDateFrom,
      startDateTo: startDateTo ?? this.startDateTo,
      assigneeId: assigneeId ?? this.assigneeId,
    );
  }
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
  final Set<int> weekendDays; // DateTime.saturday, DateTime.sunday

  const GanttViewSettings({
    this.viewMode = GanttViewMode.week,
    this.dayWidth = 32.0,
    this.rowHeight = 48.0,
    this.headerHeight = 36.0,
    this.subHeaderHeight = 28.0,
    this.sidebarWidth = 280.0,
    this.showWeekends = true,
    this.showCriticalPath = false,
    this.showDependencies = true,
    this.showProgress = true,
    this.showToday = true,
    this.weekendDays = const {DateTime.saturday, DateTime.sunday},
  });

  GanttViewSettings copyWith({
    GanttViewMode? viewMode,
    double? dayWidth,
    double? rowHeight,
    double? headerHeight,
    double? subHeaderHeight,
    double? sidebarWidth,
    bool? showWeekends,
    bool? showCriticalPath,
    bool? showDependencies,
    bool? showProgress,
    bool? showToday,
    Set<int>? weekendDays,
  }) {
    return GanttViewSettings(
      viewMode: viewMode ?? this.viewMode,
      dayWidth: dayWidth ?? this.dayWidth,
      rowHeight: rowHeight ?? this.rowHeight,
      headerHeight: headerHeight ?? this.headerHeight,
      subHeaderHeight: subHeaderHeight ?? this.subHeaderHeight,
      sidebarWidth: sidebarWidth ?? this.sidebarWidth,
      showWeekends: showWeekends ?? this.showWeekends,
      showCriticalPath: showCriticalPath ?? this.showCriticalPath,
      showDependencies: showDependencies ?? this.showDependencies,
      showProgress: showProgress ?? this.showProgress,
      showToday: showToday ?? this.showToday,
      weekendDays: weekendDays ?? this.weekendDays,
    );
  }
}
