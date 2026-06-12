import 'package:flutter/material.dart';

class ActiveFilterToken {
  const ActiveFilterToken({
    required this.icon,
    required this.label,
    required this.clearTooltip,
    required this.onClear,
  });

  final IconData icon;
  final String label;
  final String clearTooltip;
  final VoidCallback onClear;
}

class ActiveFilterBar extends StatelessWidget {
  const ActiveFilterBar({
    super.key,
    required this.tokens,
    required this.onClearAll,
    this.title = 'Active filters',
    this.clearAllLabel = 'Clear all',
  });

  final String title;
  final List<ActiveFilterToken> tokens;
  final VoidCallback onClearAll;
  final String clearAllLabel;

  @override
  Widget build(BuildContext context) {
    if (tokens.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final token in tokens) _ActiveFilterChip(token: token),
            TextButton.icon(
              onPressed: onClearAll,
              icon: const Icon(Icons.filter_alt_off_outlined, size: 16),
              label: Text(clearAllLabel),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({required this.token});

  final ActiveFilterToken token;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 260),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 8),
            Icon(token.icon, size: 15, color: colorScheme.onSecondaryContainer),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                token.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              tooltip: token.clearTooltip,
              icon: const Icon(Icons.close, size: 14),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              onPressed: token.onClear,
            ),
          ],
        ),
      ),
    );
  }
}
