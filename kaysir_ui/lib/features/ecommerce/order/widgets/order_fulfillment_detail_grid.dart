import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../../../point_of_sales/order/models/order_fulfillment_snapshot.dart';
import '../models/order_fulfillment_details.dart';

class OrderFulfillmentDetailGrid extends StatelessWidget {
  final OrderFulfillmentSnapshot fulfillment;

  const OrderFulfillmentDetailGrid({super.key, required this.fulfillment});

  @override
  Widget build(BuildContext context) {
    final details = ecommerceOrderFulfillmentDetails(fulfillment);
    if (details.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final useColumns = constraints.maxWidth >= 520;
        final width =
            useColumns
                ? (constraints.maxWidth - POSUiTokens.gap) / 2
                : constraints.maxWidth;

        return Wrap(
          spacing: POSUiTokens.gap,
          runSpacing: POSUiTokens.gap,
          children: details
              .map(
                (detail) => SizedBox(
                  width: width,
                  child: _FulfillmentDetailRow(detail: detail),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _FulfillmentDetailRow extends StatelessWidget {
  final OrderFulfillmentDetail detail;

  const _FulfillmentDetailRow({required this.detail});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          _iconFor(detail.kind),
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            maxLines: detail.kind == OrderFulfillmentDetailKind.note ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              children: [
                TextSpan(
                  text: '${detail.label}: ',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(text: detail.value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _iconFor(OrderFulfillmentDetailKind kind) {
    return switch (kind) {
      OrderFulfillmentDetailKind.status => Icons.verified_outlined,
      OrderFulfillmentDetailKind.contact => Icons.person_outline,
      OrderFulfillmentDetailKind.destination => Icons.place_outlined,
      OrderFulfillmentDetailKind.table => Icons.table_restaurant_outlined,
      OrderFulfillmentDetailKind.schedule => Icons.event_outlined,
      OrderFulfillmentDetailKind.note => Icons.sticky_note_2_outlined,
    };
  }
}
