import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/compliance_models.dart';
import 'compliance_status_styles.dart';

class CompliancePolicyPanel extends StatelessWidget {
  final List<PolicyAcknowledgement> policies;

  const CompliancePolicyPanel({super.key, required this.policies});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.policy_outlined,
      title: 'Policy Acknowledgements',
      subtitle: '${policies.length} policies',
      emptyMessage: 'No matching policy acknowledgements',
      children: policies.map((policy) => _PolicyTile(policy: policy)).toList(),
    );
  }
}

class _PolicyTile extends StatelessWidget {
  final PolicyAcknowledgement policy;

  const _PolicyTile({required this.policy});

  @override
  Widget build(BuildContext context) {
    final color = policyStatusColor(policy.status);
    final formatter = DateFormat('MMM d');

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  policy.policyName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              HrisStatusPill(
                label: policyStatusLabel(policy.status),
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${policy.audience} - due ${formatter.format(policy.deadline)}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Required',
                value: '${policy.requiredCount}',
              ),
              HrisMetricStripItem(
                label: 'Done',
                value: '${policy.completedCount}',
              ),
              HrisMetricStripItem(
                label: 'Pending',
                value: '${policy.pendingCount}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: policy.completionRate,
            color: color,
            label:
                '${(policy.completionRate * 100).toStringAsFixed(0)}% acknowledged',
          ),
        ],
      ),
    );
  }
}
