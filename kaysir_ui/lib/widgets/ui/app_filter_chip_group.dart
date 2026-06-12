import 'package:flutter/material.dart';

class AppFilterChipOption<T> {
  const AppFilterChipOption({
    required this.value,
    required this.label,
    this.chipKey,
    this.icon,
    this.count,
    this.tooltip,
  });

  final T value;
  final String label;
  final Key? chipKey;
  final IconData? icon;
  final int? count;
  final String? tooltip;
}

class AppFilterChipGroup<T> extends StatelessWidget {
  const AppFilterChipGroup({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.spacing = 8,
    this.runSpacing = 8,
    this.borderRadius = 8,
    this.enabled = true,
  });

  final T value;
  final List<AppFilterChipOption<T>> options;
  final ValueChanged<T> onChanged;
  final double spacing;
  final double runSpacing;
  final double borderRadius;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: [
        for (final option in options)
          _FilterChipTooltip(
            tooltip: option.tooltip,
            child: ChoiceChip(
              key: option.chipKey,
              label: _FilterChipLabel(option: option),
              avatar:
                  option.icon == null
                      ? null
                      : Icon(
                        option.icon,
                        size: 18,
                        color:
                            option.value == value
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurfaceVariant,
                      ),
              selected: option.value == value,
              showCheckmark: false,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              side: BorderSide(
                color:
                    option.value == value
                        ? colorScheme.primary.withValues(alpha: 0.42)
                        : colorScheme.outlineVariant,
              ),
              selectedColor: colorScheme.primaryContainer,
              backgroundColor: colorScheme.surface,
              labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                color:
                    option.value == value
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
              onSelected:
                  enabled
                      ? (selected) {
                        if (selected) {
                          onChanged(option.value);
                        }
                      }
                      : null,
            ),
          ),
      ],
    );
  }
}

class _FilterChipTooltip extends StatelessWidget {
  const _FilterChipTooltip({required this.tooltip, required this.child});

  final String? tooltip;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final message = tooltip;
    if (message == null || message.isEmpty) return child;

    return Tooltip(message: message, child: child);
  }
}

class _FilterChipLabel<T> extends StatelessWidget {
  const _FilterChipLabel({required this.option});

  final AppFilterChipOption<T> option;

  @override
  Widget build(BuildContext context) {
    if (option.count == null) {
      return Text(option.label, overflow: TextOverflow.ellipsis);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: Text(option.label, overflow: TextOverflow.ellipsis)),
        const SizedBox(width: 6),
        _FilterChipCount(count: option.count!),
      ],
    );
  }
}

class _FilterChipCount extends StatelessWidget {
  const _FilterChipCount({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        child: Text(
          count.toString(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
