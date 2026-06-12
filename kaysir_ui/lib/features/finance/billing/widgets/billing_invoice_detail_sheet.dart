import 'package:flutter/material.dart';

import '../models/billing_invoice_action.dart';
import '../models/billing_invoice.dart';
import '../models/billing_tenant_preferences.dart';
import 'billing_invoice_detail_panel.dart';

Future<void> showBillingInvoiceDetailSheet(
  BuildContext context, {
  required BillingInvoice invoice,
  BillingTenantPreferences preferences = const BillingTenantPreferences(),
  String? tenantName,
  ValueChanged<BillingInvoiceAction>? onActionSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return BillingInvoiceDetailPanel(
        invoice: invoice,
        preferences: preferences,
        tenantName: tenantName,
        onClose: () => Navigator.pop(sheetContext),
        onActionSelected: onActionSelected,
      );
    },
  );
}
