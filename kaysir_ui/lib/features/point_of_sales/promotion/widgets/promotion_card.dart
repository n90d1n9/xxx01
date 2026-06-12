import 'package:flutter/material.dart';

import '../../cashier/widgets/pos_ui.dart';
import '../models/promotion.dart';
import '../utils/promotion_policy.dart';

class PromotionCard extends StatelessWidget {
  final Promotion promotion;
  final PromotionAvailability availability;
  final VoidCallback onApply;
  final VoidCallback onRemove;

  const PromotionCard({
    super.key,
    required this.promotion,
    required this.availability,
    required this.onApply,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isApplied = availability == PromotionAvailability.applied;
    final isAvailable = availability == PromotionAvailability.available;

    return POSSurface(
      color:
          isApplied
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.32)
              : theme.colorScheme.surface,
      border: Border.all(
        color:
            isApplied
                ? theme.colorScheme.primary.withValues(alpha: 0.24)
                : theme.dividerColor,
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          POSIconBadge(
            icon: Icons.local_offer_outlined,
            backgroundColor:
                isApplied
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.secondaryContainer,
            foregroundColor:
                isApplied
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: POSUiTokens.gapLarge),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        promotion.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: POSUiTokens.gap),
                    POSMetricPill(
                      label: promotionAvailabilityLabel(availability),
                      backgroundColor: _availabilityColor(theme, availability),
                      foregroundColor: _availabilityForeground(
                        theme,
                        availability,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: POSUiTokens.gap),
                Wrap(
                  spacing: POSUiTokens.gap,
                  runSpacing: POSUiTokens.gap,
                  children: [
                    _Tag(label: promotion.code),
                    _Tag(label: promotionBenefitLabel(promotion)),
                    _Tag(
                      label:
                          'Valid ${formatPromotionDate(promotion.validUntil)}',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: POSUiTokens.gapLarge),
          POSActionButton(
            icon: Icon(isApplied ? Icons.close : Icons.add),
            label: isApplied ? 'Remove' : 'Apply',
            variant:
                isApplied
                    ? POSActionButtonVariant.outlined
                    : POSActionButtonVariant.filled,
            onPressed:
                isApplied
                    ? onRemove
                    : isAvailable
                    ? onApply
                    : null,
          ),
        ],
      ),
    );
  }

  Color _availabilityColor(
    ThemeData theme,
    PromotionAvailability availability,
  ) {
    switch (availability) {
      case PromotionAvailability.available:
        return theme.colorScheme.tertiaryContainer;
      case PromotionAvailability.applied:
        return theme.colorScheme.primaryContainer;
      case PromotionAvailability.inactive:
      case PromotionAvailability.expired:
        return theme.colorScheme.errorContainer.withValues(alpha: 0.45);
    }
  }

  Color _availabilityForeground(
    ThemeData theme,
    PromotionAvailability availability,
  ) {
    switch (availability) {
      case PromotionAvailability.available:
        return theme.colorScheme.onTertiaryContainer;
      case PromotionAvailability.applied:
        return theme.colorScheme.onPrimaryContainer;
      case PromotionAvailability.inactive:
      case PromotionAvailability.expired:
        return theme.colorScheme.error;
    }
  }
}

class _Tag extends StatelessWidget {
  final String label;

  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.58,
        ),
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
