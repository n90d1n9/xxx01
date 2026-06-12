import 'package:flutter/material.dart';

import '../models/billing_cart_item.dart';
import '../models/billing_tenant_preferences.dart';
import '../utils/billing_cart_summary.dart';
import '../utils/billing_formatters.dart';
import 'billing_order_summary.dart';

class BillingCheckoutReview extends StatelessWidget {
  final String tenantName;
  final List<CartItem> cartItems;
  final BillingCartSummary summary;
  final BillingTenantPreferences preferences;
  final double maxItemsHeight;
  final double maxWidth;

  const BillingCheckoutReview({
    super.key,
    required this.tenantName,
    required this.cartItems,
    required this.summary,
    this.preferences = const BillingTenantPreferences(),
    this.maxItemsHeight = 220,
    this.maxWidth = 420,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TenantLine(tenantName: tenantName),
          const SizedBox(height: 16),
          const Text(
            'Selected items',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          if (cartItems.isEmpty)
            const _EmptyItemState()
          else
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var index = 0; index < cartItems.length; index++) ...[
                  if (index > 0) const Divider(height: 18),
                  _CheckoutReviewLine(
                    item: cartItems[index],
                    preferences: preferences,
                  ),
                ],
              ],
            ),
          const Divider(height: 28),
          BillingOrderSummary(
            summary: summary,
            preferences: preferences,
            title: 'Payment Summary',
          ),
        ],
      ),
    );
  }
}

class _TenantLine extends StatelessWidget {
  final String tenantName;

  const _TenantLine({required this.tenantName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.apartment_outlined,
            size: 18,
            color: Color(0xFF475569),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tenantName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutReviewLine extends StatelessWidget {
  final CartItem item;
  final BillingTenantPreferences preferences;

  const _CheckoutReviewLine({required this.item, required this.preferences});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CheckoutReviewItemDetails(item: item, preferences: preferences),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: _CheckoutReviewLineTotal(item: item, preferences: preferences),
        ),
      ],
    );
  }
}

class _CheckoutReviewItemDetails extends StatelessWidget {
  final CartItem item;
  final BillingTenantPreferences preferences;

  const _CheckoutReviewItemDetails({
    required this.item,
    required this.preferences,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.product.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${item.quantity} x ${formatBillingCurrency(item.product.price, preferences: preferences)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CheckoutReviewLineTotal extends StatelessWidget {
  final CartItem item;
  final BillingTenantPreferences preferences;

  const _CheckoutReviewLineTotal({
    required this.item,
    required this.preferences,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      formatBillingCurrency(item.total, preferences: preferences),
      style: const TextStyle(
        color: Color(0xFF1E293B),
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _EmptyItemState extends StatelessWidget {
  const _EmptyItemState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Text(
        'No items selected',
        style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
      ),
    );
  }
}
