import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../product/states/product_provider.dart';

class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics Dashboard')),
      body: productsAsync.when(
        data:
            (products) => FutureBuilder<Map<String, dynamic>>(
              future: ref
                  .read(analyticsServiceProvider)
                  .calculateMetrics(products),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final metrics = snapshot.data!;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Overview Cards
                      Row(
                        children: [
                          Expanded(
                            child: _MetricCard(
                              title: 'Completion Rate',
                              value: '${metrics['completionRate']}%',
                              icon: Icons.check_circle,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _MetricCard(
                              title: 'Discrepancies',
                              value: '${metrics['discrepancies']}',
                              icon: Icons.warning,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _MetricCard(
                              title: 'Low Stock Items',
                              value: '${metrics['lowStock']}',
                              icon: Icons.inventory,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _MetricCard(
                              title: 'Total Value',
                              value:
                                  '\$${metrics['totalValue'].toStringAsFixed(2)}',
                              icon: Icons.attach_money,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Category Breakdown Chart
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Category Breakdown',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 200,
                                child: PieChart(
                                  data:
                                      (metrics['categoryBreakdown']
                                              as Map<String, int>)
                                          .entries
                                          .map(
                                            (e) => {
                                              'category': e.key,
                                              'count': e.value,
                                            },
                                          )
                                          .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
