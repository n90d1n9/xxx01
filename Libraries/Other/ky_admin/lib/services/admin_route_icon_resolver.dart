import 'package:flutter/material.dart';

import 'package:ky_core/core/features/feature_routes.dart';

IconData resolveAdminRouteIcon(FeatureRoutes route) {
  final label = '${route.title ?? ''} ${route.name ?? ''}'.toLowerCase();

  if (label.contains('dashboard')) return Icons.dashboard_outlined;
  if (label.contains('layout') || label.contains('builder')) {
    return Icons.dashboard_customize_outlined;
  }
  if (label.contains('ecommerce') || label.contains('commerce')) {
    return Icons.shopping_bag_outlined;
  }
  if (label.contains('orders')) return Icons.receipt_long_outlined;
  if (label.contains('cashier')) return Icons.point_of_sale_outlined;
  if (label.contains('billing workspaces') || label.contains('tenant')) {
    return Icons.people_outline;
  }
  if (label.contains('billing diagnostics') || label.contains('diagnostics')) {
    return Icons.health_and_safety_outlined;
  }
  if (label.contains('issue outbox') || label.contains('outbox')) {
    return Icons.outbox_outlined;
  }
  if (label.contains('create invoice')) return Icons.note_add_outlined;
  if (label.contains('cart checkout') || label.contains('checkout')) {
    return Icons.shopping_cart_outlined;
  }
  if (label.contains('billing') ||
      label.contains('invoice') ||
      label.contains('revenue')) {
    return Icons.receipt_long_outlined;
  }
  if (label.contains('inventory') || label.contains('stock')) {
    return Icons.inventory_2_outlined;
  }
  if (label.contains('product')) return Icons.sell_outlined;
  if (label.contains('command')) return Icons.rule_rounded;
  if (label.contains('project') || label.contains('gantt')) {
    return Icons.view_timeline_outlined;
  }
  if (label.contains('accounting') || label.contains('finance')) {
    return Icons.account_balance_outlined;
  }
  if (label.contains('human') ||
      label.contains('employee') ||
      label.contains('hr')) {
    return Icons.badge_outlined;
  }
  if (label.contains('login')) return Icons.login_outlined;

  return route.items.isNotEmpty ? Icons.folder_outlined : Icons.circle_outlined;
}
