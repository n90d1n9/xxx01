import 'package:flutter/material.dart';

import '../models/billing_route_link_navigation_model.dart';
import '../utils/billing_route_link.dart';
import 'billing_domain_navigation_policy.dart';
import 'billing_navigation_coverage_badge.dart';
import 'billing_navigation_coverage_summary.dart';
import 'billing_navigation_destination.dart';
import 'billing_navigation_dispatch_plan.dart';
import 'billing_navigation_dispatch_snapshot.dart';
import 'billing_navigation_launch_planner.dart';
import 'billing_navigation_launch_snapshot.dart';
import 'billing_navigation_launch_state.dart';

export 'billing_navigation_destination.dart';

class BillingNavigationDrawer extends StatelessWidget {
  final BillingNavigationDestinationId selectedDestination;
  final ValueChanged<BillingNavigationDestinationId> onDestinationSelected;
  final String? tenantName;
  final String? tenantSubtitle;
  final bool hasTenant;
  final List<BillingNavigationDestination>? destinations;
  final BillingDomainNavigationSet? navigationSet;
  final BillingNavigationLaunchPlanner? launchPlanner;
  final BillingNavigationLaunchSnapshot? launchSnapshot;
  final BillingNavigationDispatchSnapshot? dispatchSnapshot;
  final BillingRouteLinkNavigationModel? routeLinkNavigationModel;
  final List<BillingRouteLink>? routeLinks;
  final BillingNavigationCoverageSummary? coverageSummary;

  const BillingNavigationDrawer({
    super.key,
    required this.selectedDestination,
    required this.onDestinationSelected,
    this.tenantName,
    this.tenantSubtitle,
    this.hasTenant = true,
    this.destinations,
    this.navigationSet,
    this.launchPlanner,
    this.launchSnapshot,
    this.dispatchSnapshot,
    this.routeLinkNavigationModel,
    this.routeLinks,
    this.coverageSummary,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: BillingNavigationPanel(
        selectedDestination: selectedDestination,
        onDestinationSelected: onDestinationSelected,
        tenantName: tenantName,
        tenantSubtitle: tenantSubtitle,
        hasTenant: hasTenant,
        destinations: destinations,
        navigationSet: navigationSet,
        launchPlanner: launchPlanner,
        launchSnapshot: launchSnapshot,
        dispatchSnapshot: dispatchSnapshot,
        routeLinkNavigationModel: routeLinkNavigationModel,
        routeLinks: routeLinks,
        coverageSummary: coverageSummary,
        closeOnSelect: true,
      ),
    );
  }
}

class BillingNavigationPanel extends StatelessWidget {
  final BillingNavigationDestinationId selectedDestination;
  final ValueChanged<BillingNavigationDestinationId> onDestinationSelected;
  final String? tenantName;
  final String? tenantSubtitle;
  final bool closeOnSelect;
  final bool hasTenant;
  final List<BillingNavigationDestination>? destinations;
  final BillingDomainNavigationSet? navigationSet;
  final BillingNavigationLaunchPlanner? launchPlanner;
  final BillingNavigationLaunchSnapshot? launchSnapshot;
  final BillingNavigationDispatchSnapshot? dispatchSnapshot;
  final BillingRouteLinkNavigationModel? routeLinkNavigationModel;
  final List<BillingRouteLink>? routeLinks;
  final BillingNavigationCoverageSummary? coverageSummary;

