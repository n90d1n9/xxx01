import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/timeline_view.dart';
import '../states/timeline_provider.dart';

class ViewSelector extends ConsumerWidget {
  const ViewSelector({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(timelineProvider);
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children:
            TimelineView.values.map((view) {
              final isSelected = state.view == view;
              return Container(
                margin: const EdgeInsets.only(right: 12),
                child: FilterChip(
                  selected: isSelected,
                  label: Text(
                    view.name.toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: const Color(0xFF1A1A2E),
                  selectedColor: const Color(0xFF6C63FF),
                  onSelected:
                      (_) => ref.read(timelineProvider.notifier).setView(view),
                ),
              );
            }).toList(),
      ),
    );
  }
}
