import 'package:flutter/material.dart';

class IncomeStatementWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Income Statement'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sample Products Co.',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Income Statement',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'For the Five Months Ended May 31, 2017',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 24),
              _buildRow('Sales', '\$100,000'),
              _buildRow('Cost of goods sold', '\$75,000'),
              _buildRow('Gross profit', '\$25,000'),
              SizedBox(height: 24),
              Text(
                'Operating expenses',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Selling expenses',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              _buildRow('Advertising expense', '2,000'),
              _buildRow('Commissions expense', '5,000', right: '7,000'),
              SizedBox(height: 8),
              Text(
                'Administrative expenses',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              _buildRow('Office supplies expense', '3,500'),
              _buildRow('Office equipment expense', '2,500', right: '6,000'),
              _buildRow('Total operating expenses', '', right: '13,000'),
              SizedBox(height: 24),
              _buildRow('Operating income', '', right: '12,000'),
              SizedBox(height: 24),
              Text(
                'Non-Operating or other',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildRow('Interest revenues', '5,000'),
              _buildRow('Gain on sale of investments', '3,000'),
              _buildRow('Interest expense', '(500)'),
              _buildRow('Loss from lawsuit', '(1,500)'),
              _buildRow('Total non-operating', '', right: '6,000'),
              SizedBox(height: 24),
              _buildRow('Net Income', '\$18,000'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String left, {String right = ''}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
          ),
        ),
        Text(
          right.isNotEmpty ? '$right' : '$left',
          style: TextStyle(
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
