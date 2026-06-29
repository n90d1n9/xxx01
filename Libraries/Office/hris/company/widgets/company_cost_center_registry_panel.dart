import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_cost_center.dart';
import 'company_status_styles.dart';

class CompanyCostCenterRegistryPanel extends StatelessWidget {
  final List<CompanyCostCenter> centers;
  final ValueChanged<String> onMarkActive;

  const CompanyCostCenterRegistryPanel({
    super.key,
    required this.centers,
    required this.onMarkActive,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Cost Center Registry',
      subtitle: '${centers.length} centers',
      emptyMessage: 'No matching cost centers',
      children:
          centers
              .map(
                (center) => _CostCenterTile(
                  center: center,
                  onMarkActive: () => onMarkActive(center.id),
                ),
              )
              .toList(),
    );
  }
}

class _CostCenterTile extends StatelessWidget {
  final CompanyCostCenter center;
  final VoidCallback onMarkActive;

  const _CostCenterTile({required this.center, required this.onMarkActive});

  @override
  Widget build(BuildContext context) {
    final statusColor = companyCostCenterStatusColor(center.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${center.name} (${center.code})',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(label: center.status.label, color: statusColor),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${center.entityName} - ${center.orgUnitName}',
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(label: 'Owner', value: center.ownerName),
              HrisMetricStripItem(
                label: 'Budget',
                value: _compactAmount(center.annualBudget),
              ),
              HrisMetricStripItem(
                label: 'HC',
                value: '${center.activeHeadcount}/${center.allocatedHeadcount}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: center.headcountUtilization,
            color: statusColor,
            label:
                '${(center.headcountUtilization * 100).clamp(0, 150).round()}% headcount utilization',
          ),
          if (center.issues.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  center.issues
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

  String _compactAmount(int value) {
    if (value >= 1000000000) {
      return 'IDR ${(value / 1000000000).toStringAsFixed(1)}B';
    }
    if (value >= 1000000) {
      return 'IDR ${(value / 1000000).round()}M';
    }
    return 'IDR $value';
  }
}
