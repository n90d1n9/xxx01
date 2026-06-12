import '../../../point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import '../../../point_of_sales/order/models/order.dart' as pos_order;

const ecommerceOrderAllFulfillmentModesFilter = 'all_fulfillment_modes';

class OrderFulfillmentOption {
  final String key;
  final String label;

  const OrderFulfillmentOption({required this.key, required this.label});
}

bool matchesOrderFulfillmentMode(
  pos_order.Order order,
  String fulfillmentModeKey,
) {
  if (fulfillmentModeKey == ecommerceOrderAllFulfillmentModesFilter) {
    return true;
  }

  return order.fulfillment?.fulfillmentModeKey == fulfillmentModeKey;
}

List<OrderFulfillmentOption> ecommerceOrderFulfillmentOptions(
  List<pos_order.Order> orders,
) {
  final optionsByKey = <String, OrderFulfillmentOption>{};

  for (final order in orders) {
    final fulfillment = order.fulfillment;
    if (fulfillment == null || fulfillment.fulfillmentModeKey.trim().isEmpty) {
      continue;
    }

    optionsByKey.putIfAbsent(
      fulfillment.fulfillmentModeKey,
      () => OrderFulfillmentOption(
        key: fulfillment.fulfillmentModeKey,
        label:
            fulfillment.fulfillmentModeLabel.trim().isEmpty
                ? _fallbackFulfillmentLabel(fulfillment.fulfillmentModeKey)
                : fulfillment.fulfillmentModeLabel,
      ),
    );
  }

  final options =
      optionsByKey.values.toList()..sort((a, b) {
        final rankComparison = _fulfillmentRank(
          a.key,
        ).compareTo(_fulfillmentRank(b.key));
        if (rankComparison != 0) return rankComparison;
        return a.label.compareTo(b.label);
      });

  return List.unmodifiable(options);
}

String _fallbackFulfillmentLabel(String key) {
  for (final mode in POSFulfillmentMode.values) {
    if (mode.name == key) return mode.label;
  }

  return key
      .split(RegExp(r'[_\s-]+'))
      .where((segment) => segment.isNotEmpty)
      .map((segment) => '${segment[0].toUpperCase()}${segment.substring(1)}')
      .join(' ');
}

int _fulfillmentRank(String key) {
  for (var index = 0; index < POSFulfillmentMode.values.length; index += 1) {
    if (POSFulfillmentMode.values[index].name == key) return index;
  }

  return POSFulfillmentMode.values.length;
}
