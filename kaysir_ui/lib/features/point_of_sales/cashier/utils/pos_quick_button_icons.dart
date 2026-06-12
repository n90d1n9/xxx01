import 'package:flutter/material.dart';

/// Resolves stable quick-button icon keys into Material icons for the POS UI.
IconData resolvePOSQuickButtonIcon(String iconKey) {
  switch (iconKey.trim()) {
    case 'ac_unit':
      return Icons.ac_unit;
    case 'add_shopping_cart':
      return Icons.add_shopping_cart;
    case 'assignment_return':
      return Icons.assignment_return_outlined;
    case 'auto_awesome':
      return Icons.auto_awesome_outlined;
    case 'badge':
      return Icons.badge_outlined;
    case 'bakery_dining':
      return Icons.bakery_dining_outlined;
    case 'barcode_scanner':
    case 'qr_code_scanner':
      return Icons.qr_code_scanner;
    case 'call_split':
      return Icons.call_split_outlined;
    case 'category':
      return Icons.category_outlined;
    case 'coffee':
    case 'local_cafe':
      return Icons.local_cafe_outlined;
    case 'discount':
    case 'percent':
      return Icons.percent_outlined;
    case 'local_fire_department':
      return Icons.local_fire_department_outlined;
    case 'nutrition':
      return Icons.eco_outlined;
    case 'payments':
      return Icons.payments_outlined;
    case 'pause_circle':
      return Icons.pause_circle_outline;
    case 'person_search':
      return Icons.person_search_outlined;
    case 'receipt_long':
      return Icons.receipt_long_outlined;
    case 'restaurant':
      return Icons.restaurant_outlined;
    case 'room_service':
      return Icons.room_service_outlined;
    case 'scale':
      return Icons.scale_outlined;
    case 'search':
      return Icons.search;
    case 'star':
    case 'stars':
      return Icons.star_outline;
    case 'table_restaurant':
      return Icons.table_restaurant_outlined;
    case 'tapas':
      return Icons.tapas_outlined;
    case 'touch_app':
      return Icons.touch_app_outlined;
    case 'translate':
      return Icons.translate_outlined;
    case 'trending_up':
      return Icons.trending_up;
    case 'tune':
      return Icons.tune;
    default:
      return Icons.touch_app_outlined;
  }
}
