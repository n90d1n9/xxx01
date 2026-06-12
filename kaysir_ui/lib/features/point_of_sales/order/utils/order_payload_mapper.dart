import '../models/order.dart';
import '../models/order_fulfillment_snapshot.dart';
import '../models/order_item.dart';

extension POSOrderPayloadMapper on Order {
  Map<String, Object?> toPOSPayload() {
    return buildPOSOrderPayload(this);
  }
}

Map<String, Object?> buildPOSOrderPayload(Order order) {
  return {
    'id': order.id,
    'status': order.status,
    'createdAt': order.createdAt.toIso8601String(),
    'terminal': {
      'id': order.terminal.id,
      'name': order.terminal.name,
      'location': order.terminal.location,
    },
    'customer':
        order.customer == null
            ? null
            : {
              'id': order.customer!.id,
              'name': order.customer!.name,
              'phone': order.customer!.phone,
              'email': order.customer!.email,
              'loyaltyPoints': order.customer!.loyaltyPoints,
            },
    'fulfillment': _fulfillmentPayload(order.fulfillment),
    'items': order.items.map(_lineItemPayload).toList(growable: false),
    'payments': order.payments
        .map(
          (payment) => {
            'id': payment.id,
            'amount': payment.amount,
            'method': payment.method,
            'timestamp': payment.timestamp.toIso8601String(),
            'reference': payment.reference,
            'isComplete': payment.isComplete,
          },
        )
        .toList(growable: false),
    'promotions': order.appliedPromotions
        .map(
          (promotion) => {
            'id': promotion.id,
            'name': promotion.name,
            'code': promotion.code,
            'discountPercentage': promotion.discountPercentage,
            'discountAmount': promotion.discountAmount,
            'validUntil': promotion.validUntil.toIso8601String(),
          },
        )
        .toList(growable: false),
    'totals': {
      'subtotal': order.subtotal,
      'discountTotal': order.discountTotal,
      'total': order.total,
      'paidAmount': order.paidAmount,
      'remainingAmount': order.remainingAmount,
      'isPaid': order.isPaid,
    },
  };
}

Map<String, Object?> _lineItemPayload(OrderItem item) {
  final product = item.product;

  return {
    'id': item.id,
    'product': {
      'id': product.id,
      'name': product.name,
      'sku': product.sku,
      'barcode': product.barcode,
      'category': product.category,
      'unit': product.unit,
    },
    'quantity': item.quantity,
    'unitPrice': item.unitPrice,
    'discount': item.discount,
    'total': item.total,
  };
}

Map<String, Object?>? _fulfillmentPayload(
  OrderFulfillmentSnapshot? fulfillment,
) {
  if (fulfillment == null) return null;

  return {
    'commerceChannelId': fulfillment.commerceChannelId,
    'commerceChannelLabel': fulfillment.commerceChannelLabel,
    'fulfillmentModeKey': fulfillment.fulfillmentModeKey,
    'fulfillmentModeLabel': fulfillment.fulfillmentModeLabel,
    'contactName': fulfillment.contactName,
    'destination': fulfillment.destination,
    'tableName': fulfillment.tableName,
    'scheduleLabel': fulfillment.scheduleLabel,
    'note': fulfillment.note,
    'statusLabel': fulfillment.statusLabel,
    'summaryLabel': fulfillment.summaryLabel,
  };
}
