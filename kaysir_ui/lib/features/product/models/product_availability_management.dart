import '../../inventory/models/inventory_product_catalog.dart';
import '../utils/product_catalog_review_target.dart';
import 'product.dart';
import 'sales_channel_profile.dart';

enum ProductAvailabilityRuleType {
  unconfigured,
  channelAccess,
  salesStatus,
  stockPolicy,
  scheduleWindow,
  fulfillmentMode,
}

enum ProductAvailabilityRiskStatus { action, watch, healthy }

class ProductAvailabilityRuleSignal {
  const ProductAvailabilityRuleSignal({
    required this.type,
    required this.value,
    this.isBlocking = false,
    this.isDisabledChannel = false,
    this.isStockRequired = false,
  });

  final ProductAvailabilityRuleType type;
  final String value;
  final bool isBlocking;
  final bool isDisabledChannel;
  final bool isStockRequired;
}

class ProductAvailabilityManagementSummary {
  const ProductAvailabilityManagementSummary({
    required this.productCount,
    required this.availabilityRuleTypeCount,
    required this.configuredProductCount,
    required this.openAvailabilityProductCount,
    required this.availabilityRuleCount,
    required this.conflictProductCount,
    required this.gatedProductCount,
    required this.stockBlockedProductCount,
    required this.untrackedProductCount,
    required this.availabilityRiskProductCount,
    required this.totalInventoryValue,
  });

  final int productCount;
  final int availabilityRuleTypeCount;
  final int configuredProductCount;
  final int openAvailabilityProductCount;
  final int availabilityRuleCount;
  final int conflictProductCount;
  final int gatedProductCount;
  final int stockBlockedProductCount;
  final int untrackedProductCount;
  final int availabilityRiskProductCount;
  final double totalInventoryValue;

  int get availabilityCoveragePercent {
    if (productCount == 0) return 0;

    return ((configuredProductCount / productCount) * 100).round();
  }

  int get availabilityReadinessPercent {
    if (productCount == 0) return 0;

    final readyCount = productCount - availabilityRiskProductCount;
    return ((readyCount / productCount) * 100).clamp(0, 100).round();
  }

  String get coverageLabel => '$configuredProductCount/$productCount ruled';

  String get statusLabel {
    if (productCount == 0) return 'No products';
    if (conflictProductCount > 0) return 'Rule conflicts';
    if (openAvailabilityProductCount > 0) return 'Availability setup';
    if (stockBlockedProductCount > 0) return 'Stock gates';
    if (gatedProductCount > 0) return 'Availability gates';

    return 'Availability ready';
  }
}

class ProductAvailabilityManagementEntry {
  const ProductAvailabilityManagementEntry({
    required this.type,
    required this.id,
    required this.title,
    required this.productCount,
    required this.ruleCount,
    required this.conflictProductCount,
    required this.gatedProductCount,
    required this.stockBlockedProductCount,
    required this.untrackedProductCount,
    required this.totalInventoryValue,
    required this.reviewTarget,
  });

  final ProductAvailabilityRuleType type;
  final String id;
  final String title;
  final int productCount;
  final int ruleCount;
  final int conflictProductCount;
  final int gatedProductCount;
  final int stockBlockedProductCount;
  final int untrackedProductCount;
  final double totalInventoryValue;
  final ProductCatalogReviewTarget reviewTarget;

  int get riskCount {
    return conflictProductCount +
        gatedProductCount +
        stockBlockedProductCount +
        untrackedProductCount +
        (type == ProductAvailabilityRuleType.unconfigured ? productCount : 0);
  }

  bool get hasRisk => riskCount > 0;

  ProductAvailabilityRiskStatus get status {
    if (type == ProductAvailabilityRuleType.unconfigured && productCount > 0) {
      return ProductAvailabilityRiskStatus.action;
    }
    if (conflictProductCount > 0) return ProductAvailabilityRiskStatus.action;
    if (stockBlockedProductCount > 0 ||
        gatedProductCount > 0 ||
        untrackedProductCount > 0) {
      return ProductAvailabilityRiskStatus.watch;
    }

    return ProductAvailabilityRiskStatus.healthy;
  }

