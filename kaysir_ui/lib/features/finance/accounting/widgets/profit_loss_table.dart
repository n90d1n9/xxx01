import 'package:flutter/material.dart';

import '../helper/format_currency.dart';

class EnhancedProfitAndLossStatementTable extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isDarkMode;

  const EnhancedProfitAndLossStatementTable({
    Key? key,
    required this.data,
    this.isDarkMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, double> incomeByCategory = data['incomeByCategory'];
    final Map<String, double> expensesByCategory = data['expensesByCategory'];
    final double totalIncome = data['totalIncome'];
    final double totalExpenses = data['totalExpenses'];
    final double netIncome = data['netIncome'];

    final backgroundColor = isDarkMode ? const Color(0xFF252538) : Colors.white;
    final cardColor = isDarkMode ? const Color(0xFF2C2C44) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtextColor =
        isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;
    final borderColor =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
    final positiveColor =
        isDarkMode ? const Color(0xFF4ECCA3) : Colors.green.shade700;
    final negativeColor =
        isDarkMode ? const Color(0xFFFF6B6B) : Colors.red.shade700;

    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Income section
            Row(
              children: [
                Icon(Icons.arrow_circle_up, color: positiveColor),
                const SizedBox(width: 8),
                Text(
                  'Revenue',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color:
                    isDarkMode ? const Color(0xFF323250) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(
                    isDarkMode ? const Color(0xFF3A3A60) : Colors.grey.shade100,
                  ),
                  dataRowColor: MaterialStateProperty.all(Colors.transparent),
                  columnSpacing: 60,
                  horizontalMargin: 24,
                  columns: [
                    DataColumn(
                      label: Text(
                        'Category',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    DataColumn(
                      numeric: true,
                      label: Text(
                        'Amount',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                  rows: [
                    ...incomeByCategory.entries.map(
                      (entry) => DataRow(
                        cells: [
                          DataCell(
                            Text(entry.key, style: TextStyle(color: textColor)),
                          ),
                          DataCell(
                            Text(
                              formatCurrency(entry.value),
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataRow(
                      color: MaterialStateProperty.all(
                        isDarkMode
                            ? const Color(0xFF3A3A60)
                            : Colors.grey.shade100,
                      ),
                      cells: [
                        DataCell(
                          Text(
                            'Total Revenue',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            formatCurrency(totalIncome),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Expenses section
            Row(
              children: [
                Icon(Icons.arrow_circle_down, color: negativeColor),
                const SizedBox(width: 8),
                Text(
                  'Expenses',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color:
                    isDarkMode ? const Color(0xFF323250) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(
                    isDarkMode ? const Color(0xFF3A3A60) : Colors.grey.shade100,
                  ),
                  dataRowColor: MaterialStateProperty.all(Colors.transparent),
                  columnSpacing: 60,
                  horizontalMargin: 24,
                  columns: [
                    DataColumn(
                      label: Text(
                        'Category',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    DataColumn(
                      numeric: true,
                      label: Text(
                        'Amount',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                  rows: [
                    ...expensesByCategory.entries.map(
                      (entry) => DataRow(
                        cells: [
                          DataCell(
                            Text(entry.key, style: TextStyle(color: textColor)),
                          ),
                          DataCell(
                            Text(
                              formatCurrency(entry.value),
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataRow(
                      color: MaterialStateProperty.all(
                        isDarkMode
                            ? const Color(0xFF3A3A60)
                            : Colors.grey.shade100,
                      ),
                      cells: [
                        DataCell(
                          Text(
                            'Total Expenses',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            formatCurrency(totalExpenses),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Net Income
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color:
                    isDarkMode
                        ? const Color(0xFF394060)
                        : const Color(0xFFF0F5FA),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Net Income',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        netIncome >= 0
                            ? Icons.trending_up
                            : Icons.trending_down,
                        color: netIncome >= 0 ? positiveColor : negativeColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatCurrency(netIncome),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: netIncome >= 0 ? positiveColor : negativeColor,
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
