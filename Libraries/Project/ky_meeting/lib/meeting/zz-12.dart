import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'zz-8.dart';

// ==================== CALENDAR VIEW PAGE ====================

class CalendarViewPage extends ConsumerStatefulWidget {
  const CalendarViewPage({Key? key}) : super(key: key);

  @override
  ConsumerState<CalendarViewPage> createState() => _CalendarViewPageState();
}

class _CalendarViewPageState extends ConsumerState<CalendarViewPage> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final meetingsAsync = ref.watch(meetingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calendar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () => setState(() {
              _selectedDate = DateTime.now();
              _focusedMonth = DateTime.now();
            }),
          ),
        ],
      ),
      body: meetingsAsync.when(
        data: (meetings) {
          return Column(
            children: [
              _buildCalendarHeader(),
              _buildCalendarGrid(meetings),
              const Divider(),
              Expanded(child: _buildSelectedDayEvents(meetings)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddEditMeetingPage(initialDate: _selectedDate),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => setState(() {
              _focusedMonth = DateTime(
                _focusedMonth.year,
                _focusedMonth.month - 1,
              );
            }),
          ),
          Text(
            DateFormat('MMMM yyyy').format(_focusedMonth),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => setState(() {
              _focusedMonth = DateTime(
                _focusedMonth.year,
                _focusedMonth.month + 1,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(List<Meeting> meetings) {
    final firstDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    );
    final daysInMonth = lastDayOfMonth.day;
    final startingWeekday = firstDayOfMonth.weekday % 7;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map(
                  (day) => SizedBox(
                    width: 40,
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          ...List.generate(6, (weekIndex) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (dayIndex) {
                final dayNumber =
                    weekIndex * 7 + dayIndex - startingWeekday + 1;
                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const SizedBox(width: 40, height: 40);
                }

                final date = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month,
                  dayNumber,
                );
                final isSelected =
                    _selectedDate.year == date.year &&
                    _selectedDate.month == date.month &&
                    _selectedDate.day == date.day;
                final isToday =
                    DateTime.now().year == date.year &&
                    DateTime.now().month == date.month &&
                    DateTime.now().day == date.day;
                final hasMeetings = meetings.any(
                  (m) =>
                      m.dateTime.year == date.year &&
                      m.dateTime.month == date.month &&
                      m.dateTime.day == date.day,
                );

                return GestureDetector(
                  onTap: () => setState(() => _selectedDate = date),
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : isToday
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      shape: BoxShape.circle,
                      border: hasMeetings && !isSelected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            )
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$dayNumber',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : isToday
                              ? Theme.of(context).colorScheme.primary
                              : null,
                          fontWeight: isSelected || isToday
                              ? FontWeight.bold
                              : null,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSelectedDayEvents(List<Meeting> meetings) {
    final dayMeetings =
        meetings
            .where(
              (m) =>
                  m.dateTime.year == _selectedDate.year &&
                  m.dateTime.month == _selectedDate.month &&
                  m.dateTime.day == _selectedDate.day,
            )
            .toList()
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            DateFormat('EEEE, MMMM d').format(_selectedDate),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: dayMeetings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_available,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No meetings scheduled',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: dayMeetings.length,
                  itemBuilder: (context, index) =>
                      MeetingCompactCard(meeting: dayMeetings[index]),
                ),
        ),
      ],
    );
  }
}

// ==================== TASKS PAGE ====================

class TasksPage extends ConsumerWidget {
  const TasksPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewType = ref.watch(taskViewTypeProvider);
    final actionPlansAsync = ref.watch(actionPlansProvider);
    final meetingsAsync = ref.watch(meetingsProvider);
    final programsAsync = ref.watch(programsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tasks',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(_getViewIcon(viewType)),
            onPressed: () => _showViewTypeSelector(context, ref),
          ),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Performance Overview',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          meetingsAsync.when(
            data: (meetings) => _buildMeetingMetrics(context, meetings),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(height: 24),
          actionPlansAsync.when(
            data: (plans) => _buildTaskMetrics(context, plans),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(height: 24),
          programsAsync.when(
            data: (programs) => _buildProgramMetrics(context, programs),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
    );
  }

  IconData _getViewIcon(TaskViewType type) {
    switch (type) {
      case TaskViewType.list:
        return Icons.list;
      case TaskViewType.kanban:
        return Icons.view_column;
      case TaskViewType.gantt:
        return Icons.show_chart;
      case TaskViewType.calendar:
        return Icons.calendar_view_day;
    }
  }

  void _showViewTypeSelector(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'View Type',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('List View'),
              onTap: () {
                ref.read(taskViewTypeProvider.notifier).state =
                    TaskViewType.list;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.view_column),
              title: const Text('Kanban Board'),
              onTap: () {
                ref.read(taskViewTypeProvider.notifier).state =
                    TaskViewType.kanban;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.show_chart),
              title: const Text('Gantt Chart'),
              onTap: () {
                ref.read(taskViewTypeProvider.notifier).state =
                    TaskViewType.gantt;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_view_day),
              title: const Text('Calendar View'),
              onTap: () {
                ref.read(taskViewTypeProvider.notifier).state =
                    TaskViewType.calendar;
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeetingMetrics(BuildContext context, List<Meeting> meetings) {
    final now = DateTime.now();
    final thisMonth = meetings
        .where(
          (m) => m.dateTime.year == now.year && m.dateTime.month == now.month,
        )
        .length;
    final completed = meetings
        .where((m) => m.status == MeetingStatus.completed)
        .length;
    final avgDuration = meetings.isEmpty
        ? 0
        : meetings.fold<int>(0, (sum, m) => sum + m.durationMinutes) /
              meetings.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Meeting Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'This Month',
                    '$thisMonth',
                    Icons.calendar_month,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Completed',
                    '$completed',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Avg Duration',
                    '${avgDuration.toInt()}m',
                    Icons.timer,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Meeting Trends',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'Chart visualization placeholder',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskMetrics(BuildContext context, List<ActionPlan> plans) {
    final allTasks = plans.expand((p) => p.actions).toList();
    final completed = allTasks.where((t) => t.isCompleted).length;
    final inProgress = allTasks
        .where((t) => t.status == ActionItemStatus.inProgress)
        .length;
    final overdue = allTasks.where((t) => t.isOverdue).length;
    final completionRate = allTasks.isEmpty
        ? 0
        : (completed / allTasks.length * 100).toInt();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Task Performance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'Completed',
                    '$completed',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'In Progress',
                    '$inProgress',
                    Icons.pending,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Overdue',
                    '$overdue',
                    Icons.warning,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Completion Rate',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$completionRate%',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: completionRate / 100,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey.shade300,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramMetrics(BuildContext context, List<Program> programs) {
    final active = programs
        .where((p) => p.status == ProgramStatus.active)
        .length;
    final completed = programs
        .where((p) => p.status == ProgramStatus.completed)
        .length;
    final avgProgress = programs.isEmpty
        ? 0
        : programs.fold<int>(0, (sum, p) => sum + p.progressPercentage) /
              programs.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Program Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'Active',
                    '$active',
                    Icons.folder_open,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Completed',
                    '$completed',
                    Icons.done_all,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Avg Progress',
                    '${avgProgress.toInt()}%',
                    Icons.trending_up,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ==================== MORE PAGE ====================

class MorePage extends ConsumerWidget {
  const MorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'More',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(context, 'Management', [
            _buildMenuItem(
              'Meetings',
              Icons.event_note,
              Colors.blue,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MeetingsListPage()),
              ),
            ),
            _buildMenuItem(
              'Programs',
              Icons.folder,
              Colors.purple,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProgramsPage()),
              ),
            ),
            _buildMenuItem(
              'Action Plans',
              Icons.assignment,
              Colors.orange,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ActionPlansPage()),
              ),
            ),
            _buildMenuItem(
              'Evaluations',
              Icons.assessment,
              Colors.green,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EvaluationsPage()),
              ),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection(context, 'Tools', [
            _buildMenuItem('Time Tracking', Icons.timer, Colors.teal, () {}),
            _buildMenuItem('Reports', Icons.bar_chart, Colors.indigo, () {}),
            _buildMenuItem('Export Data', Icons.download, Colors.cyan, () {}),
          ]),
          const SizedBox(height: 24),
          _buildSection(context, 'Settings', [
            _buildMenuItem('Preferences', Icons.settings, Colors.grey, () {}),
            _buildMenuItem(
              'Notifications',
              Icons.notifications,
              Colors.amber,
              () {},
            ),
            _buildMenuItem('About', Icons.info, Colors.blueGrey, () {}),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        Card(child: Column(children: items)),
      ],
    );
  }

  Widget _buildMenuItem(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

// ==================== NOTIFICATIONS PAGE ====================

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () =>
                ref.read(notificationsProvider.notifier).clearAll(),
            child: const Text('Clear All'),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          final unread = notifications.where((n) => !n.isRead).toList();
          final read = notifications.where((n) => n.isRead).toList();

          return ListView(
            children: [
              if (unread.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Unread',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ...unread.map((n) => NotificationCard(notification: n)),
                const SizedBox(height: 16),
              ],
              if (read.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Read',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ...read.map((n) => NotificationCard(notification: n)),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class NotificationCard extends ConsumerWidget {
  final NotificationItem notification;

  const NotificationCard({Key? key, required this.notification})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: notification.isRead ? null : Colors.blue.shade50,
      child: ListTile(
        leading: _buildIcon(),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead
                ? FontWeight.normal
                : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            const SizedBox(height: 4),
            Text(
              _formatTime(notification.scheduledTime),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
        onTap: () {
          if (!notification.isRead) {
            ref
                .read(notificationsProvider.notifier)
                .markAsRead(notification.id);
          }
        },
      ),
    );
  }

  Widget _buildIcon() {
    IconData icon;
    Color color;

    switch (notification.type) {
      case NotificationType.meeting:
        icon = Icons.event;
        color = Colors.blue;
        break;
      case NotificationType.actionItem:
        icon = Icons.task;
        color = Colors.orange;
        break;
      case NotificationType.deadline:
        icon = Icons.warning;
        color = Colors.red;
        break;
      case NotificationType.reminder:
        icon = Icons.notifications;
        color = Colors.purple;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd').format(time);
    }
  }
}

// ==================== COMPACT CARDS ====================

class MeetingCompactCard extends StatelessWidget {
  final Meeting meeting;

  const MeetingCompactCard({Key? key, required this.meeting}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MeetingDetailsPage(meeting: meeting),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      meeting.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (meeting.isRecurring)
                    Icon(Icons.repeat, size: 16, color: Colors.grey.shade600),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('h:mm a').format(meeting.dateTime),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.timer, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${meeting.durationMinutes}m',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== STUB PAGES ====================

class MeetingsListPage extends StatelessWidget {
  const MeetingsListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Meetings')),
      body: const Center(child: Text('Meetings List')),
    );
  }
}

class ProgramsPage extends StatelessWidget {
  const ProgramsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Programs')),
      body: const Center(child: Text('Programs Page')),
    );
  }
}

class ActionPlansPage extends StatelessWidget {
  const ActionPlansPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Action Plans')),
      body: const Center(child: Text('Action Plans Page')),
    );
  }
}

class EvaluationsPage extends StatelessWidget {
  const EvaluationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Evaluations')),
      body: const Center(child: Text('Evaluations Page')),
    );
  }
}

class AddEditMeetingPage extends StatelessWidget {
  final DateTime? initialDate;

  const AddEditMeetingPage({Key? key, this.initialDate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Meeting')),
      body: const Center(child: Text('Add/Edit Meeting Form')),
    );
  }
}

class AddEditProgramPage extends StatelessWidget {
  const AddEditProgramPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Program')),
      body: const Center(child: Text('Add/Edit Program Form')),
    );
  }
}

