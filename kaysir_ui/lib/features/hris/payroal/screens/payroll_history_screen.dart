import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/payroal/states/payroll_provider.dart';

import '../models/payroll_detail.dart';

class PayrollHistoryScreen extends ConsumerWidget {
  const PayrollHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedEmployee = ref.watch(selectedEmployeeProvider3);
    if (selectedEmployee == null) {
      return const Center(child: Text('Please select an employee'));
    }

    return Scaffold(
      appBar: AppBar(title: Text('${selectedEmployee.name} - Payroll History')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (context, index) {
          final month = DateTime.now().month - index;
          final year = DateTime.now().year - (month <= 0 ? 1 : 0);
          final adjustedMonth = month <= 0 ? month + 12 : month;

          final monthName = DateFormat(
            'MMMM',
          ).format(DateTime(2025, adjustedMonth, 1));

          // Generate a slightly different salary amount for historical months
          final historicalSalary =
              selectedEmployee.salary! * (0.98 + (index * 0.005));
          final payrollDetails = PayrollDetails.fromSalary(historicalSalary);

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ExpansionTile(
              title: Text(
                '$monthName $year',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Net: ${NumberFormat.currency(symbol: '\$').format(payrollDetails.netSalary)}',
                style: TextStyle(color: Colors.green[700]),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildHistoryItem(
                        'Gross Salary',
                        payrollDetails.grossSalary,
                      ),
                      _buildHistoryItem(
                        'Federal Tax',
                        payrollDetails.federalTax,
                      ),
                      _buildHistoryItem('State Tax', payrollDetails.stateTax),
                      _buildHistoryItem(
                        'Social Security',
                        payrollDetails.socialSecurity,
                      ),
                      _buildHistoryItem('Medicare', payrollDetails.medicare),
                      _buildHistoryItem(
                        '401(k)',
                        payrollDetails.retirement401k,
                      ),
                      _buildHistoryItem(
                        'Health Insurance',
                        payrollDetails.healthInsurance,
                      ),
                      const Divider(),
                      _buildHistoryItem(
                        'Net Salary',
                        payrollDetails.netSalary,
                        isNet: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryItem(String label, double amount, {bool isNet = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            NumberFormat.currency(symbol: '\$').format(amount),
            style: TextStyle(
              fontWeight: isNet ? FontWeight.bold : FontWeight.normal,
              color: isNet ? Colors.green[700] : null,
            ),
          ),
        ],
      ),
    );
  }
}
