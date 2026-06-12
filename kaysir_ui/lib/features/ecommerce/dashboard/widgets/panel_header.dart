import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import 'tone.dart';
import 'tonal_icon_badge.dart';

class PanelHeader extends StatelessWidget {
  const PanelHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconBackgroundColor,
    this.iconForegroundColor,
    this.tone,
    this.iconBackgroundAlpha = 0.24,
    this.subtitleColor,
    this.subtitleFontWeight = FontWeight.w600,
    this.trailing,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconBackgroundColor;
  final Color? iconForegroundColor;
  final VisualTone? tone;
  final double iconBackgroundAlpha;
  final Color? subtitleColor;
  final FontWeight subtitleFontWeight;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trailing = this.trailing;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TonalIconBadge(
          icon: icon,
          tone: tone,
          backgroundSource: ToneBackgroundSource.container,
          backgroundAlpha: iconBackgroundAlpha,
          backgroundColor:
              iconBackgroundColor ??
              (tone == null ? theme.colorScheme.secondaryContainer : null),
          foregroundColor:
              iconForegroundColor ??
              (tone == null ? theme.colorScheme.onSecondaryContainer : null),
        ),
        const SizedBox(width: POSUiTokens.gapLarge),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: subtitleColor ?? theme.colorScheme.onSurfaceVariant,
                  fontWeight: subtitleFontWeight,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: POSUiTokens.gapLarge),
          trailing,
        ],
      ],
    );
  }
}
