import '../models/timeline_view.dart';
import '../states/timeline_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ViewModeSelector extends ConsumerWidget {
  const ViewModeSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(timelineProvider);

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _ViewModeChip(
            icon: Icons.view_list,
            label: 'LIST',
            mode: ViewMode.list,
            isSelected: state.viewMode == ViewMode.list,
            onTap:
                () => ref
                    .read(timelineProvider.notifier)
                    .setViewMode(ViewMode.list),
          ),
          _ViewModeChip(
            icon: Icons.grid_view,
            label: 'GRID',
            mode: ViewMode.grid,
            isSelected: state.viewMode == ViewMode.grid,
            onTap:
                () => ref
                    .read(timelineProvider.notifier)
                    .setViewMode(ViewMode.grid),
          ),
          _ViewModeChip(
            icon: Icons.timeline,
            label: 'TIMELINE',
            mode: ViewMode.timeline,
            isSelected: state.viewMode == ViewMode.timeline,
            onTap:
                () => ref
                    .read(timelineProvider.notifier)
                    .setViewMode(ViewMode.timeline),
          ),
          _ViewModeChip(
            icon: Icons.map,
            label: 'MAP',
            mode: ViewMode.map,
            isSelected: state.viewMode == ViewMode.map,
            onTap:
                () => ref
                    .read(timelineProvider.notifier)
                    .setViewMode(ViewMode.map),
          ),
          _ViewModeChip(
            icon: Icons.device_hub,
            label: 'GRAPH',
            mode: ViewMode.graph,
            isSelected: state.viewMode == ViewMode.graph,
            onTap:
                () => ref
                    .read(timelineProvider.notifier)
                    .setViewMode(ViewMode.graph),
          ),
        ],
      ),
    );
  }
}

class _ViewModeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final ViewMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  const _ViewModeChip({
    required this.icon,
    required this.label,
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: FilterChip(
        selected: isSelected,
        avatar: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.white70,
          size: 18,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        selectedColor: const Color(0xFF6C63FF),
        onSelected: (_) => onTap(),
      ),
    );
  }
}
