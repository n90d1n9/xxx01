import 'package:intl/intl.dart';

String compactMoney(int value) {
  return NumberFormat.compactCurrency(symbol: '\$').format(value);
}
