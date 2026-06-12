import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../utils/product_count_capture_view.dart';

class ProductCountCaptureSelectedTargetPanel extends StatelessWidget {
  const ProductCountCaptureSelectedTargetPanel({
    super.key,
    required this.target,
  });

  final ProductCountCaptureTarget? target;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (target == null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.45,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            'Select a product to review system stock before saving.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return ProductCountCaptureTargetCard(target: target!);
  }
}

class ProductCountCaptureSuggestionTile extends StatelessWidget {
  const ProductCountCaptureSuggestionTile({
    super.key,
    required this.target,
    required this.isSelected,
    required this.onSelected,
  });

  final ProductCountCaptureTarget target;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ProductCountCaptureTargetCard(
      target: target,
      trailing: IconButton.outlined(
        tooltip: 'Select ${target.nameLabel}',
        icon: Icon(isSelected ? Icons.check_rounded : Icons.add_task_rounded),
        onPressed: onSelected,
      ),
    );
  }
}

class ProductCountCaptureTargetCard extends StatelessWidget {
  const ProductCountCaptureTargetCard({
    super.key,
    required this.target,
    this.trailing,
  });

  final ProductCountCaptureTarget target;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor =
        target.needsCount
            ? Colors.orange
            : target.variance == 0
            ? Colors.green
            : theme.colorScheme.error;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: statusColor.withValues(alpha: 0.12),
              child: Icon(Icons.inventory_2_rounded, color: statusColor),
            ),
            const SizedBox(width: 12),
            Expanded(child: _TargetDetails(target: target, color: statusColor)),
            if (trailing != null) ...[const SizedBox(width: 10), trailing!],
          ],
        ),
      ),
    );
  }
}

class _TargetDetails extends StatelessWidget {
  const _TargetDetails({required this.target, required this.color});

  final ProductCountCaptureTarget target;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          target.nameLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${target.skuLabel} | ${target.barcodeLabel} | ${target.categoryLabel}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            AppStatusPill(label: target.countStatusLabel, color: color),
            AppStatusPill(
              label: 'System ${target.systemStock}',
              color: theme.colorScheme.primary,
            ),
            AppStatusPill(
              label: 'Actual ${target.actualStockLabel}',
              color: theme.colorScheme.secondary,
            ),
          ],
        ),
      ],
    );
  }
}
