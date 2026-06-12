import 'package:flutter/material.dart';

import '../helper/format_currency.dart';

class EnhancedCashFlowStatementTable extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isDarkMode;

  const EnhancedCashFlowStatementTable({
    super.key,
    required this.data,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final double operatingCashFlow = data['operatingCashFlow'];
    final double investingCashFlow = data['investingCashFlow'];
    final double financingCashFlow = data['financingCashFlow'];
    final double netCashFlow = data['netCashFlow'];
    final double beginningCashBalance = data['beginningCashBalance'];
    final double endingCashBalance = data['endingCashBalance'];

    final cardColor = isDarkMode ? const Color(0xFF2C2C44) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final positiveColor =
        isDarkMode ? const Color(0xFF4ECCA3) : Colors.green.shade700;
    final negativeColor =
        isDarkMode ? const Color(0xFFFF6B6B) : Colors.red.shade700;
    final operatingColor =
        isDarkMode ? const Color(0xFF4ECCA3) : const Color(0xFF2E7D32);
    final investingColor =
        isDarkMode ? const Color(0xFFFF6B6B) : const Color(0xFFD32F2F);
    final financingColor =
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
            // Operating Activities section
            Row(
              children: [
                Icon(Icons.business_center, color: operatingColor),
                const SizedBox(width: 8),
                Text(
                  'Cash Flow from Operating Activities',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildCashFlowSection(
              'Net Cash from Operations',
              operatingCashFlow,
              isDarkMode,
              textColor,
            ),

            const SizedBox(height: 32),

            // Investing Activities section
            Row(
              children: [
                Icon(Icons.trending_up, color: investingColor),
                const SizedBox(width: 8),
                Text(
                  'Cash Flow from Investing Activities',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildCashFlowSection(
              'Net Cash from Investing',
              investingCashFlow,
              isDarkMode,
              textColor,
            ),

            const SizedBox(height: 32),

            // Financing Activities section
            Row(
              children: [
                Icon(Icons.account_balance, color: financingColor),
                const SizedBox(width: 8),
                Text(
                  'Cash Flow from Financing Activities',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildCashFlowSection(
              'Net Cash from Financing',
              financingCashFlow,
              isDarkMode,
              textColor,
            ),

            const SizedBox(height: 32),

            // Cash Flow Summary
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
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Net Cash Flow',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            netCashFlow >= 0
                                ? Icons.trending_up
                                : Icons.trending_down,
                            color:
                                netCashFlow >= 0
                                    ? positiveColor
                                    : negativeColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            formatCurrency(netCashFlow),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  netCashFlow >= 0
                                      ? positiveColor
                                      : negativeColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Beginning Cash Balance',
                        style: TextStyle(color: textColor),
                      ),
                      Text(
                        formatCurrency(beginningCashBalance),
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ending Cash Balance',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        formatCurrency(endingCashBalance),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
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

  Widget _buildCashFlowSection(
    String title,
    double value,
    bool isDarkMode,
    Color textColor,
  ) {
    final Color positiveColor =
        isDarkMode ? const Color(0xFF4ECCA3) : Colors.green.shade700;
    final Color negativeColor =
        isDarkMode ? const Color(0xFFFF6B6B) : Colors.red.shade700;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF323250) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
          ),
          Text(
            formatCurrency(value),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: value >= 0 ? positiveColor : negativeColor,
            ),
          ),
        ],
      ),
    );
  }
}
