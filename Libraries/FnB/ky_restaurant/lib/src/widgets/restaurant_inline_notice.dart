import 'package:flutter/material.dart';

/// Displays compact inline feedback with optional leading and trailing actions.
class RestaurantInlineNotice extends StatelessWidget {
  const RestaurantInlineNotice({
    super.key,
    this.icon,
    this.leading,
    this.title,
    this.message,
    this.trailing,
    this.backgroundColor,
    this.borderColor,
    this.foregroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    this.borderRadius = 8,
    this.leadingSpacing = 10,
    this.titleStyle,
    this.messageStyle,
    this.semanticsLabel,
  }) : assert(
         icon == null || leading == null,
         'Use icon or leading, not both.',
       ),
       assert(title != null || message != null);

  final IconData? icon;
  final Widget? leading;
  final String? title;
  final String? message;
  final Widget? trailing;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double leadingSpacing;
  final TextStyle? titleStyle;
  final TextStyle? messageStyle;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final foreground = foregroundColor ?? colors.onSurfaceVariant;
    final leadingWidget =
        leading ?? (icon == null ? null : Icon(icon, color: foreground));

    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            colors.surfaceContainerHighest.withValues(alpha: .4),
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Padding(
        padding: padding,
        child: Row(
          crossAxisAlignment: title == null
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            if (leadingWidget != null) ...[
              leadingWidget,
              SizedBox(width: leadingSpacing),
            ],
            Expanded(
              child: _NoticeCopySemantics(
                semanticsLabel: semanticsLabel,
                child: _NoticeCopy(
                  title: title,
                  message: message,
                  foregroundColor: foreground,
                  titleStyle: titleStyle,
                  messageStyle: messageStyle,
                ),
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 12), trailing!],
          ],
        ),
      ),
    );
  }
}

/// Applies an optional combined semantics label to notice copy only.
class _NoticeCopySemantics extends StatelessWidget {
  const _NoticeCopySemantics({required this.child, this.semanticsLabel});

  final Widget child;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final label = semanticsLabel;
    if (label == null) return child;

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: label,
      child: child,
    );
  }
}

/// Renders the title and message copy inside an inline notice.
class _NoticeCopy extends StatelessWidget {
  const _NoticeCopy({
    required this.foregroundColor,
    this.title,
    this.message,
    this.titleStyle,
    this.messageStyle,
  });

  final String? title;
  final String? message;
  final Color foregroundColor;
  final TextStyle? titleStyle;
  final TextStyle? messageStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = this.title;
    final message = this.message;

    if (title == null) {
      return Text(
        message!,
        style:
            messageStyle ??
            theme.textTheme.bodySmall?.copyWith(color: foregroundColor),
      );
    }

    if (message == null) {
      return Text(
        title,
        style:
            titleStyle ??
            theme.textTheme.labelLarge?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w900,
            ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              titleStyle ??
              theme.textTheme.labelLarge?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          message,
          style:
              messageStyle ??
              theme.textTheme.bodySmall?.copyWith(color: foregroundColor),
        ),
      ],
    );
  }
}