  String get productCountLabel {
    return productCount == 1 ? '1 product' : '$productCount products';
  }

  String get ruleCountLabel {
    if (type == ProductAvailabilityRuleType.unconfigured) return 'Missing';
    if (ruleCount == 0) return 'No rules';

    return ruleCount == 1 ? '1 rule' : '$ruleCount rules';
  }

  String get issueSummaryLabel {
    if (!hasRisk) return 'Availability ready';

    final parts = [
      if (type == ProductAvailabilityRuleType.unconfigured && productCount > 0)
        _countLabel(productCount, 'missing rule'),
      if (conflictProductCount > 0)
        _countLabel(conflictProductCount, 'conflict'),
      if (stockBlockedProductCount > 0)
        _countLabel(stockBlockedProductCount, 'stock gate'),
      if (gatedProductCount > 0) _countLabel(gatedProductCount, 'gated'),
      if (untrackedProductCount > 0)
        _countLabel(untrackedProductCount, 'untracked'),
    ];

    return parts.join(' | ');
  }

  String get actionLabel {
    if (type == ProductAvailabilityRuleType.unconfigured && productCount > 0) {
      return 'Add rules';
    }
    if (conflictProductCount > 0) return 'Resolve conflicts';
    if (stockBlockedProductCount > 0) return 'Review stock';
    if (gatedProductCount > 0) return 'Review gates';

    return 'Review rules';
  }
}

class ProductAvailabilityManagementOverview {
  ProductAvailabilityManagementOverview({
    required this.summary,
    required this.channelProfile,
    required List<ProductAvailabilityManagementEntry> rules,
  }) : rules = List.unmodifiable(rules);

  final ProductAvailabilityManagementSummary summary;
  final ProductSalesChannelProfile channelProfile;
  final List<ProductAvailabilityManagementEntry> rules;

  ProductAvailabilityManagementEntry? get primaryRule {
    if (rules.isEmpty) return null;

    return rules.firstWhere((rule) => rule.hasRisk, orElse: () => rules.first);
  }
}

ProductAvailabilityManagementOverview
buildProductAvailabilityManagementOverview({
  required List<InventoryProductCatalogRecord> records,
  required ProductSalesChannelProfile channelProfile,
}) {
  final accumulators =
      <ProductAvailabilityRuleType, _ProductAvailabilityAccumulator>{};
  final configuredProductIds = <String>{};
  final openAvailabilityProductIds = <String>{};
  final conflictProductIds = <String>{};
  final gatedProductIds = <String>{};
  final stockBlockedProductIds = <String>{};
  final untrackedProductIds = <String>{};
  final riskProductIds = <String>{};

  for (final record in records) {
    final state = _ProductAvailabilityProductState.fromRecord(record);
    if (state.isConfigured) {
      configuredProductIds.add(record.id);
    } else {
      openAvailabilityProductIds.add(record.id);
      riskProductIds.add(record.id);
      accumulators
          .putIfAbsent(
            ProductAvailabilityRuleType.unconfigured,
            () => _ProductAvailabilityAccumulator(
              type: ProductAvailabilityRuleType.unconfigured,
            ),
          )
          .add(state: state);
    }

    if (state.hasConflict) {
      conflictProductIds.add(record.id);
      riskProductIds.add(record.id);
    }
    if (state.hasGate) {
      gatedProductIds.add(record.id);
    }
    if (state.isStockBlocked) {
      stockBlockedProductIds.add(record.id);
      riskProductIds.add(record.id);
    }
    if (state.isUntracked) {
      untrackedProductIds.add(record.id);
      riskProductIds.add(record.id);
    }

    for (final entry in state.signalsByType.entries) {
      accumulators
          .putIfAbsent(
            entry.key,
            () => _ProductAvailabilityAccumulator(type: entry.key),
          )
          .add(state: state, ruleCount: entry.value.length);
    }
  }

  final rules =
      accumulators.values.map((accumulator) => accumulator.toEntry()).toList()
        ..sort(_compareAvailabilityEntries);

  return ProductAvailabilityManagementOverview(
    channelProfile: channelProfile,
    summary: ProductAvailabilityManagementSummary(
      productCount: records.length,
      availabilityRuleTypeCount:
          rules
              .where(
                (rule) => rule.type != ProductAvailabilityRuleType.unconfigured,
              )
              .length,
      configuredProductCount: configuredProductIds.length,
      openAvailabilityProductCount: openAvailabilityProductIds.length,
      availabilityRuleCount: rules.fold(
        0,
        (total, rule) => total + rule.ruleCount,
      ),
      conflictProductCount: conflictProductIds.length,
      gatedProductCount: gatedProductIds.length,
      stockBlockedProductCount: stockBlockedProductIds.length,
      untrackedProductCount: untrackedProductIds.length,
      availabilityRiskProductCount: riskProductIds.length,
      totalInventoryValue: records.fold(
        0,
        (total, record) => total + record.inventoryValue,
      ),
    ),
    rules: rules,
  );
}

