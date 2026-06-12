import 'package:flutter/material.dart';

import '../models/billing_business_domain_screen_registry.dart';
import '../models/billing_invoice_tax_mode.dart';
import '../widgets/billing_diagnostics_section_profile.dart';
import '../widgets/billing_release_gate_lane_target.dart';
import '../widgets/billing_release_workspace_profile.dart';
import '../widgets/diagnostics_release_profile_saved_view.dart';
import '../widgets/diagnostics_release_profile_saved_view_registry.dart';
import '../widgets/release_profile_status_filter.dart';
import '../widgets/standard_billing_diagnostics_section_profiles.dart';
import '../widgets/standard_release_workspace_profiles.dart';
import 'billing_business_domain_modules.dart';
import 'billing_business_domain_pack.dart';
import 'billing_release_gate.dart';

BillingBusinessDomainPack commerceBillingDomainPack({
  double taxRate = 0,
  BillingInvoiceTaxMode taxMode = BillingInvoiceTaxMode.exclusive,
  BillingBusinessDomainScreenRegistry? screenRegistry,
  BillingDiagnosticsSectionProfile? diagnosticsProfile,
  BillingReleaseWorkspaceProfile? releaseWorkspaceProfile,
  BillingDiagnosticsReleaseProfileSavedViewProfile?
  releaseProfileSavedViewProfile,
  Iterable<BillingReleaseGateLane> releaseGateLanes = const [],
  Iterable<BillingReleaseGateLaneTarget> releaseGateLaneTargets = const [],
}) {
  return BillingBusinessDomainPack(
    module: commerceBillingDomainModule(
      taxRate: taxRate,
      taxMode: taxMode,
      screenRegistry: screenRegistry,
    ),
    diagnosticsProfile: diagnosticsProfile,
    releaseWorkspaceProfile:
        releaseWorkspaceProfile ??
        _standardReleaseWorkspaceProfileForDomain('commerce'),
    releaseProfileSavedViewProfile: releaseProfileSavedViewProfile,
    releaseGateLanes: releaseGateLanes,
    releaseGateLaneTargets: releaseGateLaneTargets,
  );
}

BillingBusinessDomainPack constructionBillingDomainPack({
  double taxRate = 0,
  BillingInvoiceTaxMode taxMode = BillingInvoiceTaxMode.exclusive,
  BillingBusinessDomainScreenRegistry? screenRegistry,
  BillingDiagnosticsSectionProfile? diagnosticsProfile,
  BillingReleaseWorkspaceProfile? releaseWorkspaceProfile,
  BillingDiagnosticsReleaseProfileSavedViewProfile?
  releaseProfileSavedViewProfile,
  Iterable<BillingReleaseGateLane> releaseGateLanes = const [],
  Iterable<BillingReleaseGateLaneTarget> releaseGateLaneTargets = const [],
}) {
  return BillingBusinessDomainPack(
    module: constructionBillingDomainModule(
      taxRate: taxRate,
      taxMode: taxMode,
      screenRegistry: screenRegistry,
    ),
    diagnosticsProfile:
        diagnosticsProfile ??
        _standardDiagnosticsProfileForDomain('construction'),
    releaseWorkspaceProfile:
        releaseWorkspaceProfile ??
        _standardReleaseWorkspaceProfileForDomain('construction'),
    releaseProfileSavedViewProfile:
        releaseProfileSavedViewProfile ??
        _constructionReleaseProfileSavedViewProfile,
    releaseGateLanes: releaseGateLanes,
    releaseGateLaneTargets: releaseGateLaneTargets,
  );
}

