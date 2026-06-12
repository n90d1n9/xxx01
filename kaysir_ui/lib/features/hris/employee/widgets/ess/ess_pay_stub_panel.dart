import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/employee/models/pay_stub.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import 'ess_formatters.dart';

class EssPayStubPanel extends StatelessWidget {
  final List<PayStub> payStubs;
  final VoidCallback onViewAll;

  const EssPayStubPanel({
    super.key,
    required this.payStubs,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final recentPayStubs = [...payStubs]
      ..sort((a, b) => b.payDate.compareTo(a.payDate));

    return HrisSectionPanel(
      title: 'Recent Pay Stubs',
      icon: Icons.receipt_long_outlined,
      subtitle: '${payStubs.length} available',
      emptyMessage: 'No pay stubs available',
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: onViewAll,
            child: const Text('View All'),
          ),
        ),
        ...recentPayStubs
            .take(3)
            .map((payStub) => _PayStubTile(payStub: payStub)),
      ],
    );
  }
}

class _PayStubTile extends StatelessWidget {
  final PayStub payStub;

  const _PayStubTile({required this.payStub});

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.payments_outlined,
              color: Color(0xFF059669),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${DateFormat('MMM d').format(payStub.payPeriodStart)} - ${DateFormat('MMM d, yyyy').format(payStub.payPeriodEnd)}',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Paid ${DateFormat('MMM d, yyyy').format(payStub.payDate)}',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            essCurrencyFormat.format(payStub.netAmount),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: const Color(0xFF059669),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
