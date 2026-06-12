import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_dialog_actions.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';

import '../models/vendor.dart';
import '../states/invoice_provider.dart';
import '../states/paymen_proc_provider.dart';
import '../states/vendor_provider.dart';
import '../states/vendor_statement_provider.dart';
import 'vendor_statement_components.dart';

class VendorStatementDialog extends ConsumerStatefulWidget {
  const VendorStatementDialog({super.key});

  @override
  ConsumerState<VendorStatementDialog> createState() =>
      _VendorStatementDialogState();
}

class _VendorStatementDialogState extends ConsumerState<VendorStatementDialog> {
  String? _selectedVendorId;

  @override
  Widget build(BuildContext context) {
    final vendors = ref.watch(vendorsProvider);
    _ensureSelectedVendor(vendors);

    final selectedVendor = _selectedVendor(vendors);
    final statement =
        selectedVendor == null
            ? null
            : ref
                .watch(vendorStatementServiceProvider)
                .build(
                  vendor: selectedVendor,
                  bills: ref.watch(allPayableInvoicesProvider),
                  payments: ref.watch(paymentsProvider),
                  asOf: DateTime.now(),
                );
    final currency = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Vendor Statement',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              if (vendors.isEmpty)
                const Expanded(
                  child: AppEmptyState(
                    icon: Icons.storefront_outlined,
                    title: 'No vendors configured',
                    message:
                        'Create vendors before reviewing payable statements.',
                  ),
                )
              else ...[
                AppSelectField<String>(
                  label: 'Vendor',
                  value: _selectedVendorId!,
                  icon: Icons.storefront_outlined,
                  options: [
                    for (final vendor in vendors)
                      AppSelectOption(value: vendor.id, label: vendor.name),
                  ],
                  onChanged:
                      (value) => setState(() {
                        _selectedVendorId = value;
                      }),
                ),
                const SizedBox(height: 16),
                if (statement == null)
                  const Expanded(
                    child: AppEmptyState(
                      icon: Icons.storefront_outlined,
                      title: 'Vendor unavailable',
                      message: 'Select a vendor to review statement activity.',
                    ),
                  )
                else ...[
                  VendorStatementSummaryGrid(
                    statement: statement,
                    currency: currency,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: VendorStatementLineList(
                      statement: statement,
                      currency: currency,
                    ),
                  ),
                ],
              ],
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

  void _ensureSelectedVendor(List<Vendor> vendors) {
    if (!vendors.any((vendor) => vendor.id == _selectedVendorId)) {
      _selectedVendorId = vendors.isEmpty ? null : vendors.first.id;
    }
  }

  Vendor? _selectedVendor(List<Vendor> vendors) {
    for (final vendor in vendors) {
      if (vendor.id == _selectedVendorId) {
        return vendor;
      }
    }
    return null;
  }
}
