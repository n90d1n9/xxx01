import 'package:flutter/material.dart';

import '../models/restaurant_models.dart';
import 'restaurant_menu_signal_card.dart';
import 'restaurant_spaced_list.dart';

/// Displays menu operating signals as a spaced stack of action cards.
class RestaurantMenuSignalList extends StatelessWidget {
  const RestaurantMenuSignalList({
    super.key,
    required this.signals,
    required this.onResolveMenuRisk,
    this.focusedSignalId,
  });

  final List<RestaurantMenuSignal> signals;
  final ValueChanged<String>? onResolveMenuRisk;
  final String? focusedSignalId;

  @override
  Widget build(BuildContext context) {
    return RestaurantSpacedList<RestaurantMenuSignal>(
      items: signals,
      itemBuilder: (context, signal, index) {
        return RestaurantMenuSignalCard(
          signal: signal,
          onResolveMenuRisk: onResolveMenuRisk,
          focused: signal.id == focusedSignalId,
        );
      },
    );
  }
}
