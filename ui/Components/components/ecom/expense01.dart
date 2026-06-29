import 'package:flutter/material.dart';

class ExpenseWidget extends StatelessWidget {
  final String date;
  final String day;
  final String category;
  final String description;
  final double expense;
  final double total;

  const ExpenseWidget({
    Key? key,
    required this.date,
    required this.day,
    required this.category,
    required this.description,
    required this.expense,
    required this.total,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
          ),
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date,
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                day,
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${expense.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.red,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ExpenseTracker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ExpenseWidget(
              date: '2020.07',
              day: 'Wed',
              category: 'Social Life',
              description: 'brunch with daniel',
              expense: 0.00,
              total: 34.39,
            ),
            ExpenseWidget(
              date: '2020.07',
              day: 'Tue',
              category: 'Household',
              description: 'ikea wardrobe',
              expense: 0.00,
              total: 315.48,
            ),
            ExpenseWidget(
              date: '2020.07',
              day: 'Mon',
              category: 'Transfer',
              description: 'minimum fees',
              expense: 0.00,
              total: 80.00,
            ),
            ExpenseWidget(
              date: '2020.07',
              day: 'Fri',
              category: 'Transfer',
              description: 'HIBD -> House',
              expense: 0.00,
              total: 300.00,
            ),
          ],
        ),
      ),
    );
  }
}