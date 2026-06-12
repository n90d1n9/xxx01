import 'package:flutter/material.dart';

class ChartCatalogCountBadge extends StatelessWidget {
  const ChartCatalogCountBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(
          count.toString(),
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class ChartCatalogChipLabel extends StatelessWidget {
  const ChartCatalogChipLabel({
    super.key,
    required this.label,
    required this.count,
    required this.enabled,
  });

  final String label;
  final int count;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final contentOpacity = enabled ? 1.0 : 0.48;

    return Opacity(
      opacity: contentOpacity,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(label, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 6),
          ChartCatalogCountBadge(count: count),
        ],
      ),
    );
  }
}

class ChartCatalogFilterInputChip extends StatelessWidget {
  const ChartCatalogFilterInputChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onDeleted,
    this.tooltip,
  });

  final IconData icon;
  final String label;
  final VoidCallback onDeleted;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final chip = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: InputChip(
        avatar: Icon(icon, size: 18),
        label: Text(label, overflow: TextOverflow.ellipsis),
        onDeleted: onDeleted,
      ),
    );

    if (tooltip == null || tooltip!.isEmpty) {
      return chip;
    }

    return Tooltip(message: tooltip!, child: chip);
  }
}

class ChartCatalogFacetChip extends StatelessWidget {
  const ChartCatalogFacetChip({
    super.key,
    required this.value,
    required this.label,
    required this.count,
    required this.selected,
    required this.onSelected,
    this.avatarIcon,
    this.tooltip,
  });

  final String value;
  final String label;
  final int count;
  final bool selected;
  final ValueChanged<String> onSelected;
  final IconData? avatarIcon;
  final String? tooltip;

  bool get _isEnabled => selected || count > 0;

  @override
  Widget build(BuildContext context) {
    final chip = FilterChip(
      avatar: avatarIcon == null ? null : Icon(avatarIcon),
      label: ChartCatalogChipLabel(
        label: label,
        count: count,
        enabled: _isEnabled,
      ),
      selected: selected,
      onSelected: _isEnabled ? (_) => onSelected(value) : null,
    );

    if (tooltip == null || tooltip!.isEmpty) {
      return chip;
    }

    return Tooltip(message: tooltip!, child: chip);
  }
}
