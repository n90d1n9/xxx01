import '../../../point_of_sales/order/models/order.dart' as pos_order;

enum OrderFulfillmentPromisePolicyIssueType {
  nonPositiveWarningWindow,
  blankDefaultTargetId,
  blankDefaultTargetLabel,
  nonPositiveDefaultTargetDuration,
  blankRuleId,
  duplicateRuleId,
  blankRuleLabel,
  ruleWithoutMatcher,
  duplicateRuleMatcher,
  blankRuleTargetId,
  blankRuleTargetLabel,
  nonPositiveRuleTargetDuration,
}

class OrderFulfillmentPromisePolicyIssue {
  final OrderFulfillmentPromisePolicyIssueType type;
  final String message;
  final String? ruleId;

  const OrderFulfillmentPromisePolicyIssue({
    required this.type,
    required this.message,
    this.ruleId,
  });

  @override
  String toString() => message;
}

class OrderFulfillmentPromiseTarget {
  final String id;
  final String label;
  final Duration duration;

  const OrderFulfillmentPromiseTarget({
    required this.id,
    required this.label,
    required this.duration,
  });
}

class OrderFulfillmentPromiseRule {
  final String id;
  final String label;
  final String? channelId;
  final String? fulfillmentModeKey;
  final OrderFulfillmentPromiseTarget target;

  const OrderFulfillmentPromiseRule({
    required this.id,
    required this.label,
    required this.target,
    this.channelId,
    this.fulfillmentModeKey,
  });

  bool matches(pos_order.Order order) {
    final fulfillment = order.fulfillment;
    if (fulfillment == null) return false;

    final ruleChannel = channelId?.trim().toLowerCase();
    if (ruleChannel != null &&
        ruleChannel != fulfillment.commerceChannelId.trim().toLowerCase()) {
      return false;
    }

    final ruleMode =
        fulfillmentModeKey == null
            ? null
            : compactPromiseKey(fulfillmentModeKey!);
    if (ruleMode != null &&
        ruleMode != compactPromiseKey(fulfillment.fulfillmentModeKey)) {
      return false;
    }

    return ruleChannel != null || ruleMode != null;
  }

  int get specificity {
    var score = 0;
    if (channelId?.trim().isNotEmpty ?? false) score += 2;
    if (fulfillmentModeKey?.trim().isNotEmpty ?? false) score += 1;
    return score;
  }
}

class OrderFulfillmentPromisePolicy {
  final Duration warningWindow;
  final OrderFulfillmentPromiseTarget defaultTarget;
  final List<OrderFulfillmentPromiseRule> rules;

  const OrderFulfillmentPromisePolicy({
    this.warningWindow = const Duration(minutes: 15),
    this.defaultTarget = ecommerceStandardPromiseTarget,
    this.rules = ecommerceDefaultOrderFulfillmentPromiseRules,
  });

  OrderFulfillmentPromisePolicy.withRules({
    Duration warningWindow = const Duration(minutes: 15),
    OrderFulfillmentPromiseTarget defaultTarget =
        ecommerceStandardPromiseTarget,
    required List<OrderFulfillmentPromiseRule> rules,
  }) : this(
         warningWindow: warningWindow,
         defaultTarget: defaultTarget,
         rules: List.unmodifiable(rules),
       );

  OrderFulfillmentPromisePolicy copyWith({
    Duration? warningWindow,
    OrderFulfillmentPromiseTarget? defaultTarget,
    List<OrderFulfillmentPromiseRule>? rules,
  }) {
    return OrderFulfillmentPromisePolicy.withRules(
      warningWindow: warningWindow ?? this.warningWindow,
      defaultTarget: defaultTarget ?? this.defaultTarget,
      rules: rules ?? this.rules,
    );
  }

  OrderFulfillmentPromiseRule? ruleFor(pos_order.Order order) {
    OrderFulfillmentPromiseRule? bestRule;
    var bestScore = -1;

    for (final rule in rules) {
      if (!rule.matches(order)) continue;

      final score = rule.specificity;
      if (score > bestScore) {
        bestRule = rule;
        bestScore = score;
      }
    }

    return bestRule;
  }

  OrderFulfillmentPromiseTarget targetFor(pos_order.Order order) {
    return ruleFor(order)?.target ?? defaultTarget;
  }

