import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'action_item.dart';
import 'action_item_card.dart';

class ActionItemsPage extends ConsumerWidget {
  const ActionItemsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetingsAsync = ref.watch(meetingsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Action Items',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: meetingsAsync.when(
        data: (meetings) {
          final allActionItems = <String, List<ActionItem>>{};
          for (final meeting in meetings) {
            for (final action in meeting.actionItems) {
              final key = meeting.id;
              if (!allActionItems.containsKey(key)) {
                allActionItems[key] = [];
              }
              allActionItems[key]!.add(action);
            }
          }
          if (allActionItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_box_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No action items yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }
          final pendingActions = <MapEntry<String, ActionItem>>[];
          final completedActions = <MapEntry<String, ActionItem>>[];
          allActionItems.forEach((meetingId, actions) {
            for (final action in actions) {
              final entry = MapEntry(meetingId, action);
              if (action.isCompleted) {
                completedActions.add(entry);
              } else {
                pendingActions.add(entry);
              }
            }
          });
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (pendingActions.isNotEmpty) ...[
                _buildSectionHeader('Pending', pendingActions.length),
                const SizedBox(height: 12),
                ...pendingActions.map((entry) {
                  final meeting = meetings.firstWhere((m) => m.id == entry.key);
                  return ActionItemCard(
                    actionItem: entry.value,
                    meeting: meeting,
                  );
                }),
                const SizedBox(height: 24),
              ],
              if (completedActions.isNotEmpty) ...[
                _buildSectionHeader('Completed', completedActions.length),
                const SizedBox(height: 12),
                ...completedActions.map((entry) {
                  final meeting = meetings.firstWhere((m) => m.id == entry.key);
                  return ActionItemCard(
                    actionItem: entry.value,
                    meeting: meeting,
                  );
                }),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
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
}
