import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/registry_diagnostics.dart';
import 'dialog_close_button.dart';
import 'dialog_header.dart';
import 'dialog_section.dart';
import 'registry_diagnostics_widgets.dart';
import 'notice_tone.dart';
import 'tone.dart';

Future<void> showRegistryDetailsDialog({
  required BuildContext context,
  required RegistryDiagnostics diagnostics,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => RegistryDetailsDialog(diagnostics: diagnostics),
  );
}

class RegistryDetailsDialog extends StatelessWidget {
  final RegistryDiagnostics diagnostics;

  const RegistryDetailsDialog({super.key, required this.diagnostics});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleColors = noticeIssueColors(
      theme.colorScheme,
      VisualTone.danger,
      backgroundAlpha: 0.12,
    );

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      actionsPadding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      title: DialogHeader(
        icon: Icons.rule_folder_outlined,
        title: 'Registry diagnostics',
        iconBackgroundColor: titleColors.background,
        iconForegroundColor: titleColors.foreground,
      ),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                diagnostics.noticeMessage,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: POSUiTokens.gapLarge),
              DialogSection(
                title: 'Sources',
                child: RegistrySourcePills(
                  sourceSummaries: diagnostics.sourceSummaries,
                ),
              ),
              const SizedBox(height: POSUiTokens.gapLarge),
              DialogSection(
                title: 'Issues',
                child: RegistryIssueList(diagnostics: diagnostics),
              ),
            ],
          ),
        ),
      ),
      actions: [const DialogCloseButton()],
    );
  }
}
