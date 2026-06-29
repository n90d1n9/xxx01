// CSV Export Service
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../models/budget_category.dart';
import '../models/expense.dart';
import '../models/payment.dart';
import '../models/report_data.dart';

class CSVExportService {
  Future<File> generateExpenseCSV(List<Expense> expenses) async {
    List<List<dynamic>> rows = [
      ['Date', 'Category', 'Amount', 'Description', 'Payment Method'],
    ];

    for (var expense in expenses) {
      rows.add([
        DateFormat('yyyy-MM-dd HH:mm').format(expense.date),
        expense.category,
        expense.amount,
        expense.description,
        _formatPaymentMethod(expense.paymentMethod),
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/expenses_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv',
    );

    await file.writeAsString(csv);
    return file;
  }

  Future<File> generateFullReport(
    ReportData report,
    List<BudgetCategory> budget,
  ) async {
    List<List<dynamic>> rows = [
      ['Household Manager Report'],
      [
        'Period',
        '${DateFormat('yyyy-MM-dd').format(report.startDate)} to ${DateFormat('yyyy-MM-dd').format(report.endDate)}',
      ],
      [''],
      ['Summary'],
      ['Total Expenses', report.totalExpenses],
      ['Transaction Count', report.transactionCount],
      ['Average Daily', report.averageDaily],
      [''],
      ['Category Breakdown'],
      ['Category', 'Amount', 'Percentage'],
    ];

    report.categoryBreakdown.forEach((category, amount) {
      final percentage = (amount / report.totalExpenses * 100).toStringAsFixed(
        1,
      );
      rows.add([category, amount, '$percentage%']);
    });

    rows.addAll([
      [''],
      ['Budget Analysis'],
      ['Category', 'Budget', 'Spent', 'Remaining', 'Status'],
    ]);

    for (var cat in budget) {
      final remaining = cat.budget - cat.spent;
      final status = cat.spent > cat.budget ? 'Over Budget' : 'Within Budget';
      rows.add([cat.name, cat.budget, cat.spent, remaining, status]);
    }

    rows.addAll([
      [''],
      ['All Transactions'],
      ['Date', 'Category', 'Amount', 'Description', 'Payment Method'],
    ]);

    for (var expense in report.expenses) {
      rows.add([
        DateFormat('yyyy-MM-dd HH:mm').format(expense.date),
        expense.category,
        expense.amount,
        expense.description,
        _formatPaymentMethod(expense.paymentMethod),
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv',
    );

    await file.writeAsString(csv);
    return file;
  }

  String _formatPaymentMethod(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.ewallet:
        return 'E-Wallet';
    }
  }
}
