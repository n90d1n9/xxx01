import 'package:flutter/material.dart';

import '../models/billing_business_domain_screen_registry.dart';
import 'billing_navigation_destination.dart';
import 'billing_navigation_dispatch_plan.dart';
import 'billing_navigation_dispatch_snapshot.dart';
import 'billing_navigation_launch_snapshot.dart';
import 'billing_navigation_launch_state.dart';

class BillingNavigationLaunchCenterSectionModel {
  final String? label;
  final List<BillingNavigationLaunchCenterEntry> entries;

  const BillingNavigationLaunchCenterSectionModel({
    required this.label,
    required this.entries,
  });
}

class BillingNavigationLaunchCenterEntry {
  final BillingNavigationDestination destination;
  final String description;
  final String screenKey;
  final String statusLabel;
  final String actionLabel;
  final String targetLabel;
  final String presentationLabel;
  final Color statusColor;
  final IconData statusIcon;
  final bool isActionable;
  final bool opensRoute;

  const BillingNavigationLaunchCenterEntry({
    required this.destination,
    required this.description,
    required this.screenKey,
    required this.statusLabel,
    required this.actionLabel,
    required this.targetLabel,
    required this.presentationLabel,
    required this.statusColor,
    required this.statusIcon,
    required this.isActionable,
    required this.opensRoute,
  });

  factory BillingNavigationLaunchCenterEntry.fromLaunchState(
    BillingNavigationLaunchState state,
  ) {
    final readiness = _launchReadiness(state);

    return BillingNavigationLaunchCenterEntry(
      destination: state.destination,
      description: state.description,
      screenKey: state.screenKey,
      statusLabel: readiness.label,
      actionLabel: state.isEnabled ? 'Open' : 'Blocked',
      targetLabel: _surfaceLabel(state.surface),
      presentationLabel: _presentationLabel(state.presentation),
      statusColor: readiness.color,
      statusIcon: readiness.icon,
      isActionable: state.isEnabled,
      opensRoute:
          state.presentation == BillingBusinessDomainScreenPresentation.route,
    );
  }

  factory BillingNavigationLaunchCenterEntry.fromDispatchPlan(
    BillingNavigationDispatchPlan plan,
  ) {
    final readiness = _dispatchReadiness(plan);

    return BillingNavigationLaunchCenterEntry(
      destination: plan.destination,
      description: plan.description,
      screenKey: plan.screenKey,
      statusLabel: readiness.label,
      actionLabel: plan.isActionable ? 'Open' : 'Blocked',
      targetLabel: _surfaceLabel(plan.targetSurface),
      presentationLabel: _dispatchPresentationLabel(plan),
      statusColor: readiness.color,
      statusIcon: readiness.icon,
      isActionable: plan.isActionable,
      opensRoute: plan.opensRoute,
    );
  }

  bool matches(String query) {
    if (query.isEmpty) return true;

    final normalizedQuery = query.toLowerCase();
    return [
      destination.label,
      destination.description,
      description,
      screenKey,
      statusLabel,
      targetLabel,
      presentationLabel,
    ].join(' ').toLowerCase().contains(normalizedQuery);
  }
}

List<BillingNavigationLaunchCenterSectionModel>
billingNavigationLaunchCenterSectionsFromLaunchSnapshot(
  BillingNavigationLaunchSnapshot snapshot,
) {
  return snapshot.sections
      .map((section) {
        return BillingNavigationLaunchCenterSectionModel(
          label: section.label,
          entries: section.states
              .map(BillingNavigationLaunchCenterEntry.fromLaunchState)
              .toList(growable: false),
        );
      })
      .toList(growable: false);
}

List<BillingNavigationLaunchCenterSectionModel>
billingNavigationLaunchCenterSectionsFromDispatchSnapshot(
  BillingNavigationDispatchSnapshot snapshot,
) {
  return snapshot.sections
      .map((section) {
        return BillingNavigationLaunchCenterSectionModel(
          label: section.label,
          entries: section.plans
              .map(BillingNavigationLaunchCenterEntry.fromDispatchPlan)
              .toList(growable: false),
        );
      })
      .toList(growable: false);
}

