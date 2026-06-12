import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_governance_contact.dart';
import 'company_status_styles.dart';

class CompanyGovernanceContactDirectoryPanel extends StatelessWidget {
  final List<CompanyGovernanceContact> contacts;
  final DateTime asOfDate;
  final ValueChanged<String> onMarkReviewed;
  final ValueChanged<String> onAssignBackup;

  const CompanyGovernanceContactDirectoryPanel({
    super.key,
    required this.contacts,
    required this.asOfDate,
    required this.onMarkReviewed,
    required this.onAssignBackup,
  });

  @override
  Widget build(BuildContext context) {
    final ready =
        contacts
            .where((contact) => !contact.requiresAttention(asOfDate))
            .length;

    return HrisSectionPanel(
      icon: Icons.contact_mail_outlined,
      title: 'Governance Contacts',
      subtitle: '$ready/${contacts.length} owners ready',
      emptyMessage: 'No matching governance contacts',
      children:
          contacts
              .map(
                (contact) => _GovernanceContactTile(
                  contact: contact,
                  asOfDate: asOfDate,
                  onMarkReviewed: () => onMarkReviewed(contact.id),
                  onAssignBackup: () => onAssignBackup(contact.id),
                ),
              )
              .toList(),
    );
  }
}

class _GovernanceContactTile extends StatelessWidget {
  final CompanyGovernanceContact contact;
  final DateTime asOfDate;
  final VoidCallback onMarkReviewed;
  final VoidCallback onAssignBackup;

  const _GovernanceContactTile({
    required this.contact,
    required this.asOfDate,
    required this.onMarkReviewed,
    required this.onAssignBackup,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = companyGovernanceContactStatusColor(contact.status);
    final issues = contact.issues(asOfDate);

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
                      '${contact.role.label} - ${contact.entityName}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${contact.personName} - ${contact.title}',
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
              HrisStatusPill(label: contact.status.label, color: statusColor),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(label: 'Email', value: contact.email),
              HrisMetricStripItem(
                label: 'Backup',
                value:
                    contact.backupName.trim().isEmpty
                        ? 'Unassigned'
                        : contact.backupName,
              ),
              HrisMetricStripItem(
                label: 'Review',
                value: _reviewLabel(contact),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              HrisStatusPill(
                label: contact.escalationChannel,
                color: Colors.blueGrey,
              ),
              HrisStatusPill(
                label:
                    contact.phone.trim().isEmpty ? 'No phone' : contact.phone,
                color: Colors.indigo,
              ),
            ],
          ),
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
                          color: Colors.orange,
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                if (contact.backupName.trim().isEmpty)
                  OutlinedButton.icon(
                    onPressed: onAssignBackup,
                    icon: const Icon(Icons.group_outlined),
                    label: const Text('Assign backup'),
                  ),
                FilledButton.icon(
                  onPressed: onMarkReviewed,
                  icon: const Icon(Icons.fact_check_outlined),
                  label: const Text('Mark reviewed'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _reviewLabel(CompanyGovernanceContact contact) {
    final days = contact.daysUntilReview(asOfDate);
    if (days < 0) return 'Overdue ${days.abs()}d';
    if (days == 0) return 'Today';
    return '${_formatDate(contact.nextReviewAt)} (${days}d)';
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
