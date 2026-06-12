import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/task_model.dart';
import '../providers/gantt_providers.dart';
import '../utils/date_utils.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

enum NotificationType {
  taskOverdue,
  taskDueSoon,
  commentMention,
  taskAssigned,
  dependencyBlocked,
  milestoneReached,
}

class GanttNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final String? taskId;
  final DateTime createdAt;
  final bool isRead;

  const GanttNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.taskId,
    required this.createdAt,
    this.isRead = false,
  });

  GanttNotification copyWith({bool? isRead}) => GanttNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        taskId: taskId,
        createdAt: createdAt,
        isRead: isRead ?? this.isRead,
      );

  IconData get icon => switch (type) {
        NotificationType.taskOverdue => Icons.warning_amber_outlined,
        NotificationType.taskDueSoon => Icons.schedule_outlined,
        NotificationType.commentMention => Icons.alternate_email,
        NotificationType.taskAssigned => Icons.person_add_outlined,
        NotificationType.dependencyBlocked => Icons.block_outlined,
        NotificationType.milestoneReached => Icons.flag_outlined,
      };

  Color get color => switch (type) {
        NotificationType.taskOverdue => const Color(0xFFEF4444),
        NotificationType.taskDueSoon => const Color(0xFFF59E0B),
        NotificationType.commentMention => const Color(0xFF6366F1),
        NotificationType.taskAssigned => const Color(0xFF10B981),
        NotificationType.dependencyBlocked => const Color(0xFFEF4444),
        NotificationType.milestoneReached => const Color(0xFFF59E0B),
      };
}

// ─── Mention parsing ──────────────────────────────────────────────────────────

/// Parses @name mentions from comment text.
/// Returns list of [start, end] spans for highlighting.
List<({int start, int end, String name})> parseMentions(String text) {
  final result = <({int start, int end, String name})>[];
  final re = RegExp(r'@(\w[\w\s]{0,30}?)(?=\s|$|[^\w])');
  for (final m in re.allMatches(text)) {
    result.add((start: m.start, end: m.end, name: m.group(1)!.trim()));
  }
  return result;
}

/// Builds a TextSpan with @mentions highlighted in accent color.
TextSpan buildMentionText(
  String text, {
  TextStyle? baseStyle,
  TextStyle? mentionStyle,
}) {
  final mentions = parseMentions(text);
  if (mentions.isEmpty) return TextSpan(text: text, style: baseStyle);

  final spans = <InlineSpan>[];
  int cursor = 0;
  for (final m in mentions) {
    if (m.start > cursor) {
      spans.add(
          TextSpan(text: text.substring(cursor, m.start), style: baseStyle));
    }
    spans.add(TextSpan(
      text: text.substring(m.start, m.end),
      style: mentionStyle ??
          baseStyle?.copyWith(
            color: const Color(0xFF818CF8),
            fontWeight: FontWeight.w600,
          ),
    ));
    cursor = m.end;
  }
  if (cursor < text.length) {
    spans.add(TextSpan(text: text.substring(cursor), style: baseStyle));
  }
  return TextSpan(children: spans);
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class NotificationsNotifier extends StateNotifier<List<GanttNotification>> {
  NotificationsNotifier() : super(const []);

  void add(GanttNotification n) {
    // Dedup: skip if same type+taskId within last 60s
    final now = DateTime.now();
    final dupe = state.any((x) =>
        x.taskId == n.taskId &&
        x.type == n.type &&
        now.difference(x.createdAt).inSeconds < 60);
    if (dupe) return;
    state = [n, ...state].take(100).toList();
  }

  void markRead(String id) {
    state =
        state.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList();
  }

  void markAllRead() {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
  }

  void dismiss(String id) {
    state = state.where((n) => n.id != id).toList();
  }

  void clearAll() => state = [];

  /// Called by [NotificationWatcher] to check for overdue / due-soon tasks.
  void checkTasks(List<Task> tasks) {
    final now = DateTime.now();
    final soon = now.add(const Duration(days: 3));

    for (final t in tasks) {
      if (t.status == TaskStatus.done) continue;

      if (t.isOverdue) {
        add(GanttNotification(
          id: 'overdue_${t.id}',
          type: NotificationType.taskOverdue,
          title: 'Task Overdue',
          body:
              '"${t.title}" was due ${GanttDateUtils.formatRelativeDate(t.endDate)}',
          taskId: t.id,
          createdAt: now,
        ));
      } else if (t.endDate.isBefore(soon) && t.endDate.isAfter(now)) {
        add(GanttNotification(
          id: 'soon_${t.id}',
          type: NotificationType.taskDueSoon,
          title: 'Due Soon',
          body:
              '"${t.title}" due ${GanttDateUtils.formatRelativeDate(t.endDate)}',
          taskId: t.id,
          createdAt: now,
        ));
      }

      if (t.isMilestone && t.progress >= 1.0) {
        add(GanttNotification(
          id: 'milestone_${t.id}',
          type: NotificationType.milestoneReached,
          title: 'Milestone Reached',
          body: '"${t.title}" has been completed',
          taskId: t.id,
          createdAt: now,
        ));
      }
    }
  }

  /// Called when a new comment with @mentions is added.
  void onCommentMention(
      Task task, TaskComment comment, List<String> mentionedNames) {
    for (final name in mentionedNames) {
      add(GanttNotification(
        id: 'mention_${comment.id}',
        type: NotificationType.commentMention,
        title: '@$name mentioned',
        body:
            '${comment.authorName} in "${task.title}": ${comment.content.length > 60 ? "${comment.content.substring(0, 60)}…" : comment.content}',
        taskId: task.id,
        createdAt: DateTime.now(),
      ));
    }
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<GanttNotification>>(
        (_) => NotificationsNotifier());

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).where((n) => !n.isRead).length;
});

final notificationPanelOpenProvider = StateProvider<bool>((_) => false);

// ─── Watcher: checks tasks whenever state changes ─────────────────────────────

class NotificationWatcher extends ConsumerStatefulWidget {
  final Widget child;
  const NotificationWatcher({super.key, required this.child});
  @override
  ConsumerState<NotificationWatcher> createState() =>
      _NotificationWatcherState();
}

class _NotificationWatcherState extends ConsumerState<NotificationWatcher> {
  @override
  Widget build(BuildContext context) {
    ref.listen<List<Task>>(tasksProvider, (_, tasks) {
      Future.microtask(
          () => ref.read(notificationsProvider.notifier).checkTasks(tasks));
    });
    return widget.child;
  }
}
