import 'package:flutter/material.dart';

import '../models/financial_report_package_integrity.dart';
import 'financial_report_responsive_grid_components.dart';
import 'financial_report_release_signoff_shared.dart';
import 'financial_report_tinted_surface_components.dart';

class FinancialReportReleaseSignOffHeader extends StatelessWidget {
  final String periodLabel;
  final String frameworkName;
  final int totalCount;
  final int signedCount;
  final int pendingCount;
  final int returnedCount;
  final double completionRatio;
  final FinancialReportPackageIntegrityStatus integrityStatus;

  const FinancialReportReleaseSignOffHeader({
    required this.periodLabel,
    required this.frameworkName,
    required this.totalCount,
    required this.signedCount,
    required this.pendingCount,
    required this.returnedCount,
    required this.completionRatio,
    required this.integrityStatus,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final releaseReady = totalCount > 0 && signedCount == totalCount;
    final accent =
        releaseReady
            ? Colors.teal.shade700
            : returnedCount > 0
            ? Colors.red.shade700
            : Colors.orange.shade700;

    return FinancialReportReleaseSignOffSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 720;
              final title = Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FinancialReportReleaseSignOffIcon(
                    icon: Icons.verified_user_rounded,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Report Release Center',
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
              final status = FinancialReportReleaseSignOffBadge(
                label:
                    releaseReady
                        ? 'Release signed'
                        : returnedCount > 0
                        ? '$returnedCount returned'
                        : '$pendingCount pending',
                color: accent,
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
              FinancialReportReleaseSignOffMetricCard(
                icon: Icons.draw_rounded,
                label: 'Signed',
                value: '$signedCount/$totalCount',
                helper: '${(completionRatio * 100).round()}% complete',
                color: Colors.teal.shade700,
              ),
              FinancialReportReleaseSignOffMetricCard(
                icon: Icons.pending_actions_rounded,
                label: 'Pending',
                value: pendingCount.toString(),
                color: Colors.orange.shade700,
              ),
              FinancialReportReleaseSignOffMetricCard(
                icon: _integrityIcon,
                label: 'Package integrity',
                value: integrityStatus.label,
                color:
                    integrityStatus ==
                            FinancialReportPackageIntegrityStatus.verified
                        ? Colors.teal.shade700
                        : colorScheme.tertiary,
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

  IconData get _integrityIcon {
    switch (integrityStatus) {
      case FinancialReportPackageIntegrityStatus.verified:
        return Icons.verified_rounded;
      case FinancialReportPackageIntegrityStatus.changed:
        return Icons.difference_rounded;
      case FinancialReportPackageIntegrityStatus.missingFingerprint:
        return Icons.fingerprint_rounded;
      case FinancialReportPackageIntegrityStatus.notClosed:
        return Icons.lock_open_rounded;
    }
  }
}

class FinancialReportReleaseSignOffMetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String? helper;

  const FinancialReportReleaseSignOffMetricCard({
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
          FinancialReportReleaseSignOffIcon(icon: icon, color: color, size: 36),
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
