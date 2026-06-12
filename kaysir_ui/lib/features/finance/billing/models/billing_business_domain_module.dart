import 'billing_business_domain_navigation_policy.dart';
import 'billing_business_domain_profile.dart';
import 'billing_business_domain_screen_registry.dart';
import 'billing_invoice_issue_policy.dart';
import 'billing_invoice_line_item_adapter.dart';

class BillingBusinessDomainModule {
  final BillingBusinessDomainProfile profile;
  final List<BillingInvoiceLineItemAdapter> lineItemAdapters;
  final BillingInvoiceIssuePolicy? issuePolicy;
  final BillingBusinessDomainNavigationPolicy? navigationPolicy;
  final BillingBusinessDomainScreenRegistry? screenRegistry;

  BillingBusinessDomainModule({
    required this.profile,
    Iterable<BillingInvoiceLineItemAdapter> lineItemAdapters = const [],
    BillingInvoiceIssuePolicy? issuePolicy,
    BillingBusinessDomainNavigationPolicy? navigationPolicy,
    this.screenRegistry,
  }) : issuePolicy = _ensureIssuePolicy(profile, issuePolicy),
       navigationPolicy = _ensureNavigationPolicy(
         screenRegistry,
         navigationPolicy,
       ),
       lineItemAdapters = List.unmodifiable(
         _ensureAdapters(profile, lineItemAdapters),
       );

  String get key => profile.key;

  bool get hasLineItemAdapters => lineItemAdapters.isNotEmpty;

  bool get hasIssuePolicy => issuePolicy != null;

  bool get hasNavigationPolicy => navigationPolicy != null;

  bool get hasScreenRegistry => screenRegistry != null;

  BillingInvoiceLineItemAdapterRegistry get lineItemAdapterRegistry {
    return BillingInvoiceLineItemAdapterRegistry(adapters: lineItemAdapters);
  }

  bool supports(BillingBusinessDomainCapability capability) {
    return profile.supports(capability);
  }

  BillingBusinessDomainModule copyWith({
    BillingBusinessDomainProfile? profile,
    Iterable<BillingInvoiceLineItemAdapter>? lineItemAdapters,
    Object? issuePolicy = _unset,
    Object? navigationPolicy = _unset,
    Object? screenRegistry = _unset,
  }) {
    return BillingBusinessDomainModule(
      profile: profile ?? this.profile,
      lineItemAdapters: lineItemAdapters ?? this.lineItemAdapters,
      issuePolicy:
          identical(issuePolicy, _unset)
              ? this.issuePolicy
              : issuePolicy as BillingInvoiceIssuePolicy?,
      navigationPolicy:
          identical(navigationPolicy, _unset)
              ? this.navigationPolicy
              : navigationPolicy as BillingBusinessDomainNavigationPolicy?,
      screenRegistry:
          identical(screenRegistry, _unset)
              ? this.screenRegistry
              : screenRegistry as BillingBusinessDomainScreenRegistry?,
    );
  }

  static BillingInvoiceIssuePolicy? _ensureIssuePolicy(
    BillingBusinessDomainProfile profile,
    BillingInvoiceIssuePolicy? issuePolicy,
  ) {
    final policy = issuePolicy;
    if (policy == null) return null;

    final errors = policy.validationErrors;
    if (errors.isNotEmpty) {
      throw StateError(errors.first);
    }
    if (billingBusinessDomainKey(policy.domain) != profile.key) {
      throw StateError(
        'Billing domain module ${profile.key} cannot register issue policy '
        'for ${policy.domain}.',
      );
    }

    return policy;
  }

  static BillingBusinessDomainNavigationPolicy? _ensureNavigationPolicy(
    BillingBusinessDomainScreenRegistry? screenRegistry,
    BillingBusinessDomainNavigationPolicy? navigationPolicy,
  ) {
    final policy = navigationPolicy;
    if (policy == null || screenRegistry == null) return policy;

    final destinationIds = policy.destinationIds;
    if (destinationIds == null) return policy;

    for (final destinationId in destinationIds) {
      if (!screenRegistry.contains(destinationId)) {
        throw StateError(
          'Billing domain navigation destination $destinationId has no '
          'registered module screen.',
        );
      }
    }

    return policy;
  }

  static List<BillingInvoiceLineItemAdapter> _ensureAdapters(
    BillingBusinessDomainProfile profile,
    Iterable<BillingInvoiceLineItemAdapter> adapters,
  ) {
    final errors = profile.validationErrors;
    if (errors.isNotEmpty) {
      throw StateError(errors.first);
    }

    final adapterList = adapters.toList(growable: false);
    for (final adapter in adapterList) {
      if (billingBusinessDomainKey(adapter.domain) != profile.key) {
        throw StateError(
          'Billing domain module ${profile.key} cannot register adapter '
          '${adapter.key} for a different domain.',
        );
      }
    }

    return BillingInvoiceLineItemAdapterRegistry(
      adapters: adapterList,
    ).adapters;
  }
}

class BillingBusinessDomainModuleRegistry {
  final List<BillingBusinessDomainModule> modules;

  BillingBusinessDomainModuleRegistry({
    Iterable<BillingBusinessDomainModule> modules = const [],
  }) : modules = List.unmodifiable(_ensureUnique(modules));

  bool get isEmpty => modules.isEmpty;

  List<String> get domainKeys {
    return List.unmodifiable(modules.map((module) => module.key));
  }

  BillingBusinessDomainProfileRegistry get profileRegistry {
    return BillingBusinessDomainProfileRegistry(
      profiles: modules.map((module) => module.profile),
    );
  }

  BillingInvoiceLineItemAdapterRegistry get lineItemAdapterRegistry {
    return BillingInvoiceLineItemAdapterRegistry(
      adapters: modules.expand((module) => module.lineItemAdapters),
    );
  }

  BillingInvoiceIssuePolicy? issuePolicyForDomain(String domain) {
    return find(domain)?.issuePolicy;
  }

  BillingBusinessDomainScreenRegistry? screenRegistryForDomain(String domain) {
    return find(domain)?.screenRegistry;
  }

  bool contains(String domain) {
    return find(domain) != null;
  }

  BillingBusinessDomainModuleRegistry register(
    BillingBusinessDomainModule module,
  ) {
    return BillingBusinessDomainModuleRegistry(modules: [...modules, module]);
  }

  BillingBusinessDomainModuleRegistry registerAll(
    Iterable<BillingBusinessDomainModule> modules,
  ) {
    return BillingBusinessDomainModuleRegistry(
      modules: [...this.modules, ...modules],
    );
  }

  BillingBusinessDomainModule? find(String domain) {
    final key = billingBusinessDomainKey(domain);

    for (final module in modules) {
      if (module.key == key) return module;
    }

    return null;
  }

  BillingBusinessDomainModule requireModule(String domain) {
    final module = find(domain);
    if (module == null) {
      throw StateError('No billing domain module is registered for $domain.');
    }

    return module;
  }

  static List<BillingBusinessDomainModule> _ensureUnique(
    Iterable<BillingBusinessDomainModule> modules,
  ) {
    final seenKeys = <String>{};
    final uniqueModules = <BillingBusinessDomainModule>[];

    for (final module in modules) {
      if (!seenKeys.add(module.key)) {
        throw StateError(
          'Duplicate billing domain module registered for ${module.key}.',
        );
      }
      uniqueModules.add(module);
    }

    return uniqueModules;
  }
}

const _unset = Object();
