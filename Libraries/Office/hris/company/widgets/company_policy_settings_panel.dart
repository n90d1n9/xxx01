import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_policy.dart';
import 'company_status_styles.dart';

class CompanyPolicySettingsPanel extends StatelessWidget {
  final List<CompanyPolicySetting> policies;
  final ValueChanged<String> onMarkReady;

  const CompanyPolicySettingsPanel({
    super.key,
    required this.policies,
    required this.onMarkReady,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.rule_folder_outlined,
      title: 'HR Policy Settings',
      subtitle: '${policies.length} policy modules',
      emptyMessage: 'No matching policy settings',
      children:
          policies
              .map(
                (policy) => _PolicyTile(
                  policy: policy,
                  onMarkReady: () => onMarkReady(policy.id),
                ),
              )
              .toList(),
    );
  }
}

class _PolicyTile extends StatelessWidget {
  final CompanyPolicySetting policy;
  final VoidCallback onMarkReady;

  const _PolicyTile({required this.policy, required this.onMarkReady});

  @override
  Widget build(BuildContext context) {
    final statusColor = companyPolicyStatusColor(policy.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  policy.name,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(label: policy.status.label, color: statusColor),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${policy.linkedModule} - ${policy.cadence}',
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(label: 'Owner', value: policy.ownerName),
              HrisMetricStripItem(label: 'Action', value: policy.nextAction),
            ],
          ),
          if (policy.requiresAttention) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: onMarkReady,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Mark ready'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
