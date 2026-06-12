import '../models/billing_navigation_destination_id.dart';
import 'billing_product_release_channel_launch_plan.dart';
import 'billing_product_release_channel_registry.dart';

class BillingProductReleaseChannelLaunchRouteTarget {
  final BillingNavigationDestinationId destinationId;
  final String callToActionLabel;
  final String operatorStepLabel;
  final List<String> checklistItems;

  BillingProductReleaseChannelLaunchRouteTarget({
    required this.destinationId,
    required this.callToActionLabel,
    required this.operatorStepLabel,
    Iterable<String> checklistItems = const [],
  }) : checklistItems = List.unmodifiable(checklistItems);

  Map<String, Object?> get payload {
    return {
      'destinationId': destinationId.name,
      'callToActionLabel': callToActionLabel,
      'operatorStepLabel': operatorStepLabel,
      'checklistItems': checklistItems,
    };
  }
}

class BillingProductReleaseChannelLaunchRouteRule {
  final String channelKey;
  final BillingNavigationDestinationId publishDestinationId;
  final BillingNavigationDestinationId reviewDestinationId;
  final String publishCallToActionLabel;
  final String reviewCallToActionLabel;
  final List<String> publishChecklistItems;
  final List<String> reviewChecklistItems;

  BillingProductReleaseChannelLaunchRouteRule({
    required String channelId,
    required this.publishDestinationId,
    required this.reviewDestinationId,
    required this.publishCallToActionLabel,
    required this.reviewCallToActionLabel,
    Iterable<String> publishChecklistItems = const [],
    Iterable<String> reviewChecklistItems = const [],
  }) : channelKey = billingProductReleaseChannelKey(channelId),
       publishChecklistItems = List.unmodifiable(publishChecklistItems),
       reviewChecklistItems = List.unmodifiable(reviewChecklistItems) {
    if (channelKey.isEmpty) {
      throw StateError('Billing channel launch route rule needs a channel id.');
    }
    if (publishCallToActionLabel.trim().isEmpty) {
      throw StateError(
        'Billing channel launch route rule $channelKey needs a publish CTA.',
      );
    }
    if (reviewCallToActionLabel.trim().isEmpty) {
      throw StateError(
        'Billing channel launch route rule $channelKey needs a review CTA.',
      );
    }
  }
}

class BillingProductReleaseChannelLaunchRoutePolicy {
  final List<BillingProductReleaseChannelLaunchRouteRule> rules;
  final BillingNavigationDestinationId blockedDestinationId;

  BillingProductReleaseChannelLaunchRoutePolicy({
    Iterable<BillingProductReleaseChannelLaunchRouteRule> rules = const [],
    this.blockedDestinationId = BillingNavigationDestinationId.diagnostics,
  }) : rules = List.unmodifiable(_ensureUniqueRules(rules));

  bool get isEmpty => rules.isEmpty;

  BillingProductReleaseChannelLaunchRouteRule? ruleForChannel(String id) {
    final key = billingProductReleaseChannelKey(id);

    for (final rule in rules) {
      if (rule.channelKey == key) return rule;
    }

    return null;
  }

  BillingProductReleaseChannelLaunchRouteTarget targetFor(
    BillingProductReleaseChannelLaunchAction action,
  ) {
    if (action.isBlocked) {
      return BillingProductReleaseChannelLaunchRouteTarget(
        destinationId: blockedDestinationId,
        callToActionLabel: 'Open diagnostics',
        operatorStepLabel:
            'Clear blockers before releasing ${action.editionLabel} on '
            '${action.channelLabel}.',
        checklistItems: [
          'Review domain readiness issues.',
          'Confirm tenant and release prerequisites.',
          'Re-run the channel launch plan after blockers are cleared.',
        ],
      );
    }

    final rule = ruleForChannel(action.channelKey);
    if (rule == null) {
      return BillingProductReleaseChannelLaunchRouteTarget(
        destinationId: BillingNavigationDestinationId.diagnostics,
        callToActionLabel: 'Review route',
        operatorStepLabel:
            'Register a launch route for ${action.channelLabel}.',
        checklistItems: [
          'Add the channel route rule.',
          'Map it to an exposed billing destination.',
        ],
      );
    }

    if (action.canPublish) {
      return BillingProductReleaseChannelLaunchRouteTarget(
        destinationId: rule.publishDestinationId,
        callToActionLabel: rule.publishCallToActionLabel,
        operatorStepLabel:
            'Publish ${action.editionLabel} through ${action.channelLabel}.',
        checklistItems: rule.publishChecklistItems,
      );
    }

    return BillingProductReleaseChannelLaunchRouteTarget(
      destinationId: rule.reviewDestinationId,
      callToActionLabel: rule.reviewCallToActionLabel,
      operatorStepLabel:
          'Review ${action.editionLabel} readiness for ${action.channelLabel}.',
      checklistItems: rule.reviewChecklistItems,
    );
  }