class AddEditActionPlanPage extends StatelessWidget {
  const AddEditActionPlanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Action Plan')),
      body: const Center(child: Text('Add/Edit Action Plan Form')),
    );
  }
}

class MeetingDetailsPage extends StatelessWidget {
  final Meeting meeting;

  const MeetingDetailsPage({Key? key, required this.meeting}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meeting Details')),
      body: Center(child: Text('Details for: ${meeting.title}')),
    );
  }
}

// ==================== TASK CARD ====================

class TaskCard extends StatelessWidget {
  final ActionItem task;

  const TaskCard({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildPriorityIndicator(),
                ],
              ),
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  task.description,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  if (task.assignedTo != null) ...[
                    Icon(Icons.person, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      task.assignedTo!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (task.dueDate != null) ...[
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: task.isOverdue ? Colors.red : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM dd').format(task.dueDate!),
                      style: TextStyle(
                        fontSize: 12,
                        color: task.isOverdue
                            ? Colors.red
                            : Colors.grey.shade600,
                        fontWeight: task.isOverdue ? FontWeight.bold : null,
                      ),
                    ),
                  ],
                ],
              ),
              if (task.progressPercentage > 0) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: task.progressPercentage / 100,
                  backgroundColor: Colors.grey.shade200,
                ),
                const SizedBox(height: 4),
                Text(
                  '${task.progressPercentage}% complete',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator() {
    Color color;
    switch (task.priority) {
      case ActionItemPriority.critical:
        color = Colors.red.shade700;
        break;
      case ActionItemPriority.high:
        color = Colors.red;
        break;
      case ActionItemPriority.medium:
        color = Colors.orange;
        break;
      case ActionItemPriority.low:
        color = Colors.green;
        break;
    }

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ==================== ANALYTICS PAGE ====================

class Evaluation {
  final String id;
  final String title;
  final String? programId;
  final String? actionPlanId;
  final String? meetingId;
  final EvaluationStatus status;
  final DateTime evaluationDate;
  final List<EvaluationCriteria> criteria;
  final String summary;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> recommendations;
  final int overallScore;
  final String? evaluator;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<FileAttachment> attachments;
  final List<Comment> comments;

  Evaluation({
    required this.id,
    required this.title,
    this.programId,
    this.actionPlanId,
    this.meetingId,
    required this.status,
    required this.evaluationDate,
    required this.criteria,
    required this.summary,
    required this.strengths,
    required this.weaknesses,
    required this.recommendations,
    this.overallScore = 0,
    this.evaluator,
    required this.createdAt,
    this.updatedAt,
    this.attachments = const [],
    this.comments = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'programId': programId,
    'actionPlanId': actionPlanId,
    'meetingId': meetingId,
    'status': status.name,
    'evaluationDate': evaluationDate.toIso8601String(),
    'criteria': criteria.map((c) => c.toJson()).toList(),
    'summary': summary,
    'strengths': strengths,
    'weaknesses': weaknesses,
    'recommendations': recommendations,
    'overallScore': overallScore,
    'evaluator': evaluator,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'attachments': attachments.map((a) => a.toJson()).toList(),
    'comments': comments.map((c) => c.toJson()).toList(),
  };

  factory Evaluation.fromJson(Map<String, dynamic> json) => Evaluation(
    id: json['id'],
    title: json['title'],
    programId: json['programId'],
    actionPlanId: json['actionPlanId'],
    meetingId: json['meetingId'],
    status: EvaluationStatus.values.firstWhere((e) => e.name == json['status']),
    evaluationDate: DateTime.parse(json['evaluationDate']),
    criteria: (json['criteria'] as List)
        .map((c) => EvaluationCriteria.fromJson(c))
        .toList(),
    summary: json['summary'],
    strengths: List<String>.from(json['strengths'] ?? []),
    weaknesses: List<String>.from(json['weaknesses'] ?? []),
    recommendations: List<String>.from(json['recommendations'] ?? []),
    overallScore: json['overallScore'] ?? 0,
    evaluator: json['evaluator'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'])
        : null,
    attachments: (json['attachments'] as List? ?? [])
        .map((a) => FileAttachment.fromJson(a))
        .toList(),
    comments: (json['comments'] as List? ?? [])
        .map((c) => Comment.fromJson(c))
        .toList(),
  );

  Evaluation copyWith({
    String? title,
    String? programId,
    String? actionPlanId,
    String? meetingId,
    EvaluationStatus? status,
    DateTime? evaluationDate,
    List<EvaluationCriteria>? criteria,
    String? summary,
    List<String>? strengths,
    List<String>? weaknesses,
    List<String>? recommendations,
    int? overallScore,
    String? evaluator,
    List<FileAttachment>? attachments,
    List<Comment>? comments,
  }) {
    return Evaluation(
      id: id,
      title: title ?? this.title,
      programId: programId ?? this.programId,
      actionPlanId: actionPlanId ?? this.actionPlanId,
      meetingId: meetingId ?? this.meetingId,
      status: status ?? this.status,
      evaluationDate: evaluationDate ?? this.evaluationDate,
      criteria: criteria ?? this.criteria,
      summary: summary ?? this.summary,
      strengths: strengths ?? this.strengths,
      weaknesses: weaknesses ?? this.weaknesses,
      recommendations: recommendations ?? this.recommendations,
      overallScore: overallScore ?? this.overallScore,
      evaluator: evaluator ?? this.evaluator,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      attachments: attachments ?? this.attachments,
      comments: comments ?? this.comments,
    );
  }
}

class EvaluationCriteria {
  final String name;
  final String description;
  final int score;
  final int maxScore;
  final String? comments;

  EvaluationCriteria({
    required this.name,
    required this.description,
    required this.score,
    this.maxScore = 10,
    this.comments,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'score': score,
    'maxScore': maxScore,
    'comments': comments,
  };

  factory EvaluationCriteria.fromJson(Map<String, dynamic> json) =>
      EvaluationCriteria(
        name: json['name'],
        description: json['description'],
        score: json['score'],
        maxScore: json['maxScore'] ?? 10,
        comments: json['comments'],
      );

  double get percentage => (score / maxScore) * 100;
}

// ==================== ANALYTICS MODELS ====================

class AnalyticsReport {
  final DateTime generatedAt;
  final Map<String, dynamic> meetingMetrics;
  final Map<String, dynamic> taskMetrics;
  final Map<String, dynamic> productivityMetrics;
  final Map<String, dynamic> teamMetrics;

  AnalyticsReport({
    required this.generatedAt,
    required this.meetingMetrics,
    required this.taskMetrics,
    required this.productivityMetrics,
    required this.teamMetrics,
  });
}

// ==================== PERSISTENCE ====================

class DataRepository {
  static const String _meetingsKey = 'meetings_data';
  static const String _programsKey = 'programs_data';
  static const String _actionPlansKey = 'action_plans_data';
  static const String _evaluationsKey = 'evaluations_data';
  static const String _notificationsKey = 'notifications_data';

  Future<void> saveMeetings(List<Meeting> meetings) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = meetings.map((m) => m.toJson()).toList();
    await prefs.setString(_meetingsKey, jsonEncode(jsonData));
  }

  Future<List<Meeting>> loadMeetings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_meetingsKey);
    if (jsonString == null) return [];
    final jsonData = jsonDecode(jsonString) as List;
    return jsonData.map((json) => Meeting.fromJson(json)).toList();
  }

  Future<void> savePrograms(List<Program> programs) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = programs.map((p) => p.toJson()).toList();
    await prefs.setString(_programsKey, jsonEncode(jsonData));
  }

  Future<List<Program>> loadPrograms() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_programsKey);
    if (jsonString == null) return [];
    final jsonData = jsonDecode(jsonString) as List;
    return jsonData.map((json) => Program.fromJson(json)).toList();
  }

  Future<void> saveActionPlans(List<ActionPlan> plans) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = plans.map((p) => p.toJson()).toList();
    await prefs.setString(_actionPlansKey, jsonEncode(jsonData));
  }

  Future<List<ActionPlan>> loadActionPlans() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_actionPlansKey);
    if (jsonString == null) return [];
    final jsonData = jsonDecode(jsonString) as List;
    return jsonData.map((json) => ActionPlan.fromJson(json)).toList();
  }

  Future<void> saveEvaluations(List<Evaluation> evaluations) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = evaluations.map((e) => e.toJson()).toList();
    await prefs.setString(_evaluationsKey, jsonEncode(jsonData));
  }

  Future<List<Evaluation>> loadEvaluations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_evaluationsKey);
    if (jsonString == null) return [];
    final jsonData = jsonDecode(jsonString) as List;
    return jsonData.map((json) => Evaluation.fromJson(json)).toList();
  }

  Future<void> saveNotifications(List<NotificationItem> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = notifications.map((n) => n.toJson()).toList();
    await prefs.setString(_notificationsKey, jsonEncode(jsonData));
  }

  Future<List<NotificationItem>> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_notificationsKey);
    if (jsonString == null) return [];
    final jsonData = jsonDecode(jsonString) as List;
    return jsonData.map((json) => NotificationItem.fromJson(json)).toList();
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_meetingsKey),
      prefs.remove(_programsKey),
      prefs.remove(_actionPlansKey),
      prefs.remove(_evaluationsKey),
      prefs.remove(_notificationsKey),
    ]);
  }
}

