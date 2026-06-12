import 'package:flutter/material.dart';

enum RestaurantWorkspaceView {
  pulse,
  floor,
  reservations,
  menu,
  kitchen;

  String get id => switch (this) {
    RestaurantWorkspaceView.pulse => 'pulse',
    RestaurantWorkspaceView.floor => 'floor',
    RestaurantWorkspaceView.reservations => 'reservations',
    RestaurantWorkspaceView.menu => 'menu',
    RestaurantWorkspaceView.kitchen => 'kitchen',
  };

  String get title => switch (this) {
    RestaurantWorkspaceView.pulse => 'Service Pulse',
    RestaurantWorkspaceView.floor => 'Floor Plan',
    RestaurantWorkspaceView.reservations => 'Reservations',
    RestaurantWorkspaceView.menu => 'Menu Mix',
    RestaurantWorkspaceView.kitchen => 'Kitchen Flow',
  };

  String get subtitle => switch (this) {
    RestaurantWorkspaceView.pulse => 'Live shift overview',
    RestaurantWorkspaceView.floor => 'Tables and seating pressure',
    RestaurantWorkspaceView.reservations => 'Bookings and seating flow',
    RestaurantWorkspaceView.menu => 'Demand, margin, and sell-out risk',
    RestaurantWorkspaceView.kitchen => 'Station load and ticket pacing',
  };

  IconData get icon => switch (this) {
    RestaurantWorkspaceView.pulse => Icons.monitor_heart_outlined,
    RestaurantWorkspaceView.floor => Icons.table_restaurant_outlined,
    RestaurantWorkspaceView.reservations => Icons.event_available_outlined,
    RestaurantWorkspaceView.menu => Icons.restaurant_menu_outlined,
    RestaurantWorkspaceView.kitchen => Icons.soup_kitchen_outlined,
  };

  static RestaurantWorkspaceView fromId(String? id) {
    return RestaurantWorkspaceView.values.firstWhere(
      (view) => view.id == id,
      orElse: () => RestaurantWorkspaceView.pulse,
    );
  }
}
