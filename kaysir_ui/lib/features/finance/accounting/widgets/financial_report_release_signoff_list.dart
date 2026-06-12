import 'package:flutter/material.dart';

import '../models/financial_report_release_signoff.dart';
import 'financial_report_action_card_components.dart';
import 'financial_report_panel_components.dart';
import 'financial_report_release_signoff_shared.dart';
import 'financial_report_responsive_grid_components.dart';
import 'financial_report_tinted_surface_components.dart';

class FinancialReportReleaseSignOffList extends StatelessWidget {
  final List<FinancialReportReleaseSignOffItem> items;
  final void Function(
    FinancialReportReleaseSignOffItem item,
    FinancialReportReleaseSignOffStatus status,
  )?
  onResolve;
  final ValueChanged<FinancialReportReleaseSignOffItem>? onClear;

  const FinancialReportReleaseSignOffList({
    required this.items,
    this.onResolve,
    this.onClear,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FinancialReportReleaseSignOffSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FinancialReportReleaseSignOffSectionTitle(
            icon: Icons.fact_check_rounded,
            title: 'Release Sign-offs',
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            FinancialReportPanelEmptyState(
              title:
                  'No release sign-offs are configured for this report pack.',
              icon: Icons.task_alt_rounded,
              isDarkMode: theme.brightness == Brightness.dark,
              accentColor: colorScheme.primary,
            )
          else
            FinancialReportResponsiveWrapGrid<
              FinancialReportReleaseSignOffItem
            >(
              items: items,
              breakpoints: const [
                FinancialReportResponsiveGridBreakpoint(
                  minWidth: 760,
                  columns: 2,
                ),
                FinancialReportResponsiveGridBreakpoint(
                  minWidth: 1100,
                  columns: 3,
                ),
              ],
              itemBuilder:
                  (context, item) => FinancialReportReleaseSignOffCard(
                    item: item,
                    onResolve:
                        onResolve == null
                            ? null
                            : (status) => onResolve!(item, status),
                    onClear: onClear == null ? null : () => onClear!(item),
                  ),
            ),
        ],
      ),
    );
  }
}

class FinancialReportReleaseSignOffCard extends StatelessWidget {
  final FinancialReportReleaseSignOffItem item;
  final ValueChanged<FinancialReportReleaseSignOffStatus>? onResolve;
  final VoidCallback? onClear;

  const FinancialReportReleaseSignOffCard({
    required this.item,
    this.onResolve,
    this.onClear,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = _statusColor(item, colorScheme);
    final resolution = item.resolution;

    return FinancialReportTintedSurface(
      color: color,
      minHeight: 248,
      padding: const EdgeInsets.all(14),
      fillAlpha: 0.06,
      borderAlpha: 0.22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FinancialReportActionCardTitleRow(
            icon: _statusIcon(item),
            color: color,
            title: item.requirement.title,
            showClearAction: resolution != null,
            clearTooltip: 'Clear sign-off',
            onClear: onClear,
          ),
          const SizedBox(height: 8),
          Text(
            item.requirement.description,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              FinancialReportReleaseSignOffBadge(
                label: item.statusLabel,
                color: color,
              ),
              FinancialReportReleaseSignOffBadge(
                label: item.role.label,
                color: colorScheme.primary,
              ),
              FinancialReportReleaseSignOffBadge(
                label: item.requirement.owner,
                color: Colors.blueGrey,
              ),
              FinancialReportReleaseSignOffBadge(
                label: item.requirement.reference,
                color: colorScheme.secondary,
              ),
            ],
          ),
          if (resolution != null) ...[
            const SizedBox(height: 12),
            FinancialReportActionCardResolutionLine(
              statusLabel: resolution.status.label,
              actorName: resolution.signer,
              note: resolution.note,
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed:
                    onResolve == null
                        ? null
                        : () => onResolve!(
                          FinancialReportReleaseSignOffStatus.signed,
                        ),
                icon: const Icon(Icons.draw_rounded, size: 17),
                label: const Text('Sign off'),
              ),
              OutlinedButton.icon(
                onPressed:
                    onResolve == null
                        ? null
                        : () => onResolve!(
                          FinancialReportReleaseSignOffStatus.returned,
                        ),
                icon: const Icon(Icons.assignment_return_rounded, size: 17),
                label: const Text('Return'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _statusColor(
  FinancialReportReleaseSignOffItem item,
  ColorScheme colorScheme,
) {
  if (item.isSigned) {
    return Colors.teal.shade700;
  }
  if (item.isReturned) {
    return Colors.red.shade700;
  }
  return colorScheme.tertiary;
}

IconData _statusIcon(FinancialReportReleaseSignOffItem item) {
  if (item.isSigned) {
    return Icons.verified_rounded;
  }
  if (item.isReturned) {
    return Icons.assignment_return_rounded;
  }
  return Icons.pending_actions_rounded;
}
