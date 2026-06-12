import 'billing_readiness_metric_collection.dart';

typedef BillingReadinessMetricResolver<T extends Object> =
    BillingReadinessMetricCollection Function(T source);

abstract class BillingReadinessMetricProviderBase {
  String get id;

  int get priority;

  bool supports(Object source);

  BillingReadinessMetricCollection resolveObject(Object source);
}

class BillingReadinessMetricProvider<T extends Object>
    implements BillingReadinessMetricProviderBase {
  @override
  final String id;

  @override
  final int priority;

  final BillingReadinessMetricResolver<T> resolver;

  const BillingReadinessMetricProvider({
    required this.id,
    required this.resolver,
    this.priority = 100,
  });

  BillingReadinessMetricCollection resolve(T source) {
    return resolver(source);
  }

  @override
  bool supports(Object source) {
    return source is T;
  }

  @override
  BillingReadinessMetricCollection resolveObject(Object source) {
    if (source is! T) {
      throw ArgumentError.value(
        source,
        'source',
        'must be a $T source for billing metric provider $id',
      );
    }

    return resolve(source);
  }
}

class BillingReadinessMetricProviderRegistry {
  final List<BillingReadinessMetricProviderBase> providers;

  factory BillingReadinessMetricProviderRegistry({
    Iterable<BillingReadinessMetricProviderBase> providers = const [],
  }) {
    return BillingReadinessMetricProviderRegistry._(
      _sortedMetricProviders(_validatedMetricProviders(providers)),
    );
  }

  const BillingReadinessMetricProviderRegistry._(this.providers);

  bool get isEmpty => providers.isEmpty;

  int get count => providers.length;

  List<String> get providerIds {
    return List.unmodifiable(providers.map((provider) => provider.id));
  }

  bool contains(String providerId) {
    return find(providerId) != null;
  }

  BillingReadinessMetricProviderBase? find(String providerId) {
    final normalizedProviderId = providerId.trim();

    for (final provider in providers) {
      if (provider.id == normalizedProviderId) return provider;
    }

    return null;
  }

  BillingReadinessMetricProviderBase requireProvider(String providerId) {
    final provider = find(providerId);
    if (provider == null) {
      throw StateError(
        'No billing readiness metric provider is registered for $providerId.',
      );
    }

    return provider;
  }

  BillingReadinessMetricCollection resolve(String providerId, Object source) {
    return requireProvider(providerId).resolveObject(source);
  }

  List<BillingReadinessMetricProviderBase> providersForSource(Object source) {
    return List.unmodifiable(
      providers.where((provider) => provider.supports(source)),
    );
  }

  List<BillingReadinessMetricCollection> resolveForSource(Object source) {
    return List.unmodifiable(
      providersForSource(
        source,
      ).map((provider) => provider.resolveObject(source)),
    );
  }

  BillingReadinessMetricProviderRegistry register(
    BillingReadinessMetricProviderBase provider,
  ) {
    return BillingReadinessMetricProviderRegistry(
      providers: [...providers, provider],
    );
  }

  BillingReadinessMetricProviderRegistry registerAll(
    Iterable<BillingReadinessMetricProviderBase> providers,
  ) {
    return BillingReadinessMetricProviderRegistry(
      providers: [...this.providers, ...providers],
    );
  }

  BillingReadinessMetricProviderRegistry without(Iterable<String> providerIds) {
    final hiddenProviderIds = providerIds.map((id) => id.trim()).toSet();
    return BillingReadinessMetricProviderRegistry(
      providers: providers.where(
        (provider) => !hiddenProviderIds.contains(provider.id),
      ),
    );
  }

  BillingReadinessMetricProviderRegistry extend({
    Iterable<String> hiddenProviderIds = const [],
    Iterable<BillingReadinessMetricProviderBase> extensions = const [],
  }) {
    final hiddenProviderIdSet =
        hiddenProviderIds.map((id) => id.trim()).toSet();
    final extensionProviders = extensions.toList(growable: false);
    final extensionProviderIds =
        extensionProviders.map((provider) => provider.id).toSet();

    return BillingReadinessMetricProviderRegistry(
      providers: [
        ...providers.where(
          (provider) =>
              !hiddenProviderIdSet.contains(provider.id) &&
              !extensionProviderIds.contains(provider.id),
        ),
        ...extensionProviders,
      ],
    );
  }
}

List<BillingReadinessMetricProviderBase> _validatedMetricProviders(
  Iterable<BillingReadinessMetricProviderBase> providers,
) {
  final providerList = providers.toList(growable: false);
  final ids = <String>{};

  for (final provider in providerList) {
    final normalizedId = provider.id.trim();
    if (normalizedId.isEmpty) {
      throw ArgumentError.value(
        provider.id,
        'provider.id',
        'must not be blank',
      );
    }
    if (normalizedId != provider.id) {
      throw ArgumentError.value(
        provider.id,
        'provider.id',
        'must not contain leading or trailing whitespace',
      );
    }
    if (!ids.add(normalizedId)) {
      throw ArgumentError.value(
        provider.id,
        'provider.id',
        'must be unique in a billing readiness metric provider registry',
      );
    }
  }

  return providerList;
}

List<BillingReadinessMetricProviderBase> _sortedMetricProviders(
  Iterable<BillingReadinessMetricProviderBase> providers,
) {
  final sorted = providers.toList(growable: false)..sort((left, right) {
    final priority = left.priority.compareTo(right.priority);
    if (priority != 0) return priority;

    return left.id.compareTo(right.id);
  });

  return List.unmodifiable(sorted);
}