// ==================== STATE MANAGEMENT ====================

final dataRepositoryProvider = Provider((ref) => DataRepository());

// Meetings
class MeetingsNotifier extends StateNotifier<AsyncValue<List<Meeting>>> {
  final DataRepository repository;

  MeetingsNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadMeetings();
  }

  Future<void> loadMeetings() async {
    state = const AsyncValue.loading();
    try {
      final meetings = await repository.loadMeetings();
      state = AsyncValue.data(meetings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addMeeting(Meeting meeting) async {
    final currentState = state.value ?? [];
    final newState = [...currentState, meeting];
    state = AsyncValue.data(newState);
    await repository.saveMeetings(newState);
  }

  Future<void> updateMeeting(Meeting updatedMeeting) async {
    final currentState = state.value ?? [];
    final newState = [
      for (final meeting in currentState)
        if (meeting.id == updatedMeeting.id) updatedMeeting else meeting,
    ];
    state = AsyncValue.data(newState);
    await repository.saveMeetings(newState);
  }

  Future<void> deleteMeeting(String id) async {
    final currentState = state.value ?? [];
    final newState = currentState.where((m) => m.id != id).toList();
    state = AsyncValue.data(newState);
    await repository.saveMeetings(newState);
  }
}

final meetingsProvider =
    StateNotifierProvider<MeetingsNotifier, AsyncValue<List<Meeting>>>(
      (ref) => MeetingsNotifier(ref.watch(dataRepositoryProvider)),
    );

// Programs
class ProgramsNotifier extends StateNotifier<AsyncValue<List<Program>>> {
  final DataRepository repository;

  ProgramsNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadPrograms();
  }

  Future<void> loadPrograms() async {
    state = const AsyncValue.loading();
    try {
      final programs = await repository.loadPrograms();
      state = AsyncValue.data(programs);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addProgram(Program program) async {
    final currentState = state.value ?? [];
    final newState = [...currentState, program];
    state = AsyncValue.data(newState);
    await repository.savePrograms(newState);
  }

  Future<void> updateProgram(Program updatedProgram) async {
    final currentState = state.value ?? [];
    final newState = [
      for (final program in currentState)
        if (program.id == updatedProgram.id) updatedProgram else program,
    ];
    state = AsyncValue.data(newState);
    await repository.savePrograms(newState);
  }

  Future<void> deleteProgram(String id) async {
    final currentState = state.value ?? [];
    final newState = currentState.where((p) => p.id != id).toList();
    state = AsyncValue.data(newState);
    await repository.savePrograms(newState);
  }
}

final programsProvider =
    StateNotifierProvider<ProgramsNotifier, AsyncValue<List<Program>>>(
      (ref) => ProgramsNotifier(ref.watch(dataRepositoryProvider)),
    );

// Action Plans
class ActionPlansNotifier extends StateNotifier<AsyncValue<List<ActionPlan>>> {
  final DataRepository repository;

  ActionPlansNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadActionPlans();
  }

  Future<void> loadActionPlans() async {
    state = const AsyncValue.loading();
    try {
      final plans = await repository.loadActionPlans();
      state = AsyncValue.data(plans);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addActionPlan(ActionPlan plan) async {
    final currentState = state.value ?? [];
    final newState = [...currentState, plan];
    state = AsyncValue.data(newState);
    await repository.saveActionPlans(newState);
  }

  Future<void> updateActionPlan(ActionPlan updatedPlan) async {
    final currentState = state.value ?? [];
    final newState = [
      for (final plan in currentState)
        if (plan.id == updatedPlan.id) updatedPlan else plan,
    ];
    state = AsyncValue.data(newState);
    await repository.saveActionPlans(newState);
  }

  Future<void> deleteActionPlan(String id) async {
    final currentState = state.value ?? [];
    final newState = currentState.where((p) => p.id != id).toList();
    state = AsyncValue.data(newState);
    await repository.saveActionPlans(newState);
  }
}

final actionPlansProvider =
    StateNotifierProvider<ActionPlansNotifier, AsyncValue<List<ActionPlan>>>(
      (ref) => ActionPlansNotifier(ref.watch(dataRepositoryProvider)),
    );

// Evaluations
class EvaluationsNotifier extends StateNotifier<AsyncValue<List<Evaluation>>> {
  final DataRepository repository;

  EvaluationsNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadEvaluations();
  }

  Future<void> loadEvaluations() async {
    state = const AsyncValue.loading();
    try {
      final evaluations = await repository.loadEvaluations();
      state = AsyncValue.data(evaluations);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addEvaluation(Evaluation evaluation) async {
    final currentState = state.value ?? [];
    final newState = [...currentState, evaluation];
    state = AsyncValue.data(newState);
    await repository.saveEvaluations(newState);
  }

  Future<void> updateEvaluation(Evaluation updatedEvaluation) async {
    final currentState = state.value ?? [];
    final newState = [
      for (final evaluation in currentState)
        if (evaluation.id == updatedEvaluation.id)
          updatedEvaluation
        else
          evaluation,
    ];
    state = AsyncValue.data(newState);
    await repository.saveEvaluations(newState);
  }

  Future<void> deleteEvaluation(String id) async {
    final currentState = state.value ?? [];
    final newState = currentState.where((e) => e.id != id).toList();
    state = AsyncValue.data(newState);
    await repository.saveEvaluations(newState);
  }
}

final evaluationsProvider =
    StateNotifierProvider<EvaluationsNotifier, AsyncValue<List<Evaluation>>>(
      (ref) => EvaluationsNotifier(ref.watch(dataRepositoryProvider)),
    );

// Notifications
class NotificationsNotifier
    extends StateNotifier<AsyncValue<List<NotificationItem>>> {
  final DataRepository repository;

  NotificationsNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    state = const AsyncValue.loading();
    try {
      final notifications = await repository.loadNotifications();
      state = AsyncValue.data(notifications);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addNotification(NotificationItem notification) async {
    final currentState = state.value ?? [];
    final newState = [...currentState, notification];
    state = AsyncValue.data(newState);
    await repository.saveNotifications(newState);
  }

  Future<void> markAsRead(String id) async {
    final currentState = state.value ?? [];
    final newState = [
      for (final notification in currentState)
        if (notification.id == id)
          notification.copyWith(isRead: true)
        else
          notification,
    ];
    state = AsyncValue.data(newState);
    await repository.saveNotifications(newState);
  }

  Future<void> clearAll() async {
    state = const AsyncValue.data([]);
    await repository.saveNotifications([]);
  }
}

final notificationsProvider =
    StateNotifierProvider<
      NotificationsNotifier,
      AsyncValue<List<NotificationItem>>
    >((ref) => NotificationsNotifier(ref.watch(dataRepositoryProvider)));

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(notificationsProvider);
  final notifications = notificationsAsync.value ?? [];
  return notifications.where((n) => !n.isRead).length;
});

// Task View Type
final taskViewTypeProvider = StateProvider<TaskViewType>(
  (ref) => TaskViewType.list,
);

// ==================== MAIN APP ====================

void main() {
  runApp(const ProviderScope(child: MeetingManagementApp()));
}

class MeetingManagementApp extends StatelessWidget {
  const MeetingManagementApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meeting Management Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainNavigationPage(),
    );
  }
}

// ==================== MAIN NAVIGATION ====================

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({Key? key}) : super(key: key);

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          DashboardPage(),
          CalendarViewPage(),
          TasksPage(),
          AnalyticsPage(),
          MorePage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_outlined),
            selectedIcon: Icon(Icons.task),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            selectedIcon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }
}

