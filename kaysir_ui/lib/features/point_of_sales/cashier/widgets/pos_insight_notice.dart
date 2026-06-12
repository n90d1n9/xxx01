import 'package:flutter/material.dart';

import 'pos_inline_notice.dart';
import 'pos_switch_preview_pill.dart';

class POSInsightNoticeVisuals {
  final POSInlineNoticeTone noticeTone;
  final POSSwitchPreviewTone previewTone;
  final IconData icon;

  const POSInsightNoticeVisuals({
    required this.noticeTone,
    required this.previewTone,
    required this.icon,
  });

  static const ready = POSInsightNoticeVisuals(
    noticeTone: POSInlineNoticeTone.success,
    previewTone: POSSwitchPreviewTone.positive,
    icon: Icons.check_circle_outline,
  );

  static const review = POSInsightNoticeVisuals(
    noticeTone: POSInlineNoticeTone.warning,
    previewTone: POSSwitchPreviewTone.warning,
    icon: Icons.pending_actions_outlined,
  );

  static const attention = POSInsightNoticeVisuals(
    noticeTone: POSInlineNoticeTone.danger,
    previewTone: POSSwitchPreviewTone.danger,
    icon: Icons.priority_high_outlined,
  );
}

class POSInsightNextStep extends StatelessWidget {
  final String message;
  final POSSwitchPreviewTone tone;
  final String prefix;
  final int maxLines;

  const POSInsightNextStep({
    super.key,
    required this.message,
    required this.tone,
    this.prefix = 'Next:',
    this.maxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = POSSwitchPreviewPillColors.resolve(theme.colorScheme, tone);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.route_outlined, size: 15, color: colors.foreground),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '$prefix $message',
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
