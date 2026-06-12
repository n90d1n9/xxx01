import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/ess_history_models.dart';
import '../ess/ess_formatters.dart';

class PayStubHistoryPanel extends StatelessWidget {
  final List<PayStubBreakdown> stubs;
  final ValueChanged<PayStubBreakdown> onDownload;

  const PayStubHistoryPanel({
    super.key,
    required this.stubs,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.payments_outlined,
      title: 'Pay stub history',
      subtitle: 'Detailed earnings and deduction breakdowns',
      emptyMessage: 'No pay stubs available',
      children:
          stubs
              .map(
                (stub) => _PayStubExpansion(stub: stub, onDownload: onDownload),
              )
              .toList(),
    );
  }
}

class _PayStubExpansion extends StatelessWidget {
  final PayStubBreakdown stub;
  final ValueChanged<PayStubBreakdown> onDownload;

  const _PayStubExpansion({required this.stub, required this.onDownload});

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: 8),
        title: Text(
          '${DateFormat('MMM d').format(stub.stub.payPeriodStart)} - ${DateFormat('MMM d, yyyy').format(stub.stub.payPeriodEnd)}',
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          'Paid ${DateFormat('MMM d, yyyy').format(stub.stub.payDate)}',
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              essCurrencyFormat.format(stub.stub.netAmount),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: const Color(0xFF15803D),
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Net pay',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: HrisColors.muted),
            ),
          ],
        ),
        children: [
          _PayLine(
            label: 'Gross pay',
            value: essCurrencyFormat.format(stub.stub.grossAmount),
          ),
          ...stub.deductions.map(
            (line) => _PayLine(
              label: line.label,
              value: '-${essCurrencyFormat.format(line.amount)}',
              negative: true,
            ),
          ),
          const Divider(),
          _PayLine(
            label: 'Net pay',
            value: essCurrencyFormat.format(stub.stub.netAmount),
            bold: true,
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () => onDownload(stub),
              icon: const Icon(Icons.download_outlined),
              label: const Text('Download PDF'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PayLine extends StatelessWidget {
  final String label;
  final String value;
  final bool negative;
  final bool bold;

  const _PayLine({
    required this.label,
    required this.value,
    this.negative = false,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: HrisColors.ink,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: negative ? const Color(0xFFDC2626) : HrisColors.ink,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
