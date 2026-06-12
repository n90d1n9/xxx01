import 'package:flutter/material.dart';

import '../models/financial_report_release_evidence_manifest.dart';
import 'financial_report_responsive_grid_components.dart';
import 'financial_report_release_signoff_shared.dart';
import 'financial_report_tinted_surface_components.dart';

class FinancialReportReleaseEvidenceManifestPanel extends StatelessWidget {
  const FinancialReportReleaseEvidenceManifestPanel({
    required this.summary,
    this.onOpenManagementMeasures,
    super.key,
  });

  final FinancialReportReleaseEvidenceManifestSummary summary;
  final VoidCallback? onOpenManagementMeasures;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent =
        summary.archiveReady ? Colors.teal.shade700 : colorScheme.tertiary;

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
                    icon: Icons.inventory_2_rounded,
                    color: accent,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Release Evidence Manifest',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          summary.nextAction,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
              final badge = FinancialReportReleaseSignOffBadge(
                label: summary.archiveReady ? 'Archive ready' : 'Archive open',
                color: accent,
              );
              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [title, const SizedBox(height: 12), badge],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: title),
                  const SizedBox(width: 12),
                  badge,
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FinancialReportReleaseSignOffBadge(
                label: '${summary.readyCount} ready',
                color: Colors.teal.shade700,
              ),
              FinancialReportReleaseSignOffBadge(
                label: '${summary.attentionCount} attention',
                color: colorScheme.tertiary,
              ),
              FinancialReportReleaseSignOffBadge(
                label: '${summary.missingCount} missing',
                color:
                    summary.missingCount == 0
                        ? colorScheme.secondary
                        : colorScheme.error,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: summary.completionRatio.clamp(0, 1).toDouble(),
              minHeight: 8,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
          const SizedBox(height: 14),
          FinancialReportResponsiveWrapGrid<
            FinancialReportReleaseEvidenceManifestItem
          >(
            items: summary.items,
            breakpoints: const [
              FinancialReportResponsiveGridBreakpoint(
                minWidth: 820,
                columns: 3,
              ),
            ],
            itemBuilder:
                (_, item) => FinancialReportReleaseEvidenceTile(
                  item: item,
                  onOpenManagementMeasures: onOpenManagementMeasures,
                ),
          ),
        ],
      ),
    );
  }
}

class FinancialReportReleaseEvidenceTile extends StatelessWidget {
  const FinancialReportReleaseEvidenceTile({
    required this.item,
    this.onOpenManagementMeasures,
    super.key,
  });

  final FinancialReportReleaseEvidenceManifestItem item;
  final VoidCallback? onOpenManagementMeasures;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = _statusColor(item.status, colorScheme);
    final showManagementMeasureAction =
        onOpenManagementMeasures != null &&
        item.kind ==
            FinancialReportReleaseEvidenceKind.managementMeasureAuditTrail &&
        item.status != FinancialReportReleaseEvidenceStatus.ready;

    return FinancialReportTintedSurface(
      color: color,
      minHeight: showManagementMeasureAction ? 172 : 128,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_kindIcon(item.kind), color: color, size: 19),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              FinancialReportReleaseSignOffBadge(
                label: item.status.label,
                color: color,
              ),
              FinancialReportReleaseSignOffBadge(
                label: item.reference,
                color: colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.detail,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          if (showManagementMeasureAction) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: onOpenManagementMeasures,
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Open UKTM'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  foregroundColor: color,
                  side: BorderSide(color: color.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

Color _statusColor(
  FinancialReportReleaseEvidenceStatus status,
  ColorScheme colorScheme,
) {
  switch (status) {
    case FinancialReportReleaseEvidenceStatus.ready:
      return Colors.teal.shade700;
    case FinancialReportReleaseEvidenceStatus.attention:
      return colorScheme.tertiary;
    case FinancialReportReleaseEvidenceStatus.missing:
      return colorScheme.error;
  }
}

IconData _kindIcon(FinancialReportReleaseEvidenceKind kind) {
  switch (kind) {
    case FinancialReportReleaseEvidenceKind.closeCertificate:
      return Icons.lock_clock_rounded;
    case FinancialReportReleaseEvidenceKind.packageFingerprint:
      return Icons.fingerprint_rounded;
    case FinancialReportReleaseEvidenceKind.signOffCertificate:
      return Icons.draw_rounded;
    case FinancialReportReleaseEvidenceKind.signOffAuditTrail:
      return Icons.verified_user_rounded;
    case FinancialReportReleaseEvidenceKind.managementMeasureAuditTrail:
      return Icons.fact_check_rounded;
    case FinancialReportReleaseEvidenceKind.distributionRegister:
      return Icons.send_rounded;
    case FinancialReportReleaseEvidenceKind.distributionAuditTrail:
      return Icons.manage_history_rounded;
  }
}
