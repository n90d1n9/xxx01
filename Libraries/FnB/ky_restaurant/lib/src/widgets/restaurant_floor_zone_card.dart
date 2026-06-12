import 'package:flutter/material.dart';

import '../models/restaurant_models.dart';
import 'restaurant_card_controls.dart';
import 'restaurant_card_header.dart';
import 'restaurant_mini_stat.dart';
import 'restaurant_signal_chip.dart';
import 'restaurant_status_menu_button.dart';
import 'restaurant_status_card_surface.dart';
import 'restaurant_status_styles.dart';

/// Displays one floor zone with occupancy, waitlist, and status controls.
class RestaurantFloorZoneCard extends StatelessWidget {
  const RestaurantFloorZoneCard({
    super.key,
    required this.zone,
    required this.onStatusChanged,
    this.focused = false,
  });

  final RestaurantServiceZone zone;
  final void Function(String zoneId, RestaurantServiceStatus status)?
  onStatusChanged;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final statusStyle = restaurantStatusStyle(colors, zone.status);

    return Semantics(
      container: true,
      selected: focused,
      label:
          '${zone.name}, ${zone.section}, '
          '${zone.occupiedTables} of ${zone.totalTables} tables occupied, '
          '${zone.covers} covers',
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
              title: zone.name,
              subtitle: zone.section,
              trailing: RestaurantStatusMenuCluster(
                status: zone.status,
                onChanged: onStatusChanged == null
                    ? null
                    : (status) => onStatusChanged!(zone.id, status),
                tooltip: 'Change ${zone.name} status',
              ),
            ),
            const SizedBox(height: 12),
            RestaurantProgressBar(
              value: zone.occupancyRate,
              status: zone.status,
              semanticLabel:
                  '${zone.name} occupancy, '
                  '${zone.occupiedTables} of ${zone.totalTables} tables occupied',
            ),
            const SizedBox(height: 12),
            RestaurantCardMetricRow(
              children: [
                RestaurantMiniStat(
                  icon: Icons.event_seat_outlined,
                  label: 'Tables',
                  value: '${zone.occupiedTables}/${zone.totalTables}',
                  semanticLabel:
                      '${zone.name} tables, '
                      '${zone.occupiedTables} of ${zone.totalTables} occupied',
                ),
                RestaurantMiniStat(
                  icon: Icons.groups_2_outlined,
                  label: 'Covers',
                  value: zone.covers.toString(),
                  semanticLabel: '${zone.name} covers, ${zone.covers}',
                ),
                RestaurantMiniStat(
                  icon: Icons.hourglass_bottom_outlined,
                  label: 'Waitlist',
                  value: zone.waitList.toString(),
                  semanticLabel:
                      '${zone.name} waitlist, ${zone.waitList} parties',
                ),
                RestaurantMiniStat(
                  icon: Icons.schedule_outlined,
                  label: 'Ticket',
                  value: '${zone.ticketMinutes}m',
                  semanticLabel:
                      '${zone.name} ticket time, ${zone.ticketMinutes} minutes',
                ),
              ],
            ),
            const SizedBox(height: 12),
            RestaurantCardChipRow(
              children: [
                RestaurantSignalChip(
                  icon: Icons.table_restaurant_outlined,
                  label: '${zone.availableTables} open',
                ),
                if (zone.waitList > 0)
                  RestaurantSignalChip(
                    icon: Icons.hourglass_top_rounded,
                    label: '${zone.waitList} waiting',
                    foregroundColor: statusStyle.foreground,
                    backgroundColor: statusStyle.background,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
