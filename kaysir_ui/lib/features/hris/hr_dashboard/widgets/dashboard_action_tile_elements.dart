import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_action_summary.dart';
import 'dashboard_action_metadata_chips.dart';

class DashboardActionLeadingIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const DashboardActionLeadingIcon({
    super.key,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 21),
    );
  }
}

class DashboardActionCopy extends StatelessWidget {
  final DashboardActionRecommendation item;
  final bool isNextUp;
  final bool ownerFocused;
  final ValueChanged<String>? onOwnerSelected;
  final VoidCallback? onOwnerCleared;

  const DashboardActionCopy({
    super.key,
    required this.item,
    this.isNextUp = false,
    this.ownerFocused = false,
    this.onOwnerSelected,
    this.onOwnerCleared,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isNextUp) ...[
          const DashboardActionNextUpBadge(),
          const SizedBox(height: 6),
        ],
        Text(
          item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: HrisColors.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          item.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
        ),
        const SizedBox(height: 8),
        DashboardActionMetadataWrap(
          item: item,
          ownerSelected: ownerFocused,
          onOwnerSelected: onOwnerSelected,
          onOwnerCleared: onOwnerCleared,
        ),
      ],
    );
  }
}

class DashboardActionNextUpBadge extends StatelessWidget {
  const DashboardActionNextUpBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Highest visible recommendation',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: HrisColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: HrisColors.primary.withValues(alpha: 0.22)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              size: 14,
              color: HrisColors.primary,
            ),
            const SizedBox(width: 5),
            Text(
              'Next up',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: HrisColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardActionMetric extends StatelessWidget {
  final DashboardActionRecommendation item;
  final Color color;

  const DashboardActionMetric({
    super.key,
    required this.item,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 34, minWidth: 76),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: HrisColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.metricValue,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            item.metricLabel,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: HrisColors.muted),
          ),
        ],
      ),
    );
  }
}

class DashboardActionRouteButton extends StatelessWidget {
  final DashboardActionRecommendation item;

  const DashboardActionRouteButton({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: item.route == null ? null : () => context.go(item.route!),
      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
      label: Text(item.actionLabel),
    );
  }
}
