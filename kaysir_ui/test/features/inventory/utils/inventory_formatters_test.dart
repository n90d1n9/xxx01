import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/utils/inventory_formatters.dart';

void main() {
  test('formats inventory currency with a stable default', () {
    expect(formatInventoryCurrency(1234.5), r'$1,234.50');
    expect(formatInventoryCurrency(7), r'$7.00');
  });

  test('formats inventory currency with an injected formatter', () {
    final formatter = inventoryCurrencyFormat(symbol: 'Rp ', decimalDigits: 0);

    expect(formatInventoryCurrency(12500, formatter: formatter), 'Rp 12,500');
  });

  test('formats counts and signed counts consistently', () {
    expect(formatInventoryNumber(12500), '12,500');
    expect(formatInventorySignedNumber(12500), '+12,500');
    expect(formatInventorySignedNumber(-12500), '-12,500');
    expect(formatInventorySignedNumber(0), '0');
  });

  test('formats inventory date labels used by widgets', () {
    final date = DateTime(2026, 6, 1, 14, 5);

    expect(inventoryShortDateFormat().format(date), 'Jun 1');
    expect(inventoryDateFormat().format(date), 'Jun 1, 2026');
    expect(inventoryIsoDateFormat().format(date), '2026-06-01');
    expect(inventoryDateTimeFormat().format(date), 'Jun 1, 2026 14:05');
    expect(inventoryTimestampFormat().format(date), 'Jun 1, 2026, 14:05');
    expect(formatInventoryShortDate(date), 'Jun 1');
    expect(formatInventoryDate(date), 'Jun 1, 2026');
    expect(formatInventoryIsoDate(date), '2026-06-01');
    expect(formatInventoryDateTime(date), 'Jun 1, 2026 14:05');
    expect(formatInventoryTimestamp(date), 'Jun 1, 2026, 14:05');
  });
}
