import 'package:flutter/material.dart';

import 'billing_navigation_coverage_badge.dart';
import 'billing_navigation_coverage_summary.dart';
import 'billing_navigation_destination.dart';
import 'billing_navigation_launch_center_model.dart';

class BillingNavigationLaunchCenterHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final BillingNavigationCoverageSummary? coverageSummary;

  const BillingNavigationLaunchCenterHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.coverageSummary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.hub_outlined, color: Color(0xFF2563EB)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        if (coverageSummary != null) ...[
          const SizedBox(width: 12),
          BillingNavigationCoverageBadge(summary: coverageSummary!),
        ],
      ],
    );
  }
}

class BillingNavigationLaunchCenterSection extends StatelessWidget {
  final BillingNavigationLaunchCenterSectionModel section;
  final BillingNavigationDestinationId? selectedDestination;
  final ValueChanged<BillingNavigationDestinationId>? onDestinationSelected;

  const BillingNavigationLaunchCenterSection({
    super.key,
    required this.section,
    required this.selectedDestination,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (section.label?.trim().isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 0, 2, 8),
              child: Text(
                section.label!.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: List.generate(section.entries.length, (index) {
                final entry = section.entries[index];

                return _BillingNavigationLaunchCenterRow(
                  entry: entry,
                  selected: selectedDestination == entry.destination.id,
                  showDivider: index > 0,
                  onDestinationSelected: onDestinationSelected,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class BillingNavigationLaunchCenterEmptyState extends StatelessWidget {
  const BillingNavigationLaunchCenterEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Row(
        children: [
          Icon(Icons.search_off_outlined, color: Color(0xFF64748B)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'No registered billing routes match the current search.',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BillingNavigationLaunchCenterRow extends StatelessWidget {
  final BillingNavigationLaunchCenterEntry entry;
  final bool selected;
  final bool showDivider;
  final ValueChanged<BillingNavigationDestinationId>? onDestinationSelected;

  const _BillingNavigationLaunchCenterRow({
    required this.entry,
    required this.selected,
    required this.showDivider,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final foreground =
        entry.isActionable ? const Color(0xFF0F172A) : const Color(0xFF64748B);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFF0F7FF) : Colors.white,
        border:
            showDivider
                ? const Border(top: BorderSide(color: Color(0xFFE2E8F0)))
                : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 620;
            final action = _BillingNavigationLaunchCenterActionButton(
              entry: entry,
              onDestinationSelected: onDestinationSelected,
            );
            final details = _BillingNavigationLaunchCenterRowDetails(
              entry: entry,
              foreground: foreground,
            );

            if (isCompact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  details,
                  const SizedBox(height: 10),
                  Align(alignment: Alignment.centerRight, child: action),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: details),
                const SizedBox(width: 12),
                action,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BillingNavigationLaunchCenterRowDetails extends StatelessWidget {
  final BillingNavigationLaunchCenterEntry entry;
  final Color foreground;

  const _BillingNavigationLaunchCenterRowDetails({
    required this.entry,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: entry.statusColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            entry.destination.icon,
            size: 21,
            color: entry.statusColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.destination.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foreground,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                entry.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _BillingNavigationLaunchCenterChip(
                    label: entry.statusLabel,
                    color: entry.statusColor,
                    icon: entry.statusIcon,
                  ),
                  _BillingNavigationLaunchCenterChip(
                    label: entry.targetLabel,
                    color: const Color(0xFF334155),
                    icon: Icons.desktop_windows_outlined,
                  ),
                  _BillingNavigationLaunchCenterChip(
                    label: entry.presentationLabel,
                    color: const Color(0xFF7C3AED),
                    icon: Icons.layers_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                entry.screenKey,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BillingNavigationLaunchCenterActionButton extends StatelessWidget {
  final BillingNavigationLaunchCenterEntry entry;
  final ValueChanged<BillingNavigationDestinationId>? onDestinationSelected;

  const _BillingNavigationLaunchCenterActionButton({
    required this.entry,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      key: ValueKey('billing-launch-center-open-${entry.destination.id.name}'),
      onPressed:
          entry.isActionable && onDestinationSelected != null
              ? () => onDestinationSelected!(entry.destination.id)
              : null,
      icon: Icon(entry.opensRoute ? Icons.open_in_new : Icons.arrow_forward),
      label: Text(entry.actionLabel),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF2563EB),
        disabledForegroundColor: const Color(0xFF94A3B8),
        side: BorderSide(
          color:
              entry.isActionable
                  ? const Color(0xFFBFDBFE)
                  : const Color(0xFFE2E8F0),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _BillingNavigationLaunchCenterChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _BillingNavigationLaunchCenterChip({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
