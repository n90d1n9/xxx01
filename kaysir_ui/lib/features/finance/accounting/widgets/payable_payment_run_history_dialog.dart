import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_dialog_actions.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';

import '../states/payable_payment_run_provider.dart';
import 'payable_payment_run_history_components.dart';

class PayablePaymentRunHistoryDialog extends ConsumerWidget {
  const PayablePaymentRunHistoryDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(payablePaymentRunRecordsProvider);
    final currency = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Payment Run History',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child:
                    records.isEmpty
                        ? const AppEmptyState(
                          icon: Icons.history_toggle_off_rounded,
                          title: 'No payment runs yet',
                          message:
                              'Posted AP payment runs will appear here with bill-level detail.',
                        )
                        : Scrollbar(
                          child: ListView.separated(
                            itemCount: records.length,
                            separatorBuilder:
                                (context, index) => const SizedBox(height: 12),
                            itemBuilder:
                                (context, index) => PaymentRunHistoryRecordCard(
                                  record: records[index],
                                  currency: currency,
                                ),
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
