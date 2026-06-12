import 'package:flutter/material.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/request_time_off_draft.dart';

class TimeOffBalancePanel extends StatelessWidget {
  final List<TimeOffBalance> balances;
  final String selectedType;

  const TimeOffBalancePanel({
    super.key,
    required this.balances,
    required this.selectedType,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.account_balance_outlined,
      title: 'Time off balance',
      subtitle: 'Available allowance by request category',
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final columns =
                constraints.maxWidth >= 960
                    ? 5
                    : constraints.maxWidth >= 640
                    ? 3
                    : 1;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: columns == 1 ? 3.2 : 1.55,
              ),
              itemCount: balances.length,
              itemBuilder:
                  (context, index) => _BalanceCard(
                    balance: balances[index],
                    selected: balances[index].type == selectedType,
                  ),
            );
          },
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final TimeOffBalance balance;
  final bool selected;

  const _BalanceCard({required this.balance, required this.selected});

  @override
  Widget build(BuildContext context) {
    final color = selected ? HrisColors.primary : const Color(0xFF15803D);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            selected
                ? HrisColors.primary.withValues(alpha: 0.08)
                : HrisColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected ? HrisColors.primary : HrisColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  balance.type,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (selected)
                Icon(
                  Icons.check_circle_rounded,
                  color: HrisColors.primary,
                  size: 18,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${balance.remainingDays} days available',
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          HrisProgressBar(
            value: balance.usageRatio,
            color: color,
            label: '${balance.usedDays} of ${balance.totalDays} used',
          ),
        ],
      ),
    );
  }
}
