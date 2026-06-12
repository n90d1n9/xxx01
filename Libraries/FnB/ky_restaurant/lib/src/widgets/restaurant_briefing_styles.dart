import 'package:flutter/material.dart';

import '../models/restaurant_operational_briefing.dart';

IconData restaurantBriefingCategoryIcon(RestaurantBriefingCategory category) {
  return switch (category) {
    RestaurantBriefingCategory.overview => Icons.monitor_heart_outlined,
    RestaurantBriefingCategory.floor => Icons.table_restaurant_outlined,
    RestaurantBriefingCategory.reservations => Icons.event_available_outlined,
    RestaurantBriefingCategory.kitchen => Icons.soup_kitchen_outlined,
    RestaurantBriefingCategory.menu => Icons.restaurant_menu_outlined,
    RestaurantBriefingCategory.task => Icons.task_alt_outlined,
  };
}