BillingBusinessDomainPack digitalSubscriptionBillingDomainPack({
  double taxRate = 0,
  BillingInvoiceTaxMode taxMode = BillingInvoiceTaxMode.exclusive,
  BillingBusinessDomainScreenRegistry? screenRegistry,
  BillingDiagnosticsSectionProfile? diagnosticsProfile,
  BillingReleaseWorkspaceProfile? releaseWorkspaceProfile,
  BillingDiagnosticsReleaseProfileSavedViewProfile?
  releaseProfileSavedViewProfile,
  Iterable<BillingReleaseGateLane> releaseGateLanes = const [],
  Iterable<BillingReleaseGateLaneTarget> releaseGateLaneTargets = const [],
}) {
  return BillingBusinessDomainPack(
    id: 'digital',
    module: digitalSubscriptionBillingDomainModule(
      taxRate: taxRate,
      taxMode: taxMode,
      screenRegistry: screenRegistry,
    ),
    diagnosticsProfile:
        diagnosticsProfile ?? _standardDiagnosticsProfileForDomain('digital'),
    releaseWorkspaceProfile:
        releaseWorkspaceProfile ??
        _standardReleaseWorkspaceProfileForDomain('digital'),
    releaseProfileSavedViewProfile:
        releaseProfileSavedViewProfile ??
        _subscriptionReleaseProfileSavedViewProfile,
    releaseGateLanes: releaseGateLanes,
    releaseGateLaneTargets: releaseGateLaneTargets,
  );
}

BillingBusinessDomainPackRegistry standardBillingDomainPackRegistry({
  Iterable<BillingBusinessDomainPack> additionalPacks = const [],
}) {
  return BillingBusinessDomainPackRegistry(
    packs: [
      commerceBillingDomainPack(),
      constructionBillingDomainPack(),
      digitalSubscriptionBillingDomainPack(),
      ...additionalPacks,
    ],
  );
}

BillingDiagnosticsSectionProfile _standardDiagnosticsProfileForDomain(
  String domain,
) {
  final profile = standardBillingDiagnosticsSectionProfileCatalog
      .profileForBusinessDomain(domain);
  if (profile == null) {
    throw StateError(
      'No standard billing diagnostics profile is registered for $domain.',
    );
  }

  return profile;
}

BillingReleaseWorkspaceProfile _standardReleaseWorkspaceProfileForDomain(
  String domain,
) {
  final profile = standardBillingReleaseWorkspaceProfileCatalog
      .profileForBusinessDomain(domain);
  if (profile == null) {
    throw StateError(
      'No standard billing release workspace profile is registered for $domain.',
    );
  }

  return profile;
}

const billingDiagnosticsConstructionReleaseProfileSavedViewId =
    'construction-release-profile';
const billingDiagnosticsSubscriptionReleaseProfileSavedViewId =
    'subscription-release-profile';

final _constructionReleaseProfileSavedViewProfile =
    BillingDiagnosticsReleaseProfileSavedViewProfile(
      id: 'construction-release-profile-saved-views',
      businessDomains: const ['construction'],
      extensions: const [_constructionReleaseProfileSavedView],
    );

final _subscriptionReleaseProfileSavedViewProfile =
    BillingDiagnosticsReleaseProfileSavedViewProfile(
      id: 'subscription-release-profile-saved-views',
      businessDomains: const ['digital', 'saas', 'software', 'subscription'],
      extensions: const [_subscriptionReleaseProfileSavedView],
    );

const _constructionReleaseProfileSavedView =
    BillingDiagnosticsReleaseProfileSavedView(
      id: billingDiagnosticsConstructionReleaseProfileSavedViewId,
      label: 'Construction profile',
      description:
          'Show construction release profile extensions for the active domain',
      statusOption: BillingReleaseProfileStatusFilterOption.extended,
      domainScope:
          BillingDiagnosticsReleaseProfileSavedViewDomainScope
              .focusedBusinessDomain,
      icon: Icons.engineering_outlined,
      accentColor: Color(0xFF0F766E),
    );

const _subscriptionReleaseProfileSavedView =
    BillingDiagnosticsReleaseProfileSavedView(
      id: billingDiagnosticsSubscriptionReleaseProfileSavedViewId,
      label: 'Subscription profile',
      description:
          'Show subscription release profile extensions for the active domain',
      statusOption: BillingReleaseProfileStatusFilterOption.extended,
      domainScope:
          BillingDiagnosticsReleaseProfileSavedViewDomainScope
              .focusedBusinessDomain,
      icon: Icons.autorenew_outlined,
      accentColor: Color(0xFF2563EB),
    );