List<ProductAvailabilityRuleSignal> productAvailabilityRuleSignalsFor(
  Product product,
) {
  final signals = <ProductAvailabilityRuleSignal>[];

  for (final entry in product.customAttributes.entries) {
    final normalizedKey = _normalizedAvailabilityAttributeKey(entry.key);
    final values = _availabilityTargetsFromValue(entry.value).toList();
    if (values.isEmpty) continue;

    if (_channelIncludeAttributeKeys.contains(normalizedKey)) {
      signals.addAll(
        values.map(
          (value) => ProductAvailabilityRuleSignal(
            type: ProductAvailabilityRuleType.channelAccess,
            value: value,
          ),
        ),
      );
      continue;
    }

    if (_channelExcludeAttributeKeys.contains(normalizedKey)) {
      signals.addAll(
        values.map(
          (value) => ProductAvailabilityRuleSignal(
            type: ProductAvailabilityRuleType.channelAccess,
            value: value,
            isDisabledChannel: true,
          ),
        ),
      );
      continue;
    }

    if (_statusAttributeKeys.contains(normalizedKey)) {
      signals.addAll(
        values.map(
          (value) => ProductAvailabilityRuleSignal(
            type: ProductAvailabilityRuleType.salesStatus,
            value: value,
            isBlocking: _looksLikeBlockingStatus(value),
          ),
        ),
      );
      continue;
    }

    if (_stockPolicyAttributeKeys.contains(normalizedKey)) {
      signals.addAll(
        values.map(
          (value) => ProductAvailabilityRuleSignal(
            type: ProductAvailabilityRuleType.stockPolicy,
            value: value,
            isStockRequired: _stockPolicyRequiresStock(normalizedKey, value),
          ),
        ),
      );
      continue;
    }

    if (_scheduleAttributeKeys.contains(normalizedKey)) {
      signals.addAll(
        values.map(
          (value) => ProductAvailabilityRuleSignal(
            type: ProductAvailabilityRuleType.scheduleWindow,
            value: value,
            isBlocking: _looksLikeBlockingSchedule(value),
          ),
        ),
      );
      continue;
    }

    if (_fulfillmentAttributeKeys.contains(normalizedKey)) {
      signals.addAll(
        values.map(
          (value) => ProductAvailabilityRuleSignal(
            type: ProductAvailabilityRuleType.fulfillmentMode,
            value: value,
          ),
        ),
      );
    }
  }

  return List.unmodifiable(signals);
}

String productAvailabilityRuleTypeTitle(ProductAvailabilityRuleType type) {
  switch (type) {
    case ProductAvailabilityRuleType.unconfigured:
      return 'Unconfigured products';
    case ProductAvailabilityRuleType.channelAccess:
      return 'Channel access';
    case ProductAvailabilityRuleType.salesStatus:
      return 'Sales status';
    case ProductAvailabilityRuleType.stockPolicy:
      return 'Stock policy';
    case ProductAvailabilityRuleType.scheduleWindow:
      return 'Schedule window';
    case ProductAvailabilityRuleType.fulfillmentMode:
      return 'Fulfillment modes';
  }
}

class _ProductAvailabilityProductState {
  _ProductAvailabilityProductState({
    required this.record,
    required List<ProductAvailabilityRuleSignal> signals,
  }) : signals = List.unmodifiable(signals);

