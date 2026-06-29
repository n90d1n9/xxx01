import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/statistics_provider.dart';
import '../states/timeline_provider.dart';

class TagFilter extends ConsumerWidget {
  const TagFilter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTags = ref.watch(allTagsProvider);
    final selectedTags = ref.watch(timelineProvider).selectedTags;

    if (allTags.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.label, size: 16, color: Colors.white.withOpacity(0.7)),
              const SizedBox(width: 8),
              Text(
                'Tags',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: allTags.length,
              itemBuilder: (context, index) {
                final tag = allTags[index];
                final isSelected = selectedTags.contains(tag);

                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(
                      '#$tag',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: Colors.white.withOpacity(0.05),
                    selectedColor: const Color(0xFF6C63FF).withOpacity(0.5),
                    onSelected: (_) {
                      ref.read(timelineProvider.notifier).toggleTag(tag);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
