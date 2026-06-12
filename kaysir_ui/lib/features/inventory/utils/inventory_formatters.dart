import 'package:intl/intl.dart';

const inventoryDefaultLocale = 'en_US';
const inventoryDefaultCurrencySymbol = r'$';

NumberFormat inventoryCurrencyFormat({
  String locale = inventoryDefaultLocale,
  String symbol = inventoryDefaultCurrencySymbol,
  int decimalDigits = 2,
}) {
  return NumberFormat.currency(
    locale: locale,
    symbol: symbol,
    decimalDigits: decimalDigits,
  );
}

NumberFormat inventoryNumberFormat({String locale = inventoryDefaultLocale}) {
  return NumberFormat.decimalPattern(locale);
}

DateFormat inventoryShortDateFormat() {
  return DateFormat('MMM d');
}

DateFormat inventoryDateFormat() {
  return DateFormat('MMM d, yyyy');
}

DateFormat inventoryIsoDateFormat() {
  return DateFormat('yyyy-MM-dd');
}

DateFormat inventoryDateTimeFormat() {
  return DateFormat('MMM d, yyyy HH:mm');
}

DateFormat inventoryTimestampFormat() {
  return DateFormat('MMM d, yyyy, HH:mm');
}

String formatInventoryCurrency(num value, {NumberFormat? formatter}) {
  return (formatter ?? inventoryCurrencyFormat()).format(value);
}

String formatInventoryNumber(num value, {NumberFormat? formatter}) {
  return (formatter ?? inventoryNumberFormat()).format(value);
}

String formatInventorySignedNumber(num value, {NumberFormat? formatter}) {
  final formatted = formatInventoryNumber(value.abs(), formatter: formatter);
  if (value > 0) return '+$formatted';
  if (value < 0) return '-$formatted';
  return formatted;
}

String formatInventoryShortDate(DateTime value) {
  return inventoryShortDateFormat().format(value);
}

String formatInventoryDate(DateTime value) {
  return inventoryDateFormat().format(value);
}

String formatInventoryIsoDate(DateTime value) {
  return inventoryIsoDateFormat().format(value);
}

String formatInventoryDateTime(DateTime value) {
  return inventoryDateTimeFormat().format(value);
}

String formatInventoryTimestamp(DateTime value) {
  return inventoryTimestampFormat().format(value);
}