  factory _ProductAvailabilityProductState.fromRecord(
    InventoryProductCatalogRecord record,
  ) {
    return _ProductAvailabilityProductState(
      record: record,
      signals: productAvailabilityRuleSignalsFor(record.product),
    );
  }

  final InventoryProductCatalogRecord record;
  final List<ProductAvailabilityRuleSignal> signals;

  String get id => record.id;
  bool get isConfigured => signals.isNotEmpty;
  bool get isUntracked =>
      record.status == InventoryProductCatalogStatus.untracked;
  bool get hasGate => signals.any((signal) => signal.isBlocking);
  bool get isStockBlocked {
    return signals.any((signal) => signal.isStockRequired) &&
        record.needsAttention;
  }

  bool get hasConflict {
    final enabledChannels = {
      for (final signal in signals)
        if (signal.type == ProductAvailabilityRuleType.channelAccess &&
            !signal.isDisabledChannel)
          _normalizedAvailabilityValue(signal.value),
    };
    final disabledChannels = {
      for (final signal in signals)
        if (signal.type == ProductAvailabilityRuleType.channelAccess &&
            signal.isDisabledChannel)
          _normalizedAvailabilityValue(signal.value),
    };

    enabledChannels.remove('');
    disabledChannels.remove('');

    return enabledChannels.any(disabledChannels.contains);
  }

  Map<ProductAvailabilityRuleType, List<ProductAvailabilityRuleSignal>>
  get signalsByType {
    final grouped =
        <ProductAvailabilityRuleType, List<ProductAvailabilityRuleSignal>>{};
    for (final signal in signals) {
      grouped.putIfAbsent(signal.type, () => []).add(signal);
    }

    return grouped;
  }
}

class _ProductAvailabilityAccumulator {
  _ProductAvailabilityAccumulator({required this.type});

  final ProductAvailabilityRuleType type;
  final productIds = <String>{};
  final conflictProductIds = <String>{};
  final gatedProductIds = <String>{};
  final stockBlockedProductIds = <String>{};
  final untrackedProductIds = <String>{};
  var ruleCount = 0;
  var totalInventoryValue = 0.0;

  void add({
    required _ProductAvailabilityProductState state,
    int ruleCount = 0,
  }) {
    if (productIds.add(state.id)) {
      totalInventoryValue += state.record.inventoryValue;
    }
    this.ruleCount += ruleCount;

    if (state.hasConflict) conflictProductIds.add(state.id);
    if (state.hasGate) gatedProductIds.add(state.id);
    if (state.isStockBlocked) stockBlockedProductIds.add(state.id);
    if (state.isUntracked) untrackedProductIds.add(state.id);
  }

  ProductAvailabilityManagementEntry toEntry() {
    final title = productAvailabilityRuleTypeTitle(type);
    final hasStockIssue =
        stockBlockedProductIds.isNotEmpty || untrackedProductIds.isNotEmpty;

    return ProductAvailabilityManagementEntry(
      type: type,
      id: type.name,
      title: title,
      productCount: productIds.length,
      ruleCount: ruleCount,
      conflictProductCount: conflictProductIds.length,
      gatedProductCount: gatedProductIds.length,
      stockBlockedProductCount: stockBlockedProductIds.length,
      untrackedProductCount: untrackedProductIds.length,
      totalInventoryValue: totalInventoryValue,
      reviewTarget: ProductCatalogReviewTarget(
        filter:
            conflictProductIds.isEmpty && hasStockIssue
                ? InventoryProductCatalogFilter.attention
                : InventoryProductCatalogFilter.all,
        title: 'Availability rules',
        reasonLabel:
            type == ProductAvailabilityRuleType.unconfigured
                ? 'missing availability rules'
                : '${title.toLowerCase()} products',
      ),
    );
  }
}

int _compareAvailabilityEntries(
  ProductAvailabilityManagementEntry first,
  ProductAvailabilityManagementEntry second,
) {
  final statusRank = first.status.index.compareTo(second.status.index);
  if (statusRank != 0) return statusRank;

  final riskRank = second.riskCount.compareTo(first.riskCount);
  if (riskRank != 0) return riskRank;

  final typeRank = _availabilityTypeSortRank(
    first.type,
  ).compareTo(_availabilityTypeSortRank(second.type));
  if (typeRank != 0) return typeRank;

  final productRank = second.productCount.compareTo(first.productCount);
  if (productRank != 0) return productRank;

  return first.title.compareTo(second.title);
}

