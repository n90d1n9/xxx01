import 'package:flutter/material.dart';

import 'billing_domain_navigation_policy.dart';
import 'billing_navigation_destination.dart';
import 'billing_navigation_dispatch_plan.dart';
import 'billing_navigation_dispatch_snapshot.dart';
import 'billing_navigation_launch_planner.dart';
import 'billing_navigation_launch_snapshot.dart';
import 'billing_navigation_launch_state.dart';

class BillingQuickActionMenu extends StatelessWidget {
  final bool hasTenant;
  final List<BillingNavigationDestinationId>? destinations;
  final BillingDomainNavigationSet? navigationSet;
  final BillingNavigationLaunchPlanner? launchPlanner;
  final BillingNavigationLaunchSnapshot? launchSnapshot;
  final BillingNavigationDispatchSnapshot? dispatchSnapshot;
  final ValueChanged<BillingNavigationDestinationId> onDestinationSelected;

  const BillingQuickActionMenu({
    super.key,
    required this.hasTenant,
    required this.onDestinationSelected,
    this.destinations,
    this.navigationSet,
    this.launchPlanner,
    this.launchSnapshot,
    this.dispatchSnapshot,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedLaunchPlanner =
        launchPlanner ??
        BillingNavigationLaunchPlanner(
          hasTenant: hasTenant,
          navigationSet: navigationSet,
        );
    final resolvedLaunchSnapshot =
        launchSnapshot ??
        resolvedLaunchPlanner.quickActionSnapshot(destinationIds: destinations);

    final resolvedDispatchSnapshot = dispatchSnapshot;

    return PopupMenuButton<BillingNavigationDestinationId>(
      key: const ValueKey('billing-quick-action-menu'),
      tooltip: 'Billing quick actions',
      icon: const Icon(Icons.bolt_outlined, color: Color(0xFF4A5568)),
      onSelected: onDestinationSelected,
      itemBuilder:
          (context) =>
              resolvedDispatchSnapshot != null
                  ? resolvedDispatchSnapshot.plans.map((dispatchPlan) {
                    return PopupMenuItem<BillingNavigationDestinationId>(
                      key: ValueKey(
                        'billing-quick-action-${dispatchPlan.destinationId.name}',
                      ),
                      value: dispatchPlan.destinationId,
                      enabled: dispatchPlan.isActionable,
                      child: _BillingQuickActionItem.fromDispatchPlan(
                        dispatchPlan,
                      ),
                    );
                  }).toList()
                  : resolvedLaunchSnapshot.states.map((launchState) {
                    return PopupMenuItem<BillingNavigationDestinationId>(
                      key: ValueKey(
                        'billing-quick-action-${launchState.destinationId.name}',
                      ),
                      value: launchState.destinationId,
                      enabled: launchState.isEnabled,
                      child: _BillingQuickActionItem.fromLaunchState(
                        launchState,
                      ),
                    );
                  }).toList(),
    );
  }
}

class _BillingQuickActionItem extends StatelessWidget {
  final BillingNavigationDestination destination;
  final String description;
  final bool enabled;

  const _BillingQuickActionItem({
    required this.destination,
    required this.description,
    required this.enabled,
  });

  factory _BillingQuickActionItem.fromLaunchState(
    BillingNavigationLaunchState launchState,
  ) {
    return _BillingQuickActionItem(
      destination: launchState.destination,
      description: launchState.description,
      enabled: launchState.isEnabled,
    );
  }

  factory _BillingQuickActionItem.fromDispatchPlan(
    BillingNavigationDispatchPlan dispatchPlan,
  ) {
    return _BillingQuickActionItem(
      destination: dispatchPlan.destination,
      description: dispatchPlan.description,
      enabled: dispatchPlan.isActionable,
    );
  }

  @override
  Widget build(BuildContext context) {
    final foreground =
        enabled ? const Color(0xFF1E293B) : const Color(0xFF94A3B8);
    final iconBackground =
        enabled ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9);

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 240),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(destination.icon, size: 20, color: foreground),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  destination.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
