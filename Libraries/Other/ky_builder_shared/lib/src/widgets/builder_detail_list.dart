import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

/// Presents a titled group of builder detail values in a compact text block.
class KyBuilderDetailList extends StatelessWidget {
  final String title;
  final List<String> details;
  final IconData? icon;
  final String emptyMessage;
  final String separator;
  final double spacing;

  const KyBuilderDetailList({
    super.key,
    required this.title,
    required this.details,
    this.icon,
    this.emptyMessage = '',
    this.separator = ', ',
    this.spacing = 4,
  });

  @Preview(name: 'Builder detail list')
  const KyBuilderDetailList.preview({super.key})
    : title = 'Mapped kinds',
      details = const ['image_holder to image', 'custom_button to button'],
      icon = Icons.transform,
      emptyMessage = '',
      separator = ', ',
      spacing = 4;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final detailText = details.isEmpty ? emptyMessage : details.join(separator);

    if (detailText.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
            ],
            Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        SizedBox(height: spacing),
        Text(
          detailText,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
