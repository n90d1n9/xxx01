import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/payroll_detail.dart';

class TaxCalculatorScreen extends ConsumerStatefulWidget {
  const TaxCalculatorScreen({super.key});

  @override
  ConsumerState<TaxCalculatorScreen> createState() =>
      _TaxCalculatorScreenState();
}

class _TaxCalculatorScreenState extends ConsumerState<TaxCalculatorScreen> {
  final _salaryController = TextEditingController();
  double _grossSalary = 0;
  PayrollDetails? _calculatedDetails;

  @override
  void dispose() {
    _salaryController.dispose();
    super.dispose();
  }

  void _calculateTax() {
    final salary = double.tryParse(_salaryController.text) ?? 0;
    if (salary > 0) {
      setState(() {
        _grossSalary = salary;
        _calculatedDetails = PayrollDetails.fromSalary(salary);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tax Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter Gross Monthly Salary',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _salaryController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Gross Salary',
                      prefix: const Text('\$ '),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _calculateTax,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Calculate'),
                    ),
                  ),
                ],
              ),
            ),
            if (_calculatedDetails != null) ...[
              const SizedBox(height: 24),
              Text(
                'Tax Breakdown for \$${_grossSalary.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildTaxBreakdownCard(_calculatedDetails!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTaxBreakdownCard(PayrollDetails details) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Container(
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
      child: Column(
        children: [
          _buildTaxRow('Federal Tax (15%)', details.federalTax, currencyFormat),
          _buildTaxRow('State Tax (5%)', details.stateTax, currencyFormat),
          _buildTaxRow(
            'Social Security (6.2%)',
            details.socialSecurity,
            currencyFormat,
          ),
          _buildTaxRow('Medicare (1.45%)', details.medicare, currencyFormat),
          _buildTaxRow('401(k) (5%)', details.retirement401k, currencyFormat),
          _buildTaxRow(
            'Health Insurance',
            details.healthInsurance,
            currencyFormat,
          ),
          const Divider(),
          _buildTaxRow(
            'Total Deductions',
            details.grossSalary - details.netSalary,
            currencyFormat,
            color: Colors.red[700],
          ),
          _buildTaxRow(
            'Net Salary',
            details.netSalary,
            currencyFormat,
            color: Colors.green[700],
            bold: true,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTaxRow(
    String label,
    double amount,
    NumberFormat formatter, {
    Color? color,
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            formatter.format(amount),
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
