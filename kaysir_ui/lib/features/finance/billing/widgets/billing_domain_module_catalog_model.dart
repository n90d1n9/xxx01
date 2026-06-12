import '../models/billing_business_domain_module.dart';
import '../models/billing_business_domain_profile.dart';
import '../utils/billing_business_domain_module_readiness.dart';

class BillingDomainModuleCatalogEntry {
  final BillingDomainModuleReadinessReport readinessReport;

  const BillingDomainModuleCatalogEntry({required this.readinessReport});

  BillingBusinessDomainModule get module => readinessReport.module;

  BillingBusinessDomainProfile get profile => module.profile;

  String get domainKey => readinessReport.domainKey;

  String get domainLabel => readinessReport.domainLabel;

  String get sourceLabel => _sourceLabel(profile.defaultSourceType);

  int get adapterCount => module.lineItemAdapters.length;

  int get screenCount => module.screenRegistry?.screens.length ?? 0;

  List<String> get capabilityLabels {
    final labels = profile.capabilities
        .map(billingBusinessDomainCapabilityLabel)
        .toList(growable: false);
    labels.sort();
    return List.unmodifiable(labels);
  }

  List<BillingDomainModuleCatalogContract> get contracts {
    return List.unmodifiable([
      BillingDomainModuleCatalogContract(
        label: 'Line items',
        value: adapterCount == 1 ? '1 adapter' : '$adapterCount adapters',
        isReady: adapterCount > 0,
      ),
      BillingDomainModuleCatalogContract(
        label: 'Issue policy',
        value: module.hasIssuePolicy ? 'Configured' : 'Missing',
        isReady: module.hasIssuePolicy,
      ),
      BillingDomainModuleCatalogContract(
        label: 'Navigation',
        value: module.hasNavigationPolicy ? 'Configured' : 'Missing',
        isReady: module.hasNavigationPolicy,
      ),
      BillingDomainModuleCatalogContract(
        label: 'Screens',
        value: screenCount == 1 ? '1 screen' : '$screenCount screens',
        isReady: screenCount > 0,
      ),
    ]);
  }
}

class BillingDomainModuleCatalogContract {
  final String label;
  final String value;
  final bool isReady;

  const BillingDomainModuleCatalogContract({
    required this.label,
    required this.value,
    required this.isReady,
  });
}

List<BillingDomainModuleCatalogEntry> billingDomainModuleCatalogEntries(
  BillingDomainModuleRegistryReadinessReport report,
) {
  return List.unmodifiable(
    report.moduleReports.map(
      (moduleReport) =>
          BillingDomainModuleCatalogEntry(readinessReport: moduleReport),
    ),
  );
}

String billingBusinessDomainCapabilityLabel(
  BillingBusinessDomainCapability capability,
) {
  return switch (capability) {
    BillingBusinessDomainCapability.productCatalog => 'Product catalog',
    BillingBusinessDomainCapability.inventory => 'Inventory',
    BillingBusinessDomainCapability.cartCheckout => 'Cart checkout',
    BillingBusinessDomainCapability.projectMilestones => 'Project milestones',
    BillingBusinessDomainCapability.progressBilling => 'Progress billing',
    BillingBusinessDomainCapability.recurringSubscriptions =>
      'Recurring subscriptions',
    BillingBusinessDomainCapability.meteredUsage => 'Metered usage',
    BillingBusinessDomainCapability.servicePeriods => 'Service periods',
    BillingBusinessDomainCapability.retainers => 'Retainers',
    BillingBusinessDomainCapability.omniChannel => 'Omni-channel',
  };
}

String _sourceLabel(String sourceType) {
  final words = sourceType
      .trim()
      .split(RegExp(r'[_\s-]+'))
      .where((word) => word.isNotEmpty)
      .toList(growable: false);
  if (words.isEmpty) return 'Domain value';

  return words
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}
