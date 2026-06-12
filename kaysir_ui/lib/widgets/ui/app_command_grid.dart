import 'package:flutter/material.dart';

enum AppCommandGridItemVariant { primary, secondary, subtle }

@immutable
class AppCommandGridItem {
  const AppCommandGridItem({
    required this.title,
    required this.helper,
    required this.icon,
    required this.onPressed,
    this.variant = AppCommandGridItemVariant.secondary,
    this.accentColor,
  });

  final String title;
  final String helper;
  final IconData icon;
  final VoidCallback? onPressed;
  final AppCommandGridItemVariant variant;
  final Color? accentColor;
}

class AppCommandGrid extends StatelessWidget {
  const AppCommandGrid({
    super.key,
    required this.items,
    this.spacing = 12,
    this.minTileWidth = 220,
    this.maxColumns = 3,
  });

  final List<AppCommandGridItem> items;
  final double spacing;
  final double minTileWidth;
  final int maxColumns;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final widthBasedColumns =
            ((constraints.maxWidth + spacing) / (minTileWidth + spacing))
                .floor();
        final columnLimit = maxColumns.clamp(1, items.length);
        final columns = widthBasedColumns.clamp(1, columnLimit);
        final tileWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final item in items)
              SizedBox(width: tileWidth, child: _AppCommandButton(item: item)),
          ],
        );
      },
    );
  }
}

class _AppCommandButton extends StatelessWidget {
  const _AppCommandButton({required this.item});

  final AppCommandGridItem item;

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(context);
    final child = _AppCommandButtonContent(item: item);

    switch (item.variant) {
      case AppCommandGridItemVariant.primary:
        return FilledButton(
          style: style,
          onPressed: item.onPressed,
          child: child,
        );
      case AppCommandGridItemVariant.secondary:
        return OutlinedButton(
          style: style,
          onPressed: item.onPressed,
          child: child,
        );
      case AppCommandGridItemVariant.subtle:
        return TextButton(
          style: style,
          onPressed: item.onPressed,
          child: child,
        );
    }
  }

  ButtonStyle _styleFor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = item.accentColor ?? colorScheme.primary;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    );
    final padding = const EdgeInsets.all(12);
    final minimumSize = const Size.fromHeight(78);
    final textStyle = Theme.of(
      context,
    ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800);

    switch (item.variant) {
      case AppCommandGridItemVariant.primary:
        return FilledButton.styleFrom(
          alignment: Alignment.centerLeft,
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          disabledBackgroundColor: colorScheme.onSurface.withValues(
            alpha: 0.08,
          ),
          disabledForegroundColor: colorScheme.onSurface.withValues(
            alpha: 0.38,
          ),
          minimumSize: minimumSize,
          padding: padding,
          shape: shape,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: textStyle,
        );
      case AppCommandGridItemVariant.secondary:
        return OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          backgroundColor: accent.withValues(alpha: 0.05),
          foregroundColor: colorScheme.onSurface,
          disabledForegroundColor: colorScheme.onSurface.withValues(
            alpha: 0.38,
          ),
          minimumSize: minimumSize,
          padding: padding,
          shape: shape,
          side: BorderSide(color: accent.withValues(alpha: 0.26)),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: textStyle,
        );
      case AppCommandGridItemVariant.subtle:
        return TextButton.styleFrom(
          alignment: Alignment.centerLeft,
          backgroundColor: colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.28,
          ),
          foregroundColor: colorScheme.onSurfaceVariant,
          disabledForegroundColor: colorScheme.onSurface.withValues(
            alpha: 0.38,
          ),
          minimumSize: minimumSize,
          padding: padding,
          shape: shape,
          side: BorderSide(color: colorScheme.outlineVariant),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: textStyle,
        );
    }
  }
}

class _AppCommandButtonContent extends StatelessWidget {
  const _AppCommandButtonContent({required this.item});

  final AppCommandGridItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final enabled = item.onPressed != null;
    final accent = item.accentColor ?? colorScheme.primary;
    final iconColor =
        enabled ? accent : colorScheme.onSurface.withValues(alpha: 0.38);
    final labelColor =
        enabled
            ? colorScheme.onSurface
            : colorScheme.onSurface.withValues(alpha: 0.38);
    final helperColor =
        enabled
            ? colorScheme.onSurfaceVariant
            : colorScheme.onSurface.withValues(alpha: 0.38);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: enabled ? 0.12 : 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(item.icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: labelColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                item.helper,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: helperColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.arrow_forward_rounded, color: helperColor, size: 18),
      ],
    );
  }
}
