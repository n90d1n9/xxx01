// Format currency helper
import 'package:intl/intl.dart';

String formatCurrency(double amount) {
  return NumberFormat.currency(symbol: '\$').format(amount);
}
