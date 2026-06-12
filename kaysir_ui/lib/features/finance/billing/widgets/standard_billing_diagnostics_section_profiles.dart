import 'package:flutter/material.dart';

import 'billing_diagnostics_domain_signal_section.dart';
import 'billing_diagnostics_section_profile.dart';
import 'billing_diagnostics_section_registry.dart';

const billingDiagnosticsConstructionSignalSectionId = 'construction-signal';
const billingDiagnosticsSubscriptionSignalSectionId = 'subscription-signal';
const billingDiagnosticsConstructionProfileId = 'construction';
const billingDiagnosticsSubscriptionProfileId = 'subscription';

final standardBillingDiagnosticsSectionProfileCatalog =
    BillingDiagnosticsSectionProfileCatalog(
      profiles: [
        BillingDiagnosticsSectionProfile(
          id: billingDiagnosticsConstructionProfileId,
          businessDomains: const ['construction'],
          extensions: [_constructionSignalSection.toDescriptor()],
        ),
        BillingDiagnosticsSectionProfile(
          id: billingDiagnosticsSubscriptionProfileId,
          businessDomains: const [
            'digital',
            'saas',
            'software',
            'subscription',
          ],
          extensions: [_subscriptionSignalSection.toDescriptor()],
        ),
      ],
    );

BillingDiagnosticsSectionRegistry
billingDiagnosticsSectionRegistryForBusinessDomain(
  String businessDomain, {
  BillingDiagnosticsSectionProfileCatalog? catalog,
}) {
  return (catalog ?? standardBillingDiagnosticsSectionProfileCatalog)
      .registryForBusinessDomain(businessDomain);
}

final _constructionSignalSection = BillingDiagnosticsDomainSignalSection(
  id: billingDiagnosticsConstructionSignalSectionId,
  title: 'Construction milestone diagnostics',
  summary:
      'Tracks progress billing, deposits, and milestone payment readiness '
      'before invoices are issued.',
  icon: Icons.engineering_outlined,
  accentColor: const Color(0xFF0F766E),
  signals: const ['Milestone billing', 'Deposits', 'Progress claims'],
);

final _subscriptionSignalSection = BillingDiagnosticsDomainSignalSection(
  id: billingDiagnosticsSubscriptionSignalSectionId,
  title: 'Subscription health diagnostics',
  summary:
      'Tracks recurring billing, renewal readiness, and plan entitlements '
      'for digital product billing.',
  icon: Icons.autorenew_outlined,
  accentColor: const Color(0xFF2563EB),
  signals: const ['Renewals', 'Entitlements', 'Recurring invoices'],
);
