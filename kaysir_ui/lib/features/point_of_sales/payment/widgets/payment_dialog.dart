import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cashier/experiences/pos_checkout_behavior.dart';
import '../../cashier/experiences/pos_experience_provider.dart';
import '../../cashier/utils/pos_formatters.dart';
import '../../cashier/widgets/pos_ui.dart';
import '../../order/states/current_order_provider.dart';
import '../../order/widgets/order_completion_flow.dart';
import '../models/payment.dart';
import '../utils/payment_tendering.dart';
import 'payment_history_list.dart';
import 'payment_method_icon.dart';
import 'payment_summary_panel.dart';
import 'payment_tender_status.dart';
import 'tender_amount_chips.dart';

class PaymentDialog extends ConsumerStatefulWidget {
  const PaymentDialog({super.key});

  @override
  ConsumerState<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends ConsumerState<PaymentDialog> {
  final TextEditingController _amountController = TextEditingController();
  late String _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    _selectedPaymentMethod = ref.read(posPaymentBehaviorProvider).defaultMethod;
    final currentOrder = ref.read(currentOrderProvider);
    if (currentOrder != null) {
      _setTenderAmount(currentOrder.remainingAmount, notify: false);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentOrder = ref.watch(currentOrderProvider);
    final checkoutBehavior = ref.watch(posCheckoutBehaviorProvider);
    final paymentBehavior = ref.watch(posPaymentBehaviorProvider);
    final theme = Theme.of(context);

    if (currentOrder == null) {
      return AlertDialog(
        title: const Text('Payment unavailable'),
        content: const Text('No active order to process payment.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      );
    }

    final amount = _currentAmount;
    final selectedPaymentMethod = paymentBehavior.normalizeMethod(
      _selectedPaymentMethod,
    );
    final suggestions = paymentBehavior.resolveTenderSuggestions(
      remainingAmount: currentOrder.remainingAmount,
      method: selectedPaymentMethod,
    );
    final evaluation = paymentBehavior.evaluateTender(
      amount: amount,
      remainingAmount: currentOrder.remainingAmount,
      method: selectedPaymentMethod,
    );

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const POSIconBadge(icon: Icons.payments_outlined),
                  const SizedBox(width: POSUiTokens.gapLarge),
                  Expanded(
                    child: Text(
                      'Payment',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              PaymentSummaryPanel(order: currentOrder),
              const SizedBox(height: 20),
              Text(
                'Payment method',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: POSUiTokens.gap),
              SegmentedButton<String>(
                showSelectedIcon: false,
                segments:
                    paymentBehavior.paymentMethods
                        .map(
                          (method) => ButtonSegment<String>(
                            value: method,
                            label: Text(method),
                            icon: Icon(paymentMethodIcon(method)),
                          ),
                        )
                        .toList(),
                selected: {selectedPaymentMethod},
                onSelectionChanged: (selected) {
                  final method = selected.first;
                  setState(() {
                    _selectedPaymentMethod = method;
                    if (!paymentBehavior.canOverpay(method) &&
                        _currentAmount > currentOrder.remainingAmount) {
                      _setTenderAmount(
                        currentOrder.remainingAmount,
                        notify: false,
                      );
                    }
                  });
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Amount tendered',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: POSUiTokens.gap),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(POSUiTokens.radius),
                  ),
                  suffixIcon:
                      _amountController.text.isEmpty
                          ? null
                          : IconButton(
                            tooltip: 'Clear amount',
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _amountController.clear();
                              setState(() {});
                            },
                          ),
                ),
              ),
              const SizedBox(height: POSUiTokens.gapLarge),
              TenderAmountChips(
                suggestions: suggestions,
                selectedAmount: amount,
                onSelected: _setTenderAmount,
              ),
              const SizedBox(height: POSUiTokens.gapLarge),
              PaymentTenderStatus(evaluation: evaluation),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: POSActionButton(
                  icon: const Icon(Icons.check_circle_outline),
                  label: checkoutBehavior.paymentActionLabel(evaluation),
                  variant: POSActionButtonVariant.filled,
                  onPressed:
                      evaluation.isValid
                          ? () => _processPayment(
                            context,
                            ref,
                            evaluation,
                            checkoutBehavior,
                          )
                          : null,
                ),
              ),
              if (currentOrder.payments.isNotEmpty) ...[
                const SizedBox(height: 20),
                PaymentHistoryList(order: currentOrder),
              ],
            ],
          ),
        ),
      ),
    );
  }

  double get _currentAmount => double.tryParse(_amountController.text) ?? 0;

  void _setTenderAmount(double amount, {bool notify = true}) {
    _amountController.text = formatPaymentAmountInput(amount);
    _amountController.selection = TextSelection.collapsed(
      offset: _amountController.text.length,
    );
    if (notify) setState(() {});
  }

  Future<void> _processPayment(
    BuildContext context,
    WidgetRef ref,
    PaymentTenderEvaluation evaluation,
    POSCheckoutBehavior checkoutBehavior,
  ) async {
    final now = DateTime.now();
    final payment = Payment(
      id: 'payment_${now.millisecondsSinceEpoch}',
      amount: evaluation.amount,
      method: evaluation.method,
      timestamp: now,
      reference: 'REF${now.millisecondsSinceEpoch}',
      isComplete: true,
    );

    ref.read(currentOrderProvider.notifier).addPayment(payment);

    final shouldAutoComplete = checkoutBehavior.shouldAutoComplete(evaluation);
    final navigator = Navigator.of(context);
    final navigatorContext = navigator.context;
    final messenger = ScaffoldMessenger.of(context);
    final snackBarColor = Theme.of(context).colorScheme.primary;
    navigator.pop();

    if (shouldAutoComplete) {
      await completeAndPresentPOSOrder(
        context: navigatorContext,
        ref: ref,
        successMessage: checkoutBehavior.autoCompletedMessage,
        successColor: snackBarColor,
      );
      return;
    }

    final message =
        evaluation.changeDue > 0
            ? 'Payment recorded. Change due ${formatPOSCurrency(evaluation.changeDue)}.'
            : 'Payment of ${formatPOSCurrency(evaluation.amount)} recorded.';

    messenger.showSnackBar(
      SnackBar(content: Text(message), backgroundColor: snackBarColor),
    );
  }
}
