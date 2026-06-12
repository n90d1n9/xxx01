import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/billing_navigation_destination_id.dart';
import '../models/billing_policy_capability.dart';
import '../models/billing_policy_config.dart';
import '../models/billing_tenant_preferences.dart';
import '../states/billing_dashboard_provider.dart';
import '../states/billing_management_navigation_context_provider.dart';
import '../utils/billing_policy_presets.dart';
import '../utils/billing_route_locations.dart';
import '../utils/billing_tenant_domain_profile.dart';
import 'billing_management_navigation_scaffold.dart';
import 'billing_policy_center_content.dart';

/// Main billing policy management screen for capability and exception config.
class BillingPolicyCenterScreen extends ConsumerStatefulWidget {
  final String? initialTenantId;
  final String? initialBusinessDomain;
  final BillingPolicyConfig? initialConfig;

  const BillingPolicyCenterScreen({
    super.key,
    this.initialTenantId,
    this.initialBusinessDomain,
    this.initialConfig,
  });

  @override
  ConsumerState<BillingPolicyCenterScreen> createState() {
    return _BillingPolicyCenterScreenState();
  }
}

class _BillingPolicyCenterScreenState
    extends ConsumerState<BillingPolicyCenterScreen> {
  late BillingPolicyConfig _config;

  @override
  void initState() {
    super.initState();
    _config =
        widget.initialConfig ??
        standardBillingPolicyConfig(
          businessDomain: widget.initialBusinessDomain,
        );
  }

  @override
  Widget build(BuildContext context) {
    final selectedTenantId = ref.watch(selectedBillingTenantIdProvider);
    final effectiveTenantId = _firstNonBlank([
      widget.initialTenantId,
      selectedTenantId,
    ]);
    final effectiveBusinessDomain =
        _firstNonBlank([widget.initialBusinessDomain]) ??
        defaultBillingBusinessDomain;
    final preferences = BillingTenantPreferences(
      businessDomain: effectiveBusinessDomain,
    );
    final navigationContext = ref.watch(
      billingManagementNavigationContextProvider(
        BillingManagementNavigationContextRequest.optionalTenant(
          preferences: preferences,
          tenantId: effectiveTenantId,
          noTenantBusinessDomain: effectiveBusinessDomain,
          selectedDestinationId: BillingNavigationDestinationId.policyCenter,
          currentSurface: BillingNavigationSurface.dashboard,
        ),
      ),
    );

    return BillingManagementNavigationScaffold(
      navigationContext: navigationContext,
      backgroundColor: const Color(0xFFF7F9FC),
      selectedDestination: BillingNavigationDestinationId.policyCenter,
      tenantName:
          effectiveTenantId == null ? null : 'Tenant $effectiveTenantId',
      tenantSubtitle: '${_domainLabel(effectiveBusinessDomain)} policy profile',
      onDestinationSelected:
          (destination) => _goToDestination(
            context,
            destination,
            tenantId: effectiveTenantId,
            businessDomain: effectiveBusinessDomain,
          ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Billing Policy Center',
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: SingleChildScrollView(
        child: BillingPolicyCenterContent(
          config: _config,
          capabilities: standardBillingPolicyCapabilities(),
          businessDomainLabel: _domainLabel(effectiveBusinessDomain),
          onCapabilityChanged: _setCapabilityEnabled,
        ),
      ),
    );
  }

  void _setCapabilityEnabled(
    BillingPolicyCapabilityId capabilityId,
    bool enabled,
  ) {
    setState(() {
      _config =
          enabled
              ? _config.enable(capabilityId)
              : _config.disable(capabilityId);
    });
  }

  void _goToDestination(
    BuildContext context,
    BillingNavigationDestinationId destinationId, {
    required String? tenantId,
    required String businessDomain,
  }) {
    final location = billingRouteLocationForDestination(
      destinationId,
      tenantId: tenantId,
      businessDomain: businessDomain,
    );
    if (GoRouterState.of(context).uri.toString() != location) {
      context.go(location);
    }
  }
}

@Preview(name: 'Billing policy center screen')
Widget billingPolicyCenterScreenPreview() {
  return const ProviderScope(
    child: MaterialApp(
      home: BillingPolicyCenterScreen(initialBusinessDomain: 'construction'),
    ),
  );
}

String? _firstNonBlank(Iterable<String?> values) {
  for (final value in values) {
    final normalized = value?.trim();
    if (normalized != null && normalized.isNotEmpty) return normalized;
  }

  return null;
}

String _domainLabel(String businessDomain) {
  final words = businessDomain
      .trim()
      .split(RegExp(r'[_\s-]+'))
      .where((word) => word.isNotEmpty);
  final label = words.map(_capitalize).join(' ');
  return label.isEmpty ? 'Agnostic' : label;
}

String _capitalize(String value) {
  if (value.isEmpty) return value;
  return '${value[0].toUpperCase()}${value.substring(1)}';
}
