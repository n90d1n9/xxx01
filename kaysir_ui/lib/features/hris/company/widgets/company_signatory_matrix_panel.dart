import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_signatory.dart';
import 'company_status_styles.dart';

class CompanySignatoryMatrixPanel extends StatelessWidget {
  final List<CompanySignatory> signatories;
  final DateTime asOfDate;
  final ValueChanged<String> onActivateEvidence;
  final ValueChanged<String> onAssignBackup;

  const CompanySignatoryMatrixPanel({
    super.key,
    required this.signatories,
    required this.asOfDate,
    required this.onActivateEvidence,
    required this.onAssignBackup,
  });

  @override
  Widget build(BuildContext context) {
    final readyCount =
        signatories
            .where((signatory) => !signatory.requiresAttention(asOfDate))
            .length;

    return HrisSectionPanel(
      icon: Icons.assignment_ind_outlined,
      title: 'Signatory Delegation Matrix',
      subtitle: '$readyCount ready of ${signatories.length} authorities',
      emptyMessage: 'No matching signatory delegations',
      children:
          signatories
              .map(
                (signatory) => _SignatoryTile(
                  signatory: signatory,
                  asOfDate: asOfDate,
                  onActivateEvidence: () => onActivateEvidence(signatory.id),
                  onAssignBackup: () => onAssignBackup(signatory.id),
                ),
              )
              .toList(),
    );
  }
}

class _SignatoryTile extends StatelessWidget {
  final CompanySignatory signatory;
  final DateTime asOfDate;
  final VoidCallback onActivateEvidence;
  final VoidCallback onAssignBackup;

  const _SignatoryTile({
    required this.signatory,
    required this.asOfDate,
    required this.onActivateEvidence,
    required this.onAssignBackup,
  });

  @override
  Widget build(BuildContext context) {
    final issues = signatory.issues(asOfDate);
    final statusColor = companySignatoryStatusColor(signatory.status);

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
                      signatory.personName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${signatory.title} - ${signatory.entityName}',
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
              Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.end,
                children: [
                  HrisStatusPill(
                    label: signatory.authorityLevel.label,
                    color: Colors.indigo,
                  ),
                  HrisStatusPill(
                    label: signatory.status.label,
                    color: statusColor,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(label: 'Scope', value: signatory.scope.label),
              HrisMetricStripItem(label: 'Expiry', value: _expiryLabel()),
              HrisMetricStripItem(
                label: 'Backup',
                value:
                    signatory.backupSignerName.trim().isEmpty
                        ? 'Missing'
                        : signatory.backupSignerName,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            signatory.evidenceSummary.trim().isEmpty
                ? 'Delegation evidence missing'
                : signatory.evidenceSummary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: HrisColors.ink),
          ),
          if (signatory.delegationNotes.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              signatory.delegationNotes,
              maxLines: 3,
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
                              issue == CompanySignatoryIssue.expiryOverdue ||
                                      issue ==
                                          CompanySignatoryIssue
                                              .inactiveAuthority
                                  ? Colors.red
                                  : Colors.orange,
                        ),
                      )
                      .toList(),
            ),
          ],
          if (issues.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: onAssignBackup,
                  icon: const Icon(Icons.group_add_outlined),
                  label: const Text('Assign backup'),
                ),
                FilledButton.icon(
                  onPressed: onActivateEvidence,
                  icon: const Icon(Icons.verified_outlined),
                  label: const Text('Activate evidence'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _expiryLabel() {
    final days = signatory.daysUntilExpiry(asOfDate);
    if (days < 0) return 'Expired ${days.abs()}d';
    if (days == 0) return 'Today';
    final month = signatory.expiryDate.month.toString().padLeft(2, '0');
    final day = signatory.expiryDate.day.toString().padLeft(2, '0');
    return '${signatory.expiryDate.year}-$month-$day (${days}d)';
  }
}
