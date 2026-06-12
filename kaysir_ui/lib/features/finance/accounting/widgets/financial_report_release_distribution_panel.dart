import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/financial_report_release_distribution.dart';
import 'financial_report_action_card_components.dart';
import 'financial_report_panel_components.dart';
import 'financial_report_release_signoff_shared.dart';
import 'financial_report_responsive_grid_components.dart';
import 'financial_report_tinted_surface_components.dart';

class FinancialReportReleaseDistributionPanel extends StatelessWidget {
  const FinancialReportReleaseDistributionPanel({
    required this.items,
    required this.completedCount,
    required this.acknowledgedCount,
    required this.exceptionCount,
    required this.overdueCount,
    this.actionLockedReason,
    this.onUpdate,
    this.onClear,
    super.key,
  });

  final List<FinancialReportReleaseDistributionItem> items;
  final int completedCount;
  final int acknowledgedCount;
  final int exceptionCount;
  final int overdueCount;
  final String? actionLockedReason;
  final void Function(
    FinancialReportReleaseDistributionItem item,
    FinancialReportReleaseDistributionStatus status,
  )?
  onUpdate;
  final ValueChanged<FinancialReportReleaseDistributionItem>? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FinancialReportReleaseSignOffSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FinancialReportReleaseSignOffSectionTitle(
            icon: Icons.send_time_extension_rounded,
            title: 'Distribution Register',
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _DistributionMetricChip(
                label: '$completedCount/${items.length} complete',
                icon: Icons.task_alt_rounded,
                color: colorScheme.primary,
              ),
              _DistributionMetricChip(
                label: '$acknowledgedCount acknowledged',
                icon: Icons.how_to_reg_rounded,
                color: Colors.teal.shade700,
              ),
              _DistributionMetricChip(
                label: '$overdueCount overdue',
                icon: Icons.timer_off_rounded,
                color:
                    overdueCount == 0
                        ? colorScheme.secondary
                        : colorScheme.error,
              ),
              _DistributionMetricChip(
                label: '$exceptionCount exception(s)',
                icon: Icons.report_problem_rounded,
                color:
                    exceptionCount == 0
                        ? colorScheme.secondary
                        : colorScheme.error,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (actionLockedReason != null) ...[
            FinancialReportReleaseDistributionLockNotice(
              reason: actionLockedReason!,
            ),
            const SizedBox(height: 12),
          ],
          if (items.isEmpty)
            FinancialReportPanelEmptyState(
              title: 'No distribution recipients are configured.',
              icon: Icons.send_rounded,
              isDarkMode: theme.brightness == Brightness.dark,
              accentColor: colorScheme.primary,
            )
          else
            FinancialReportResponsiveWrapGrid<
              FinancialReportReleaseDistributionItem
            >(
              items: items,
              breakpoints: const [
                FinancialReportResponsiveGridBreakpoint(
                  minWidth: 1040,
                  columns: 2,
                ),
              ],
              itemBuilder:
                  (context, item) => FinancialReportReleaseDistributionCard(
                    item: item,
                    actionLockedReason: actionLockedReason,
                    onUpdate:
                        onUpdate == null
                            ? null
                            : (status) => onUpdate!(item, status),
                    onClear: onClear == null ? null : () => onClear!(item),
                  ),
            ),
        ],
      ),
    );
  }
}

class FinancialReportReleaseDistributionCard extends StatelessWidget {
  const FinancialReportReleaseDistributionCard({
    required this.item,
    this.actionLockedReason,
    this.onUpdate,
    this.onClear,
    super.key,
  });

  final FinancialReportReleaseDistributionItem item;
  final String? actionLockedReason;
  final ValueChanged<FinancialReportReleaseDistributionStatus>? onUpdate;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final recipient = item.recipient;
    final resolution = item.resolution;
    final color = _statusColor(item.status, colorScheme);
    final dueDate = DateFormat('MMM d, yyyy').format(recipient.dueDate);
    final updateLocked = actionLockedReason != null || onUpdate == null;

