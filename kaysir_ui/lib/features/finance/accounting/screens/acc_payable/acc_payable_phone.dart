import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

import '../../models/invoice.dart';
import '../../models/vendor.dart';
import '../../states/invoice_filter_provider.dart';
import '../../states/invoice_provider.dart';
import '../../states/vendor_provider.dart';

// Main Screen
class AccountsPayableScreen extends ConsumerWidget {
  const AccountsPayableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Accounts Payable',
          style: TextStyle(
            color: Color(0xFF2D3748),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF2D3748),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF6366F1),
            child: Text(
              'JD',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDashboardHeader(ref),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 24),
            _buildInvoicesSection(context, ref),
            const SizedBox(height: 24),
            _buildVendorsSection(ref),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6366F1),
        child: const Icon(Icons.add),
        onPressed: () {
          // Show dialog to add new invoice
        },
      ),
    );
  }

  Widget _buildDashboardHeader(WidgetRef ref) {
    final selectedPeriod = ref.watch(selectedPeriodProvider);
    final invoices = ref.watch(payableInvoicesProvider);

    // Calculate summary data
    final totalPending = invoices
        .where((invoice) => invoice.status == InvoiceStatus.pending)
        .fold(0.0, (sum, invoice) => sum + invoice.amount);

    final totalOverdue = invoices
        .where((invoice) => invoice.status == InvoiceStatus.overdue)
        .fold(0.0, (sum, invoice) => sum + invoice.amount);

    final totalPaid = invoices
        .where((invoice) => invoice.status == InvoiceStatus.paid)
        .fold(0.0, (sum, invoice) => sum + invoice.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            DropdownButton<String>(
              value: selectedPeriod,
              items:
                  ['This Week', 'This Month', 'This Quarter', 'This Year']
                      .map(
                        (period) => DropdownMenuItem(
                          value: period,
                          child: Text(
                            period,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                if (value != null) {
                  ref.read(selectedPeriodProvider.notifier).state = value;
                }
              },
              underline: Container(),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Pending',
                '\$${totalPending.toStringAsFixed(2)}',
                const Color(0xFFFFF7ED),
                const Color(0xFFFB923C),
                Icons.access_time,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                'Overdue',
                '\$${totalOverdue.toStringAsFixed(2)}',
                const Color(0xFFFEF2F2),
                const Color(0xFFEF4444),
                Icons.warning_amber_rounded,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                'Paid',
                '\$${totalPaid.toStringAsFixed(2)}',
                const Color(0xFFF0FDF4),
                const Color(0xFF22C55E),
                Icons.check_circle_outline,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String amount,
    Color bgColor,
    Color iconColor,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionButton(
                'New Invoice',
                Icons.receipt_outlined,
                const Color(0xFF6366F1),
              ),
              _buildActionButton(
                'Add Vendor',
                Icons.business_outlined,
                const Color(0xFF8B5CF6),
              ),
              _buildActionButton(
                'Pay Bills',
                Icons.payments_outlined,
                const Color(0xFF22C55E),
              ),
              _buildActionButton(
                'Reports',
                Icons.bar_chart_outlined,
                const Color(0xFFFB923C),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }

  Widget _buildInvoicesSection(BuildContext context, WidgetRef ref) {
    final displayedInvoices = ref.watch(displayedInvoicesProvider);
    final currentFilter = ref.watch(selectedFilterProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Invoices',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildFilterChips(ref, currentFilter),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: displayedInvoices.length,
            separatorBuilder:
                (context, index) =>
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
            itemBuilder: (context, index) {
              final invoice = displayedInvoices[index];
              return _buildInvoiceItem(context, ref, invoice);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(WidgetRef ref, String currentFilter) {
    return Row(
      children: [
        _buildFilterChip(ref, 'all', currentFilter, 'All'),
        const SizedBox(width: 8),
        _buildFilterChip(ref, 'pending', currentFilter, 'Pending'),
        const SizedBox(width: 8),
        _buildFilterChip(ref, 'overdue', currentFilter, 'Overdue'),
        const SizedBox(width: 8),
        _buildFilterChip(ref, 'paid', currentFilter, 'Paid'),
      ],
    );
  }

  Widget _buildFilterChip(
    WidgetRef ref,
    String filter,
    String currentFilter,
    String label,
  ) {
    final isSelected = filter == currentFilter;

    return InkWell(
      onTap: () {
        ref.read(selectedFilterProvider.notifier).state = filter;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF6366F1) : const Color(0xFFCBD5E1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceItem(
    BuildContext context,
    WidgetRef ref,
    Invoice invoice,
  ) {
    final formatter = DateFormat('MMM dd, yyyy');

    Color getStatusColor() {
      switch (invoice.status) {
        case InvoiceStatus.pending:
          return const Color(0xFFFB923C);
        case InvoiceStatus.overdue:
          return const Color(0xFFEF4444);
        case InvoiceStatus.paid:
          return const Color(0xFF22C55E);
        default:
          return Colors.grey;
      }
    }

    String getStatusText() {
      switch (invoice.status) {
        case InvoiceStatus.pending:
          return 'Pending';
        case InvoiceStatus.overdue:
          return 'Overdue';
        case InvoiceStatus.paid:
          return 'Paid';
        case InvoiceStatus.partiallyPaid:
          return 'Partial';
        case InvoiceStatus.outstanding:
          return 'Outstanding';
        case InvoiceStatus.disputed:
          return 'Disputed';
      }
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        invoice.vendorName ?? invoice.vendorId ?? 'Unknown',
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Color(0xFF1E293B),
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            'Due: ${formatter.format(invoice.dueDate!)}',
            style: TextStyle(
              fontSize: 12,
              color:
                  invoice.status == InvoiceStatus.overdue
                      ? Colors.red
                      : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Invoice #${invoice.id}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
        ],
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '\$${invoice.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: getStatusColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              getStatusText(),
              style: TextStyle(
                fontSize: 12,
                color: getStatusColor(),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      onTap: () {
        _showInvoiceDetails(context, ref, invoice);
      },
    );
  }

  void _showInvoiceDetails(
    BuildContext context,
    WidgetRef ref,
    Invoice invoice,
  ) {
    final formatter = DateFormat('MMM dd, yyyy');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Invoice #${invoice.id}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildInvoiceDetailItem(
                'Vendor',
                invoice.vendorName ?? invoice.vendorId ?? 'Unknown',
              ),
              _buildInvoiceDetailItem(
                'Amount',
                '\$${invoice.amount.toStringAsFixed(2)}',
              ),
              _buildInvoiceDetailItem(
                'Due Date',
                formatter.format(invoice.dueDate!),
              ),
              _buildInvoiceDetailItem(
                'Status',
                invoice.status.name.toUpperCase(),
              ),
              const SizedBox(height: 24),
              if (invoice.status != InvoiceStatus.paid)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      ref
                          .read(invoicesProvider.notifier)
                          .markAsPaid(invoice.id);
                      Navigator.pop(context);
                    },
                    child: const Text('Mark as Paid'),
                  ),
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF6366F1)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // Download invoice
                  },
                  child: const Text('Download Invoice'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInvoiceDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorsSection(WidgetRef ref) {
    final vendors = ref.watch(vendorsProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Top Vendors',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: vendors.length > 3 ? 3 : vendors.length,
            separatorBuilder:
                (context, index) =>
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
            itemBuilder: (context, index) {
              final vendor = vendors[index];
              return _buildVendorItem(vendor);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVendorItem(Vendor vendor) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: Color(0xFF6366F1).withValues(alpha: 0.1),
        child: Text(
          vendor.name.substring(0, 1),
          style: const TextStyle(
            color: Color(0xFF6366F1),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        vendor.name,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Color(0xFF1E293B),
        ),
      ),
      subtitle: Text(
        vendor.email,
        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
      ),
      trailing: Text(
        '\$${vendor.totalOutstanding.toStringAsFixed(2)}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
        ),
      ),
      onTap: () {
        // Show vendor details
      },
    );
  }
}

// Main app
class APApp extends StatelessWidget {
  const APApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AP Management',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          fontFamily: 'Inter',
          scaffoldBackgroundColor: const Color(0xFFF8F9FC),
        ),
        home: const AccountsPayableScreen(),
      ),
    );
  }
}

void main() {
  runApp(const APApp());
}