// ==================== DASHBOARD PAGE ====================

class DashboardPage extends ConsumerWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetingsAsync = ref.watch(meetingsProvider);
    final programsAsync = ref.watch(programsProvider);
    final actionPlansAsync = ref.watch(actionPlansProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsPage()),
                ),
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(meetingsProvider);
          ref.invalidate(programsProvider);
          ref.invalidate(actionPlansProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Welcome Back!',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Here\'s what\'s happening today',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildQuickStatCard(
                    'Today\'s Meetings',
                    _getTodayMeetingsCount(
                      meetingsAsync.value ?? [],
                    ).toString(),
                    Icons.event_note,
                    Colors.blue,
                    context,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickStatCard(
                    'Active Tasks',
                    _getActiveTasksCount(
                      actionPlansAsync.value ?? [],
                    ).toString(),
                    Icons.task,
                    Colors.orange,
                    context,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickStatCard(
                    'Programs',
                    programsAsync.value?.length.toString() ?? '0',
                    Icons.folder,
                    Colors.purple,
                    context,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickStatCard(
                    'Overdue Tasks',
                    _getOverdueTasksCount(
                      actionPlansAsync.value ?? [],
                    ).toString(),
                    Icons.warning,
                    Colors.red,
                    context,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upcoming Meetings',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(onPressed: () {}, child: const Text('See All')),
              ],
            ),
            const SizedBox(height: 12),
            meetingsAsync.when(
              data: (meetings) {
                final upcoming =
                    meetings
                        .where(
                          (m) =>
                              m.dateTime.isAfter(DateTime.now()) &&
                              m.status == MeetingStatus.scheduled,
                        )
                        .toList()
                      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

                if (upcoming.isEmpty) {
                  return _buildEmptyState(
                    'No upcoming meetings',
                    Icons.event_available,
                  );
                }

                return Column(
                  children: upcoming
                      .take(3)
                      .map((m) => MeetingCompactCard(meeting: m))
                      .toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Error loading meetings'),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildActivityTimeline(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickActionSheet(context),
        child: const Icon(Icons.add),
        // label: const Text('Quick Add'),
      ),
    );
  }

  int _getTodayMeetingsCount(List<Meeting> meetings) {
    final now = DateTime.now();
    return meetings.where((m) {
      return m.dateTime.year == now.year &&
          m.dateTime.month == now.month &&
          m.dateTime.day == now.day &&
          m.status != MeetingStatus.cancelled;
    }).length;
  }

  int _getActiveTasksCount(List<ActionPlan> plans) {
    return plans.fold(
      0,
      (sum, plan) =>
          sum +
          plan.actions
              .where((a) => a.status == ActionItemStatus.inProgress)
              .length,
    );
  }

  int _getOverdueTasksCount(List<ActionPlan> plans) {
    final now = DateTime.now();
    return plans.fold(
      0,
      (sum, plan) => sum + plan.actions.where((a) => a.isOverdue).length,
    );
  }

  Widget _buildQuickStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    BuildContext context,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //----
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(icon, size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(message, style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityTimeline() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildActivityItem(
              'Meeting completed',
              'Q4 Planning Meeting',
              '2 hours ago',
              Icons.check_circle,
              Colors.green,
            ),
            const Divider(),
            _buildActivityItem(
              'Task assigned',
              'Update project documentation',
              '5 hours ago',
              Icons.assignment,
              Colors.blue,
            ),
            const Divider(),
            _buildActivityItem(
              'Comment added',
              'John commented on Marketing Plan',
              '1 day ago',
              Icons.comment,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    String time,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  void _showQuickActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Quick Add',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('New Meeting'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddEditMeetingPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.task),
              title: const Text('New Task'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to task creation
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('New Program'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddEditProgramPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// pubspec.yaml dependencies:
// flutter_riverpod: ^2.4.9
// uuid: ^4.2.1
// intl: ^0.18.1
// shared_preferences: ^2.2.2
// fl_chart: ^0.65.0
// file_picker: ^6.1.1
// path_provider: ^2.1.1
// syncfusion_flutter_charts: ^24.1.41
// flutter_local_notifications: ^16.3.0
// timezone: ^0.9.2
// rrule: ^0.2.15

// ==================== ENUMS ====================

enum MeetingPriority { low, medium, high, urgent }

enum MeetingStatus { scheduled, inProgress, completed, cancelled }

enum MeetingType {
  standup,
  planning,
  review,
  retrospective,
  oneOnOne,
  program,
  evaluation,
  other,
}

enum ActionItemPriority { low, medium, high, critical }

enum ActionItemStatus { notStarted, inProgress, completed, blocked, cancelled }

enum ProgramStatus { planning, active, onHold, completed, cancelled }

enum EvaluationStatus { draft, inReview, completed }

enum RecurrenceType { none, daily, weekly, biweekly, monthly, yearly, custom }

enum NotificationType { meeting, actionItem, deadline, reminder }

enum FileType { document, image, spreadsheet, presentation, pdf, other }

enum TaskViewType { list, kanban, gantt, calendar }

// ==================== MODELS ====================

class RecurrenceRule {
  final RecurrenceType type;
  final int interval;
  final DateTime? endDate;
  final int? occurrences;
  final List<int>? daysOfWeek; // 1=Monday, 7=Sunday
  final int? dayOfMonth;

  RecurrenceRule({
    required this.type,
    this.interval = 1,
    this.endDate,
    this.occurrences,
    this.daysOfWeek,
    this.dayOfMonth,
  });

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'interval': interval,
    'endDate': endDate?.toIso8601String(),
    'occurrences': occurrences,
    'daysOfWeek': daysOfWeek,
    'dayOfMonth': dayOfMonth,
  };

  factory RecurrenceRule.fromJson(Map<String, dynamic> json) => RecurrenceRule(
    type: RecurrenceType.values.firstWhere((e) => e.name == json['type']),
    interval: json['interval'] ?? 1,
    endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    occurrences: json['occurrences'],
    daysOfWeek: json['daysOfWeek'] != null
        ? List<int>.from(json['daysOfWeek'])
        : null,
    dayOfMonth: json['dayOfMonth'],
  );

  String getDescription() {
    switch (type) {
      case RecurrenceType.none:
        return 'Does not repeat';
      case RecurrenceType.daily:
        return interval == 1 ? 'Daily' : 'Every $interval days';
      case RecurrenceType.weekly:
        return interval == 1 ? 'Weekly' : 'Every $interval weeks';
      case RecurrenceType.biweekly:
        return 'Every 2 weeks';
      case RecurrenceType.monthly:
        return interval == 1 ? 'Monthly' : 'Every $interval months';
      case RecurrenceType.yearly:
        return 'Yearly';
      case RecurrenceType.custom:
        return 'Custom recurrence';
    }
  }
}

class FileAttachment {
  final String id;
  final String name;
  final String path;
  final FileType type;
  final int sizeBytes;
  final DateTime uploadedAt;
  final String? uploadedBy;

  FileAttachment({
    required this.id,
    required this.name,
    required this.path,
    required this.type,
    required this.sizeBytes,
    required this.uploadedAt,
    this.uploadedBy,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'path': path,
    'type': type.name,
    'sizeBytes': sizeBytes,
    'uploadedAt': uploadedAt.toIso8601String(),
    'uploadedBy': uploadedBy,
  };

  factory FileAttachment.fromJson(Map<String, dynamic> json) => FileAttachment(
    id: json['id'],
    name: json['name'],
    path: json['path'],
    type: FileType.values.firstWhere((e) => e.name == json['type']),
    sizeBytes: json['sizeBytes'],
    uploadedAt: DateTime.parse(json['uploadedAt']),
    uploadedBy: json['uploadedBy'],
  );

  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024)
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class Comment {
  final String id;
  final String content;
  final String author;
  final DateTime timestamp;
  final List<String> mentions;

  Comment({
    required this.id,
    required this.content,
    required this.author,
    required this.timestamp,
    this.mentions = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'author': author,
    'timestamp': timestamp.toIso8601String(),
    'mentions': mentions,
  };

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    id: json['id'],
    content: json['content'],
    author: json['author'],
    timestamp: DateTime.parse(json['timestamp']),
    mentions: List<String>.from(json['mentions'] ?? []),
  );
}

class TimeEntry {
  final String id;
  final String description;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationMinutes;
  final String userId;
  final String? taskId;

  TimeEntry({
    required this.id,
    required this.description,
    required this.startTime,
    this.endTime,
    required this.durationMinutes,
    required this.userId,
    this.taskId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'description': description,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'durationMinutes': durationMinutes,
    'userId': userId,
    'taskId': taskId,
  };

  factory TimeEntry.fromJson(Map<String, dynamic> json) => TimeEntry(
    id: json['id'],
    description: json['description'],
    startTime: DateTime.parse(json['startTime']),
    endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    durationMinutes: json['durationMinutes'],
    userId: json['userId'],
    taskId: json['taskId'],
  );

  String get formattedDuration {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime scheduledTime;
  final bool isRead;
  final String? relatedEntityId;
  final Map<String, dynamic>? data;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.scheduledTime,
    this.isRead = false,
    this.relatedEntityId,
    this.data,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'type': type.name,
    'scheduledTime': scheduledTime.toIso8601String(),
    'isRead': isRead,
    'relatedEntityId': relatedEntityId,
    'data': data,
  };

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      NotificationItem(
        id: json['id'],
        title: json['title'],
        body: json['body'],
        type: NotificationType.values.firstWhere((e) => e.name == json['type']),
        scheduledTime: DateTime.parse(json['scheduledTime']),
        isRead: json['isRead'] ?? false,
        relatedEntityId: json['relatedEntityId'],
        data: json['data'],
      );

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      body: body,
      type: type,
      scheduledTime: scheduledTime,
      isRead: isRead ?? this.isRead,
      relatedEntityId: relatedEntityId,
      data: data,
    );
  }
}

class Attendee {
  final String id;
  final String name;
  final String email;
  final bool isOrganizer;
  final bool isOptional;
  final AttendeeStatus status;

  Attendee({
    required this.id,
    required this.name,
    required this.email,
    this.isOrganizer = false,
    this.isOptional = false,
    this.status = AttendeeStatus.pending,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'isOrganizer': isOrganizer,
    'isOptional': isOptional,
    'status': status.name,
  };

  factory Attendee.fromJson(Map<String, dynamic> json) => Attendee(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    isOrganizer: json['isOrganizer'] ?? false,
    isOptional: json['isOptional'] ?? false,
    status: AttendeeStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => AttendeeStatus.pending,
    ),
  );

  Attendee copyWith({
    String? name,
    String? email,
    bool? isOrganizer,
    bool? isOptional,
    AttendeeStatus? status,
  }) {
    return Attendee(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      isOrganizer: isOrganizer ?? this.isOrganizer,
      isOptional: isOptional ?? this.isOptional,
      status: status ?? this.status,
    );
  }
}

enum AttendeeStatus { pending, accepted, declined, tentative }

class ActionItem {
  final String id;
  final String title;
  final String description;
  final String? assignedTo;
  final DateTime? dueDate;
  final ActionItemStatus status;
  final ActionItemPriority priority;
  final int progressPercentage;
  final DateTime createdAt;
  final String? parentId;
  final List<String> dependencies;
  final List<String> tags;
  final List<TimeEntry> timeEntries;
  final List<Comment> comments;
  final List<FileAttachment> attachments;
  final int estimatedHours;

  ActionItem({
    required this.id,
    required this.title,
    this.description = '',
    this.assignedTo,
    this.dueDate,
    this.status = ActionItemStatus.notStarted,
    this.priority = ActionItemPriority.medium,
    this.progressPercentage = 0,
    required this.createdAt,
    this.parentId,
    this.dependencies = const [],
    this.tags = const [],
    this.timeEntries = const [],
    this.comments = const [],
    this.attachments = const [],
    this.estimatedHours = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'assignedTo': assignedTo,
    'dueDate': dueDate?.toIso8601String(),
    'status': status.name,
    'priority': priority.name,
    'progressPercentage': progressPercentage,
    'createdAt': createdAt.toIso8601String(),
    'parentId': parentId,
    'dependencies': dependencies,
    'tags': tags,
    'timeEntries': timeEntries.map((t) => t.toJson()).toList(),
    'comments': comments.map((c) => c.toJson()).toList(),
    'attachments': attachments.map((a) => a.toJson()).toList(),
    'estimatedHours': estimatedHours,
  };

  factory ActionItem.fromJson(Map<String, dynamic> json) => ActionItem(
    id: json['id'],
    title: json['title'],
    description: json['description'] ?? '',
    assignedTo: json['assignedTo'],
    dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    status: ActionItemStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => ActionItemStatus.notStarted,
    ),
    priority: ActionItemPriority.values.firstWhere(
      (e) => e.name == json['priority'],
      orElse: () => ActionItemPriority.medium,
    ),
    progressPercentage: json['progressPercentage'] ?? 0,
    createdAt: DateTime.parse(json['createdAt']),
    parentId: json['parentId'],
    dependencies: List<String>.from(json['dependencies'] ?? []),
    tags: List<String>.from(json['tags'] ?? []),
    timeEntries: (json['timeEntries'] as List? ?? [])
        .map((t) => TimeEntry.fromJson(t))
        .toList(),
    comments: (json['comments'] as List? ?? [])
        .map((c) => Comment.fromJson(c))
        .toList(),
    attachments: (json['attachments'] as List? ?? [])
        .map((a) => FileAttachment.fromJson(a))
        .toList(),
    estimatedHours: json['estimatedHours'] ?? 0,
  );

  ActionItem copyWith({
    String? title,
    String? description,
    String? assignedTo,
    DateTime? dueDate,
    ActionItemStatus? status,
    ActionItemPriority? priority,
    int? progressPercentage,
    String? parentId,
    List<String>? dependencies,
    List<String>? tags,
    List<TimeEntry>? timeEntries,
    List<Comment>? comments,
    List<FileAttachment>? attachments,
    int? estimatedHours,
  }) {
    return ActionItem(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedTo: assignedTo ?? this.assignedTo,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      createdAt: createdAt,
      parentId: parentId ?? this.parentId,
      dependencies: dependencies ?? this.dependencies,
      tags: tags ?? this.tags,
      timeEntries: timeEntries ?? this.timeEntries,
      comments: comments ?? this.comments,
      attachments: attachments ?? this.attachments,
      estimatedHours: estimatedHours ?? this.estimatedHours,
    );
  }

  bool get isCompleted => status == ActionItemStatus.completed;
  bool get isOverdue =>
      dueDate != null && dueDate!.isBefore(DateTime.now()) && !isCompleted;

  int get totalTimeSpent =>
      timeEntries.fold(0, (sum, entry) => sum + entry.durationMinutes);

  String get formattedTimeSpent {
    final hours = totalTimeSpent ~/ 60;
    final minutes = totalTimeSpent % 60;
    return '${hours}h ${minutes}m';
  }
}

class MeetingNote {
  final String id;
  final String content;
  final DateTime timestamp;
  final String? author;

  MeetingNote({
    required this.id,
    required this.content,
    required this.timestamp,
    this.author,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
    'author': author,
  };

  factory MeetingNote.fromJson(Map<String, dynamic> json) => MeetingNote(
    id: json['id'],
    content: json['content'],
    timestamp: DateTime.parse(json['timestamp']),
    author: json['author'],
  );
}

class Meeting {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final int durationMinutes;
  final List<Attendee> attendees;
  final List<MeetingNote> notes;
  final List<ActionItem> actionItems;
  final MeetingPriority priority;
  final MeetingStatus status;
  final MeetingType type;
  final String? location;
  final String? meetingLink;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final RecurrenceRule? recurrenceRule;
  final String? programId;
  final String? actionPlanId;
  final List<FileAttachment> attachments;
  final List<Comment> comments;
  final String? parentRecurringId;

  Meeting({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    this.durationMinutes = 60,
    required this.attendees,
    required this.notes,
    required this.actionItems,
    required this.priority,
    required this.status,
    required this.type,
    this.location,
    this.meetingLink,
    required this.tags,
    required this.createdAt,
    this.updatedAt,
    this.recurrenceRule,
    this.programId,
    this.actionPlanId,
    this.attachments = const [],
    this.comments = const [],
    this.parentRecurringId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'dateTime': dateTime.toIso8601String(),
    'durationMinutes': durationMinutes,
    'attendees': attendees.map((a) => a.toJson()).toList(),
    'notes': notes.map((n) => n.toJson()).toList(),
    'actionItems': actionItems.map((a) => a.toJson()).toList(),
    'priority': priority.name,
    'status': status.name,
    'type': type.name,
    'location': location,
    'meetingLink': meetingLink,
    'tags': tags,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'recurrenceRule': recurrenceRule?.toJson(),
    'programId': programId,
    'actionPlanId': actionPlanId,
    'attachments': attachments.map((a) => a.toJson()).toList(),
    'comments': comments.map((c) => c.toJson()).toList(),
    'parentRecurringId': parentRecurringId,
  };

  factory Meeting.fromJson(Map<String, dynamic> json) => Meeting(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    dateTime: DateTime.parse(json['dateTime']),
    durationMinutes: json['durationMinutes'] ?? 60,
    attendees: (json['attendees'] as List)
        .map((a) => Attendee.fromJson(a))
        .toList(),
    notes: (json['notes'] as List).map((n) => MeetingNote.fromJson(n)).toList(),
    actionItems: (json['actionItems'] as List)
        .map((a) => ActionItem.fromJson(a))
        .toList(),
    priority: MeetingPriority.values.firstWhere(
      (e) => e.name == json['priority'],
    ),
    status: MeetingStatus.values.firstWhere((e) => e.name == json['status']),
    type: MeetingType.values.firstWhere((e) => e.name == json['type']),
    location: json['location'],
    meetingLink: json['meetingLink'],
    tags: List<String>.from(json['tags'] ?? []),
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'])
        : null,
    recurrenceRule: json['recurrenceRule'] != null
        ? RecurrenceRule.fromJson(json['recurrenceRule'])
        : null,
    programId: json['programId'],
    actionPlanId: json['actionPlanId'],
    attachments: (json['attachments'] as List? ?? [])
        .map((a) => FileAttachment.fromJson(a))
        .toList(),
    comments: (json['comments'] as List? ?? [])
        .map((c) => Comment.fromJson(c))
        .toList(),
    parentRecurringId: json['parentRecurringId'],
  );

  Meeting copyWith({
    String? title,
    String? description,
    DateTime? dateTime,
    int? durationMinutes,
    List<Attendee>? attendees,
    List<MeetingNote>? notes,
    List<ActionItem>? actionItems,
    MeetingPriority? priority,
    MeetingStatus? status,
    MeetingType? type,
    String? location,
    String? meetingLink,
    List<String>? tags,
    DateTime? updatedAt,
    RecurrenceRule? recurrenceRule,
    String? programId,
    String? actionPlanId,
    List<FileAttachment>? attachments,
    List<Comment>? comments,
  }) {
    return Meeting(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      attendees: attendees ?? this.attendees,
      notes: notes ?? this.notes,
      actionItems: actionItems ?? this.actionItems,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      type: type ?? this.type,
      location: location ?? this.location,
      meetingLink: meetingLink ?? this.meetingLink,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      programId: programId ?? this.programId,
      actionPlanId: actionPlanId ?? this.actionPlanId,
      attachments: attachments ?? this.attachments,
      comments: comments ?? this.comments,
      parentRecurringId: parentRecurringId,
    );
  }

  DateTime get endTime => dateTime.add(Duration(minutes: durationMinutes));

  bool get isRecurring =>
      recurrenceRule != null && recurrenceRule!.type != RecurrenceType.none;
}

class Program {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final ProgramStatus status;
  final List<String> objectives;
  final List<String> stakeholders;
  final String? budget;
  final int progressPercentage;
  final List<String> milestones;
  final List<String> risks;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<FileAttachment> attachments;
  final List<Comment> comments;

  Program({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.objectives,
    required this.stakeholders,
    this.budget,
    this.progressPercentage = 0,
    required this.milestones,
    required this.risks,
    required this.createdAt,
    this.updatedAt,
    this.attachments = const [],
    this.comments = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'status': status.name,
    'objectives': objectives,
    'stakeholders': stakeholders,
    'budget': budget,
    'progressPercentage': progressPercentage,
    'milestones': milestones,
    'risks': risks,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'attachments': attachments.map((a) => a.toJson()).toList(),
    'comments': comments.map((c) => c.toJson()).toList(),
  };

  factory Program.fromJson(Map<String, dynamic> json) => Program(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    startDate: DateTime.parse(json['startDate']),
    endDate: DateTime.parse(json['endDate']),
    status: ProgramStatus.values.firstWhere((e) => e.name == json['status']),
    objectives: List<String>.from(json['objectives'] ?? []),
    stakeholders: List<String>.from(json['stakeholders'] ?? []),
    budget: json['budget'],
    progressPercentage: json['progressPercentage'] ?? 0,
    milestones: List<String>.from(json['milestones'] ?? []),
    risks: List<String>.from(json['risks'] ?? []),
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'])
        : null,
    attachments: (json['attachments'] as List? ?? [])
        .map((a) => FileAttachment.fromJson(a))
        .toList(),
    comments: (json['comments'] as List? ?? [])
        .map((c) => Comment.fromJson(c))
        .toList(),
  );

  Program copyWith({
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    ProgramStatus? status,
    List<String>? objectives,
    List<String>? stakeholders,
    String? budget,
    int? progressPercentage,
    List<String>? milestones,
    List<String>? risks,
    List<FileAttachment>? attachments,
    List<Comment>? comments,
  }) {
    return Program(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      objectives: objectives ?? this.objectives,
      stakeholders: stakeholders ?? this.stakeholders,
      budget: budget ?? this.budget,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      milestones: milestones ?? this.milestones,
      risks: risks ?? this.risks,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      attachments: attachments ?? this.attachments,
      comments: comments ?? this.comments,
    );
  }
}

class ActionPlan {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime targetEndDate;
  final String? programId;
  final List<String> goals;
  final List<ActionItem> actions;
  final List<String> kpis;
  final int overallProgress;
  final String? owner;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<FileAttachment> attachments;
  final List<Comment> comments;

  ActionPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.targetEndDate,
    this.programId,
    required this.goals,
    required this.actions,
    required this.kpis,
    this.overallProgress = 0,
    this.owner,
    required this.createdAt,
    this.updatedAt,
    this.attachments = const [],
    this.comments = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'startDate': startDate.toIso8601String(),
    'targetEndDate': targetEndDate.toIso8601String(),
    'programId': programId,
    'goals': goals,
    'actions': actions.map((a) => a.toJson()).toList(),
    'kpis': kpis,
    'overallProgress': overallProgress,
    'owner': owner,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'attachments': attachments.map((a) => a.toJson()).toList(),
    'comments': comments.map((c) => c.toJson()).toList(),
  };

  factory ActionPlan.fromJson(Map<String, dynamic> json) => ActionPlan(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    startDate: DateTime.parse(json['startDate']),
    targetEndDate: DateTime.parse(json['targetEndDate']),
    programId: json['programId'],
    goals: List<String>.from(json['goals'] ?? []),
    actions: (json['actions'] as List)
        .map((a) => ActionItem.fromJson(a))
        .toList(),
    kpis: List<String>.from(json['kpis'] ?? []),
    overallProgress: json['overallProgress'] ?? 0,
    owner: json['owner'],
    createdAt: DateTime.parse(json['createdAt']),

    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'])
        : null,
    attachments: (json['attachments'] as List? ?? [])
        .map((a) => FileAttachment.fromJson(a))
        .toList(),
    comments: (json['comments'] as List? ?? [])
        .map((c) => Comment.fromJson(c))
        .toList(),
  );

  ActionPlan copyWith({
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? targetEndDate,
    String? programId,
    List<String>? goals,
    List<ActionItem>? actions,
    List<String>? kpis,
    int? overallProgress,
    String? owner,
    List<FileAttachment>? attachments,
    List<Comment>? comments,
  }) {
    return ActionPlan(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      targetEndDate: targetEndDate ?? this.targetEndDate,
      programId: programId ?? this.programId,
      goals: goals ?? this.goals,
      actions: actions ?? this.actions,
      kpis: kpis ?? this.kpis,
      overallProgress: overallProgress ?? this.overallProgress,
      owner: owner ?? this.owner,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      attachments: attachments ?? this.attachments,
      comments: comments ?? this.comments,
    );
  }
}

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetingsAsync = ref.watch(meetingsProvider);
    final actionPlansAsync = ref.watch(actionPlansProvider);
    final programsAsync = ref.watch(programsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Analytics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),

      body: actionPlansAsync.when(
        data: (plans) {
          final allTasks = plans.expand((p) => p.actions).toList();

          if (allTasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No tasks yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditActionPlanPage()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildListView(List<ActionItem> tasks, List<ActionPlan> plans) {
    final groupedTasks = <ActionItemStatus, List<ActionItem>>{};
    for (final task in tasks) {
      groupedTasks.putIfAbsent(task.status, () => []).add(task);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (groupedTasks[ActionItemStatus.notStarted]?.isNotEmpty ?? false) ...[
          _buildTaskSection(
            'Not Started',
            groupedTasks[ActionItemStatus.notStarted]!,
            Colors.grey,
          ),
          const SizedBox(height: 16),
        ],
        if (groupedTasks[ActionItemStatus.inProgress]?.isNotEmpty ?? false) ...[
          _buildTaskSection(
            'In Progress',
            groupedTasks[ActionItemStatus.inProgress]!,
            Colors.blue,
          ),
          const SizedBox(height: 16),
        ],
        if (groupedTasks[ActionItemStatus.completed]?.isNotEmpty ?? false) ...[
          _buildTaskSection(
            'Completed',
            groupedTasks[ActionItemStatus.completed]!,
            Colors.green,
          ),
          const SizedBox(height: 16),
        ],
        if (groupedTasks[ActionItemStatus.blocked]?.isNotEmpty ?? false) ...[
          _buildTaskSection(
            'Blocked',
            groupedTasks[ActionItemStatus.blocked]!,
            Colors.red,
          ),
        ],
      ],
    );
  }

  Widget _buildTaskSection(String title, List<ActionItem> tasks, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${tasks.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...tasks.map((task) => TaskCard(task: task)),
      ],
    );
  }

  Widget _buildKanbanView(List<ActionItem> tasks) {
    final columns = <ActionItemStatus, List<ActionItem>>{
      ActionItemStatus.notStarted: [],
      ActionItemStatus.inProgress: [],
      ActionItemStatus.completed: [],
      ActionItemStatus.blocked: [],
    };

    for (final task in tasks) {
      columns[task.status]?.add(task);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: columns.entries.map((entry) {
          return Container(
            width: 300,
            margin: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getStatusColor(entry.key).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _getStatusLabel(entry.key),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(entry.key).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${entry.value.length}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(entry.key),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: entry.value.length,
                    itemBuilder: (context, index) =>
                        TaskCard(task: entry.value[index]),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGanttView(List<ActionItem> tasks) {
    final tasksWithDates = tasks.where((t) => t.dueDate != null).toList()
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

    if (tasksWithDates.isEmpty) {
      return Center(
        child: Text(
          'No tasks with due dates',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasksWithDates.length,
      itemBuilder: (context, index) {
        final task = tasksWithDates[index];
        final daysUntilDue = task.dueDate!.difference(DateTime.now()).inDays;
        final progress = task.progressPercentage / 100;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    _buildPriorityBadge(task.priority),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM dd').format(task.dueDate!),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      daysUntilDue > 0 ? '$daysUntilDue days left' : 'Overdue',
                      style: TextStyle(
                        fontSize: 12,
                        color: daysUntilDue > 0
                            ? Colors.grey.shade600
                            : Colors.red,
                        fontWeight: daysUntilDue > 0 ? null : FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${task.progressPercentage}% complete',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalendarView(List<ActionItem> tasks) {
    return Center(
      child: Text(
        'Calendar view for tasks',
        style: TextStyle(color: Colors.grey.shade600),
      ),
    );
  }

  Color _getStatusColor(ActionItemStatus status) {
    switch (status) {
      case ActionItemStatus.notStarted:
        return Colors.grey;
      case ActionItemStatus.inProgress:
        return Colors.blue;
      case ActionItemStatus.completed:
        return Colors.green;
      case ActionItemStatus.blocked:
        return Colors.red;
      case ActionItemStatus.cancelled:
        return Colors.orange;
    }
  }

  String _getStatusLabel(ActionItemStatus status) {
    switch (status) {
      case ActionItemStatus.notStarted:
        return 'Not Started';
      case ActionItemStatus.inProgress:
        return 'In Progress';
      case ActionItemStatus.completed:
        return 'Completed';
      case ActionItemStatus.blocked:
        return 'Blocked';
      case ActionItemStatus.cancelled:
        return 'Cancelled';
    }
  }

  Widget _buildPriorityBadge(ActionItemPriority priority) {
    Color color;
    String label;

    switch (priority) {
      case ActionItemPriority.critical:
        color = Colors.red.shade700;
        label = 'Critical';
        break;
      case ActionItemPriority.high:
        color = Colors.red;
        label = 'High';
        break;
      case ActionItemPriority.medium:
        color = Colors.orange;
        label = 'Medium';
        break;
      case ActionItemPriority.low:
        color = Colors.green;
        label = 'Low';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
