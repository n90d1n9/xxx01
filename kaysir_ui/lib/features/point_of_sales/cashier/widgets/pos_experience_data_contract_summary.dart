import 'package:flutter/material.dart';

import '../experiences/pos_data_contract.dart';
import '../experiences/pos_data_trait.dart';
import 'pos_ui.dart';

class POSExperienceDataContractSummary extends StatelessWidget {
  final List<POSDataTraitContract> contracts;

  const POSExperienceDataContractSummary({super.key, required this.contracts});

  @override
  Widget build(BuildContext context) {
    if (contracts.isEmpty) {
      return const Text('No data contracts declared');
    }

    return Column(
      children:
          contracts
              .map((contract) => _DataContractTile(contract: contract))
              .toList(),
    );
  }
}

class _DataContractTile extends StatelessWidget {
  final POSDataTraitContract contract;

  const _DataContractTile({required this.contract});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final trait = POSDataTraits.resolve(contract.traitKey);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(POSUiTokens.radius),
          border: Border.all(color: colorScheme.outlineVariant),
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.28),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              POSIconBadge(
                icon: _areaIcon(trait?.area),
                backgroundColor: colorScheme.primaryContainer.withValues(
                  alpha: 0.54,
                ),
                foregroundColor: colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: POSUiTokens.gapLarge),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contract.traitLabel,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      contract.requiredFieldLabels.join(', '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (contract.recommendedFields.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        'Recommended: ${contract.recommendedFields.map((field) => field.label).join(', ')}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.82,
                          ),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _areaIcon(POSDataTraitArea? area) {
    switch (area) {
      case POSDataTraitArea.catalog:
        return Icons.inventory_2_outlined;
      case POSDataTraitArea.order:
        return Icons.receipt_long_outlined;
      case POSDataTraitArea.customer:
        return Icons.person_outline;
      case POSDataTraitArea.payment:
        return Icons.payments_outlined;
      case POSDataTraitArea.inventory:
        return Icons.warehouse_outlined;
      case POSDataTraitArea.service:
        return Icons.handyman_outlined;
      case POSDataTraitArea.hospitality:
        return Icons.room_service_outlined;
      case POSDataTraitArea.compliance:
        return Icons.verified_user_outlined;
      case null:
        return Icons.schema_outlined;
    }
  }
}
