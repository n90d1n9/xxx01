import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_work_authorization_models.dart';
import 'employee_work_authorization_styles.dart';

class EmployeeWorkAuthorizationSummaryStrip extends StatelessWidget {
  final EmployeeWorkAuthorizationProfile profile;

  const EmployeeWorkAuthorizationSummaryStrip({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Valid', value: '${profile.validCount}'),
        HrisMetricStripItem(
          label: 'Renewal',
          value: '${profile.renewalDueCount}',
        ),
        HrisMetricStripItem(
          label: 'Evidence',
          value: '${profile.evidenceIssueCount}',
        ),
        HrisMetricStripItem(
          label: 'Sponsored',
          value: '${profile.sponsorshipCount}',
        ),
      ],
    );
  }
}

class EmployeeWorkAuthorizationRecordTile extends StatelessWidget {
  final EmployeeWorkAuthorizationRecord record;
  final DateTime asOfDate;
  final VoidCallback onVerifyEvidence;
  final VoidCallback onStartRenewal;
  final VoidCallback onMarkValid;
  final VoidCallback onSuspend;

  const EmployeeWorkAuthorizationRecordTile({
    super.key,
    required this.record,
    required this.asOfDate,
    required this.onVerifyEvidence,
    required this.onStartRenewal,
    required this.onMarkValid,
    required this.onSuspend,
  });

  @override
  Widget build(BuildContext context) {
    final expired = record.isExpired(asOfDate);
    final expiringSoon = record.isExpiringSoon(asOfDate);
    final reviewDue = record.isReviewDue(asOfDate);
    final statusColor =
        expired
            ? const Color(0xFFB91C1C)
            : record.status != EmployeeWorkAuthorizationStatus.valid
            ? employeeWorkAuthorizationStatusColor(record.status)
            : expiringSoon || reviewDue
            ? const Color(0xFFB45309)
            : employeeWorkAuthorizationStatusColor(record.status);
    final evidenceColor = employeeWorkAuthorizationEvidenceColor(
      record.evidenceStatus,
    );
    final sponsorshipColor = employeeWorkAuthorizationSponsorshipColor(
      record.sponsorship,
    );

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TileHeader(
            icon: employeeWorkAuthorizationTypeIcon(record.type),
            title: record.title,
            subtitle: '${record.type.label} - ${record.owner}',
            color: statusColor,
            status: HrisStatusPill(
              label: _statusLabel(expired, expiringSoon, reviewDue),
              color: statusColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            record.notes,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(icon: Icons.public_outlined, label: record.country),
              _MetaChip(
                icon: Icons.event_busy_outlined,
                label: 'Expiry ${_formatDate(record.expiryDate)}',
                color: expired || expiringSoon ? const Color(0xFFB45309) : null,
              ),
              _MetaChip(
                icon: Icons.fact_check_outlined,
                label: 'Review ${_formatDate(record.reviewDate)}',
                color: reviewDue ? const Color(0xFFB45309) : null,
              ),
              _MetaChip(
                icon: employeeWorkAuthorizationEvidenceIcon(
                  record.evidenceStatus,
                ),
                label: record.evidenceStatus.label,
                color: evidenceColor,
              ),
              _MetaChip(
                icon: employeeWorkAuthorizationSponsorshipIcon(
                  record.sponsorship,
                ),
                label: record.sponsorship.label,
                color: sponsorshipColor,
              ),
              _MetaChip(
                icon: Icons.numbers_outlined,
                label: record.documentNumberMasked,
              ),
            ],
          ),
          if (_hasActions) ...[
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                if (record.canVerifyEvidence)
                  FilledButton.tonalIcon(
                    onPressed: onVerifyEvidence,
                    icon: const Icon(Icons.verified_outlined),
                    label: const Text('Verify evidence'),
                  ),
                if (record.canStartRenewal)
                  FilledButton.tonalIcon(
                    onPressed: onStartRenewal,
                    icon: const Icon(Icons.update_outlined),
                    label: const Text('Start renewal'),
                  ),
                if (record.canMarkValid)
                  FilledButton.tonalIcon(
                    onPressed: onMarkValid,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Mark valid'),
                  ),
                if (record.status !=
                        EmployeeWorkAuthorizationStatus.suspended &&
                    record.status != EmployeeWorkAuthorizationStatus.expired)
                  OutlinedButton.icon(
                    onPressed: onSuspend,
                    icon: const Icon(Icons.pause_circle_outline),
                    label: const Text('Suspend'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  bool get _hasActions {
    return record.canVerifyEvidence ||
        record.canStartRenewal ||
        record.canMarkValid ||
        (record.status != EmployeeWorkAuthorizationStatus.suspended &&
            record.status != EmployeeWorkAuthorizationStatus.expired);
  }

  String _statusLabel(bool expired, bool expiringSoon, bool reviewDue) {
    if (expired) return 'Expired';
    if (record.status != EmployeeWorkAuthorizationStatus.valid) {
      return record.status.label;
    }
    if (expiringSoon) return 'Renewal due';
    if (reviewDue) return 'Review due';
    return record.status.label;
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
            overflow: TextOverflow.ellipsis,
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
