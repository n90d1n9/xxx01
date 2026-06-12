import 'billing_navigation_destination_id.dart';
import '../utils/billing_business_domain_pack_remediation.dart';
import '../utils/billing_business_domain_pack_remediation_navigation.dart';

/// Presentation grouping for billing domain-pack contract remediation actions.
class DomainPackContractActionGroup {
  final BillingNavigationDestinationId destinationId;
  final String callToActionLabel;
  final List<BillingBusinessDomainPackRemediationAction> actions;

  DomainPackContractActionGroup({
    required this.destinationId,
    required this.callToActionLabel,
    required Iterable<BillingBusinessDomainPackRemediationAction> actions,
  }) : actions = List.unmodifiable(actions) {
    if (this.actions.isEmpty) {
      throw ArgumentError.value(
        actions,
        'actions',
        'A domain-pack contract action group needs at least one action.',
      );
    }
  }

  BillingBusinessDomainPackRemediationAction get primaryAction {
    return actions.first;
  }

  int get actionCount => actions.length;

  bool get isBlocker {
    return actions.any((action) => action.isBlocker);
  }

  String get displayLabel {
    if (actionCount == 1) return callToActionLabel;

    return '$callToActionLabel ($actionCount)';
  }

  String get tooltipLabel {
    if (actionCount == 1) return primaryAction.label;

    final visibleLabels = actions.take(3).map((action) => action.label);
    final hiddenCount = actionCount - visibleLabels.length;
    if (hiddenCount <= 0) return visibleLabels.join('\n');

    return '${visibleLabels.join('\n')}\n+$hiddenCount more '
        '${_plural(hiddenCount, 'action')}';
  }

  static List<DomainPackContractActionGroup> fromActions(
    Iterable<BillingBusinessDomainPackRemediationAction> actions,
  ) {
    final builders = <BillingNavigationDestinationId, _ActionGroupBuilder>{};

    for (final action in actions) {
      final target = billingBusinessDomainPackRemediationNavigationTargetFor(
        action,
      );
      final builder = builders.putIfAbsent(
        target.destinationId,
        () => _ActionGroupBuilder(
          destinationId: target.destinationId,
          callToActionLabel: target.callToActionLabel,
        ),
      );
      builder.actions.add(action);
    }

    return List.unmodifiable(builders.values.map((builder) => builder.build()));
  }
}

class _ActionGroupBuilder {
  final BillingNavigationDestinationId destinationId;
  final String callToActionLabel;
  final List<BillingBusinessDomainPackRemediationAction> actions = [];

  _ActionGroupBuilder({
    required this.destinationId,
    required this.callToActionLabel,
  });

  DomainPackContractActionGroup build() {
    return DomainPackContractActionGroup(
      destinationId: destinationId,
      callToActionLabel: callToActionLabel,
      actions: actions,
    );
  }
}

String _plural(int count, String singular) {
  return count == 1 ? singular : '${singular}s';
}
