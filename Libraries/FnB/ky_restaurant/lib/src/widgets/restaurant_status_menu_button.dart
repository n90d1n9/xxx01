import 'package:flutter/material.dart';

import '../models/restaurant_models.dart';
import 'restaurant_status_styles.dart';

/// Displays a compact status pill with an optional status-change menu.
class RestaurantStatusMenuCluster extends StatelessWidget {
  const RestaurantStatusMenuCluster({
    super.key,
    required this.status,
    this.onChanged,
    this.tooltip = 'Change status',
  });

  final RestaurantServiceStatus status;
  final ValueChanged<RestaurantServiceStatus>? onChanged;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RestaurantStatusPill(status: status, compact: true),
        if (onChanged != null)
          RestaurantStatusMenuButton(
            currentStatus: status,
            onChanged: onChanged,
            tooltip: tooltip,
          ),
      ],
    );
  }
}

/// Displays a popup menu for changing a service status.
class RestaurantStatusMenuButton extends StatelessWidget {
  const RestaurantStatusMenuButton({
    super.key,
    required this.currentStatus,
    required this.onChanged,
    this.tooltip = 'Change status',
  });

  final RestaurantServiceStatus currentStatus;
  final ValueChanged<RestaurantServiceStatus> onChanged;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<RestaurantServiceStatus>(
      tooltip: tooltip,
      icon: const Icon(Icons.tune_rounded),
      onSelected: onChanged,
      itemBuilder: (context) {
        return RestaurantServiceStatus.values
            .map(
              (status) => PopupMenuItem(
                value: status,
                enabled: status != currentStatus,
                child: Row(
                  children: [
                    RestaurantStatusPill(status: status),
                    const Spacer(),
                    if (status == currentStatus)
                      const Icon(Icons.check_rounded, size: 18),
                  ],
                ),
              ),
            )
            .toList(growable: false);
      },
    );
  }
}
