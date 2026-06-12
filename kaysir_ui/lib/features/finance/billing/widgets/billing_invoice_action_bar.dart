import 'package:flutter/material.dart';

import '../models/billing_invoice_action.dart';

class BillingInvoiceActionBar extends StatelessWidget {
  final List<BillingInvoiceAction> actions;
  final ValueChanged<BillingInvoiceAction>? onActionSelected;

  const BillingInvoiceActionBar({
    super.key,
    required this.actions,
    this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();

    final primaryActions =
        actions
            .where(
              (action) => action.style == BillingInvoiceActionStyle.primary,
            )
            .toList();
    final secondaryActions =
        actions
            .where(
              (action) => action.style == BillingInvoiceActionStyle.secondary,
            )
            .toList();
    final orderedActions = [...primaryActions, ...secondaryActions];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 460;

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children:
                orderedActions
                    .map(
                      (action) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _InvoiceActionButton(
                          action: action,
                          onPressed: _onPressed(action),
                        ),
                      ),
                    )
                    .toList(),
          );
        }

        return Row(
          children: [
            if (primaryActions.isNotEmpty)
              Expanded(
                child: _InvoiceActionButton(
                  action: primaryActions.first,
                  onPressed: _onPressed(primaryActions.first),
                ),
              ),
            ...secondaryActions.map(
              (action) => Padding(
                padding: const EdgeInsets.only(left: 12),
                child: _InvoiceActionButton(
                  action: action,
                  onPressed: _onPressed(action),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  VoidCallback? _onPressed(BillingInvoiceAction action) {
    if (!action.enabled) return null;
    return () => onActionSelected?.call(action);
  }
}

class _InvoiceActionButton extends StatelessWidget {
  final BillingInvoiceAction action;
  final VoidCallback? onPressed;

  const _InvoiceActionButton({required this.action, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final icon = billingInvoiceActionIcon(action.type);

    if (action.style == BillingInvoiceActionStyle.primary) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(action.label),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(action.label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

IconData billingInvoiceActionIcon(BillingInvoiceActionType type) {
  switch (type) {
    case BillingInvoiceActionType.collectPayment:
      return Icons.payments_outlined;
    case BillingInvoiceActionType.sendReminder:
      return Icons.mark_email_unread_outlined;
    case BillingInvoiceActionType.download:
      return Icons.download_outlined;
  }
}
