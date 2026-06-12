import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/billing_invoice.dart';
import '../models/billing_tenant_account.dart';
import '../states/billing_invoice_create_provider.dart';
import 'billing_invoice_create_panel.dart';

Future<BillingInvoice?> showBillingInvoiceCreateSheet(
  BuildContext context, {
  required BillingTenantAccount tenant,
  DateTime? initialDate,
}) {
  return showModalBottomSheet<BillingInvoice>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return Consumer(
        builder: (context, ref, child) {
          return BillingInvoiceCreatePanel(
            tenant: tenant,
            initialDate: initialDate,
            onCancel: () => Navigator.pop(sheetContext),
            onCreated: (invoice) => Navigator.pop(sheetContext, invoice),
            onCreate:
                (draft) => ref
                    .read(billingInvoiceCreateControllerProvider.notifier)
                    .createInvoice(draft),
          );
        },
      );
    },
  );
}
