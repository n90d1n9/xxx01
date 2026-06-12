import 'package:flutter/material.dart';

class POSUiTokens {
  static const double radius = 8;
  static const double gap = 8;
  static const double gapLarge = 12;
  static const double controlHeight = 40;
  static const EdgeInsets controlPadding = EdgeInsets.symmetric(horizontal: 12);

  const POSUiTokens._();
}

enum POSActionButtonVariant { outlined, tonal, filled }

class POSSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final BoxBorder? border;
  final BorderRadiusGeometry borderRadius;
  final bool elevated;

  const POSSurface({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.color,
    this.border,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(POSUiTokens.radius),
    ),
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? theme.colorScheme.surface,
        borderRadius: borderRadius,
        border: border,
        boxShadow:
            elevated
                ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.035),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
                : null,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class POSIconBadge extends StatelessWidget {
  final IconData icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double size;
  final double iconSize;

  const POSIconBadge({
    super.key,
    required this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.size = 34,
    this.iconSize = 19,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: foregroundColor ?? theme.colorScheme.onSecondaryContainer,
      ),
    );
  }
}

class POSMetricPill extends StatelessWidget {
  final Widget? icon;
  final String label;
  final String? value;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const POSMetricPill({
    super.key,
    this.icon,
    required this.label,
    this.value,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveForeground =
        foregroundColor ?? theme.colorScheme.onPrimaryContainer;

    return Container(
      height: POSUiTokens.controlHeight,
      padding: POSUiTokens.controlPadding,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            IconTheme(
              data: IconThemeData(size: 18, color: effectiveForeground),
              child: icon!,
            ),
            const SizedBox(width: POSUiTokens.gap),
          ],
          Flexible(
            child: Text(
              value == null ? label : '$label | $value',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge?.copyWith(
                color: effectiveForeground,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class POSActionButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback? onPressed;
  final POSActionButtonVariant variant;
  final String? tooltip;

  const POSActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.variant = POSActionButtonVariant.outlined,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final style = _buttonStyle();
    final button = _buildButton(style);

    final message = tooltip?.trim();
    if (message == null || message.isEmpty) return button;

    return Tooltip(message: message, child: button);
  }

  Widget _buildButton(ButtonStyle style) {
    switch (variant) {
      case POSActionButtonVariant.outlined:
        return OutlinedButton.icon(
          icon: icon,
          label: Text(label),
          onPressed: onPressed,
          style: style,
        );
      case POSActionButtonVariant.tonal:
        return FilledButton.tonalIcon(
          icon: icon,
          label: Text(label),
          onPressed: onPressed,
          style: style,
        );
      case POSActionButtonVariant.filled:
        return FilledButton.icon(
          icon: icon,
          label: Text(label),
          onPressed: onPressed,
          style: style,
        );
    }
  }

  ButtonStyle _buttonStyle() {
    return ButtonStyle(
      minimumSize: WidgetStateProperty.all(
        const Size(0, POSUiTokens.controlHeight),
      ),
      padding: WidgetStateProperty.all(POSUiTokens.controlPadding),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(POSUiTokens.radius),
        ),
      ),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}

class POSChoicePill extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const POSChoicePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: onSelected,
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primaryContainer,
      side: BorderSide(
        color:
            selected
                ? theme.colorScheme.primary.withValues(alpha: 0.32)
                : theme.dividerColor,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
      ),
      labelStyle: theme.textTheme.labelLarge?.copyWith(
        color:
            selected
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant,
        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}

class POSEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const POSEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: POSUiTokens.gapLarge),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: POSUiTokens.gapLarge),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
