import 'package:flutter/material.dart';

import '../models/customer.dart';
import '../utils/customer_lookup.dart';
import 'pos_ui.dart';

class CustomerTile extends StatelessWidget {
  final Customer customer;
  final bool selected;
  final VoidCallback onSelected;

  const CustomerTile({
    super.key,
    required this.customer,
    required this.onSelected,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return POSSurface(
      color:
          selected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.34)
              : theme.colorScheme.surface,
      border: Border.all(
        color:
            selected
                ? theme.colorScheme.primary.withValues(alpha: 0.28)
                : theme.dividerColor,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
        onTap: onSelected,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _CustomerAvatar(name: customer.name, selected: selected),
              const SizedBox(width: POSUiTokens.gapLarge),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      customer.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      customerContactLine(customer),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: POSUiTokens.gapLarge),
              POSMetricPill(
                icon: const Icon(Icons.stars_outlined),
                label: '${customer.loyaltyPoints} pts',
                backgroundColor:
                    selected
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.secondaryContainer,
                foregroundColor:
                    selected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSecondaryContainer,
              ),
              const SizedBox(width: POSUiTokens.gap),
              Icon(
                selected ? Icons.check_circle : Icons.arrow_forward_ios,
                size: selected ? 20 : 16,
                color:
                    selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerAvatar extends StatelessWidget {
  final String name;
  final bool selected;

  const _CustomerAvatar({required this.name, required this.selected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color:
            selected
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
      ),
      child: Text(
        customerInitials(name),
        style: theme.textTheme.labelLarge?.copyWith(
          color:
              selected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
