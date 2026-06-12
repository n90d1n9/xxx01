import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../models/customer.dart';
import '../../models/invoice.dart';
import '../../states/aging_bucket_provider.dart';
import '../../states/ar_summary_provider.dart';
import '../../states/customer_provider.dart';
import '../../states/invoice_provider.dart';
import '../../widgets/invoice_detail_screen.dart';

enum _ArActivityType { invoice, payment }

class _ArActivity {
  final _ArActivityType type;
  final DateTime date;
  final double amount;
  final String invoiceId;
  final String? customerId;

  const _ArActivity({
    required this.type,
    required this.date,
    required this.amount,
    required this.invoiceId,
    this.customerId,
  });
}

class ARDashboardScreen extends ConsumerWidget {
  const ARDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arSummary = ref.watch(arSummaryProvider);
    final agingBuckets = ref.watch(agingBucketsProvider);
    final invoices =
        ref
            .watch(invoicesProvider)
            .invoices
            .where(_isReceivableInvoice)
            .toList();
    final customers = ref.watch(customersProvider);
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('AR Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh dashboard',
            onPressed: () => _refreshDashboard(ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshDashboard(ref),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            arSummary.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error: $err'),
              data:
                  (summary) => _buildSummaryCards(context, summary, formatter),
            ),
            const SizedBox(height: 24.0),
            _buildAgingCard(context, agingBuckets, formatter),
            const SizedBox(height: 24.0),
            _buildAtRiskCustomersCard(context, invoices, customers, formatter),
            const SizedBox(height: 24.0),
            _buildRecentActivityCard(context, invoices, customers, formatter),
          ],
        ),
      ),
    );
  }

  void _refreshDashboard(WidgetRef ref) {
    ref.invalidate(invoicesProvider);
    ref.invalidate(customersProvider);
    ref.invalidate(arSummaryProvider);
    ref.invalidate(agingBucketsProvider);
  }

  Widget _buildSummaryCards(
    BuildContext context,
    Map<String, double> summary,
    NumberFormat formatter,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth =
            constraints.maxWidth >= 960
                ? (constraints.maxWidth - 48) / 4
                : constraints.maxWidth >= 600
                ? (constraints.maxWidth - 16) / 2
                : constraints.maxWidth;

        return Wrap(
          spacing: 16.0,
          runSpacing: 16.0,
          children: [
            _buildSummaryCard(
              context,
              width: cardWidth,
              title: 'Total Receivable',
              value: formatter.format(summary['totalReceivable'] ?? 0),
              color: Colors.indigo,
              icon: Icons.account_balance_wallet,
            ),
            _buildSummaryCard(
              context,
              width: cardWidth,
              title: 'Overdue',
              value: formatter.format(summary['totalOverdue'] ?? 0),
              color: Colors.red,
              icon: Icons.warning_rounded,
            ),
            _buildSummaryCard(
              context,
              width: cardWidth,
              title: 'Collected',
              value: formatter.format(summary['totalPaid'] ?? 0),
              color: Colors.green,
              icon: Icons.check_circle,
            ),
            _buildSummaryCard(
              context,
              width: cardWidth,
              title: 'Collection Rate',
              value:
                  '${((summary['collectionRate'] ?? 0) * 100).toStringAsFixed(1)}%',
              color: Colors.blue,
              icon: Icons.trending_up_rounded,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required double width,
    required String title,
    required String value,
    required MaterialColor color,
    required IconData icon,
  }) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.shade100,
                child: Icon(icon, color: color.shade700),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: color.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgingCard(
    BuildContext context,
    AsyncValue<Map<String, double>> agingBuckets,
    NumberFormat formatter,
  ) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aging Analysis',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            agingBuckets.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error: $err'),
              data: (buckets) => _buildAgingChart(buckets, formatter),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgingChart(Map<String, double> buckets, NumberFormat formatter) {
    if (buckets.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('No aging data available')),
      );
    }

    final maxValue = buckets.values.fold<double>(
      0,
      (max, value) => value > max ? value : max,
    );

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxValue == 0 ? 1 : maxValue * 1.2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final bucketName = buckets.keys.elementAt(groupIndex);
                return BarTooltipItem(
                  '$bucketName\n${formatter.format(rod.toY)}',
                  const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
          titlesData: const FlTitlesData(show: true),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(
            buckets.length,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: buckets.values.elementAt(index),
                  color: _agingColor(index),
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAtRiskCustomersCard(
    BuildContext context,
    List<Invoice> invoices,
    List<Customer> customers,
    NumberFormat formatter,
  ) {
    final overdueByCustomer = <String, double>{};
    for (final invoice in invoices.where((invoice) => invoice.isOverdue)) {
      final customerId = invoice.customerId;
      if (customerId == null) {
        continue;
      }
      overdueByCustomer[customerId] =
          (overdueByCustomer[customerId] ?? 0) + invoice.remainingAmount;
    }

    final rows =
        overdueByCustomer.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'At-Risk Customers',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (rows.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No overdue customer balances',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              )
            else
              ...rows.take(5).map((entry) {
                final customerName = _customerName(customers, entry.key);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colors.red.shade50,
                    child: Icon(
                      Icons.priority_high,
                      color: Colors.red.shade700,
                    ),
                  ),
                  title: Text(customerName),
                  subtitle: const Text('Overdue receivable balance'),
                  trailing: Text(
                    formatter.format(entry.value),
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityCard(
    BuildContext context,
    List<Invoice> invoices,
    List<Customer> customers,
    NumberFormat formatter,
  ) {
    final activities = _recentActivities(invoices);

    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            if (activities.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Text(
                    'No recent activity',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activities.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  final isInvoice = activity.type == _ArActivityType.invoice;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor:
                          isInvoice ? Colors.blue[100] : Colors.green[100],
                      child: Icon(
                        isInvoice ? Icons.description : Icons.payment,
                        color: isInvoice ? Colors.blue : Colors.green,
                      ),
                    ),
                    title: Text(
                      isInvoice
                          ? 'Invoice ${activity.invoiceId} issued'
                          : 'Payment received for ${activity.invoiceId}',
                    ),
                    subtitle: Text(
                      [
                        DateFormat('MMM d, yyyy').format(activity.date),
                        if (activity.customerId != null)
                          _customerName(customers, activity.customerId!),
                      ].join(' - '),
                    ),
                    trailing: Text(
                      formatter.format(activity.amount),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isInvoice ? Colors.blue[700] : Colors.green[700],
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => InvoiceDetailScreen(
                                invoiceId: activity.invoiceId,
                              ),
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  List<_ArActivity> _recentActivities(List<Invoice> invoices) {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final activities = <_ArActivity>[];

    for (final invoice in invoices) {
      final issueDate = invoice.issueDate;
      if (issueDate != null && issueDate.isAfter(cutoff)) {
        activities.add(
          _ArActivity(
            type: _ArActivityType.invoice,
            date: issueDate,
            amount: invoice.amount,
            invoiceId: invoice.id,
            customerId: invoice.customerId,
          ),
        );
      }

      for (final payment in invoice.payments ?? const []) {
        final paymentDate = payment.paymentDate;
        if (paymentDate == null || paymentDate.isBefore(cutoff)) {
          continue;
        }
        activities.add(
          _ArActivity(
            type: _ArActivityType.payment,
            date: paymentDate,
            amount: payment.amount,
            invoiceId: invoice.id,
            customerId: invoice.customerId,
          ),
        );
      }
    }

    activities.sort((a, b) => b.date.compareTo(a.date));
    return activities.take(10).toList();
  }

  MaterialColor _agingColor(int index) {
    return switch (index) {
      0 => Colors.green,
      1 => Colors.orange,
      2 => Colors.deepOrange,
      _ => Colors.red,
    };
  }

  bool _isReceivableInvoice(Invoice invoice) {
    return invoice.customerId != null && invoice.dueDate != null;
  }

  String _customerName(List<Customer> customers, String customerId) {
    final customer = customers.firstWhere(
      (customer) => customer.id == customerId,
      orElse: () => Customer(id: '', name: 'Unknown', email: '', phone: ''),
    );
    return customer.name;
  }
}
