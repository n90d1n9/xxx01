import 'package:flutter/material.dart';

import '../models/financial_report_release_action_queue.dart';
import 'financial_report_release_signoff_shared.dart';
import 'financial_report_tinted_surface_components.dart';

class FinancialReportReleaseSectionNavigator extends StatelessWidget {
  const FinancialReportReleaseSectionNavigator({
    required this.selectedDestination,
    required this.onSelect,
    super.key,
  });

  final FinancialReportReleaseActionDestination? selectedDestination;
  final ValueChanged<FinancialReportReleaseActionDestination> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FinancialReportReleaseSignOffSurface(
      child: LayoutBuilder(
        builder: (context, constraints) {
          const spacing = 8.0;
          final columns =
              constraints.maxWidth >= 920
                  ? 3
                  : constraints.maxWidth >= 620
                  ? 2
                  : 1;
          final itemWidth =
              columns == 1
                  ? constraints.maxWidth
                  : (constraints.maxWidth - (spacing * (columns - 1))) /
                      columns;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FinancialReportReleaseSignOffIcon(
                    icon: Icons.route_rounded,
                    color: colorScheme.primary,
                    size: 38,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Release Sections',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FinancialReportReleaseSignOffBadge(
                    label: '${_sectionItems.length} controls',
                    color: colorScheme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final item in _sectionItems)
                    _ReleaseSectionButton(
                      item: item,
                      width: itemWidth,
                      selected: selectedDestination == item.destination,
                      onPressed: () => onSelect(item.destination),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReleaseSectionButton extends StatelessWidget {
  const _ReleaseSectionButton({
    required this.item,
    required this.width,
    required this.selected,
    required this.onPressed,
  });

  final _ReleaseSectionItem item;
  final double width;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = _sectionColor(item.destination, colorScheme);
    final borderColor =
        selected ? color.withValues(alpha: 0.72) : colorScheme.outlineVariant;
    final backgroundColor =
        selected
            ? color.withValues(alpha: 0.1)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.34);

    return SizedBox(
      width: width,
      child: Tooltip(
        message: item.tooltip,
        child: Semantics(
          button: true,
          selected: selected,
          label: item.tooltip,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: ValueKey('release-section-${item.destination.name}'),
              borderRadius: BorderRadius.circular(8),
              onTap: onPressed,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                constraints: const BoxConstraints(minHeight: 72),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    FinancialReportTintedSurface(
                      color: color,
                      width: 36,
                      minHeight: 36,
                      padding: EdgeInsets.zero,
                      fillAlpha: selected ? 0.14 : 0.08,
                      borderAlpha: selected ? 0.3 : 0.18,
                      child: Center(
                        child: Icon(item.icon, color: color, size: 19),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child:
                          selected
                              ? Icon(
                                Icons.check_circle_rounded,
                                key: const ValueKey('selected'),
                                color: color,
                                size: 18,
                              )
                              : Icon(
                                Icons.chevron_right_rounded,
                                key: const ValueKey('idle'),
                                color: colorScheme.onSurfaceVariant,
                                size: 18,
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReleaseSectionItem {
  const _ReleaseSectionItem({
    required this.destination,
    required this.label,
    required this.caption,
    required this.tooltip,
    required this.icon,
  });

  final FinancialReportReleaseActionDestination destination;
  final String label;
  final String caption;
  final String tooltip;
  final IconData icon;
}

const _sectionItems = [
  _ReleaseSectionItem(
    destination: FinancialReportReleaseActionDestination.signOff,
    label: 'Sign-off',
    caption: 'Approval gate',
    tooltip: 'Open release sign-off',
    icon: Icons.verified_user_rounded,
  ),
  _ReleaseSectionItem(
    destination: FinancialReportReleaseActionDestination.evidenceManifest,
    label: 'Evidence',
    caption: 'Manifest',
    tooltip: 'Open release evidence manifest',
    icon: Icons.fact_check_rounded,
  ),
  _ReleaseSectionItem(
    destination: FinancialReportReleaseActionDestination.distribution,
    label: 'Distribution',
    caption: 'Recipients',
    tooltip: 'Open release distribution',
    icon: Icons.outbox_rounded,
  ),
  _ReleaseSectionItem(
    destination: FinancialReportReleaseActionDestination.archive,
    label: 'Archive',
    caption: 'Custody',
    tooltip: 'Open release archive',
    icon: Icons.inventory_2_rounded,
  ),
  _ReleaseSectionItem(
    destination: FinancialReportReleaseActionDestination.retention,
    label: 'Retention',
    caption: 'Review',
    tooltip: 'Open archive retention',
    icon: Icons.event_repeat_rounded,
  ),
  _ReleaseSectionItem(
    destination: FinancialReportReleaseActionDestination.statutoryFiling,
    label: 'Filing',
    caption: 'Tax support',
    tooltip: 'Open statutory filing',
    icon: Icons.account_balance_rounded,
  ),
];

Color _sectionColor(
  FinancialReportReleaseActionDestination destination,
  ColorScheme colorScheme,
) {
  switch (destination) {
    case FinancialReportReleaseActionDestination.signOff:
      return colorScheme.primary;
    case FinancialReportReleaseActionDestination.evidenceManifest:
      return Colors.teal.shade700;
    case FinancialReportReleaseActionDestination.distribution:
      return Colors.indigo.shade600;
    case FinancialReportReleaseActionDestination.archive:
      return Colors.blueGrey.shade700;
    case FinancialReportReleaseActionDestination.retention:
      return Colors.amber.shade800;
    case FinancialReportReleaseActionDestination.statutoryFiling:
      return Colors.deepPurple.shade600;
    case FinancialReportReleaseActionDestination.reportPack:
    case FinancialReportReleaseActionDestination
        .managementMeasureReleaseChecklist:
    case FinancialReportReleaseActionDestination.managementMeasureApprovalCheck:
    case FinancialReportReleaseActionDestination
        .managementMeasureReconciliationCheck:
    case FinancialReportReleaseActionDestination
        .managementMeasureExportEvidenceCheck:
    case FinancialReportReleaseActionDestination.managementMeasureAuditTrail:
      return colorScheme.secondary;
  }
}