  List<OrderFulfillmentPromisePolicyIssue> validate() {
    final issues = <OrderFulfillmentPromisePolicyIssue>[];

    if (warningWindow <= Duration.zero) {
      issues.add(
        const OrderFulfillmentPromisePolicyIssue(
          type: OrderFulfillmentPromisePolicyIssueType.nonPositiveWarningWindow,
          message:
              ' fulfillment promise warning window must be greater than zero.',
        ),
      );
    }

    _validateTarget(
      issues: issues,
      target: defaultTarget,
      blankIdType: OrderFulfillmentPromisePolicyIssueType.blankDefaultTargetId,
      blankLabelType:
          OrderFulfillmentPromisePolicyIssueType.blankDefaultTargetLabel,
      nonPositiveDurationType:
          OrderFulfillmentPromisePolicyIssueType
              .nonPositiveDefaultTargetDuration,
      messagePrefix: 'Default ecommerce fulfillment promise target',
    );

    final seenRuleIds = <String>{};
    final reportedRuleIds = <String>{};
    final seenMatchers = <String>{};
    final reportedMatchers = <String>{};

    for (final rule in rules) {
      final normalizedRuleId = rule.id.trim();
      final label = normalizedRuleId.isEmpty ? 'unknown' : normalizedRuleId;

      if (normalizedRuleId.isEmpty) {
        issues.add(
          const OrderFulfillmentPromisePolicyIssue(
            type: OrderFulfillmentPromisePolicyIssueType.blankRuleId,
            message: ' fulfillment promise rule id cannot be blank.',
          ),
        );
      } else if (!seenRuleIds.add(normalizedRuleId) &&
          reportedRuleIds.add(normalizedRuleId)) {
        issues.add(
          OrderFulfillmentPromisePolicyIssue(
            type: OrderFulfillmentPromisePolicyIssueType.duplicateRuleId,
            ruleId: normalizedRuleId,
            message:
                'Duplicate ecommerce fulfillment promise rule id "$normalizedRuleId" found.',
          ),
        );
      }

      if (rule.label.trim().isEmpty) {
        issues.add(
          OrderFulfillmentPromisePolicyIssue(
            type: OrderFulfillmentPromisePolicyIssueType.blankRuleLabel,
            ruleId: normalizedRuleId,
            message:
                ' fulfillment promise rule "$label" label cannot be blank.',
          ),
        );
      }

      final matcherKey = _matcherKey(rule);
      if (matcherKey == null) {
        issues.add(
          OrderFulfillmentPromisePolicyIssue(
            type: OrderFulfillmentPromisePolicyIssueType.ruleWithoutMatcher,
            ruleId: normalizedRuleId,
            message:
                ' fulfillment promise rule "$label" must define a channel id, fulfillment mode key, or both.',
          ),
        );
      } else if (!seenMatchers.add(matcherKey) &&
          reportedMatchers.add(matcherKey)) {
        issues.add(
          OrderFulfillmentPromisePolicyIssue(
            type: OrderFulfillmentPromisePolicyIssueType.duplicateRuleMatcher,
            ruleId: normalizedRuleId,
            message:
                'Duplicate ecommerce fulfillment promise matcher "$matcherKey" found.',
          ),
        );
      }

      _validateTarget(
        issues: issues,
        target: rule.target,
        blankIdType: OrderFulfillmentPromisePolicyIssueType.blankRuleTargetId,
        blankLabelType:
            OrderFulfillmentPromisePolicyIssueType.blankRuleTargetLabel,
        nonPositiveDurationType:
            OrderFulfillmentPromisePolicyIssueType
                .nonPositiveRuleTargetDuration,
        messagePrefix: ' fulfillment promise rule "$label" target',
        ruleId: normalizedRuleId,
      );
    }

    return List.unmodifiable(issues);
  }

  bool get isValid => validate().isEmpty;

  void throwIfInvalid() {
    final issues = validate();
    if (issues.isEmpty) return;

    throw StateError(
      ' fulfillment promise policy is invalid: '
      '${issues.map((issue) => issue.message).join(' ')}',
    );
  }
}

const ecommerceStandardPromiseTarget = OrderFulfillmentPromiseTarget(
  id: 'standard',
  label: 'Standard promise',
  duration: Duration(hours: 2),
);

const ecommerceCourierPrepPromiseTarget = OrderFulfillmentPromiseTarget(
  id: 'courier_prep',
  label: 'Courier prep',
  duration: Duration(minutes: 35),
);

const ecommerceAccountStagingPromiseTarget = OrderFulfillmentPromiseTarget(
  id: 'account_stage',
  label: 'Account staging',
  duration: Duration(days: 2),
);

const ecommerceMarketplaceShipPromiseTarget = OrderFulfillmentPromiseTarget(
  id: 'marketplace_ship',
  label: 'Marketplace ship',
  duration: Duration(hours: 12),
);

const ecommerceImmediateHandoffPromiseTarget = OrderFulfillmentPromiseTarget(
  id: 'immediate',
  label: 'Immediate handoff',
  duration: Duration(minutes: 15),
);

const ecommercePickupPromiseTarget = OrderFulfillmentPromiseTarget(
  id: 'pickup',
  label: 'Pickup promise',
  duration: Duration(minutes: 45),
);

