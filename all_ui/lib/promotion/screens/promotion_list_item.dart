import 'package:flutter/material.dart';

import '../models/enums.dart';
import '../models/promotion.dart';

class PromotionListItem extends StatelessWidget {
  final Promotion promotion;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  const PromotionListItem({
    Key? key,
    required this.promotion,
    required this.onEdit,
    required this.onToggleStatus,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(getPromotionTitle(promotion)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Original: ${promotion.originPrice}, Promo: ${promotion.promoPrice}',
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(
                    promotion.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: promotion.isActive ? Colors.white : Colors.black87,
                    ),
                  ),
                  backgroundColor:
                      promotion.isActive ? Colors.green : Colors.grey[300],
                ),
                if (promotion.isRequirement)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Chip(
                      label: const Text('Has Requirements'),
                      backgroundColor: Colors.blue[100],
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                promotion.isActive ? Icons.toggle_on : Icons.toggle_off,
                color: promotion.isActive ? Colors.green : Colors.grey,
              ),
              onPressed: onToggleStatus,
            ),
            IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  String getPromotionTitle(Promotion promotion) {
    switch (promotion.type) {
      case PromotionType.Discount:
        return 'Discount Promotion';
      case PromotionType.Coupons:
        return 'Coupon Promotion';
      case PromotionType.Bogo:
        return 'Buy One Get One';
      case PromotionType.Bundling:
        return 'Product Bundle';
      case PromotionType.Loyalty:
        return 'Loyalty Discount';
      case PromotionType.cashback:
        return 'Cashback Offer';
      case PromotionType.Customize:
        return 'Custom Promotion';
      default:
        return 'Promotion #${promotion.id}';
    }
  }
}
