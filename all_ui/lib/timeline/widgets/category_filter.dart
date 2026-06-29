import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/timeline_view.dart';
import '../states/timeline_provider.dart';

class CategoryFilter extends ConsumerWidget {
  const CategoryFilter({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(timelineProvider);
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children:
            EventCategory.values.map((category) {
              final isSelected = state.selectedCategories.contains(category);
              return Container(
                margin: const EdgeInsets.only(right: 12),
                child: FilterChip(
                  selected: isSelected,
                  label: Text(
                    category.name.toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: const Color(0xFF1A1A2E),
                  selectedColor: const Color(0xFF6C63FF),
                  onSelected:
                      (_) => ref
                          .read(timelineProvider.notifier)
                          .toggleCategory(category),
                ),
              );
            }).toList(),
      ),
    );
  }
}
