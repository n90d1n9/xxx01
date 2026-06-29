import 'package:flutter/material.dart';

class Income02 extends StatelessWidget {
  const Income02({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company B Income Statement'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'For Year Ended September 28, 2019 (In thousands)',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              _buildRow('Net Sales', '\$ 4,358,100'),
              _buildRow('Cost of Sales', '\$ 2,738,714'),
              const SizedBox(height: 10),
              _buildRow('Gross Profit', '\$ 1,619,386'),
              const SizedBox(height: 20),
              _buildRow('Selling and Operating Expenses', '\$ 560,430'),
              _buildRow('General and Administrative Expenses', '\$ 293,729'),
              const SizedBox(height: 10),
              _buildRow('Total Operating Expenses', '\$ 854,159'),
              const SizedBox(height: 10),
              _buildRow('Operating Income', '\$ 765,227'),
              const SizedBox(height: 20),
              _buildRow('Other Income', '\$ 960'),
              _buildRow('Gain (Loss) on Financial Instruments', '\$ 5,513'),
              _buildRow('(Loss) Gain on Foreign Currency', '(\$ 12,649)'),
              _buildRow('Interest Expense', '(\$ 18,177)'),
              const SizedBox(height: 10),
              _buildRow('Income Before Taxes', '\$ 740,874'),
              const SizedBox(height: 10),
              _buildRow('Income Tax Expense', '\$ 257,642'),
              const SizedBox(height: 10),
              _buildRow('Net Income', '\$ 483,232'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value),
      ],
    );
  }
}