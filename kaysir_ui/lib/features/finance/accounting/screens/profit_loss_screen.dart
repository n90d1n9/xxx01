// Profit and Loss Statement Table
import 'package:flutter/material.dart';

import '../helper/format_currency.dart';

class ProfitAndLossStatementTable extends StatelessWidget {
  final Map<String, dynamic> data;

  const ProfitAndLossStatementTable({Key? key, required this.data})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, double> incomeByCategory = data['incomeByCategory'];
    final Map<String, double> expensesByCategory = data['expensesByCategory'];
    final double totalIncome = data['totalIncome'];
    final double totalExpenses = data['totalExpenses'];
    final double netIncome = data['netIncome'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profit and Loss Statement',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'For the period ending March 15, 2025',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            // Income section
            const Text(
              'Revenue',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(1),
              },
              children: [
                ...incomeByCategory.entries
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
                        'Total Revenue',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        formatCurrency(totalIncome),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Expenses section
            const Text(
              'Expenses',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(1),
              },
              children: [
                ...expensesByCategory.entries
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
                        'Total Expenses',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        formatCurrency(totalExpenses),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Net Income
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
                        'Net Income',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formatCurrency(netIncome),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: netIncome >= 0 ? Colors.green : Colors.red,
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
