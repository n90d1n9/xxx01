import 'package:flutter/material.dart';

import '../models/restaurant_models.dart';
import 'restaurant_card_controls.dart';
import 'restaurant_card_header.dart';
import 'restaurant_mini_stat.dart';
import 'restaurant_signal_chip.dart';
import 'restaurant_status_menu_button.dart';
import 'restaurant_status_card_surface.dart';
import 'restaurant_status_styles.dart';

/// Displays one kitchen station with ticket pressure and status controls.
class RestaurantKitchenStationCard extends StatelessWidget {
  const RestaurantKitchenStationCard({
    super.key,
    required this.station,
    required this.onStatusChanged,
    this.focused = false,
  });

  final RestaurantKitchenStation station;
  final void Function(String stationId, RestaurantServiceStatus status)?
  onStatusChanged;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final statusStyle = restaurantStatusStyle(colors, station.status);
    final pressure = (station.averageFireMinutes / 24).clamp(0.0, 1.0);

    return Semantics(
      container: true,
      selected: focused,
      label: station.accessibilityLabel,
      child: RestaurantStatusCardSurface(
        statusStyle: statusStyle,
        isFocused: focused,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RestaurantCardHeader(
              icon: statusStyle.icon,
              foregroundColor: statusStyle.foreground,
              backgroundColor: statusStyle.background,
              title: station.name,
              subtitle: station.queueLeadLabel,
              trailing: RestaurantStatusMenuCluster(
                status: station.status,
                onChanged: onStatusChanged == null
                    ? null
                    : (status) => onStatusChanged!(station.id, status),
                tooltip: 'Change ${station.name} status',
              ),
            ),
            const SizedBox(height: 12),
            RestaurantProgressBar(
              value: pressure,
              status: station.status,
              semanticLabel: station.pressureAccessibilityLabel,
            ),
            const SizedBox(height: 12),
            RestaurantCardMetricRow(
              children: [
                RestaurantMiniStat(
                  icon: Icons.receipt_long_outlined,
                  label: 'Tickets',
                  value: station.ticketsInProgress.toString(),
                  semanticLabel:
                      '${station.name} tickets, ${station.ticketsInProgress}',
                ),
                RestaurantMiniStat(
                  icon: Icons.local_fire_department_outlined,
                  label: 'Fire avg',
                  value: '${station.averageFireMinutes}m',
                  semanticLabel: station.averageFireAccessibilityLabel,
                ),
              ],
            ),
            const SizedBox(height: 12),
            RestaurantCardChipRow(
              children: [
                RestaurantSignalChip(
                  icon: Icons.room_service_outlined,
                  label: station.queueLabel,
                ),
                RestaurantSignalChip(
                  icon: Icons.person_outline_rounded,
                  label: station.lead,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
