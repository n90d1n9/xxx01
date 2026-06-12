import 'package:flutter/material.dart';

import '../experiences/pos_commerce_channel.dart';
import '../states/pos_layout_provider.dart';

IconData posCommerceChannelIcon(POSCommerceChannelKind kind) {
  switch (kind) {
    case POSCommerceChannelKind.inStore:
      return Icons.storefront_outlined;
    case POSCommerceChannelKind.kiosk:
      return Icons.touch_app_outlined;
    case POSCommerceChannelKind.mobilePOS:
      return Icons.phone_android_outlined;
    case POSCommerceChannelKind.webStore:
      return Icons.language_outlined;
    case POSCommerceChannelKind.marketplace:
      return Icons.store_mall_directory_outlined;
    case POSCommerceChannelKind.socialOrder:
      return Icons.chat_bubble_outline;
    case POSCommerceChannelKind.deliveryApp:
      return Icons.delivery_dining_outlined;
    case POSCommerceChannelKind.wholesale:
      return Icons.warehouse_outlined;
    case POSCommerceChannelKind.fieldSales:
      return Icons.route_outlined;
    case POSCommerceChannelKind.phoneOrder:
      return Icons.call_outlined;
    case POSCommerceChannelKind.tableService:
      return Icons.table_restaurant_outlined;
  }
}

IconData posLayoutPreferenceIcon(POSLayoutPreference preference) {
  switch (preference) {
    case POSLayoutPreference.auto:
      return Icons.auto_mode;
    case POSLayoutPreference.counter:
      return Icons.view_sidebar_outlined;
    case POSLayoutPreference.compact:
      return Icons.view_agenda_outlined;
    case POSLayoutPreference.checkout:
      return Icons.receipt_long_outlined;
  }
}
