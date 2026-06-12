import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import 'tone.dart';
import 'tonal_icon_badge.dart';

class DialogHeader extends StatelessWidget {
  const DialogHeader({
    required this.icon,
    required this.title,
    this.iconBackgroundColor,
    this.iconForegroundColor,
    this.tone = VisualTone.secondary,
    this.iconBackgroundAlpha = 1,
    this.trailing,
    super.key,
  });

  final IconData icon;
  final String title;
  final Color? iconBackgroundColor;
  final Color? iconForegroundColor;
  final VisualTone tone;
  final double iconBackgroundAlpha;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trailing = this.trailing;

    return Row(
      children: [
        TonalIconBadge(
          icon: icon,
          tone: tone,
          backgroundSource: ToneBackgroundSource.container,
          backgroundAlpha: iconBackgroundAlpha,
          backgroundColor: iconBackgroundColor,
          foregroundColor: iconForegroundColor,
        ),
        const SizedBox(width: POSUiTokens.gapLarge),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: POSUiTokens.gap),
          trailing,
        ],
      ],
    );
  }
}
