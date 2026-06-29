import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/compensation_models.dart';
import 'compensation_formatters.dart';
import 'compensation_status_styles.dart';

class AllowanceBudgetPanel extends StatelessWidget {
  final List<AllowanceBudget> allowances;

  const AllowanceBudgetPanel({super.key, required this.allowances});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      title: 'Allowance Budgets',
      icon: Icons.account_balance_wallet_outlined,
      subtitle: '${allowances.length} budgets',
      emptyMessage: 'No allowance budgets match filters',
      children:
          allowances
              .map((allowance) => _AllowanceTile(allowance: allowance))
              .toList(),
    );
  }
}

class _AllowanceTile extends StatelessWidget {
  final AllowanceBudget allowance;

  const _AllowanceTile({required this.allowance});

  @override
  Widget build(BuildContext context) {
    final color = allowanceStatusColor(allowance.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  allowance.allowanceType,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              HrisStatusPill(
                label: allowanceStatusLabel(allowance.status),
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 10),
          HrisProgressBar(
            value: allowance.usedRate,
            color: color,
            label:
                '${compactMoney(allowance.spent)} spent of ${compactMoney(allowance.budget)}',
          ),
          const SizedBox(height: 8),
          Text(
            'Forecast ${compactMoney(allowance.forecast)}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
        ],
      ),
    );
  }
}
