import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_accommodation_models.dart';
import 'employee_accommodation_styles.dart';

class EmployeeAccommodationSummaryStrip extends StatelessWidget {
  final EmployeeAccommodationProfile profile;

  const EmployeeAccommodationSummaryStrip({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Active', value: '${profile.activeCount}'),
        HrisMetricStripItem(
          label: 'Requested',
          value: '${profile.requestedCount}',
        ),
        HrisMetricStripItem(
          label: 'Review',
          value: '${profile.reviewDueCount}',
        ),
        HrisMetricStripItem(
          label: 'Sensitive',
          value: '${profile.restrictedCount}',
        ),
      ],
    );
  }
}

class EmployeeAccommodationRecordTile extends StatelessWidget {
  final EmployeeAccommodationRecord record;
  final DateTime asOfDate;
  final VoidCallback onApprove;
  final VoidCallback onActivate;
  final VoidCallback onReview;
  final VoidCallback onExpire;
  final VoidCallback onDecline;

  const EmployeeAccommodationRecordTile({
    super.key,
    required this.record,
    required this.asOfDate,
    required this.onApprove,
    required this.onActivate,
    required this.onReview,
    required this.onExpire,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final reviewDue = record.isReviewDue(asOfDate);
    final expired = record.isExpired(asOfDate);
    final statusColor =
        expired
            ? const Color(0xFFB91C1C)
            : reviewDue
            ? const Color(0xFFB45309)
            : employeeAccommodationStatusColor(record.status);
    final sensitivityColor = employeeAccommodationSensitivityColor(
      record.sensitivity,
    );

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TileHeader(
            icon: employeeAccommodationTypeIcon(record.type),
            title: record.title,
            subtitle: '${record.type.label} - ${record.owner}',
            color: statusColor,
            status: HrisStatusPill(
              label:
                  expired
                      ? 'Expired'
                      : reviewDue
                      ? 'Review due'
                      : record.status.label,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            record.summary,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: Icons.inbox_outlined,
                label: 'Requested ${_formatDate(record.requestedAt)}',
              ),
              _MetaChip(
                icon: Icons.play_circle_outline,
                label: 'Start ${_formatDate(record.startDate)}',
              ),
              _MetaChip(
                icon: Icons.fact_check_outlined,
                label: 'Review ${_formatDate(record.reviewDate)}',
                color: reviewDue ? const Color(0xFFB45309) : null,
              ),
              if (record.endDate != null)
                _MetaChip(
                  icon: Icons.event_busy_outlined,
                  label: 'End ${_formatDate(record.endDate!)}',
                  color: const Color(0xFFB91C1C),
                ),
              _MetaChip(
                icon: employeeAccommodationSensitivityIcon(record.sensitivity),
                label: record.sensitivity.label,
                color: sensitivityColor,
              ),
            ],
          ),
          if (record.canApprove ||
              record.canActivate ||
              record.canReview ||
              record.canExpire ||
              record.canDecline) ...[
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                if (record.canDecline)
                  OutlinedButton.icon(
                    onPressed: onDecline,
                    icon: const Icon(Icons.close_outlined),
                    label: const Text('Decline'),
                  ),
                if (record.canApprove)
                  FilledButton.tonalIcon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Approve'),
                  ),
                if (record.canActivate)
                  FilledButton.tonalIcon(
                    onPressed: onActivate,
                    icon: const Icon(Icons.play_arrow_outlined),
                    label: const Text('Activate'),
                  ),
                if (record.canReview)
                  FilledButton.tonalIcon(
                    onPressed: onReview,
                    icon: const Icon(Icons.fact_check_outlined),
                    label: const Text('Review'),
                  ),
                if (record.canExpire)
                  OutlinedButton.icon(
                    onPressed: onExpire,
                    icon: const Icon(Icons.event_busy_outlined),
                    label: const Text('Expire'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TileHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Widget status;

  const _TileHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        status,
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MetaChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? HrisColors.muted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: chipColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return DateFormat('MMM d, yyyy').format(date);
}
