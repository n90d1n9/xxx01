import 'billing_invoice_tax_mode.dart';

String billingBusinessDomainKey(String domain) {
  return domain.trim().toLowerCase();
}

enum BillingBusinessDomainCapability {
  productCatalog,
  inventory,
  cartCheckout,
  projectMilestones,
  progressBilling,
  recurringSubscriptions,
  meteredUsage,
  servicePeriods,
  retainers,
  omniChannel,
}

class BillingBusinessDomainProfile {
  final String domain;
  final String label;
  final String defaultSourceType;
  final bool taxable;
  final double taxRate;
  final BillingInvoiceTaxMode taxMode;
  final Set<BillingBusinessDomainCapability> capabilities;
  final Map<String, String> attributes;

  BillingBusinessDomainProfile({
    required this.domain,
    required this.label,
    required this.defaultSourceType,
    this.taxable = true,
    this.taxRate = 0,
    this.taxMode = BillingInvoiceTaxMode.exclusive,
    Iterable<BillingBusinessDomainCapability> capabilities = const [],
    Map<String, String> attributes = const {},
  }) : capabilities = Set.unmodifiable(capabilities),
       attributes = Map.unmodifiable(attributes);

  String get key => billingBusinessDomainKey(domain);

  bool get isValid => validationErrors.isEmpty;

  bool supports(BillingBusinessDomainCapability capability) {
    return capabilities.contains(capability);
  }

  List<String> get validationErrors {
    final errors = <String>[];

    if (domain.trim().isEmpty) {
      errors.add('Billing domain is required.');
    }
    if (label.trim().isEmpty) {
      errors.add('Billing domain label is required.');
    }
    if (defaultSourceType.trim().isEmpty) {
      errors.add('Billing domain default source type is required.');
    }
    if (taxRate < 0 || taxRate > 1) {
      errors.add('Billing domain tax rate must be between 0 and 1.');
    }

    return List.unmodifiable(errors);
  }

  BillingBusinessDomainProfile copyWith({
    String? domain,
    String? label,
    String? defaultSourceType,
    bool? taxable,
    double? taxRate,
    BillingInvoiceTaxMode? taxMode,
    Iterable<BillingBusinessDomainCapability>? capabilities,
    Map<String, String>? attributes,
  }) {
    return BillingBusinessDomainProfile(
      domain: domain ?? this.domain,
      label: label ?? this.label,
      defaultSourceType: defaultSourceType ?? this.defaultSourceType,
      taxable: taxable ?? this.taxable,
      taxRate: taxRate ?? this.taxRate,
      taxMode: taxMode ?? this.taxMode,
      capabilities: capabilities ?? this.capabilities,
      attributes: attributes ?? this.attributes,
    );
  }
}

class BillingBusinessDomainProfileRegistry {
  final List<BillingBusinessDomainProfile> profiles;

  BillingBusinessDomainProfileRegistry({
    Iterable<BillingBusinessDomainProfile> profiles = const [],
  }) : profiles = List.unmodifiable(_ensureUnique(profiles));

  bool get isEmpty => profiles.isEmpty;

  List<String> get domainKeys {
    return List.unmodifiable(profiles.map((profile) => profile.key));
  }

  bool contains(String domain) {
    return find(domain) != null;
  }

  BillingBusinessDomainProfileRegistry register(
    BillingBusinessDomainProfile profile,
  ) {
    return BillingBusinessDomainProfileRegistry(
      profiles: [...profiles, profile],
    );
  }

  BillingBusinessDomainProfileRegistry registerAll(
    Iterable<BillingBusinessDomainProfile> profiles,
  ) {
    return BillingBusinessDomainProfileRegistry(
      profiles: [...this.profiles, ...profiles],
    );
  }

  BillingBusinessDomainProfile? find(String domain) {
    final key = billingBusinessDomainKey(domain);

    for (final profile in profiles) {
      if (profile.key == key) return profile;
    }

    return null;
  }

  BillingBusinessDomainProfile requireProfile(String domain) {
    final profile = find(domain);
    if (profile == null) {
      throw StateError('No billing domain profile is registered for $domain.');
    }

    return profile;
  }

  static List<BillingBusinessDomainProfile> _ensureUnique(
    Iterable<BillingBusinessDomainProfile> profiles,
  ) {
    final seenKeys = <String>{};
    final uniqueProfiles = <BillingBusinessDomainProfile>[];

    for (final profile in profiles) {
      final errors = profile.validationErrors;
      if (errors.isNotEmpty) {
        throw StateError(errors.first);
      }
      if (!seenKeys.add(profile.key)) {
        throw StateError(
          'Duplicate billing domain profile registered for ${profile.key}.',
        );
      }
      uniqueProfiles.add(profile);
    }

    return uniqueProfiles;
  }
}