    return FinancialReportTintedSurface(
      color: color,
      minHeight: 228,
      padding: const EdgeInsets.all(14),
      fillAlpha: 0.06,
      borderAlpha: 0.22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FinancialReportActionCardTitleRow(
            icon: _statusIcon(item.status),
            color: color,
            title: recipient.name,
            maxTitleLines: 1,
            showClearAction: resolution != null,
            clearTooltip: 'Clear distribution status',
            onClear: onClear,
          ),
          const SizedBox(height: 7),
          Text(
            recipient.purpose,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              FinancialReportReleaseSignOffBadge(
                label: item.statusLabel,
                color: color,
              ),
              FinancialReportReleaseSignOffBadge(
                label: recipient.channel.label,
                color: colorScheme.primary,
              ),
              FinancialReportReleaseSignOffBadge(
                label:
                    recipient.requiresAcknowledgement
                        ? 'Ack required'
                        : 'Send only',
                color: colorScheme.secondary,
              ),
              FinancialReportReleaseSignOffBadge(
                label: 'Due $dueDate',
                color: Colors.blueGrey,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${recipient.role} / ${recipient.organization}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (resolution != null) ...[
            const SizedBox(height: 8),
            FinancialReportActionCardResolutionLine(
              statusLabel: resolution.status.label,
              actorName: resolution.owner,
              actorContext: _distributionResolutionContext(resolution),
              note: resolution.note,
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed:
                    updateLocked
                        ? null
                        : () => onUpdate!(
                          FinancialReportReleaseDistributionStatus.sent,
                        ),
                icon: const Icon(Icons.send_rounded, size: 17),
                label: const Text('Sent'),
              ),
              OutlinedButton.icon(
                onPressed:
                    updateLocked
                        ? null
                        : () => onUpdate!(
                          FinancialReportReleaseDistributionStatus.acknowledged,
                        ),
                icon: const Icon(Icons.how_to_reg_rounded, size: 17),
                label: const Text('Ack'),
              ),
              OutlinedButton.icon(
                onPressed:
                    updateLocked
                        ? null
                        : () => onUpdate!(
                          FinancialReportReleaseDistributionStatus.exception,
                        ),
                icon: const Icon(Icons.report_problem_rounded, size: 17),
                label: const Text('Exception'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FinancialReportReleaseDistributionLockNotice extends StatelessWidget {
  const FinancialReportReleaseDistributionLockNotice({
    required this.reason,
    super.key,
  });

  final String reason;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FinancialReportTintedSurface(
      color: colorScheme.error,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      backgroundColor: colorScheme.errorContainer.withValues(alpha: 0.5),
      borderAlpha: 0.24,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_clock_rounded, color: colorScheme.error, size: 19),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              reason,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onErrorContainer,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DistributionMetricChip extends StatelessWidget {
  const _DistributionMetricChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 240),
      child: FinancialReportPanelBadge(
        label: label,
        color: color,
        isDarkMode: isDarkMode,
        icon: icon,
      ),
    );
  }
}

Color _statusColor(
  FinancialReportReleaseDistributionStatus status,
  ColorScheme colorScheme,
) {
  switch (status) {
    case FinancialReportReleaseDistributionStatus.acknowledged:
      return Colors.teal.shade700;
    case FinancialReportReleaseDistributionStatus.sent:
      return colorScheme.primary;
    case FinancialReportReleaseDistributionStatus.exception:
      return colorScheme.error;
    case FinancialReportReleaseDistributionStatus.pending:
      return colorScheme.tertiary;
  }
}

String _distributionResolutionContext(
  FinancialReportReleaseDistributionResolution resolution,
) {
  final updatedAt = DateFormat(
    'MMM d, yyyy HH:mm',
  ).format(resolution.updatedAt);
  final evidence = resolution.evidenceReference?.trim();
  final evidenceLabel =
      evidence == null || evidence.isEmpty ? '' : ' / $evidence';
  return ' / $updatedAt$evidenceLabel';
}

IconData _statusIcon(FinancialReportReleaseDistributionStatus status) {
  switch (status) {
    case FinancialReportReleaseDistributionStatus.acknowledged:
      return Icons.how_to_reg_rounded;
    case FinancialReportReleaseDistributionStatus.sent:
      return Icons.send_rounded;
    case FinancialReportReleaseDistributionStatus.exception:
      return Icons.report_problem_rounded;
    case FinancialReportReleaseDistributionStatus.pending:
      return Icons.pending_actions_rounded;
  }
}