  const BillingNavigationPanel({
    super.key,
    required this.selectedDestination,
    required this.onDestinationSelected,
    this.tenantName,
    this.tenantSubtitle,
    this.closeOnSelect = false,
    this.hasTenant = true,
    this.destinations,
    this.navigationSet,
    this.launchPlanner,
    this.launchSnapshot,
    this.dispatchSnapshot,
    this.routeLinkNavigationModel,
    this.routeLinks,
    this.coverageSummary,
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
        resolvedLaunchPlanner.destinationSnapshot(destinations: destinations);
    final resolvedDispatchSnapshot = dispatchSnapshot;
    final resolvedRouteLinkNavigationModel =
        routeLinkNavigationModel ??
        (routeLinks == null
            ? null
            : BillingRouteLinkNavigationModel(
              routeLinks: routeLinks!,
              selectedDestinationId: selectedDestination,
            ));
    final resolvedSelectedDestination =
        resolvedRouteLinkNavigationModel != null
            ? resolvedRouteLinkNavigationModel.selectedDestinationId
            : resolvedDispatchSnapshot?.selectedDestinationIdFor(
                  selectedDestination,
                ) ??
                resolvedLaunchSnapshot.selectedDestinationIdFor(
                  selectedDestination,
                );

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BillingNavigationHeader(
            tenantName: tenantName,
            tenantSubtitle: tenantSubtitle,
            coverageSummary: coverageSummary,
          ),
          Expanded(
            child:
                resolvedRouteLinkNavigationModel != null
                    ? _BillingRouteLinkNavigationList(
                      navigationModel: resolvedRouteLinkNavigationModel,
                      closeOnSelect: closeOnSelect,
                      onDestinationSelected: onDestinationSelected,
                    )
                    : resolvedDispatchSnapshot != null
                    ? _BillingDispatchNavigationList(
                      dispatchSnapshot: resolvedDispatchSnapshot,
                      selectedDestination: resolvedSelectedDestination,
                      closeOnSelect: closeOnSelect,
                      onDestinationSelected: onDestinationSelected,
                    )
                    : _BillingLaunchNavigationList(
                      launchSnapshot: resolvedLaunchSnapshot,
                      selectedDestination: resolvedSelectedDestination,
                      closeOnSelect: closeOnSelect,
                      onDestinationSelected: onDestinationSelected,
                    ),
          ),
        ],
      ),
    );
  }
}

class _BillingRouteLinkNavigationList extends StatelessWidget {
  final BillingRouteLinkNavigationModel navigationModel;
  final bool closeOnSelect;
  final ValueChanged<BillingNavigationDestinationId> onDestinationSelected;

  const _BillingRouteLinkNavigationList({
    required this.navigationModel,
    required this.closeOnSelect,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      itemCount: navigationModel.sections.length,
      itemBuilder: (context, index) {
        final section = navigationModel.sections[index];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (section.hasLabel)
              _BillingNavigationSectionLabel(label: section.label!),
            ...section.items.map((item) {
              return _BillingNavigationTile.fromRouteLink(
                item,
                selected: navigationModel.isSelected(item),
                onTap:
                    item.isEnabled
                        ? () => _selectDestination(context, item.destinationId)
                        : null,
              );
            }),
          ],
        );
      },
    );
  }

  void _selectDestination(
    BuildContext context,
    BillingNavigationDestinationId destinationId,
  ) {
    if (closeOnSelect && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    onDestinationSelected(destinationId);
  }
}

class _BillingLaunchNavigationList extends StatelessWidget {
  final BillingNavigationLaunchSnapshot launchSnapshot;
  final BillingNavigationDestinationId selectedDestination;
  final bool closeOnSelect;
  final ValueChanged<BillingNavigationDestinationId> onDestinationSelected;

  const _BillingLaunchNavigationList({
    required this.launchSnapshot,
    required this.selectedDestination,
    required this.closeOnSelect,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      itemCount: launchSnapshot.sections.length,
      itemBuilder: (context, index) {
        final section = launchSnapshot.sections[index];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (section.hasLabel)
              _BillingNavigationSectionLabel(label: section.label!),
            ...section.states.map((launchState) {
              final destination = launchState.destination;

              return _BillingNavigationTile.fromLaunchState(
                launchState,
                selected: selectedDestination == destination.id,
                onTap:
                    launchState.isEnabled
                        ? () => _selectDestination(context, destination.id)
                        : null,
              );
            }),
          ],
        );
      },
    );
  }

  void _selectDestination(
    BuildContext context,
    BillingNavigationDestinationId destinationId,
  ) {
    if (closeOnSelect && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    onDestinationSelected(destinationId);
  }
}

