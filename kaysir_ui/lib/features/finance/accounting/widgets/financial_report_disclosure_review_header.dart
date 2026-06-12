import 'package:flutter/material.dart';

import 'financial_report_responsive_grid_components.dart';
import 'financial_report_disclosure_review_shared.dart';
import 'financial_report_tinted_surface_components.dart';

class FinancialReportDisclosureReviewHeader extends StatelessWidget {
  final String periodLabel;
  final String frameworkName;
  final int totalCount;
  final int unresolvedCount;
  final int approvedCount;
  final double reviewRatio;
  final bool locked;

  const FinancialReportDisclosureReviewHeader({
    required this.periodLabel,
    required this.frameworkName,
    required this.totalCount,
    required this.unresolvedCount,
    required this.approvedCount,
    required this.reviewRatio,
    required this.locked,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent =
        unresolvedCount == 0 ? Colors.teal.shade700 : Colors.orange.shade700;

    return FinancialReportDisclosureSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 720;
              final title = Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FinancialReportDisclosureIcon(
                    icon: Icons.sticky_note_2_rounded,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Financial Notes Center',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$periodLabel | $frameworkName',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
              final status = FinancialReportDisclosureStatusBadge(
                label:
                    locked
                        ? 'Closed period'
                        : unresolvedCount == 0
                        ? 'Ready'
                        : '$unresolvedCount review',
                color: locked ? Colors.blueGrey : accent,
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [title, const SizedBox(height: 12), status],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: title),
                  const SizedBox(width: 16),
                  status,
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          FinancialReportResponsiveWrapGrid<Widget>(
            items: [
              FinancialReportDisclosureMetricCard(
                icon: Icons.article_outlined,
                label: 'Disclosure items',
                value: totalCount.toString(),
                color: colorScheme.primary,
              ),
              FinancialReportDisclosureMetricCard(
                icon:
                    unresolvedCount == 0
                        ? Icons.verified_rounded
                        : Icons.rate_review_rounded,
                label: 'Needs review',
                value: unresolvedCount.toString(),
                color: accent,
              ),
              FinancialReportDisclosureMetricCard(
                icon: Icons.approval_rounded,
                label: 'Approved',
                value: approvedCount.toString(),
                helper: '${(reviewRatio * 100).round()}% resolved',
                color: Colors.teal.shade700,
              ),
            ],
            breakpoints: const [
              FinancialReportResponsiveGridBreakpoint(
                minWidth: 760,
                columns: 3,
              ),
            ],
            itemBuilder: (_, metric) => metric,
          ),
        ],
      ),
    );
  }
}

class FinancialReportDisclosureMetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String? helper;

  const FinancialReportDisclosureMetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.helper,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FinancialReportTintedSurface(
      color: color,
      minHeight: 92,
      borderAlpha: 0.18,
      child: Row(
        children: [
          FinancialReportDisclosureIcon(icon: icon, color: color, size: 36),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (helper != null)
                  Text(
                    helper!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(color: color),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
