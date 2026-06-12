// Cash Flow Statement Table
import 'package:flutter/material.dart';

import '../helper/format_currency.dart';

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
                          color:
                              operatingCashFlow >= 0
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
                          color:
                              investingCashFlow >= 0
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
                          color:
                              financingCashFlow >= 0
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
