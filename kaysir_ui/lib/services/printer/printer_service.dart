import 'package:flutter/foundation.dart';

import '../../features/hardware/receipt/models/receipt.dart';

class PrinterService {
  static Future<void> printReceipt(Receipt receipt) async {
    // Implementation for your specific printer hardware
    final buffer = StringBuffer();

    // Header
    buffer.writeln('===================================');
    buffer.writeln('          STORE NAME');
    buffer.writeln('===================================');
    buffer.writeln('Date: ${_formatDateTime(receipt.dateTime)}');
    buffer.writeln('Receipt #: ${receipt.id}');
    buffer.writeln('Cashier: ${receipt.cashierName}');
    buffer.writeln('-----------------------------------');

    // Items
    for (final item in receipt.items) {
      buffer.writeln('${item.name}');
      buffer.writeln(
        '  ${item.quantity} x \$${item.price!.toStringAsFixed(2)}'
        '  \$${item.total.toStringAsFixed(2)}',
      );
    }

    // Totals
    buffer.writeln('-----------------------------------');
    buffer.writeln('Subtotal: \$${receipt.subtotal.toStringAsFixed(2)}');
    if (receipt.discount > 0) {
      buffer.writeln('Discount: -\$${receipt.discount.toStringAsFixed(2)}');
    }
    buffer.writeln('Tax: \$${receipt.tax.toStringAsFixed(2)}');
    buffer.writeln('Total: \$${receipt.total.toStringAsFixed(2)}');
    buffer.writeln('');
    buffer.writeln('Payment: ${receipt.paymentMethod.name.toUpperCase()}');
    buffer.writeln('===================================');
    buffer.writeln('          Thank You!');
    buffer.writeln('===================================');

    // Print the receipt (implement actual printing logic here)
    debugPrint(buffer.toString());
  }

  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month}-${dateTime.day} '
        '${dateTime.hour}:${dateTime.minute}:${dateTime.second}';
  }
}
