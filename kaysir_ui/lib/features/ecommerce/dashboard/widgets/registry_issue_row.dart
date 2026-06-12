import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/registry_diagnostics.dart';
import 'notice_tone.dart';
import 'registry_issue_source_icon.dart';
import 'tone.dart';

class RegistryIssueRow extends StatelessWidget {
  const RegistryIssueRow({required this.issue, super.key});

  final RegistryIssueEntry issue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final issueColors = noticeIssueColors(
      theme.colorScheme,
      VisualTone.danger,
      borderAlpha: 0.55,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: POSUiTokens.gap),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: issueColors.border, width: 3)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: POSUiTokens.gapLarge),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                registryIssueSourceIcon(issue.source),
                color: issueColors.foreground,
                size: 18,
              ),
              const SizedBox(width: POSUiTokens.gap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      spacing: POSUiTokens.gap,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          issue.source.label,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: issueColors.foreground,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          issue.typeName,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      issue.message,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