int _availabilityTypeSortRank(ProductAvailabilityRuleType type) {
  switch (type) {
    case ProductAvailabilityRuleType.unconfigured:
      return 0;
    case ProductAvailabilityRuleType.channelAccess:
      return 1;
    case ProductAvailabilityRuleType.salesStatus:
      return 2;
    case ProductAvailabilityRuleType.stockPolicy:
      return 3;
    case ProductAvailabilityRuleType.scheduleWindow:
      return 4;
    case ProductAvailabilityRuleType.fulfillmentMode:
      return 5;
  }
}

Iterable<String> _availabilityTargetsFromValue(String value) {
  return value
      .split(RegExp(r'(?:[,;|\n]|\s+[+/]\s+)'))
      .map((target) => target.trim())
      .where((target) => target.isNotEmpty);
}

bool _looksLikeBlockingStatus(String value) {
  final normalized = _normalizedAvailabilityValue(value);
  return _blockingStatusValues.contains(normalized);
}

bool _looksLikeBlockingSchedule(String value) {
  final normalized = _normalizedAvailabilityValue(value);
  return _blockingScheduleValues.contains(normalized);
}

bool _stockPolicyRequiresStock(String key, String value) {
  final normalizedValue = _normalizedAvailabilityValue(value);
  if (key == 'allow_backorder' ||
      key == 'backorder' ||
      key == 'preorder' ||
      key == 'pre_order') {
    return _negativeValues.contains(normalizedValue);
  }

  return _stockRequiredValues.contains(normalizedValue);
}

String _normalizedAvailabilityAttributeKey(String key) {
  return key.trim().toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');
}

String _normalizedAvailabilityValue(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
}

String _countLabel(int count, String label) {
  return count == 1 ? '1 $label' : '$count ${label}s';
}

const _channelIncludeAttributeKeys = {
  'available_channel',
  'available_channels',
  'availability_channel',
  'availability_channels',
  'channel',
  'channels',
  'sales_channel',
  'sales_channels',
  'sellable_channel',
  'sellable_channels',
  'enabled_channel',
  'enabled_channels',
  'publish_channel',
  'publish_channels',
};

const _channelExcludeAttributeKeys = {
  'unavailable_channel',
  'unavailable_channels',
  'disabled_channel',
  'disabled_channels',
  'blocked_channel',
  'blocked_channels',
  'excluded_channel',
  'excluded_channels',
  'hidden_channel',
  'hidden_channels',
};

const _statusAttributeKeys = {
  'availability_status',
  'sales_status',
  'sellable_status',
  'publish_status',
  'product_status',
  'visibility',
};

const _stockPolicyAttributeKeys = {
  'stock_policy',
  'inventory_policy',
  'selling_policy',
  'sell_when_out_of_stock',
  'allow_backorder',
  'backorder',
  'preorder',
  'pre_order',
};

const _scheduleAttributeKeys = {
  'available_from',
  'available_until',
  'start_date',
  'end_date',
  'launch_date',
  'availability_window',
  'schedule',
  'daypart',
  'sale_window',
};

const _fulfillmentAttributeKeys = {
  'fulfillment',
  'fulfillment_mode',
  'fulfillment_modes',
  'service_mode',
  'service_modes',
  'pickup',
  'delivery',
  'dine_in',
  'shipping',
};

const _blockingStatusValues = {
  'archived',
  'blocked',
  'disabled',
  'draft',
  'hidden',
  'inactive',
  'paused',
  'retired',
  'unavailable',
};

const _blockingScheduleValues = {
  'blackout',
  'closed',
  'ended',
  'expired',
  'paused',
  'suspended',
};

const _stockRequiredValues = {
  'available_stock',
  'deny_oos',
  'in_stock',
  'in_stock_only',
  'no_backorder',
  'requires_stock',
  'stock_required',
  'track_stock',
};

const _negativeValues = {'0', 'false', 'n', 'no', 'off'};
