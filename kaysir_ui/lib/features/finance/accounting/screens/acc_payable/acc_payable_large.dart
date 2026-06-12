// MAIN.DART
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_checkbox_row.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_filter_bar.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';

import '../../models/invoice.dart';
import '../../models/payable_aging.dart';
import '../../states/invoice_filter_provider.dart';
import '../../states/invoice_provider.dart';
import '../../states/vendor_provider.dart';
import '../../widgets/invoice_table.dart';
import '../../widgets/payable_aging_summary.dart';
import '../../widgets/payable_bill_dialog.dart';
import '../../widgets/payable_cash_forecast_card.dart';
import '../../widgets/payable_payment_run_dialog.dart';
import '../../widgets/payable_payment_run_history_dialog.dart';
import '../../widgets/payable_reconciliation_card.dart';
import '../../widgets/vendor_statement_dialog.dart';

// UI COMPONENTS
class AccountsPayableDashboard extends ConsumerWidget {
  const AccountsPayableDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalOutstanding = ref.watch(totalOutstandingProvider);
    final overdueCount = ref.watch(overdueInvoicesCountProvider);
    final upcomingDue = ref.watch(upcomingDueInvoicesProvider);
    final displayedPayables = ref.watch(payableInvoicesProvider);
    final currency = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts Payable Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Vendor Statement',
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () => _showVendorStatementDialog(context),
          ),
          IconButton(
            tooltip: 'Payment Run',
            icon: const Icon(Icons.payments_outlined),
            onPressed: () => _showPaymentRunDialog(context),
          ),
          IconButton(
            tooltip: 'Payment Run History',
            icon: const Icon(Icons.history_outlined),
            onPressed: () => _showPaymentRunHistoryDialog(context),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final tableHeight =
              (constraints.maxHeight * 0.42).clamp(360.0, 560.0).toDouble();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPayableOverview(
                  totalOutstanding: totalOutstanding,
                  overdueCount: overdueCount,
                  upcomingDueCount: upcomingDue.length,
                  displayedPayableCount: displayedPayables.length,
                  currency: currency,
                ),

                const SizedBox(height: 24),

                const PayableAgingSummaryStrip(),

                const SizedBox(height: 16),

                const PayableCashForecastCard(),

                const SizedBox(height: 16),

                const PayableReconciliationCard(),

                const SizedBox(height: 16),

                AppContentPanel(
                  title: 'Bill Controls',
                  subtitle: 'Narrow payable work by status, vendor, and aging.',
                  leadingIcon: Icons.tune_rounded,
                  child: _buildFilterSection(ref),
                ),

                const SizedBox(height: 16),

                AppContentPanel(
                  title: 'Bills',
                  subtitle:
                      'Review filtered invoices and post vendor payments.',
                  leadingIcon: Icons.receipt_long_rounded,
                  trailing: Text(
                    '${displayedPayables.length} shown',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: SizedBox(
                    height: tableHeight,
                    child: const InvoicesTable(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddInvoiceDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPayableOverview({
    required double totalOutstanding,
    required int overdueCount,
    required int upcomingDueCount,
    required int displayedPayableCount,
    required NumberFormat currency,
  }) {
    return AppMetricGrid(
      maxColumns: 3,
      metrics: [
        AppMetricGridItem(
          title: 'Total Outstanding',
          value: currency.format(totalOutstanding),
          helper: _billCountLabel(displayedPayableCount),
          icon: Icons.account_balance_wallet_outlined,
          accentColor: Colors.indigo,
        ),
        AppMetricGridItem(
          title: 'Overdue Invoices',
          value: overdueCount.toString(),
          helper: overdueCount == 0 ? 'No overdue bills' : 'Needs attention',
          icon: Icons.warning_amber_rounded,
          accentColor: overdueCount == 0 ? Colors.teal : Colors.red,
        ),
        AppMetricGridItem(
          title: 'Due Within 7 Days',
          value: upcomingDueCount.toString(),
          helper:
              upcomingDueCount == 0 ? 'No near-term due dates' : 'Plan cash',
          icon: Icons.event_available_outlined,
          accentColor: Colors.amber.shade700,
        ),
      ],
    );
  }

  Widget _buildFilterSection(WidgetRef ref) {
    final filter = ref.watch(invoiceFilterProvider);
    final vendors = ref.watch(vendorsProvider);

    return AppFilterBar(
      contained: false,
      compactBreakpoint: 900,
      trailingWidth: 220,
      filters: [
        AppCheckboxRow(
          title: 'Show Overdue Only',
          icon: Icons.schedule_outlined,
          iconBadge: true,
          contained: true,
          value: filter.showOverdueOnly,
          onChanged: (value) {
            if (value != null) {
              ref.read(invoiceFilterProvider.notifier).state = filter.copyWith(
                showOverdueOnly: value,
              );
            }
          },
        ),
        if (filter.agingBucketId != null)
          InputChip(
            avatar: const Icon(Icons.calendar_month_outlined, size: 18),
            label: Text(
              'Aging: ${PayableAgingBucketIds.labelFor(filter.agingBucketId!)}',
            ),
            onDeleted: () {
              ref.read(invoiceFilterProvider.notifier).state = filter
                  .withAgingBucket(null);
            },
          ),
      ],
      trailing: [
        AppSelectField<InvoiceStatus?>(
          label: 'Status',
          icon: Icons.fact_check_outlined,
          value: filter.status,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          options: [
            const AppSelectOption(value: null, label: 'All Statuses'),
            for (final status in InvoiceStatus.values)
              AppSelectOption(value: status, label: _formatStatus(status)),
          ],
          onChanged: (value) {
            ref.read(invoiceFilterProvider.notifier).state = InvoiceFilter(
              status: value,
              vendorId: filter.vendorId,
              showOverdueOnly: filter.showOverdueOnly,
              agingBucketId: filter.agingBucketId,
            );
          },
        ),
        AppSelectField<String?>(
          label: 'Vendor',
          icon: Icons.storefront_outlined,
          value: filter.vendorId,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          options: [
            const AppSelectOption(value: null, label: 'All Vendors'),
            for (final vendor in vendors)
              AppSelectOption(value: vendor.id, label: vendor.name),
          ],
          onChanged: (value) {
            ref.read(invoiceFilterProvider.notifier).state = InvoiceFilter(
              status: filter.status,
              vendorId: value,
              showOverdueOnly: filter.showOverdueOnly,
              agingBucketId: filter.agingBucketId,
            );
          },
        ),
        AppActionButton(
          label: 'Reset',
          icon: Icons.clear,
          variant: AppActionButtonVariant.secondary,
          height: 48,
          onPressed: () {
            ref.read(invoiceFilterProvider.notifier).state = InvoiceFilter();
          },
        ),
      ],
    );
  }

  void _showAddInvoiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const PayableBillDialog(),
    );
  }

  void _showPaymentRunDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const PayablePaymentRunDialog(),
    );
  }

  void _showPaymentRunHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const PayablePaymentRunHistoryDialog(),
    );
  }

  void _showVendorStatementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const VendorStatementDialog(),
    );
  }

  String _formatStatus(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.pending:
        return 'Pending';
      case InvoiceStatus.partiallyPaid:
        return 'Partially Paid';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.overdue:
        return 'Overdue';
      case InvoiceStatus.disputed:
        return 'Disputed';
      case InvoiceStatus.outstanding:
        return 'Outstanding';
    }
  }

  String _billCountLabel(int count) {
    return count == 1 ? '1 bill shown' : '$count bills shown';
  }
}
