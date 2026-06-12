import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../data/demo_kitchen_stations.dart';
import '../models/restaurant_models.dart';
import 'restaurant_kitchen_pressure_callout.dart';

/// Preview entry for the restaurant kitchen station pressure callout.
@Preview(name: 'Kitchen Pressure Callout', group: 'Restaurant')
Widget restaurantKitchenPressureCalloutPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: RestaurantKitchenPressureCallout(
          signal: RestaurantKitchenPressureSignal.fromStations(
            restaurantDemoKitchenStations,
          ),
          onFocusPressure: () {},
        ),
      ),
    ),
  );
}