  static List<BillingProductReleaseChannelLaunchRouteRule> _ensureUniqueRules(
    Iterable<BillingProductReleaseChannelLaunchRouteRule> rules,
  ) {
    final seenKeys = <String>{};
    final uniqueRules = <BillingProductReleaseChannelLaunchRouteRule>[];

    for (final rule in rules) {
      if (!seenKeys.add(rule.channelKey)) {
        throw StateError(
          'Duplicate billing channel launch route rule for '
          '${rule.channelKey}.',
        );
      }
      uniqueRules.add(rule);
    }

    return uniqueRules;
  }
}

BillingProductReleaseChannelLaunchRoutePolicy
standardBillingProductReleaseChannelLaunchRoutePolicy() {
  return BillingProductReleaseChannelLaunchRoutePolicy(
    rules: [
      BillingProductReleaseChannelLaunchRouteRule(
        channelId: 'pos_counter',
        publishDestinationId: BillingNavigationDestinationId.cartCheckout,
        reviewDestinationId: BillingNavigationDestinationId.productWorkspace,
        publishCallToActionLabel: 'Open checkout',
        reviewCallToActionLabel: 'Review catalog',
        publishChecklistItems: const [
          'Verify active catalog items and pricing.',
          'Run a cashier checkout with the target tenant.',
          'Confirm receipts and payment capture.',
        ],
        reviewChecklistItems: const [
          'Check product workspace coverage.',
          'Validate cashier roles and tenant catalog rules.',
        ],
      ),
      BillingProductReleaseChannelLaunchRouteRule(
        channelId: 'admin_back_office',
        publishDestinationId: BillingNavigationDestinationId.dashboard,
        reviewDestinationId: BillingNavigationDestinationId.diagnostics,
        publishCallToActionLabel: 'Open dashboard',
        reviewCallToActionLabel: 'Review readiness',
        publishChecklistItems: const [
          'Confirm operator dashboard health.',
          'Review invoices, collections, and reporting widgets.',
        ],
        reviewChecklistItems: const [
          'Inspect module readiness.',
          'Confirm all billing screens are registered.',
        ],
      ),
      BillingProductReleaseChannelLaunchRouteRule(
        channelId: 'self_serve_portal',
        publishDestinationId: BillingNavigationDestinationId.invoices,
        reviewDestinationId: BillingNavigationDestinationId.reports,
        publishCallToActionLabel: 'Open invoices',
        reviewCallToActionLabel: 'Review insights',
        publishChecklistItems: const [
          'Confirm customer-visible invoice states.',
          'Validate renewal and payment copy.',
        ],
        reviewChecklistItems: const [
          'Review subscription and portal reporting needs.',
          'Confirm account-admin access rules.',
        ],
      ),
      BillingProductReleaseChannelLaunchRouteRule(
        channelId: 'field_operations',
        publishDestinationId: BillingNavigationDestinationId.createInvoice,
        reviewDestinationId: BillingNavigationDestinationId.reports,
        publishCallToActionLabel: 'Create field invoice',
        reviewCallToActionLabel: 'Review field reports',
        publishChecklistItems: const [
          'Create a field-service invoice draft.',
          'Check due terms, tax, and service line item mapping.',
        ],
        reviewChecklistItems: const [
          'Review mobile and field collection readiness.',
          'Confirm project or work-order handoff data.',
        ],
      ),
      BillingProductReleaseChannelLaunchRouteRule(
        channelId: 'partner_api',
        publishDestinationId: BillingNavigationDestinationId.issueOutbox,
        reviewDestinationId: BillingNavigationDestinationId.issueOutbox,
        publishCallToActionLabel: 'Open outbox',
        reviewCallToActionLabel: 'Audit outbox',
        publishChecklistItems: const [
          'Inspect issue command delivery.',
          'Retry and verify partner-facing invoice sync.',
        ],
        reviewChecklistItems: const [
          'Audit failed and pending commands.',
          'Confirm retry policy and integration handoff.',
        ],
      ),
    ],
  );
}
