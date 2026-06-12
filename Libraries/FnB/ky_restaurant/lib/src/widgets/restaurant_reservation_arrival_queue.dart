import 'package:flutter/material.dart';

import '../models/restaurant_reservation_arrival_window.dart';
import 'arrival_window_tile.dart';
import 'restaurant_section_header.dart';
import 'restaurant_section_surface.dart';

/// Shows reservation arrival windows that can drive focused booking filters.
class RestaurantReservationArrivalQueue extends StatelessWidget {
  const RestaurantReservationArrivalQueue({
    super.key,
    required this.windows,
    this.title = 'Arrival queue',
    this.selectedWindowKind,
    this.onWindowSelected,
  });

  final List<RestaurantReservationArrivalWindow> windows;
  final String title;
  final RestaurantReservationArrivalWindowKind? selectedWindowKind;
  final ValueChanged<RestaurantReservationArrivalWindowKind>? onWindowSelected;

  @override
  Widget build(BuildContext context) {
    final orderedWindows = [
      for (final kind in RestaurantReservationArrivalWindowKind.values)
        windows.firstWhere(
          (window) => window.kind == kind,
          orElse: () => RestaurantReservationArrivalWindow(
            kind: kind,
            reservations: const [],
          ),
        ),
    ];

    return Semantics(
      container: true,
      label: _semanticLabel(title, orderedWindows),
      child: RestaurantSectionSurface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RestaurantSectionHeader(
              icon: Icons.timeline_rounded,
              title: title,
              trailingLabel: _totalCoverLabel(orderedWindows),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final tileWidth = _tileWidth(constraints.maxWidth);
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final window in orderedWindows)
                      RestaurantReservationArrivalWindowTile(
                        width: tileWidth,
                        window: window,
                        isSelected: window.kind == selectedWindowKind,
                        onSelected:
                            onWindowSelected == null || !window.hasReservations
                            ? null
                            : () => onWindowSelected!(window.kind),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

double _tileWidth(double maxWidth) {
  if (maxWidth >= 680) return (maxWidth - 32) / 5;
  if (maxWidth >= 420) return (maxWidth - 8) / 2;
  return maxWidth;
}

String _totalCoverLabel(List<RestaurantReservationArrivalWindow> windows) {
  final covers = windows
      .where(
        (window) =>
            window.kind != RestaurantReservationArrivalWindowKind.closed,
      )
      .fold<int>(0, (total, window) => total + window.covers);
  return '$covers active covers';
}

String _semanticLabel(
  String title,
  List<RestaurantReservationArrivalWindow> windows,
) {
  final windowLabels = windows.map(
    (window) =>
        '${window.kind.label}: ${window.bookingLabel}, ${window.coverLabel}',
  );
  return '$title. ${windowLabels.join('. ')}.';
}
