// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

import 'states/financial_provider.dart';

class FinancialStatementsScreen extends ConsumerWidget {
  const FinancialStatementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(selectedStatementTypeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Statements'),
        actions: [
          DropdownButton<String>(
            value: selectedType,
            onChanged: (value) {
              if (value != null) {
                ref.read(selectedStatementTypeProvider.notifier).state = value;
              }
            },
            items: const [
              DropdownMenuItem(
                value: 'profitAndLoss',
                child: Text('Profit & Loss'),
              ),
              DropdownMenuItem(
                value: 'balanceSheet',
                child: Text('Balance Sheet'),
              ),
              DropdownMenuItem(value: 'cashFlow', child: Text('Cash Flow')),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            // Large screen layout
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildSelectedStatement(selectedType, ref),
            );
          } else {
            // Small screen layout - could be different
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildSelectedStatement(selectedType, ref),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildSelectedStatement(String type, WidgetRef ref) {
    final controller = ref.watch(financialStatementsControllerProvider);

    switch (type) {
      case 'profitAndLoss':
        final data = controller.generateProfitAndLossStatement();
        return ProfitAndLossStatementTable(data: data);
      case 'balanceSheet':
        final data = controller.generateBalanceSheet();
        return BalanceSheetTable(data: data);
      case 'cashFlow':
        final data = controller.generateCashFlowStatement();
        return CashFlowStatementTable(data: data);
      default:
        return const Center(child: Text('Select a statement type'));
    }
  }
}

// Format currency helper
String formatCurrency(double amount) {
  return NumberFormat.currency(symbol: '\$').format(amount);
}

// Profit and Loss Statement Table
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

// Balance Sheet Table
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

// Cash Flow Statement Table
class CashFlowStatementTable extends StatelessWidget {
  final Map<String, dynamic> data;

  const CashFlowStatementTable({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final double operatingCashFlow = data['operatingCashFlow'];
    final double investingCashFlow = data['investingCashFlow'];
    final double financingCashFlow = data['financingCashFlow'];
    final double netCashFlow = data['netCashFlow'];
    final double beginningCashBalance = data['beginningCashBalance'];
    final double endingCashBalance = data['endingCashBalance'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cash Flow Statement',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'For the period ending March 15, 2025',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            // Operating Activities
            const Text(
              'Cash Flow from Operating Activities',
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
                      child: Text('Net Cash from Operations'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        formatCurrency(operatingCashFlow),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: operatingCashFlow >= 0
                              ? Colors.black
                              : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Investing Activities
            const Text(
              'Cash Flow from Investing Activities',
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
                      child: Text('Purchase of Equipment'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        formatCurrency(investingCashFlow),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: investingCashFlow >= 0
                              ? Colors.black
                              : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Financing Activities
            const Text(
              'Cash Flow from Financing Activities',
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
                      child: Text('Net Proceeds from Loans'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        formatCurrency(financingCashFlow),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: financingCashFlow >= 0
                              ? Colors.black
                              : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Summary
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
                        'Net Cash Flow',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        formatCurrency(netCashFlow),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: netCashFlow >= 0 ? Colors.black : Colors.red,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                        child: Text('Beginning Cash Balance'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                        child: Text(
                          formatCurrency(beginningCashBalance),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Ending Cash Balance',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          formatCurrency(endingCashBalance),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.right,
                        ),
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
