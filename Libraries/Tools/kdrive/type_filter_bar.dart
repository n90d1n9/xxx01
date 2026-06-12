// lib/widgets/type_filter_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/file_item.dart';
import '../providers/file_provider.dart';
import '../utils/file_utils.dart';

class TypeFilterBar extends ConsumerWidget {
  const TypeFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(typeFilterProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final types = FileUtils.filterableTypes;

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // "All" chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _FilterChip(
              label: 'All',
              icon: Icons.apps_rounded,
              color: colorScheme.primary,
              isActive: activeFilter == null,
              onTap: () => ref.read(typeFilterProvider.notifier).state = null,
            ),
          ),
          ...types.map((type) {
            final color = FileUtils.getFileColor(type);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: FileUtils.getFileTypeName(type),
                icon: FileUtils.getFileIcon(type),
                color: color,
                isActive: activeFilter == type,
                onTap: () => ref.read(typeFilterProvider.notifier).state =
                    activeFilter == type ? null : type,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label, required this.icon, required this.color,
    required this.isActive, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.15) : colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? color : colorScheme.outlineVariant.withOpacity(0.4),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14,
              color: isActive ? color : colorScheme.onSurfaceVariant),
            const SizedBox(width: 5),
            Text(label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? color : colorScheme.onSurfaceVariant,
              )),
          ],
        ),
      ),
    );
  }
}
