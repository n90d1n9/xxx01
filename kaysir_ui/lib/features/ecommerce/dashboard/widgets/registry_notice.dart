import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_inline_notice.dart';
import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/registry_diagnostics.dart';
import 'action_button.dart';
import 'notice_pill.dart';
import 'registry_details_dialog.dart';
import 'registry_issue_source_icon.dart';
import 'tone.dart';

class RegistryNotice extends StatelessWidget {
  final RegistryDiagnostics diagnostics;
  final int maxVisibleIssues;

  const RegistryNotice({
    super.key,
    required this.diagnostics,
    this.maxVisibleIssues = 4,
  });

  @override
  Widget build(BuildContext context) {
    if (!diagnostics.hasIssues) return const SizedBox.shrink();

    final visibleEntries = diagnostics.visibleIssues(maxVisibleIssues);
    final hiddenCount = diagnostics.hiddenIssueCount(maxVisibleIssues);

    return POSInlineNotice(
      tone: POSInlineNoticeTone.danger,
      icon: Icons.rule_folder_outlined,
      title: diagnostics.noticeTitle,
      message: diagnostics.noticeMessage,
      trailing: ActionButton(
        variant: ActionButtonVariant.plain,
        onPressed:
            () => showRegistryDetailsDialog(
              context: context,
              diagnostics: diagnostics,
            ),
        icon: Icons.open_in_new_outlined,
        iconSize: 17,
        label: 'View details',
      ),
      footer: Wrap(
        spacing: POSUiTokens.gap,
        runSpacing: POSUiTokens.gap,
        children: [
          ...visibleEntries.map(
            (entry) => NoticePill(
              key: ValueKey(
                'commerce_workspace_registry_issue_${entry.source.name}_${entry.typeName}_${entry.index}',
              ),
              icon: registryIssueSourceIcon(entry.source),
              label: entry.source.label,
              message: entry.message,
              tone: VisualTone.danger,
            ),
          ),
          if (hiddenCount > 0) NoticeOverflowPill(hiddenCount: hiddenCount),
        ],
      ),
    );
  }
}
