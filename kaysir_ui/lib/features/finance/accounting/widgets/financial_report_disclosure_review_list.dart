import 'package:flutter/material.dart';

import '../models/financial_report_disclosure_review.dart';
import 'financial_report_disclosure_review_shared.dart';
import 'financial_report_action_card_components.dart';
import 'financial_report_panel_components.dart';
import 'financial_report_responsive_grid_components.dart';
import 'financial_report_tinted_surface_components.dart';

class FinancialReportDisclosureReviewList extends StatelessWidget {
  final List<FinancialReportDisclosureReviewItem> items;
  final bool locked;
  final void Function(
    FinancialReportDisclosureReviewItem item,
    FinancialReportDisclosureResolutionStatus status,
  )?
  onResolve;
  final ValueChanged<FinancialReportDisclosureReviewItem>? onClear;

  const FinancialReportDisclosureReviewList({
    required this.items,
    required this.locked,
    this.onResolve,
    this.onClear,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FinancialReportDisclosureSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FinancialReportDisclosureSectionTitle(
            icon: Icons.fact_check_rounded,
            title: 'Disclosure Review',
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            FinancialReportPanelEmptyState(
              title:
                  'No disclosure requirements are attached to the current report pack.',
              icon: Icons.task_alt_rounded,
              isDarkMode: theme.brightness == Brightness.dark,
              accentColor: colorScheme.primary,
            )
          else
            FinancialReportResponsiveWrapGrid<
              FinancialReportDisclosureReviewItem
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
                  (context, item) => FinancialReportDisclosureReviewCard(
                    item: item,
                    locked: locked,
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

class FinancialReportDisclosureReviewCard extends StatelessWidget {
  final FinancialReportDisclosureReviewItem item;
  final bool locked;
  final ValueChanged<FinancialReportDisclosureResolutionStatus>? onResolve;
  final VoidCallback? onClear;

  const FinancialReportDisclosureReviewCard({
    required this.item,
    required this.locked,
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
      minHeight: 264,
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
            clearTooltip: 'Clear review',
            onClear: locked ? null : onClear,
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
              FinancialReportDisclosureStatusBadge(
                label: _statusLabel(item),
                color: color,
              ),
              FinancialReportDisclosureStatusBadge(
                label: item.requirement.priority.label,
                color:
                    item.requirement.blocksClose
                        ? Colors.orange.shade700
                        : Colors.blueGrey,
              ),
              FinancialReportDisclosureStatusBadge(
                label: item.requirement.owner,
                color: colorScheme.primary,
              ),
              FinancialReportDisclosureStatusBadge(
                label: 'Note ${item.requirement.noteNumber}',
                color: Colors.blueGrey,
              ),
              for (final reference in item.requirement.standardReferences)
                FinancialReportDisclosureStatusBadge(
                  label: reference,
                  color: colorScheme.secondary,
                ),
            ],
          ),
          if (resolution != null) ...[
            const SizedBox(height: 12),
            FinancialReportActionCardResolutionLine(
              statusLabel: resolution.status.label,
              actorName: resolution.reviewer,
              note: resolution.note,
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _DisclosureActionButton(
                icon: Icons.edit_note_rounded,
                label: 'Prepare',
                onPressed:
                    locked || onResolve == null
                        ? null
                        : () => onResolve!(
                          FinancialReportDisclosureResolutionStatus.prepared,
                        ),
              ),
              _DisclosureActionButton(
                icon: Icons.approval_rounded,
                label: 'Approve',
                onPressed:
                    locked || onResolve == null
                        ? null
                        : () => onResolve!(
                          FinancialReportDisclosureResolutionStatus.approved,
                        ),
              ),
              _DisclosureActionButton(
                icon: Icons.schedule_rounded,
                label: 'Defer',
                onPressed:
                    locked || onResolve == null
                        ? null
                        : () => onResolve!(
                          FinancialReportDisclosureResolutionStatus.deferred,
                        ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DisclosureActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _DisclosureActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 17),
      label: Text(label),
    );
  }
}

Color _statusColor(
  FinancialReportDisclosureReviewItem item,
  ColorScheme colorScheme,
) {
  final status = item.resolution?.status;
  if (status == FinancialReportDisclosureResolutionStatus.approved) {
    return Colors.teal.shade700;
  }
  if (status == FinancialReportDisclosureResolutionStatus.prepared) {
    return colorScheme.primary;
  }
  if (status == FinancialReportDisclosureResolutionStatus.deferred) {
    return Colors.orange.shade800;
  }
  return item.requirement.blocksClose
      ? Colors.orange.shade700
      : Colors.blueGrey;
}

IconData _statusIcon(FinancialReportDisclosureReviewItem item) {
  final status = item.resolution?.status;
  if (status == FinancialReportDisclosureResolutionStatus.approved) {
    return Icons.verified_rounded;
  }
  if (status == FinancialReportDisclosureResolutionStatus.prepared) {
    return Icons.edit_note_rounded;
  }
  if (status == FinancialReportDisclosureResolutionStatus.deferred) {
    return Icons.schedule_rounded;
  }
  return Icons.rate_review_rounded;
}

String _statusLabel(FinancialReportDisclosureReviewItem item) {
  final status = item.resolution?.status;
  if (status != null) {
    return status.label;
  }
  return item.requirement.blocksClose ? 'Needs review' : 'Advisory';
}