const ecommerceDeliveryPromiseTarget = OrderFulfillmentPromiseTarget(
  id: 'delivery',
  label: 'Delivery promise',
  duration: Duration(hours: 1),
);

const ecommerceShipmentPromiseTarget = OrderFulfillmentPromiseTarget(
  id: 'shipment',
  label: 'Shipment promise',
  duration: Duration(days: 1),
);

const ecommercePreorderPromiseTarget = OrderFulfillmentPromiseTarget(
  id: 'preorder',
  label: 'Scheduled promise',
  duration: Duration(days: 2),
);

const ecommerceDefaultOrderFulfillmentPromiseRules =
    <OrderFulfillmentPromiseRule>[
      OrderFulfillmentPromiseRule(
        id: 'marketplace_shipment',
        label: 'Marketplace shipment',
        channelId: 'marketplace',
        fulfillmentModeKey: 'shipment',
        target: ecommerceMarketplaceShipPromiseTarget,
      ),
      OrderFulfillmentPromiseRule(
        id: 'delivery_app',
        label: 'Delivery app courier prep',
        channelId: 'delivery_app',
        target: ecommerceCourierPrepPromiseTarget,
      ),
      OrderFulfillmentPromiseRule(
        id: 'wholesale',
        label: 'Wholesale account staging',
        channelId: 'wholesale',
        target: ecommerceAccountStagingPromiseTarget,
      ),
      OrderFulfillmentPromiseRule(
        id: 'immediate_handoff',
        label: 'Immediate handoff',
        fulfillmentModeKey: 'immediate_handoff',
        target: ecommerceImmediateHandoffPromiseTarget,
      ),
      OrderFulfillmentPromiseRule(
        id: 'table_service',
        label: 'Table service',
        fulfillmentModeKey: 'table_service',
        target: ecommerceImmediateHandoffPromiseTarget,
      ),
      OrderFulfillmentPromiseRule(
        id: 'pickup',
        label: 'Pickup',
        fulfillmentModeKey: 'pickup',
        target: ecommercePickupPromiseTarget,
      ),
      OrderFulfillmentPromiseRule(
        id: 'delivery',
        label: 'Delivery',
        fulfillmentModeKey: 'delivery',
        target: ecommerceDeliveryPromiseTarget,
      ),
      OrderFulfillmentPromiseRule(
        id: 'field_delivery',
        label: 'Field delivery',
        fulfillmentModeKey: 'field_delivery',
        target: ecommerceDeliveryPromiseTarget,
      ),
      OrderFulfillmentPromiseRule(
        id: 'shipment',
        label: 'Shipment',
        fulfillmentModeKey: 'shipment',
        target: ecommerceShipmentPromiseTarget,
      ),
      OrderFulfillmentPromiseRule(
        id: 'preorder',
        label: 'Pre-order',
        fulfillmentModeKey: 'preorder',
        target: ecommercePreorderPromiseTarget,
      ),
    ];

String compactPromiseKey(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'[_\s-]+'), '');
}

void _validateTarget({
  required List<OrderFulfillmentPromisePolicyIssue> issues,
  required OrderFulfillmentPromiseTarget target,
  required OrderFulfillmentPromisePolicyIssueType blankIdType,
  required OrderFulfillmentPromisePolicyIssueType blankLabelType,
  required OrderFulfillmentPromisePolicyIssueType nonPositiveDurationType,
  required String messagePrefix,
  String? ruleId,
}) {
  if (target.id.trim().isEmpty) {
    issues.add(
      OrderFulfillmentPromisePolicyIssue(
        type: blankIdType,
        ruleId: ruleId,
        message: '$messagePrefix id cannot be blank.',
      ),
    );
  }

  if (target.label.trim().isEmpty) {
    issues.add(
      OrderFulfillmentPromisePolicyIssue(
        type: blankLabelType,
        ruleId: ruleId,
        message: '$messagePrefix label cannot be blank.',
      ),
    );
  }

  if (target.duration <= Duration.zero) {
    issues.add(
      OrderFulfillmentPromisePolicyIssue(
        type: nonPositiveDurationType,
        ruleId: ruleId,
        message: '$messagePrefix duration must be greater than zero.',
      ),
    );
  }
}

String? _matcherKey(OrderFulfillmentPromiseRule rule) {
  final channel = rule.channelId?.trim().toLowerCase();
  final mode =
      rule.fulfillmentModeKey == null
          ? null
          : compactPromiseKey(rule.fulfillmentModeKey!);
  final hasChannel = channel != null && channel.isNotEmpty;
  final hasMode = mode != null && mode.isNotEmpty;

  if (!hasChannel && !hasMode) return null;
  return 'channel:${hasChannel ? channel : '*'}|mode:${hasMode ? mode : '*'}';
}
