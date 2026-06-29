import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'meeting_priority.dart';
import 'meeting_type.dart';

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statisticsProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Statistics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatCard(
            'Total Meetings',
            stats.totalMeetings.toString(),
            Icons.event,
            theme.colorScheme.primary,
          ),
          _buildStatCard(
            'Upcoming',
            stats.upcomingMeetings.toString(),
            Icons.upcoming,
            Colors.blue,
          ),
          _buildStatCard(
            'Completed',
            stats.completedMeetings.toString(),
            Icons.check_circle,
            Colors.green,
          ),
          _buildStatCard(
            'Action Items',
            '${stats.completedActionItems}/${stats.totalActionItems}',
            Icons.check_box,
            Colors.orange,
          ),
          const SizedBox(height: 24),
          const Text(
            'Meetings by Type',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...stats.meetingsByType.entries.map((entry) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(_getTypeIcon(entry.key)),
                title: Text(entry.key.name),
                trailing: Text(
                  '${entry.value}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          const Text(
            'Meetings by Priority',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...stats.meetingsByPriority.entries.map((entry) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(Icons.flag, color: _getPriorityColor(entry.key)),
                title: Text(entry.key.name),
                trailing: Text(
                  '${entry.value}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
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

  IconData _getTypeIcon(MeetingType type) {
    switch (type) {
      case MeetingType.standup:
        return Icons.groups;
      case MeetingType.planning:
        return Icons.calendar_view_week;
      case MeetingType.review:
        return Icons.rate_review;
      case MeetingType.retrospective:
        return Icons.replay;
      case MeetingType.oneOnOne:
        return Icons.person;
      case MeetingType.other:
        return Icons.event;
    }
  }

  Color _getPriorityColor(MeetingPriority priority) {
    switch (priority) {
      case MeetingPriority.urgent:
        return Colors.red.shade700;
      case MeetingPriority.high:
        return Colors.red;
      case MeetingPriority.medium:
        return Colors.orange;
      case MeetingPriority.low:
        return Colors.green;
    }
  }
}
