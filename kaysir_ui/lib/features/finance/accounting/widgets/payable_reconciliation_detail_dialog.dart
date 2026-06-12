import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_dialog_actions.dart';

import '../states/payable_reconciliation_provider.dart';
import 'payable_reconciliation_detail_components.dart';
import 'reconciliation_detail_components.dart';

class PayableReconciliationDetailDialog extends ConsumerWidget {
  const PayableReconciliationDetailDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reconciliation = ref.watch(payableReconciliationProvider);
    final currency = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    final dateFormat = DateFormat('MM/dd/yyyy');
    final statusColor =
        reconciliation.isBalanced ? Colors.teal : Colors.deepOrange;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ReconciliationDetailHeader(
                title: 'AP Reconciliation Detail',
                subtitle:
                    'Compare open vendor bills with posted accounts payable ledger activity.',
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
                      PayableReconciliationTotalsPanel(
                        reconciliation: reconciliation,
                        currency: currency,
                      ),
                      const SizedBox(height: 18),
                      ReconciliationSectionHeader(
                        title: 'Open Payable Subledger',
                        amount: reconciliation.subledgerBalance,
                        currency: currency,
                        icon: Icons.inventory_2_outlined,
                      ),
                      const SizedBox(height: 10),
                      PayableSubledgerReconciliationTable(
                        lines: reconciliation.subledgerLines,
                        currency: currency,
                        dateFormat: dateFormat,
                      ),
                      const SizedBox(height: 18),
                      ReconciliationSectionHeader(
                        title: 'Accounts Payable GL Activity',
                        amount: reconciliation.ledgerBalance,
                        currency: currency,
                        icon: Icons.account_balance_wallet_outlined,
                      ),
                      const SizedBox(height: 10),
                      PayableLedgerReconciliationTable(
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
