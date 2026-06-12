import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'meeting_status.dart';
import 'meeting_type.dart';

class FilterBottomSheet extends ConsumerWidget {
  const FilterBottomSheet({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedStatus = ref.watch(selectedStatusProvider);
    final selectedType = ref.watch(selectedTypeProvider);
    final selectedTags = ref.watch(selectedTagsProvider);
    final allTags = ref.watch(allTagsProvider);
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  ref.read(selectedStatusProvider.notifier).state = null;
                  ref.read(selectedTypeProvider.notifier).state = null;
                  ref.read(selectedTagsProvider.notifier).state = {};
                  ref.read(dateRangeProvider.notifier).state = null;
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: MeetingStatus.values.map((status) {
              final isSelected = selectedStatus == status;
              return FilterChip(
                label: Text(status.name),
                selected: isSelected,
                onSelected: (selected) {
                  ref.read(selectedStatusProvider.notifier).state = selected
                      ? status
                      : null;
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text('Type', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: MeetingType.values.map((type) {
              final isSelected = selectedType == type;
              return FilterChip(
                label: Text(type.name),
                selected: isSelected,
                onSelected: (selected) {
                  ref.read(selectedTypeProvider.notifier).state = selected
                      ? type
                      : null;
                },
              );
            }).toList(),
          ),
          if (allTags.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Tags', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: allTags.map((tag) {
                final isSelected = selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) {
                    final newTags = {...selectedTags};
                    if (selected) {
                      newTags.add(tag);
                    } else {
                      newTags.remove(tag);
                    }
                    ref.read(selectedTagsProvider.notifier).state = newTags;
                  },
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
