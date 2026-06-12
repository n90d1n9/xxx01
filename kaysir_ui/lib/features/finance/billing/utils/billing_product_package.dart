import '../models/billing_business_domain_profile.dart';
import 'billing_business_domain_blueprint_fit_matrix.dart';

String billingProductPackageKey(String id) {
  return id.trim().toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');
}

class BillingProductPackage {
  final String id;
  final String label;
  final String description;
  final String audienceLabel;
  final String channelLabel;
  final List<String> domainKeys;
  final List<BillingBusinessDomainBlueprintFitSignal> requiredSignals;
  final List<BillingBusinessDomainBlueprintFitSignal> recommendedSignals;

  BillingProductPackage({
    required this.id,
    required this.label,
    required this.description,
    required this.audienceLabel,
    required this.channelLabel,
    required Iterable<String> domainKeys,
    required Iterable<BillingBusinessDomainBlueprintFitSignal> requiredSignals,
    Iterable<BillingBusinessDomainBlueprintFitSignal> recommendedSignals =
        const [],
  }) : domainKeys = List.unmodifiable(domainKeys.map(billingBusinessDomainKey)),
       requiredSignals = List.unmodifiable(requiredSignals),
       recommendedSignals = List.unmodifiable(recommendedSignals) {
    if (id.trim().isEmpty) {
      throw StateError('Billing product package id is required.');
    }
    if (label.trim().isEmpty) {
      throw StateError('Billing product package label is required.');
    }
    if (this.domainKeys.isEmpty) {
      throw StateError('Billing product package $id needs a domain target.');
    }
    if (this.requiredSignals.isEmpty) {
      throw StateError('Billing product package $id needs fit signals.');
    }
  }

  String get key {
    return billingProductPackageKey(id);
  }
}

class BillingProductPackageRegistry {
  final List<BillingProductPackage> packages;

  BillingProductPackageRegistry({
    Iterable<BillingProductPackage> packages = const [],
  }) : packages = List.unmodifiable(_ensureUnique(packages));

  bool get isEmpty => packages.isEmpty;

  List<String> get packageKeys {
    return List.unmodifiable(packages.map((package) => package.key));
  }

  BillingProductPackage? find(String id) {
    final key = billingProductPackageKey(id);

    for (final package in packages) {
      if (package.key == key) return package;
    }

    return null;
  }

  BillingProductPackage requirePackage(String id) {
    final package = find(id);
    if (package == null) {
      throw StateError('No billing product package is registered for $id.');
    }

    return package;
  }

  static List<BillingProductPackage> _ensureUnique(
    Iterable<BillingProductPackage> packages,
  ) {
    final seenKeys = <String>{};
    final uniquePackages = <BillingProductPackage>[];

    for (final package in packages) {
      if (!seenKeys.add(package.key)) {
        throw StateError(
          'Duplicate billing product package registered for ${package.key}.',
        );
      }
      uniquePackages.add(package);
    }

    return uniquePackages;
  }
}

BillingProductPackageRegistry standardBillingProductPackageRegistry() {
  return BillingProductPackageRegistry(
    packages: [
      BillingProductPackage(
        id: 'commerce_checkout',
        label: 'Commerce checkout',
        description: 'Catalog, cart, inventory, and receipt-led billing.',
        audienceLabel: 'Retail and commerce teams',
        channelLabel: 'Storefront, POS, and back office',
        domainKeys: const ['commerce'],
        requiredSignals: const [
          BillingBusinessDomainBlueprintFitSignal.checkout,
        ],
        recommendedSignals: const [
          BillingBusinessDomainBlueprintFitSignal.omniChannel,
        ],
      ),
      BillingProductPackage(
        id: 'project_billing',
        label: 'Project billing',
        description: 'Milestones, progress billing, and staged collections.',
        audienceLabel: 'Construction and project operators',
        channelLabel: 'Back office and field review',
        domainKeys: const ['construction'],
        requiredSignals: const [
          BillingBusinessDomainBlueprintFitSignal.projects,
        ],
        recommendedSignals: const [
          BillingBusinessDomainBlueprintFitSignal.service,
        ],
      ),
      BillingProductPackage(
        id: 'digital_subscriptions',
        label: 'Digital subscriptions',
        description: 'Recurring subscriptions, usage, and renewal billing.',
        audienceLabel: 'SaaS and digital product teams',
        channelLabel: 'Self-serve, admin, and finance',
        domainKeys: const ['digital'],
        requiredSignals: const [
          BillingBusinessDomainBlueprintFitSignal.subscriptions,
        ],
        recommendedSignals: const [
          BillingBusinessDomainBlueprintFitSignal.omniChannel,
        ],
      ),
      BillingProductPackage(
        id: 'service_operations',
        label: 'Service operations',
        description: 'Service periods, retainers, and work-order billing.',
        audienceLabel: 'Service and operations teams',
        channelLabel: 'Back office and assisted service',
        domainKeys: const ['construction', 'digital'],
        requiredSignals: const [
          BillingBusinessDomainBlueprintFitSignal.service,
        ],
      ),
      BillingProductPackage(
        id: 'omni_channel_billing',
        label: 'Omni-channel billing',
        description: 'Multi-channel billing packages for hybrid businesses.',
        audienceLabel: 'Hybrid commerce and subscription teams',
        channelLabel: 'POS, online, admin, and partner channels',
        domainKeys: const ['commerce', 'digital'],
        requiredSignals: const [
          BillingBusinessDomainBlueprintFitSignal.omniChannel,
        ],
        recommendedSignals: const [
          BillingBusinessDomainBlueprintFitSignal.checkout,
          BillingBusinessDomainBlueprintFitSignal.subscriptions,
        ],
      ),
    ],
  );
}
