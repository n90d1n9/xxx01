import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/form_theme.dart';
import '../states/filtered_provider.dart';
import '../states/form_field_provider.dart';

class StatsBar extends ConsumerWidget {
  final FormTheme? theme;
  const StatsBar({super.key, this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allFields = ref.watch(formFieldsProvider);
    final filteredFields = ref.watch(filteredFieldsProvider);
    final filterState = ref.watch(filterManagerProvider);

    final requiredCount = allFields.where((f) => f.required).length;
    final containerCount = allFields.where((f) => f.isContainer).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF252526),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          _StatItem(
            icon: Icons.layers,
            label: 'Total',
            value: allFields.length.toString(),
          ),
          if (filterState.searchQuery.isNotEmpty ||
              filterState.fieldTypes.isNotEmpty) ...[
            const SizedBox(width: 16),
            _StatItem(
              icon: Icons.filter_list,
              label: 'Filtered',
              value: filteredFields.length.toString(),
              color: Colors.blue,
            ),
          ],
          const SizedBox(width: 16),
          _StatItem(
            icon: Icons.star,
            label: 'Required',
            value: requiredCount.toString(),
            color: Colors.red,
          ),
          const SizedBox(width: 16),
          _StatItem(
            icon: Icons.view_module,
            label: 'Containers',
            value: containerCount.toString(),
            color: Colors.purple,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color ?? Colors.white54),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: color ?? Colors.white54, fontSize: 11),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
