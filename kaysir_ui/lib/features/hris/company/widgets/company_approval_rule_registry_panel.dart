import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_approval_rule.dart';
import 'company_status_styles.dart';

class CompanyApprovalRuleRegistryPanel extends StatelessWidget {
  final List<CompanyApprovalRule> rules;
  final ValueChanged<String> onMarkActive;

  const CompanyApprovalRuleRegistryPanel({
    super.key,
    required this.rules,
    required this.onMarkActive,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.route_outlined,
      title: 'Approval Matrix',
      subtitle: '${rules.length} routing rules',
      emptyMessage: 'No matching approval rules',
      children:
          rules
              .map(
                (rule) => _ApprovalRuleTile(
                  rule: rule,
                  onMarkActive: () => onMarkActive(rule.id),
                ),
              )
              .toList(),
    );
  }
}

class _ApprovalRuleTile extends StatelessWidget {
  final CompanyApprovalRule rule;
  final VoidCallback onMarkActive;

  const _ApprovalRuleTile({required this.rule, required this.onMarkActive});

  @override
  Widget build(BuildContext context) {
    final statusColor = companyApprovalRuleStatusColor(rule.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${rule.domain.label} - ${rule.scopeName}',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(label: rule.status.label, color: statusColor),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${rule.entityName} - ${rule.thresholdLabel}',
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(label: 'Approver', value: rule.approverRole),
              HrisMetricStripItem(
                label: 'Backup',
                value: rule.backupApproverRole,
              ),
              HrisMetricStripItem(label: 'SLA', value: '${rule.slaHours}h'),
            ],
          ),
          if (rule.issues.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  rule.issues
                      .map(
                        (issue) => HrisStatusPill(
                          label: issue.label,
                          color: Colors.orange,
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: onMarkActive,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Mark active'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
