import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../billing_routes.dart';
import '../models/billing_navigation_destination_id.dart';
import '../utils/billing_route_context.dart';
import 'billing_empty_state.dart';

/// Fallback surface shown when an extension route has no registered builder.
class BillingRouteUnavailableScreen extends StatelessWidget {
  final BillingManagementRouteDefinition routeDefinition;
  final BillingRouteContext routeContext;

  const BillingRouteUnavailableScreen({
    super.key,
    required this.routeDefinition,
    this.routeContext = BillingRouteContext.empty,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: Text(routeDefinition.title),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: BillingEmptyState(
                icon: Icons.route_outlined,
                title: 'Route builder unavailable',
                message: _message,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String get _message {
    final contextLabel = [
      if (routeContext.tenantId != null) 'tenant ${routeContext.tenantId}',
      if (routeContext.businessDomain != null) routeContext.businessDomain,
    ].join(' / ');

    return [
      '${routeDefinition.name} is registered in billing navigation, but no page builder is attached yet.',
      'Route: ${routeDefinition.path}',
      if (contextLabel.isNotEmpty) 'Context: $contextLabel',
    ].join('\n');
  }
}

@Preview(name: 'Billing route unavailable')
Widget billingRouteUnavailableScreenPreview() {
  return MaterialApp(
    home: BillingRouteUnavailableScreen(
      routeDefinition: BillingManagementRouteDefinition(
        name: 'Billing Entitlements',
        routeName: 'billingEntitlements',
        title: 'Entitlements',
        subtitle: 'Access billing',
        description:
            'Review entitlement billing policies for the selected workspace.',
        icon: 'billing-entitlements',
        path: '${BillingRoutes.managementPath}/entitlements',
        destinationId: BillingNavigationDestinationId.diagnostics,
        routeIdentityKey: 'billingEntitlements',
        surface: BillingManagementRouteSurface.dashboard,
      ),
      routeContext: BillingRouteContext(
        tenantId: 'tenant-a',
        businessDomain: 'digital',
      ),
    ),
  );
}
