import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_dialog_actions.dart';

import '../states/receivable_reconciliation_provider.dart';
import 'receivable_reconciliation_detail_components.dart';
import 'reconciliation_detail_components.dart';

class ReceivableReconciliationDetailDialog extends ConsumerWidget {
  const ReceivableReconciliationDetailDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reconciliation = ref.watch(receivableReconciliationProvider);
    final currency = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    final dateFormat = DateFormat('MM/dd/yyyy');
    final statusColor =
        reconciliation.isBalanced ? Colors.teal : Colors.deepOrange;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1040, maxHeight: 760),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ReconciliationDetailHeader(
                title: 'AR Reconciliation Detail',
                subtitle:
                    'Compare open customer invoices with posted accounts receivable ledger activity.',
                icon: Icons.fact_check_outlined,
                statusLabel:
                    reconciliation.isBalanced ? 'Balanced' : 'Variance',
                statusColor: statusColor,
                statusIcon:
                    reconciliation.isBalanced
                        ? Icons.verified_outlined
                        : Icons.warning_amber_rounded,
              ),
              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ReceivableReconciliationTotalsPanel(
                        reconciliation: reconciliation,
                        currency: currency,
                      ),
                      const SizedBox(height: 18),
                      ReconciliationSectionHeader(
                        title: 'Aging Buckets',
                        amount: reconciliation.overdueBalance,
                        amountLabel: 'Overdue',
                        currency: currency,
                        icon: Icons.timer_outlined,
                      ),
                      const SizedBox(height: 10),
                      ReceivableAgingBucketStrip(
                        buckets: reconciliation.agingBuckets,
                        currency: currency,
                      ),
                      const SizedBox(height: 18),
                      ReconciliationSectionHeader(
                        title: 'Open Receivable Subledger',
                        amount: reconciliation.subledgerBalance,
                        currency: currency,
                        icon: Icons.receipt_long_outlined,
                      ),
                      const SizedBox(height: 10),
                      ReceivableSubledgerReconciliationTable(
                        lines: reconciliation.subledgerLines,
                        currency: currency,
                        dateFormat: dateFormat,
                      ),
                      const SizedBox(height: 18),
                      ReconciliationSectionHeader(
                        title: 'Accounts Receivable GL Activity',
                        amount: reconciliation.ledgerBalance,
                        currency: currency,
                        icon: Icons.account_balance_wallet_outlined,
                      ),
                      const SizedBox(height: 10),
                      ReceivableLedgerReconciliationTable(
                        lines: reconciliation.ledgerLines,
                        currency: currency,
                        dateFormat: dateFormat,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppDialogActions(
                confirmLabel: 'Close',
                confirmIcon: Icons.close_rounded,
                confirmVariant: AppActionButtonVariant.text,
                onConfirm: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
