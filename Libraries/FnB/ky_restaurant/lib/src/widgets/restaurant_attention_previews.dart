import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../data/restaurant_demo_snapshot.dart';
import '../services/attention_signal_builder.dart';
import 'restaurant_attention_signal_strip.dart';

/// Preview entry for the cross-FnB attention signal strip.
@Preview(name: 'Attention Signal Strip', group: 'Restaurant')
Widget restaurantAttentionSignalStripPreview() {
  final queue = const RestaurantAttentionSignalBuilder().build(
    restaurantDemoSnapshot,
  );

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: RestaurantAttentionSignalStrip(queue: queue),
      ),
    ),
  );
}
