// Balance Sheet Table
import 'package:flutter/material.dart';

import '../helper/format_currency.dart';

class BalanceSheetTable extends StatelessWidget {
  final Map<String, dynamic> data;

  const BalanceSheetTable({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, double> assetsByCategory = data['assetsByCategory'];
    final Map<String, double> liabilitiesByCategory =
        data['liabilitiesByCategory'];
    final double totalAssets = data['totalAssets'];
    final double totalLiabilities = data['totalLiabilities'];
    final double equity = data['equity'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Balance Sheet',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text('As of March 15, 2025', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 24),

            // Assets section
            const Text(
              'Assets',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(1),
              },
              children: [
                ...assetsByCategory.entries
                    .map(
                      (entry) => TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(entry.key),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              formatCurrency(entry.value),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),

                TableRow(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(width: 1, color: Colors.grey.shade300),
                    ),
                  ),
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Total Assets',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        formatCurrency(totalAssets),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Liabilities section
            const Text(
              'Liabilities',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(1),
              },
              children: [
                ...liabilitiesByCategory.entries
                    .map(
                      (entry) => TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(entry.key),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              formatCurrency(entry.value),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),

                TableRow(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(width: 1, color: Colors.grey.shade300),
                    ),
                  ),
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Total Liabilities',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        formatCurrency(totalLiabilities),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Equity section
            const Text(
              'Equity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('Owner\'s Equity'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        formatCurrency(equity),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),

                TableRow(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(width: 1, color: Colors.grey.shade300),
                    ),
                  ),
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Total Equity',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        formatCurrency(equity),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Total Liabilities and Equity
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade200,
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(1),
                },
                children: [
                  TableRow(
                    children: [
                      const Text(
                        'Total Liabilities and Equity',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formatCurrency(totalLiabilities + equity),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
