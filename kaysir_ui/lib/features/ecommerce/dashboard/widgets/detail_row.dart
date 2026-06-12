import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import 'tone.dart';
import 'tonal_icon_badge.dart';

enum DetailRowTitleScale { compact, standard }

class DetailRow extends StatelessWidget {
  const DetailRow({
    required this.icon,
    required this.title,
    required this.description,
    this.footer,
    this.iconColors,
    this.iconTone,
    this.iconBackgroundColor,
    this.iconForegroundColor,
    this.iconBackgroundSource = ToneBackgroundSource.foreground,
    this.iconBackgroundAlpha = 0.12,
    this.iconBadgeSize = 34,
    this.iconSize = 19,
    this.titleScale = DetailRowTitleScale.compact,
    this.titleMaxLines = 1,
    this.descriptionMaxLines = 2,
    this.descriptionWeight = FontWeight.w600,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget? footer;
  final ToneColors? iconColors;
  final VisualTone? iconTone;
  final Color? iconBackgroundColor;
  final Color? iconForegroundColor;
  final ToneBackgroundSource iconBackgroundSource;
  final double iconBackgroundAlpha;
  final double iconBadgeSize;
  final double iconSize;
  final DetailRowTitleScale titleScale;
  final int titleMaxLines;
  final int descriptionMaxLines;
  final FontWeight descriptionWeight;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final footer = this.footer;

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TonalIconBadge(
            icon: icon,
            colors: iconColors,
            tone: iconTone,
            backgroundSource: iconBackgroundSource,
            backgroundAlpha: iconBackgroundAlpha,
            size: iconBadgeSize,
            iconSize: iconSize,
            backgroundColor: iconBackgroundColor,
            foregroundColor: iconForegroundColor,
          ),
          const SizedBox(width: POSUiTokens.gapLarge),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: titleMaxLines,
                  overflow: TextOverflow.ellipsis,
                  style: _titleTextStyle(
                    theme,
                  )?.copyWith(fontWeight: FontWeight.w900),
                ),
                SizedBox(height: _titleDescriptionSpacing),
                Text(
                  description,
                  maxLines: descriptionMaxLines,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: descriptionWeight,
                  ),
                ),
                if (footer != null) ...[
                  const SizedBox(height: POSUiTokens.gap),
                  footer,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  double get _titleDescriptionSpacing {
    return switch (titleScale) {
      DetailRowTitleScale.compact => 3,
      DetailRowTitleScale.standard => 4,
    };
  }

  TextStyle? _titleTextStyle(ThemeData theme) {
    return switch (titleScale) {
      DetailRowTitleScale.compact => theme.textTheme.titleSmall,
      DetailRowTitleScale.standard => theme.textTheme.titleMedium,
    };
  }
}
