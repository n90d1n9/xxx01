import 'expense.dart';

enum RecurrenceType { daily, weekly, monthly, yearly }

enum ReportPeriod { daily, weekly, monthly, yearly }

// Report Data Model
class ReportData {
  final DateTime startDate;
  final DateTime endDate;
  final ReportPeriod period;
  final double totalExpenses;
  final int transactionCount;
  final Map<String, double> categoryBreakdown;
  final Map<String, double> paymentMethodBreakdown;
  final double averageDaily;
  final List<Expense> expenses;

  ReportData({
    required this.startDate,
    required this.endDate,
    required this.period,
    required this.totalExpenses,
    required this.transactionCount,
    required this.categoryBreakdown,
    required this.paymentMethodBreakdown,
    required this.averageDaily,
    required this.expenses,
  });
}
