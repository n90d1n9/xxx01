import 'package:flutter/material.dart';

import 'billing_navigation_destination_id.dart';

export 'billing_navigation_destination_id.dart';

class BillingNavigationDestination {
  final BillingNavigationDestinationId id;
  final String label;
  final String description;
  final IconData icon;
  final String? sectionLabel;
  final BillingNavigationSurface surface;
  final bool requiresTenant;
  final String disabledDescription;

  const BillingNavigationDestination({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
    this.sectionLabel,
    this.surface = BillingNavigationSurface.dashboard,
    this.requiresTenant = false,
    this.disabledDescription = 'Select a tenant first',
  });

  bool get isTenantIndependent => !requiresTenant;

  bool get opensDashboard => surface == BillingNavigationSurface.dashboard;

  bool get opensProductWorkspace =>
      surface == BillingNavigationSurface.productWorkspace;

  bool get opensTenantSelection =>
      surface == BillingNavigationSurface.tenantSelection;

  static const all = [
    BillingNavigationDestination(
      id: BillingNavigationDestinationId.dashboard,
      label: 'Dashboard',
      description: 'Balances, insights, and activity',
      icon: Icons.dashboard_outlined,
      sectionLabel: 'Workspace',
    ),
    BillingNavigationDestination(
      id: BillingNavigationDestinationId.workCenter,
      label: 'Work center',
      description: 'Unified follow-up queue',
      icon: Icons.space_dashboard_outlined,
      requiresTenant: true,
    ),
    BillingNavigationDestination(
      id: BillingNavigationDestinationId.productWorkspace,
      label: 'Products & checkout',
      description: 'Catalog, cart, and checkout',
      icon: Icons.storefront_outlined,
      surface: BillingNavigationSurface.productWorkspace,
      requiresTenant: true,
    ),
    BillingNavigationDestination(
      id: BillingNavigationDestinationId.cartCheckout,
      label: 'Cart & checkout',
      description: 'Review cart and collect payment',
      icon: Icons.shopping_cart_outlined,
      surface: BillingNavigationSurface.productWorkspace,
      requiresTenant: true,
    ),
    BillingNavigationDestination(
      id: BillingNavigationDestinationId.tenants,
      label: 'Tenants',
      description: 'Switch business workspace',
      icon: Icons.people_outline,
      surface: BillingNavigationSurface.tenantSelection,
    ),
    BillingNavigationDestination(
      id: BillingNavigationDestinationId.invoices,
      label: 'Invoices',
      description: 'Browse and filter receivables',
      icon: Icons.article_outlined,
      sectionLabel: 'Billing operations',
      requiresTenant: true,
    ),
    BillingNavigationDestination(
      id: BillingNavigationDestinationId.createInvoice,
      label: 'Create invoice',
      description: 'Issue a draft from tenant data',
      icon: Icons.note_add_outlined,
      requiresTenant: true,
    ),
    BillingNavigationDestination(
      id: BillingNavigationDestinationId.reports,
      label: 'Reports & insights',
      description: 'Cash forecast and collections',
      icon: Icons.insights_outlined,
      requiresTenant: true,
    ),
    BillingNavigationDestination(
      id: BillingNavigationDestinationId.issueOutbox,
      label: 'Issue outbox',
      description: 'Retry and audit issue commands',
      icon: Icons.outbox_outlined,
      requiresTenant: true,
    ),
    BillingNavigationDestination(
      id: BillingNavigationDestinationId.policyCenter,
      label: 'Policy center',
      description: 'Capability gates and exceptions',
      icon: Icons.policy_outlined,
      sectionLabel: 'System',
    ),
    BillingNavigationDestination(
      id: BillingNavigationDestinationId.diagnostics,
      label: 'Diagnostics',
      description: 'Module readiness and route health',
      icon: Icons.health_and_safety_outlined,
    ),
  ];

  static const quickActionIds = [
    BillingNavigationDestinationId.createInvoice,
    BillingNavigationDestinationId.invoices,
    BillingNavigationDestinationId.productWorkspace,
    BillingNavigationDestinationId.cartCheckout,
    BillingNavigationDestinationId.reports,
    BillingNavigationDestinationId.issueOutbox,
    BillingNavigationDestinationId.tenants,
  ];
}

class BillingNavigationAvailability {
  final BillingNavigationDestination destination;
  final bool hasTenant;

  const BillingNavigationAvailability({
    required this.destination,
    required this.hasTenant,
  });

  bool get isEnabled => hasTenant || destination.isTenantIndependent;

  String get description {
    return isEnabled
        ? destination.description
        : destination.disabledDescription;
  }

  String? get disabledReason {
    return isEnabled ? null : destination.disabledDescription;
  }
}

BillingNavigationDestination billingNavigationDestinationFor(
  BillingNavigationDestinationId id,
) {
  return BillingNavigationDestination.all.firstWhere(
    (destination) => destination.id == id,
  );
}

BillingNavigationSurface billingNavigationSurfaceFor(
  BillingNavigationDestinationId id,
) {
  return billingNavigationDestinationFor(id).surface;
}

BillingNavigationDestinationId billingDashboardActiveDestinationFor(
  BillingNavigationDestinationId id,
) {
  final destination = billingNavigationDestinationFor(id);
  return destination.opensDashboard
      ? id
      : BillingNavigationDestinationId.dashboard;
}

BillingNavigationDestinationId billingProductWorkspaceActiveDestinationFor(
  BillingNavigationDestinationId id,
) {
  final destination = billingNavigationDestinationFor(id);
  return destination.opensProductWorkspace
      ? id
      : BillingNavigationDestinationId.productWorkspace;
}

BillingNavigationAvailability billingNavigationAvailabilityFor(
  BillingNavigationDestinationId id, {
  required bool hasTenant,
}) {
  return BillingNavigationAvailability(
    destination: billingNavigationDestinationFor(id),
    hasTenant: hasTenant,
  );
}
