import 'package:flutter/material.dart';

import '../models/order_workspace_breadcrumb.dart';
import 'order_workspace_breadcrumbs.dart';
import 'order_workspace_link_actions.dart';

class OrderWorkspaceNavigationHeader extends StatelessWidget {
  final List<OrderWorkspaceBreadcrumb> breadcrumbs;
  final String currentLocation;
  final ValueChanged<String>? onOpenLocation;

  const OrderWorkspaceNavigationHeader({
    super.key,
    this.breadcrumbs = const [],
    this.currentLocation = '',
    this.onOpenLocation,
  });

  @override
  Widget build(BuildContext context) {
    final hasBreadcrumbs = breadcrumbs.any(
      (breadcrumb) => breadcrumb.label.trim().isNotEmpty,
    );
    final hasCurrentLocation = currentLocation.trim().isNotEmpty;
    if (!hasBreadcrumbs && !hasCurrentLocation) {
      return const SizedBox.shrink();
    }

    return Row(
      key: const ValueKey('order_workspace_navigation_header'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (hasBreadcrumbs)
          Expanded(
            child: OrderWorkspaceBreadcrumbs(
              items: breadcrumbs,
              onOpenLocation: onOpenLocation,
            ),
          )
        else
          const Spacer(),
        if (hasCurrentLocation) ...[
          const SizedBox(width: 8),
          OrderWorkspaceLinkActions(
            location: currentLocation,
            onOpenLocation: onOpenLocation,
          ),
        ],
      ],
    );
  }
}
