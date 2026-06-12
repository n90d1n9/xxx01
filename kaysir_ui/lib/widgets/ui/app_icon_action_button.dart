import 'package:flutter/material.dart';

enum AppIconActionButtonVariant { ghost, tonal, outlined }

class AppIconActionButton extends StatelessWidget {
  const AppIconActionButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.variant = AppIconActionButtonVariant.ghost,
    this.selectedIcon,
    this.isSelected,
    this.badgeCount,
    this.maxBadgeCount = 9,
    this.size = 40,
    this.iconSize = 20,
    this.borderRadius = 8,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String tooltip;
  final VoidCallback? onPressed;
  final AppIconActionButtonVariant variant;
  final bool? isSelected;
  final int? badgeCount;
  final int maxBadgeCount;
  final double size;
  final double iconSize;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final style = _styleFor(colorScheme);

    final button = IconButton(
      icon: Icon(icon),
      selectedIcon: selectedIcon == null ? null : Icon(selectedIcon),
      isSelected: isSelected,
      iconSize: iconSize,
      tooltip: tooltip,
      style: style,
      onPressed: onPressed,
    );

    if (badgeCount == null || badgeCount! <= 0) return button;

    return Badge(label: Text(_badgeLabel), child: button);
  }

  String get _badgeLabel {
    final count = badgeCount ?? 0;
    return count > maxBadgeCount ? '$maxBadgeCount+' : count.toString();
  }

  ButtonStyle _styleFor(ColorScheme colorScheme) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    );
    final fixedSize = Size.square(size);

    switch (variant) {
      case AppIconActionButtonVariant.ghost:
        return IconButton.styleFrom(
          fixedSize: fixedSize,
          minimumSize: fixedSize,
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: colorScheme.onSurfaceVariant,
          disabledForegroundColor: colorScheme.onSurface.withValues(
            alpha: 0.38,
          ),
          shape: shape,
        );
      case AppIconActionButtonVariant.tonal:
        return IconButton.styleFrom(
          fixedSize: fixedSize,
          minimumSize: fixedSize,
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: colorScheme.onSecondaryContainer,
          backgroundColor: colorScheme.secondaryContainer,
          disabledForegroundColor: colorScheme.onSurface.withValues(
            alpha: 0.38,
          ),
          disabledBackgroundColor: colorScheme.onSurface.withValues(
            alpha: 0.12,
          ),
          shape: shape,
        );
      case AppIconActionButtonVariant.outlined:
        return IconButton.styleFrom(
          fixedSize: fixedSize,
          minimumSize: fixedSize,
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: colorScheme.onSurfaceVariant,
          backgroundColor: colorScheme.surface,
          disabledForegroundColor: colorScheme.onSurface.withValues(
            alpha: 0.38,
          ),
          side: BorderSide(color: colorScheme.outlineVariant),
          shape: shape,
        );
    }
  }
}
