import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/compensation_models.dart';
import 'compensation_formatters.dart';
import 'compensation_meta_label.dart';
import 'compensation_status_styles.dart';

class IncentivePayoutPanel extends StatelessWidget {
  final List<IncentivePayout> incentives;

  const IncentivePayoutPanel({super.key, required this.incentives});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      title: 'Incentive Payouts',
      icon: Icons.emoji_events_outlined,
      subtitle: '${incentives.length} payouts',
      emptyMessage: 'No incentives match filters',
      children:
          incentives
              .map((incentive) => _IncentiveTile(incentive: incentive))
              .toList(),
    );
  }
}

class _IncentiveTile extends StatelessWidget {
  final IncentivePayout incentive;

  const _IncentiveTile({required this.incentive});

  @override
  Widget build(BuildContext context) {
    final color = incentiveStatusColor(incentive.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  incentive.employeeName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              HrisStatusPill(
                label: incentiveStatusLabel(incentive.status),
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            incentive.programName,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 10),
          HrisProgressBar(
            value: incentive.approvalRate,
            color: color,
            label:
                '${compactMoney(incentive.approvedAmount)} of ${compactMoney(incentive.targetAmount)} approved',
          ),
          const SizedBox(height: 8),
          CompensationMetaLabel(
            icon: Icons.calendar_today_outlined,
            label: DateFormat('MMM d').format(incentive.payoutDate),
          ),
        ],
      ),
    );
  }
}
