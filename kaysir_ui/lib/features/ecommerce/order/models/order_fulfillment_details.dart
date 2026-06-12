import '../../../point_of_sales/order/models/order_fulfillment_snapshot.dart';

enum OrderFulfillmentDetailKind {
  status,
  contact,
  destination,
  table,
  schedule,
  note,
}

class OrderFulfillmentDetail {
  final OrderFulfillmentDetailKind kind;
  final String label;
  final String value;

  const OrderFulfillmentDetail({
    required this.kind,
    required this.label,
    required this.value,
  });
}

List<OrderFulfillmentDetail> ecommerceOrderFulfillmentDetails(
  OrderFulfillmentSnapshot fulfillment,
) {
  final details = <OrderFulfillmentDetail>[
    _detail(
      OrderFulfillmentDetailKind.status,
      'Status',
      fulfillment.statusLabel,
    ),
    _detail(
      OrderFulfillmentDetailKind.contact,
      'Contact',
      fulfillment.contactName,
    ),
    _detail(
      OrderFulfillmentDetailKind.destination,
      'Destination',
      fulfillment.destination,
    ),
    _detail(OrderFulfillmentDetailKind.table, 'Table', fulfillment.tableName),
    _detail(
      OrderFulfillmentDetailKind.schedule,
      'Schedule',
      fulfillment.scheduleLabel,
    ),
    _detail(OrderFulfillmentDetailKind.note, 'Note', fulfillment.note),
  ].where((detail) => detail.value.trim().isNotEmpty).toList(growable: false);

  return List.unmodifiable(details);
}

OrderFulfillmentDetail _detail(
  OrderFulfillmentDetailKind kind,
  String label,
  String value,
) {
  return OrderFulfillmentDetail(kind: kind, label: label, value: value.trim());
}
