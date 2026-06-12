import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.message,
    this.centered = false,
    this.prominent = false,
    this.fontWeight = FontWeight.w700,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  final String message;
  final bool centered;
  final bool prominent;
  final FontWeight fontWeight;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = Text(
      message,
      textAlign: centered ? TextAlign.center : TextAlign.start,
      style: (prominent
              ? theme.textTheme.bodyMedium
              : theme.textTheme.bodySmall)
          ?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: fontWeight,
          ),
    );

    final padded = Padding(padding: padding, child: text);
    if (!centered) return padded;

    return Center(child: padded);
  }
}
