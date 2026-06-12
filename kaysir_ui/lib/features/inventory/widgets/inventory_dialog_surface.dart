import 'package:flutter/material.dart';

import '../../../widgets/ui/app_text_cluster.dart';

class InventoryDialogSurface extends StatelessWidget {
  const InventoryDialogSurface({
    super.key,
    required this.child,
    this.maxWidth = 640,
    this.maxHeight,
    this.padding = const EdgeInsets.all(20),
    this.scrollable = true,
  });

  final Widget child;
  final double maxWidth;
  final double? maxHeight;
  final EdgeInsetsGeometry padding;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final constraints =
        maxHeight == null
            ? BoxConstraints(maxWidth: maxWidth)
            : BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight!);

    final content =
        scrollable
            ? SingleChildScrollView(padding: padding, child: child)
            : Padding(padding: padding, child: child);

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(constraints: constraints, child: content),
    );
  }
}

class InventoryDialogHeader extends StatelessWidget {
  const InventoryDialogHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.onClose,
    this.closeTooltip = 'Close dialog',
    this.showCloseButton = true,
    this.titleMaxLines = 2,
    this.subtitleMaxLines = 2,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;
  final VoidCallback? onClose;
  final String closeTooltip;
  final bool showCloseButton;
  final int titleMaxLines;
  final int subtitleMaxLines;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(
      context,
    ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AppTextCluster(
            eyebrow: eyebrow,
            title: title,
            subtitle: subtitle,
            titleMaxLines: titleMaxLines,
            subtitleMaxLines: subtitleMaxLines,
            titleStyle: titleStyle,
          ),
        ),
        if (showCloseButton) ...[
          const SizedBox(width: 12),
          IconButton(
            tooltip: closeTooltip,
            icon: const Icon(Icons.close_rounded),
            onPressed: onClose,
          ),
        ],
      ],
    );
  }
}
