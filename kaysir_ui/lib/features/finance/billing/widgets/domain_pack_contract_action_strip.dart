import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/domain_pack_contract_action_group.dart';
import '../utils/billing_business_domain_pack_readiness.dart';
import '../utils/billing_business_domain_pack_remediation.dart';
import '../utils/billing_business_domain_packs.dart';
import 'billing_navigation_destination.dart';

/// Reusable shortcut strip for billing domain-pack contract remediation.
class DomainPackContractActionStrip extends StatelessWidget {
  final List<BillingBusinessDomainPackRemediationAction> actions;
  final ValueChanged<BillingNavigationDestinationId>? onDestinationSelected;
  final int maxVisibleActions;

  const DomainPackContractActionStrip({
    super.key,
    required this.actions,
    this.onDestinationSelected,
    this.maxVisibleActions = 2,
  }) : assert(maxVisibleActions > 0);

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty || onDestinationSelected == null) {
      return const SizedBox.shrink();
    }

    final actionGroups = DomainPackContractActionGroup.fromActions(actions);
    final visibleGroups = actionGroups.take(maxVisibleActions).toList();
    final hiddenActionCount = actionGroups
        .skip(visibleGroups.length)
        .fold(0, (total, group) => total + group.actionCount);

    return Wrap(
      key: const ValueKey('domain-pack-contract-action-strip'),
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final actionGroup in visibleGroups)
          _ContractActionButton(
            actionGroup: actionGroup,
            onDestinationSelected: onDestinationSelected,
          ),
        if (hiddenActionCount > 0)
          Text(
            '+$hiddenActionCount more '
            '${_plural(hiddenActionCount, 'action')}',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
      ],
    );
  }
}

@Preview(name: 'Domain pack contract action strip')
Widget domainPackContractActionStripPreview() {
  final registryReadiness =
      BillingBusinessDomainPackRegistryReadinessReport.forRegistry(
        standardBillingDomainPackRegistry(),
      );
  final plan = BillingBusinessDomainPackRegistryRemediationPlan.forReadiness(
    registryReadiness,
  );

  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 560,
          child: DomainPackContractActionStrip(
            actions: plan.actions,
            onDestinationSelected: (_) {},
          ),
        ),
      ),
    ),
  );
}

class _ContractActionButton extends StatelessWidget {
  final DomainPackContractActionGroup actionGroup;
  final ValueChanged<BillingNavigationDestinationId>? onDestinationSelected;

  const _ContractActionButton({
    required this.actionGroup,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        actionGroup.isBlocker
            ? const Color(0xFFB91C1C)
            : const Color(0xFFB45309);

    return Tooltip(
      message: actionGroup.tooltipLabel,
      child: TextButton.icon(
        key: ValueKey(
          'domain-pack-contract-open-${actionGroup.primaryAction.id}',
        ),
        onPressed: () => onDestinationSelected?.call(actionGroup.destinationId),
        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
        label: Text(actionGroup.displayLabel),
        style: TextButton.styleFrom(
          foregroundColor: color,
          minimumSize: const Size(0, 34),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

String _plural(int count, String singular) {
  return count == 1 ? singular : '${singular}s';
}
