import 'package:flutter/material.dart';

@immutable
class AdminLegendEntry {
  const AdminLegendEntry({required this.color, required this.label});

  final Color color;
  final String label;
}

class AdminLegend extends StatelessWidget {
  const AdminLegend({
    super.key,
    required this.entries,
    this.spacing = 12,
    this.runSpacing = 8,
  });

  final List<AdminLegendEntry> entries;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final entry in entries)
          _AdminLegendItem(color: entry.color, label: entry.label),
      ],
    );
  }
}

class _AdminLegendItem extends StatelessWidget {
  const _AdminLegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