List<BillingNavigationLaunchCenterSectionModel>
billingNavigationLaunchCenterFilteredSections(
  String query,
  List<BillingNavigationLaunchCenterSectionModel> sections,
) {
  final normalizedQuery = query.trim();
  if (normalizedQuery.isEmpty) return sections;

  final filtered = <BillingNavigationLaunchCenterSectionModel>[];
  for (final section in sections) {
    final entries = section.entries
        .where((entry) => entry.matches(normalizedQuery))
        .toList(growable: false);
    if (entries.isEmpty) continue;

    filtered.add(
      BillingNavigationLaunchCenterSectionModel(
        label: section.label,
        entries: entries,
      ),
    );
  }

  return List.unmodifiable(filtered);
}

class _BillingNavigationLaunchCenterReadiness {
  final String label;
  final Color color;
  final IconData icon;

  const _BillingNavigationLaunchCenterReadiness({
    required this.label,
    required this.color,
    required this.icon,
  });
}

_BillingNavigationLaunchCenterReadiness _launchReadiness(
  BillingNavigationLaunchState state,
) {
  if (!state.isExposed) {
    return const _BillingNavigationLaunchCenterReadiness(
      label: 'Hidden',
      color: Color(0xFF64748B),
      icon: Icons.visibility_off_outlined,
    );
  }
  if (!state.hasRegisteredScreen) {
    return const _BillingNavigationLaunchCenterReadiness(
      label: 'No screen',
      color: Color(0xFFD97706),
      icon: Icons.warning_amber_outlined,
    );
  }
  if (!state.isEnabled) {
    return const _BillingNavigationLaunchCenterReadiness(
      label: 'Blocked',
      color: Color(0xFFDC2626),
      icon: Icons.block,
    );
  }

  return const _BillingNavigationLaunchCenterReadiness(
    label: 'Ready',
    color: Color(0xFF059669),
    icon: Icons.check_circle_outline,
  );
}

_BillingNavigationLaunchCenterReadiness _dispatchReadiness(
  BillingNavigationDispatchPlan plan,
) {
  switch (plan.kind) {
    case BillingNavigationDispatchKind.local:
      return const _BillingNavigationLaunchCenterReadiness(
        label: 'Local',
        color: Color(0xFF2563EB),
        icon: Icons.bolt_outlined,
      );
    case BillingNavigationDispatchKind.route:
      return const _BillingNavigationLaunchCenterReadiness(
        label: 'Route',
        color: Color(0xFF059669),
        icon: Icons.open_in_new,
      );
    case BillingNavigationDispatchKind.unavailable:
      return const _BillingNavigationLaunchCenterReadiness(
        label: 'Blocked',
        color: Color(0xFFDC2626),
        icon: Icons.block,
      );
    case BillingNavigationDispatchKind.ignored:
      return const _BillingNavigationLaunchCenterReadiness(
        label: 'Not wired',
        color: Color(0xFFD97706),
        icon: Icons.report_problem_outlined,
      );
  }
}

String _surfaceLabel(BillingNavigationSurface surface) {
  return switch (surface) {
    BillingNavigationSurface.dashboard => 'Dashboard',
    BillingNavigationSurface.productWorkspace => 'Product workspace',
    BillingNavigationSurface.tenantSelection => 'Tenant selection',
  };
}

String _presentationLabel(
  BillingBusinessDomainScreenPresentation presentation,
) {
  return switch (presentation) {
    BillingBusinessDomainScreenPresentation.embedded => 'Embedded',
    BillingBusinessDomainScreenPresentation.route => 'Route',
    BillingBusinessDomainScreenPresentation.sheet => 'Sheet',
    BillingBusinessDomainScreenPresentation.workflow => 'Workflow',
  };
}

String _dispatchPresentationLabel(BillingNavigationDispatchPlan plan) {
  switch (plan.routeIntent.presentation) {
    case BillingBusinessDomainScreenPresentation.embedded:
      return plan.isLocal ? 'Embedded' : 'Route';
    case BillingBusinessDomainScreenPresentation.route:
      return 'Route';
    case BillingBusinessDomainScreenPresentation.sheet:
      return 'Sheet';
    case BillingBusinessDomainScreenPresentation.workflow:
      return 'Workflow';
  }
}
