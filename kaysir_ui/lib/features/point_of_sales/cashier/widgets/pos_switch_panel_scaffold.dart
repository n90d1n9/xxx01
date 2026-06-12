import 'package:flutter/material.dart';

import 'pos_switch_panel_chrome.dart';
import 'pos_ui.dart';

class POSSwitchPanelScaffold extends StatelessWidget {
  final String title;
  final String currentLabel;
  final EdgeInsetsGeometry padding;
  final bool shrinkWrap;
  final Widget? contextBanner;
  final Widget? filters;
  final Widget body;

  const POSSwitchPanelScaffold({
    super.key,
    required this.title,
    required this.currentLabel,
    required this.body,
    this.padding = const EdgeInsets.fromLTRB(16, 6, 16, 16),
    this.shrinkWrap = false,
    this.contextBanner,
    this.filters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            POSSwitchPanelHeader(title: title, currentLabel: currentLabel),
            const SizedBox(height: POSUiTokens.gap),
            if (contextBanner != null) ...[
              contextBanner!,
              const SizedBox(height: POSUiTokens.gap),
            ],
            if (filters != null) filters!,
            if (shrinkWrap) body else Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
