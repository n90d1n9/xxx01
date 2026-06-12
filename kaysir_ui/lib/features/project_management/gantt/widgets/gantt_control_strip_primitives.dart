import 'package:flutter/material.dart';

enum GanttControlAccent { primary, secondary, tertiary }

class GanttControlStripShell extends StatelessWidget {
  const GanttControlStripShell({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.children,
    this.spacing = 12,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final GanttControlAccent accent;
  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: spacing,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 168, maxWidth: 220),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: accent.containerColor(colorScheme),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        icon,
                        size: 18,
                        color: accent.onContainerColor(colorScheme),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

class GanttControlToggleChip extends StatelessWidget {
  const GanttControlToggleChip({
    required this.label,
    required this.tooltip,
    required this.icon,
    required this.selected,
    required this.accent,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final String label;
  final String tooltip;
  final IconData icon;
  final bool selected;
  final GanttControlAccent accent;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.56,
      child: Tooltip(
        message: tooltip,
        child: FilterChip(
          selected: selected,
          showCheckmark: false,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          avatar: _GanttControlChipIcon(
            icon: icon,
            selected: selected,
            accent: accent,
          ),
          label: Text(label, overflow: TextOverflow.ellipsis),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide(color: _borderColor(context, selected, accent)),
          selectedColor: accent.containerColor(Theme.of(context).colorScheme),
          backgroundColor: Theme.of(context).colorScheme.surface,
          labelStyle: _labelStyle(context, selected, accent),
          onSelected: enabled ? (_) => onChanged(!selected) : null,
        ),
      ),
    );
  }
}

class GanttControlChipGroup<T extends Object> extends StatelessWidget {
  const GanttControlChipGroup({
    required this.label,
    required this.value,
    required this.options,
    required this.accent,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final String label;
  final T value;
  final List<GanttControlChipOption<T>> options;
  final GanttControlAccent accent;
  final ValueChanged<T> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Opacity(
      opacity: enabled ? 1 : 0.56,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w900,
            ),
          ),
          for (final option in options)
            GanttControlChoiceChip(
              key: option.key,
              label: option.label,
              icon: option.icon,
              tooltip: option.tooltip,
              selected: option.value == value,
              enabled: enabled && option.enabled,
              accent: accent,
              onSelected: () => onChanged(option.value),
            ),
        ],
      ),
    );
  }
}

class GanttControlChipOption<T extends Object> {
  const GanttControlChipOption({
    required this.value,
    required this.label,
    required this.icon,
    this.key,
    this.tooltip,
    this.enabled = true,
  });

  final T value;
  final String label;
  final IconData icon;
  final Key? key;
  final String? tooltip;
  final bool enabled;
}

class GanttControlChoiceChip extends StatelessWidget {
  const GanttControlChoiceChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.accent,
    required this.onSelected,
    this.enabled = true,
    this.tooltip,
    super.key,
  });

  final String label;
  final IconData icon;
  final String? tooltip;
  final bool selected;
  final GanttControlAccent accent;
  final VoidCallback onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final chip = ChoiceChip(
      selected: selected,
      showCheckmark: false,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      avatar: _GanttControlChipIcon(
        icon: icon,
        selected: selected,
        accent: accent,
      ),
      label: Text(label, overflow: TextOverflow.ellipsis),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide(color: _borderColor(context, selected, accent)),
      selectedColor: accent.containerColor(Theme.of(context).colorScheme),
      backgroundColor: Theme.of(context).colorScheme.surface,
      labelStyle: _labelStyle(context, selected, accent),
      onSelected: enabled ? (_) => onSelected() : null,
    );

    final message = tooltip;
    if (message == null || message.isEmpty) return chip;

    return Tooltip(message: message, child: chip);
  }
}

class _GanttControlChipIcon extends StatelessWidget {
  const _GanttControlChipIcon({
    required this.icon,
    required this.selected,
    required this.accent,
  });

  final IconData icon;
  final bool selected;
  final GanttControlAccent accent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Icon(
      icon,
      size: 17,
      color:
          selected
              ? accent.onContainerColor(colorScheme)
              : colorScheme.onSurfaceVariant,
    );
  }
}

TextStyle? _labelStyle(
  BuildContext context,
  bool selected,
  GanttControlAccent accent,
) {
  final colorScheme = Theme.of(context).colorScheme;

  return Theme.of(context).textTheme.labelLarge?.copyWith(
    color:
        selected
            ? accent.onContainerColor(colorScheme)
            : colorScheme.onSurfaceVariant,
    fontWeight: FontWeight.w800,
  );
}

Color _borderColor(
  BuildContext context,
  bool selected,
  GanttControlAccent accent,
) {
  final colorScheme = Theme.of(context).colorScheme;

  return selected
      ? accent.accentColor(colorScheme).withValues(alpha: 0.42)
      : colorScheme.outlineVariant;
}

extension _GanttControlAccentColors on GanttControlAccent {
  Color containerColor(ColorScheme colorScheme) {
    switch (this) {
      case GanttControlAccent.primary:
        return colorScheme.primaryContainer;
      case GanttControlAccent.secondary:
        return colorScheme.secondaryContainer;
      case GanttControlAccent.tertiary:
        return colorScheme.tertiaryContainer;
    }
  }

  Color onContainerColor(ColorScheme colorScheme) {
    switch (this) {
      case GanttControlAccent.primary:
        return colorScheme.onPrimaryContainer;
      case GanttControlAccent.secondary:
        return colorScheme.onSecondaryContainer;
      case GanttControlAccent.tertiary:
        return colorScheme.onTertiaryContainer;
    }
  }

  Color accentColor(ColorScheme colorScheme) {
    switch (this) {
      case GanttControlAccent.primary:
        return colorScheme.primary;
      case GanttControlAccent.secondary:
        return colorScheme.secondary;
      case GanttControlAccent.tertiary:
        return colorScheme.tertiary;
    }
  }
}
