import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../utils/billing_route_context.dart';
import '../utils/billing_route_locations.dart';
import 'billing_navigation_route_target.dart';

bool openBillingAppRouteTarget(
  BuildContext context,
  BillingNavigationRouteTarget routeTarget, {
  String? tenantId,
  String? businessDomain,
  BillingRouteContext routeContext = BillingRouteContext.empty,
}) {
  final location = billingRouteLocationForTarget(
    routeTarget,
    tenantId: tenantId,
    businessDomain: businessDomain,
    routeContext: routeContext,
  );
  if (location == null) return false;

  final router = GoRouter.maybeOf(context);
  if (router == null) return false;

  router.go(location);
  return true;
}
