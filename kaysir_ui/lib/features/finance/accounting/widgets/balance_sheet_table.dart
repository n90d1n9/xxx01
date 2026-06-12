import 'package:flutter/material.dart';

import '../helper/format_currency.dart';

class EnhancedBalanceSheetTable extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isDarkMode;

  const EnhancedBalanceSheetTable({
    Key? key,
    required this.data,
    this.isDarkMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, double> assetsByCategory = data['assetsByCategory'];
    final Map<String, double> liabilitiesByCategory =
        data['liabilitiesByCategory'];
    final double totalAssets = data['totalAssets'];
    final double totalLiabilities = data['totalLiabilities'];
    final double equity = data['equity'];

    final backgroundColor = isDarkMode ? const Color(0xFF252538) : Colors.white;
    final cardColor = isDarkMode ? const Color(0xFF2C2C44) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtextColor =
        isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;
    final borderColor =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
    final assetColor =
        isDarkMode ? const Color(0xFF4ECCA3) : const Color(0xFF2E7D32);
    final liabilityColor =
        isDarkMode ? const Color(0xFFFF6B6B) : const Color(0xFFD32F2F);
    final equityColor =
        isDarkMode ? const Color(0xFF71C0F0) : const Color(0xFF1976D2);

    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Assets section
            Row(
              children: [
                Icon(Icons.account_balance_wallet, color: assetColor),
                const SizedBox(width: 8),
                Text(
                  'Assets',
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
                    ...assetsByCategory.entries.map(
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
                            'Total Assets',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            formatCurrency(totalAssets),
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

            // Liabilities section
            Row(
              children: [
                Icon(Icons.account_balance, color: liabilityColor),
                const SizedBox(width: 8),
                Text(
                  'Liabilities',
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
                    ...liabilitiesByCategory.entries.map(
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
                            'Total Liabilities',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            formatCurrency(totalLiabilities),
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

            // Equity section
            Row(
              children: [
                Icon(Icons.equalizer, color: equityColor),
                const SizedBox(width: 8),
                Text(
                  'Equity',
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
                    DataRow(
                      cells: [
                        DataCell(
                          Text(
                            'Owner\'s Equity',
                            style: TextStyle(color: textColor),
                          ),
                        ),
                        DataCell(
                          Text(
                            formatCurrency(equity),
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
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
                            'Total Equity',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            formatCurrency(equity),
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

            // Total Liabilities and Equity
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
                    'Total Liabilities and Equity',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    formatCurrency(totalLiabilities + equity),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
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
