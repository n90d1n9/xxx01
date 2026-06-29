import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'meeting_status.dart';
import 'meeting.dart';
import 'filter_bottom_sheet.dart';
import 'meeting_card.dart';
import 'add_edit_meeting_page.dart';

class MeetingsHomePage extends ConsumerWidget {
  const MeetingsHomePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetingsAsync = ref.watch(meetingsProvider);
    final meetings = ref.watch(filteredMeetingsProvider);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Meeting Notes Pro',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context, ref),
          ),
        ],
      ),
      body: meetingsAsync.when(
        data: (allMeetings) {
          if (allMeetings.isEmpty) {
            return _buildEmptyState(context);
          }
          final now = DateTime.now();
          final upcoming =
              meetings
                  .where(
                    (m) =>
                        m.dateTime.isAfter(now) &&
                        m.status == MeetingStatus.scheduled,
                  )
                  .toList()
                ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
          final today =
              meetings.where((m) {
                final isToday =
                    m.dateTime.year == now.year &&
                    m.dateTime.month == now.month &&
                    m.dateTime.day == now.day;
                return isToday && m.status != MeetingStatus.completed;
              }).toList();
          final past =
              meetings
                  .where(
                    (m) =>
                        m.dateTime.isBefore(now) ||
                        m.status == MeetingStatus.completed ||
                        m.status == MeetingStatus.cancelled,
                  )
                  .toList()
                ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(meetingsProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (today.isNotEmpty) ...[
                  _buildSectionHeader('Today', today.length, Icons.today),
                  const SizedBox(height: 12),
                  ...today.map((m) => MeetingCard(meeting: m)),
                  const SizedBox(height: 24),
                ],
                if (upcoming.isNotEmpty) ...[
                  _buildSectionHeader(
                    'Upcoming',
                    upcoming.length,
                    Icons.upcoming,
                  ),
                  const SizedBox(height: 12),
                  ...upcoming.take(5).map((m) => MeetingCard(meeting: m)),
                  const SizedBox(height: 24),
                ],
                if (past.isNotEmpty) ...[
                  _buildSectionHeader('Past', past.length, Icons.history),
                  const SizedBox(height: 12),
                  ...past.take(10).map((m) => MeetingCard(meeting: m)),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(meetingsProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddMeeting(context),
        icon: const Icon(Icons.add),
        label: const Text('New Meeting'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No meetings yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first meeting to get started',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Search Meetings'),
            content: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search by title, description, or attendee',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  ref.read(searchQueryProvider.notifier).state = '';
                  Navigator.pop(context);
                },
                child: const Text('Clear'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => FilterBottomSheet(),
    );
  }

  void _navigateToAddMeeting(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditMeetingPage()),
    );
  }
}
