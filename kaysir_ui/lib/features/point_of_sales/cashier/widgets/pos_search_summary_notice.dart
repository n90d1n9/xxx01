import 'package:flutter/material.dart';

import 'pos_inline_notice.dart';
import 'pos_ui.dart';

class POSSearchSummaryNotice extends StatelessWidget {
  final String title;
  final String message;
  final String clearActionLabel;
  final VoidCallback onClear;
  final String? recoveryActionLabel;
  final VoidCallback? onRecover;
  final Key? clearActionKey;
  final Key? recoveryActionKey;
  final IconData icon;
  final IconData clearIcon;
  final IconData recoveryIcon;

  const POSSearchSummaryNotice({
    super.key,
    required this.title,
    required this.message,
    required this.clearActionLabel,
    required this.onClear,
    this.recoveryActionLabel,
    this.onRecover,
    this.clearActionKey,
    this.recoveryActionKey,
    this.icon = Icons.manage_search_outlined,
    this.clearIcon = Icons.search_off_outlined,
    this.recoveryIcon = Icons.arrow_forward,
  });

  @override
  Widget build(BuildContext context) {
    return POSInlineNotice(
      tone: POSInlineNoticeTone.info,
      icon: icon,
      title: title,
      message: message,
      footer: Wrap(
        spacing: POSUiTokens.gap,
        runSpacing: POSUiTokens.gap,
        children: [
          TextButton.icon(
            key: clearActionKey,
            icon: Icon(clearIcon),
            label: Text(clearActionLabel),
            onPressed: onClear,
          ),
          if (recoveryActionLabel != null && onRecover != null)
            FilledButton.tonalIcon(
              key: recoveryActionKey,
              icon: Icon(recoveryIcon),
              label: Text(recoveryActionLabel!),
              onPressed: onRecover,
            ),
        ],
      ),
    );
  }
}
