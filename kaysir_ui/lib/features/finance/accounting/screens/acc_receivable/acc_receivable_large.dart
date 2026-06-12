import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

import '../../helper/ar_dash_data.dart';
import '../../states/ar_dash_provider.dart';
import '../../states/customer_provider.dart';
import '../../widgets/add_invoice_dialog.dart';
import '../../widgets/ar_table.dart';
import '../../widgets/receivable_reconciliation_card.dart';

class ARDashboardScreen extends ConsumerWidget {
  const ARDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arData = ref.watch(arDashboardProvider);
    final currencyFormat = NumberFormat('#,##0.00');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts Receivable'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddInvoiceDialog(context, ref);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth =
                    constraints.maxWidth >= 960
                        ? (constraints.maxWidth - 48) / 4
                        : constraints.maxWidth >= 560
                        ? (constraints.maxWidth - 16) / 2
                        : constraints.maxWidth;

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildSummaryCard(
                      'Total Outstanding',
                      '\$${currencyFormat.format(arData.totalOutstandingAR)}',
                      Colors.blue,
                      cardWidth,
                    ),
                    _buildSummaryCard(
                      'Overdue',
                      '${arData.overdueInvoices.length} invoices',
                      Colors.red,
                      cardWidth,
                    ),
                    _buildSummaryCard(
                      'Due This Week',
                      '\$${currencyFormat.format(arData.dueSoonTotal)}',
                      Colors.orange,
                      cardWidth,
                    ),
                    _buildSummaryCard(
                      'Collection Rate',
                      '${(arData.collectionRate * 100).toStringAsFixed(1)}%',
                      Colors.green,
                      cardWidth,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            _buildAgingStrip(arData),
            const SizedBox(height: 24),
            const ReceivableReconciliationCard(),
            const SizedBox(height: 24),

            // Invoices Table
            const Text(
              'Invoices',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ArInvoicesDataTable(arData: arData),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgingStrip(ARDashboardData arData) {
    final formatter = NumberFormat('#,##0.00');
    final buckets = arData.agingBuckets;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aging Snapshot',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children:
                      buckets.entries.map((entry) {
                        final color = _agingColor(entry.key);
                        return SizedBox(
                          width: constraints.maxWidth >= 760 ? 140 : 160,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: color.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.key,
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '\$${formatter.format(entry.value)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _agingColor(String bucket) {
    switch (bucket) {
      case 'Current':
        return Colors.green;
      case '1-30':
        return Colors.orange;
      case '31-60':
        return Colors.deepOrange;
      case '61-90':
      case '90+':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    Color color,
    double width,
  ) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddInvoiceDialog(BuildContext context, WidgetRef ref) {
    final customers = ref.read(customersProvider);

    showDialog(
      context: context,
      builder: (context) {
        return AddInvoiceDialog(customers: customers);
      },
    );
  }
}
