import 'package:flutter/material.dart';

class IncomeStatementWidget extends StatelessWidget {
  const IncomeStatementWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Income Statement 2021-2022'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Figures USD',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              DataTable(
                columns: const [
                  DataColumn(label: Text('')),
                  DataColumn(label: Text('2021')),
                  DataColumn(label: Text('2022')),
                ],
                rows: [
                  DataRow(
                    cells: [
                      DataCell(const Text('Sales (Revenue)')),
                      DataCell(const Text('15,500,000')),
                      DataCell(const Text('14,625,000')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(const Text('Less: Cost of Goods Sold (COGS)')),
                      DataCell(const Text('(9,900,000)')),
                      DataCell(const Text('(10,500,000)')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(const Text('Gross Income')),
                      DataCell(const Text('5,600,000')),
                      DataCell(const Text('4,125,000')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(const Text('Less: Selling, General, Administrative Costs (SG&A)')),
                      DataCell(const Text('(3,300,000)')),
                      DataCell(const Text('(2,350,000)')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(const Text('Operating Income Before Depreciation (EBITDA)')),
                      DataCell(const Text('2,300,000')),
                      DataCell(const Text('1,775,000')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(const Text('Less: Depreciation, Amortization, Depletion')),
                      DataCell(const Text('(11,000)')),
                      DataCell(const Text('(10,000)')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(const Text('Operating Income (EBIT)')),
                      DataCell(const Text('2,289,000')),
                      DataCell(const Text('1,765,000')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(const Text('Less: Interest Expense')),
                      DataCell(const Text('(93,000)')),
                      DataCell(const Text('(89,000)')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(const Text('Non-operating Income')),
                      DataCell(const Text('2,196,000')),
                      DataCell(const Text('1,676,000')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(const Text('Less: Non-operating Expenses')),
                      DataCell(const Text('(42,000)')),
                      DataCell(const Text('(40,000)')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(const Text('Pretax Accounting Income')),
                      DataCell(const Text('2,154,000')),
                      DataCell(const Text('1,636,000')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(const Text('Less: Income Taxes')),
                      DataCell(const Text('(1,350,000)')),
                      DataCell(const Text('(1,240,000)')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(const Text('Income Before Extraordinary Items')),
                      DataCell(const Text('804,000')),
                      DataCell(const Text('396,000')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(const Text('Less: Preferred Stock Dividends')),
                      DataCell(const Text('(87,000)')),
                      DataCell(const Text('(85,000)')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(const Text('Income Available for Common Stockholders')),
                      DataCell(const Text('717,000')),
                      DataCell(const Text('311,000')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(const Text('Less: Extraordinary Items')),
                      DataCell(const Text('(18,000)')),
                      DataCell(const Text('(15,000)')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(const Text('Less: Discontinued Operations')),
                      DataCell(const Text('(400,000)')),
                      DataCell(const Text('(100,000)')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(const Text('Adjusted Net Income')),
                      DataCell(const Text('299,000')),
                      DataCell(const Text('196,000')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(const Text('Earnings Per Share (200,000 shares of stock)')),
                      DataCell(const Text('\$1.50')),
                      DataCell(const Text('\$0.98')),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