class _BillingDispatchNavigationList extends StatelessWidget {
  final BillingNavigationDispatchSnapshot dispatchSnapshot;
  final BillingNavigationDestinationId selectedDestination;
  final bool closeOnSelect;
  final ValueChanged<BillingNavigationDestinationId> onDestinationSelected;

  const _BillingDispatchNavigationList({
    required this.dispatchSnapshot,
    required this.selectedDestination,
    required this.closeOnSelect,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      itemCount: dispatchSnapshot.sections.length,
      itemBuilder: (context, index) {
        final section = dispatchSnapshot.sections[index];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (section.hasLabel)
              _BillingNavigationSectionLabel(label: section.label!),
            ...section.plans.map((dispatchPlan) {
              final destination = dispatchPlan.destination;

              return _BillingNavigationTile.fromDispatchPlan(
                dispatchPlan,
                selected: selectedDestination == destination.id,
                onTap:
                    dispatchPlan.isActionable
                        ? () => _selectDestination(context, destination.id)
                        : null,
              );
            }),
          ],
        );
      },
    );
  }

  void _selectDestination(
    BuildContext context,
    BillingNavigationDestinationId destinationId,
  ) {
    if (closeOnSelect && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    onDestinationSelected(destinationId);
  }
}

class _BillingNavigationHeader extends StatelessWidget {
  final String? tenantName;
  final String? tenantSubtitle;
  final BillingNavigationCoverageSummary? coverageSummary;

  const _BillingNavigationHeader({
    this.tenantName,
    this.tenantSubtitle,
    this.coverageSummary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Kaysir Billing',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            tenantName?.trim().isNotEmpty == true
                ? tenantName!
                : 'No tenant selected',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tenantSubtitle?.trim().isNotEmpty == true
                ? tenantSubtitle!
                : 'Billing, checkout, and collection workspace',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              height: 1.3,
            ),
          ),
          if (coverageSummary != null) ...[
            const SizedBox(height: 12),
            BillingNavigationCoverageBadge(summary: coverageSummary!),
          ],
        ],
      ),
    );
  }
}

class _BillingNavigationSectionLabel extends StatelessWidget {
  final String label;

  const _BillingNavigationSectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 6),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _BillingNavigationTile extends StatelessWidget {
  final BillingNavigationDestination destination;
  final String description;
  final bool enabled;
  final bool selected;
  final VoidCallback? onTap;

  const _BillingNavigationTile({
    required this.destination,
    required this.description,
    required this.enabled,
    required this.selected,
    required this.onTap,
  });

  factory _BillingNavigationTile.fromLaunchState(
    BillingNavigationLaunchState launchState, {
    required bool selected,
    required VoidCallback? onTap,
  }) {
    return _BillingNavigationTile(
      destination: launchState.destination,
      description: launchState.description,
      enabled: launchState.isEnabled,
      selected: selected,
      onTap: onTap,
    );
  }

  factory _BillingNavigationTile.fromDispatchPlan(
    BillingNavigationDispatchPlan dispatchPlan, {
    required bool selected,
    required VoidCallback? onTap,
  }) {
    return _BillingNavigationTile(
      destination: dispatchPlan.destination,
      description: dispatchPlan.description,
      enabled: dispatchPlan.isActionable,
      selected: selected,
      onTap: onTap,
    );
  }

  factory _BillingNavigationTile.fromRouteLink(
    BillingRouteLinkNavigationItem item, {
    required bool selected,
    required VoidCallback? onTap,
  }) {
    return _BillingNavigationTile(
      destination: item.destination,
      description: item.description,
      enabled: item.isEnabled,
      selected: selected,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final foreground =
        !enabled
            ? const Color(0xFF94A3B8)
            : selected
            ? const Color(0xFF1D4ED8)
            : const Color(0xFF334155);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        key: ValueKey('billing-navigation-tile-${destination.id.name}'),
        color: selected ? const Color(0xFFEFF6FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(destination.icon, color: foreground, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        destination.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: foreground,
                          fontSize: 14,
                          fontWeight:
                              selected ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color:
                              enabled
                                  ? const Color(0xFF64748B)
                                  : const Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
