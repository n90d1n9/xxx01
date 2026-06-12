import '../utils/inventory_formatters.dart';

String stockOpnameSignedQuantityLabel(int quantity) {
  return '${formatInventorySignedNumber(quantity)} units';
}
