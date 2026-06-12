import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_inline_notice.dart';
import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/module.dart';
import 'notice_pill.dart';
import 'tone.dart';

class ModuleNotice extends StatelessWidget {
  final List<ModuleIssue> issues;
  final int maxVisibleIssues;

  const ModuleNotice({
    super.key,
    required this.issues,
    this.maxVisibleIssues = 3,
  });

  @override
  Widget build(BuildContext context) {
    if (issues.isEmpty) return const SizedBox.shrink();

    final visibleIssues = issues.take(maxVisibleIssues).toList(growable: false);
    final hiddenCount = issues.length - visibleIssues.length;

    return POSInlineNotice(
      tone: POSInlineNoticeTone.warning,
      icon: Icons.extension_outlined,
      title: 'Workspace modules need review',
      message:
          '${issues.length} ${_noun(issues.length, 'module issue')} can affect Commerce Workspace navigation.',
      footer: Wrap(
        spacing: POSUiTokens.gap,
        runSpacing: POSUiTokens.gap,
        children: [
          ...visibleIssues.map(
            (issue) => NoticePill(
              key: ValueKey(
                'commerce_workspace_module_issue_${issue.type.name}',
              ),
              icon: Icons.error_outline,
              message: issue.message,
              tone: VisualTone.success,
              maxWidth: 360,
            ),
          ),
          if (hiddenCount > 0) NoticeOverflowPill(hiddenCount: hiddenCount),
        ],
      ),
    );
  }
}

String _noun(int count, String singular) {
  return count == 1 ? singular : '${singular}s';
}
