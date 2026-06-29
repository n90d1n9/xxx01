import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_position_control.dart';
import 'company_status_styles.dart';

class CompanyPositionControlRegistryPanel extends StatelessWidget {
  final List<CompanyPositionControl> positions;
  final DateTime asOfDate;
  final ValueChanged<String> onApprove;
  final ValueChanged<String> onCloseRecruiting;

  const CompanyPositionControlRegistryPanel({
    super.key,
    required this.positions,
    required this.asOfDate,
    required this.onApprove,
    required this.onCloseRecruiting,
  });

  @override
  Widget build(BuildContext context) {
    final readyCount =
        positions
            .where((position) => !position.requiresAttention(asOfDate))
            .length;

    return HrisSectionPanel(
      icon: Icons.work_outline,
      title: 'Position Control Registry',
      subtitle: '$readyCount ready of ${positions.length} authorized positions',
      emptyMessage: 'No matching position controls',
      children:
          positions
              .map(
                (position) => _PositionControlTile(
                  position: position,
                  asOfDate: asOfDate,
                  onApprove: () => onApprove(position.id),
                  onCloseRecruiting: () => onCloseRecruiting(position.id),
                ),
              )
              .toList(),
    );
  }
}

class _PositionControlTile extends StatelessWidget {
  final CompanyPositionControl position;
  final DateTime asOfDate;
  final VoidCallback onApprove;
  final VoidCallback onCloseRecruiting;

  const _PositionControlTile({
    required this.position,
    required this.asOfDate,
    required this.onApprove,
    required this.onCloseRecruiting,
  });

  @override
  Widget build(BuildContext context) {
    final issues = position.issues(asOfDate);
    final statusColor = companyPositionControlStatusColor(position.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      position.positionTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${position.entityName} - ${position.orgUnitName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              HrisStatusPill(label: position.status.label, color: statusColor),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Seats',
                value:
                    '${position.filledSeats}/${position.authorizedSeats} filled',
              ),
              HrisMetricStripItem(
                label: 'Available',
                value: '${position.availableSeats}',
              ),
              HrisMetricStripItem(
                label: 'FTE',
                value: position.fte.toStringAsFixed(
                  position.fte.truncateToDouble() == position.fte ? 0 : 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(label: 'Type', value: position.type.label),
              HrisMetricStripItem(
                label: 'Band',
                value:
                    position.compensationBand.trim().isEmpty
                        ? 'Missing'
                        : position.compensationBand,
              ),
              HrisMetricStripItem(label: 'Review', value: _reviewLabel()),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            position.hiringPlan.trim().isEmpty
                ? 'No hiring plan linked'
                : position.hiringPlan,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: HrisColors.ink),
          ),
          if (position.linkedRequisition.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              position.linkedRequisition,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: HrisColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (issues.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  issues
                      .map(
                        (issue) => HrisStatusPill(
                          label: issue.label,
                          color:
                              issue == CompanyPositionControlIssue.overfilled ||
                                      issue ==
                                          CompanyPositionControlIssue
                                              .reviewOverdue
                                  ? Colors.red
                                  : Colors.orange,
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: onCloseRecruiting,
                  icon: const Icon(Icons.done_all_outlined),
                  label: const Text('Close recruiting'),
                ),
                FilledButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.verified_outlined),
                  label: const Text('Approve control'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _reviewLabel() {
    final days = position.daysUntilReview(asOfDate);
    if (days < 0) return 'Overdue ${days.abs()}d';
    if (days == 0) return 'Today';
    final month = position.nextReviewDate.month.toString().padLeft(2, '0');
    final day = position.nextReviewDate.day.toString().padLeft(2, '0');
    return '${position.nextReviewDate.year}-$month-$day (${days}d)';
  }
}
