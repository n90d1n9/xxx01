import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_employer_account.dart';
import 'company_status_styles.dart';

class CompanyEmployerAccountRegistryPanel extends StatelessWidget {
  final List<CompanyEmployerAccount> accounts;
  final DateTime asOfDate;
  final ValueChanged<String> onMarkVerified;
  final ValueChanged<String> onRotateCredentialOwner;

  const CompanyEmployerAccountRegistryPanel({
    super.key,
    required this.accounts,
    required this.asOfDate,
    required this.onMarkVerified,
    required this.onRotateCredentialOwner,
  });

  @override
  Widget build(BuildContext context) {
    final readyCount =
        accounts
            .where((account) => !account.requiresAttention(asOfDate))
            .length;

    return HrisSectionPanel(
      icon: Icons.account_balance_outlined,
      title: 'Employer Account Registry',
      subtitle: '$readyCount ready of ${accounts.length} statutory accounts',
      emptyMessage: 'No matching employer accounts',
      children:
          accounts
              .map(
                (account) => _EmployerAccountTile(
                  account: account,
                  asOfDate: asOfDate,
                  onMarkVerified: () => onMarkVerified(account.id),
                  onRotateCredentialOwner:
                      () => onRotateCredentialOwner(account.id),
                ),
              )
              .toList(),
    );
  }
}

class _EmployerAccountTile extends StatelessWidget {
  final CompanyEmployerAccount account;
  final DateTime asOfDate;
  final VoidCallback onMarkVerified;
  final VoidCallback onRotateCredentialOwner;

  const _EmployerAccountTile({
    required this.account,
    required this.asOfDate,
    required this.onMarkVerified,
    required this.onRotateCredentialOwner,
  });

  @override
  Widget build(BuildContext context) {
    final issues = account.issues(asOfDate);
    final statusColor = companyEmployerAccountStatusColor(account.status);

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
                      account.accountName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${account.entityName} - ${account.type.label}',
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
              HrisStatusPill(label: account.status.label, color: statusColor),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Account',
                value:
                    account.accountNumber.trim().isEmpty
                        ? 'Missing'
                        : account.accountNumber,
              ),
              HrisMetricStripItem(label: 'Owner', value: account.ownerName),
              HrisMetricStripItem(label: 'Review', value: _reviewLabel()),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Credential',
                value:
                    account.credentialOwnerName.trim().isEmpty
                        ? 'Missing'
                        : account.credentialOwnerName,
              ),
              HrisMetricStripItem(
                label: 'Linked',
                value:
                    account.linkedFiling.trim().isEmpty
                        ? 'Not linked'
                        : account.linkedFiling,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            account.nextAction,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: HrisColors.ink),
          ),
          if (account.evidenceSummary.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              account.evidenceSummary,
              maxLines: 2,
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
                              issue == CompanyEmployerAccountIssue.suspended ||
                                      issue ==
                                          CompanyEmployerAccountIssue
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
                  onPressed: onRotateCredentialOwner,
                  icon: const Icon(Icons.key_outlined),
                  label: const Text('Rotate credential'),
                ),
                FilledButton.icon(
                  onPressed: onMarkVerified,
                  icon: const Icon(Icons.verified_outlined),
                  label: const Text('Mark verified'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _reviewLabel() {
    final days = account.daysUntilReview(asOfDate);
    if (days < 0) return 'Overdue ${days.abs()}d';
    if (days == 0) return 'Today';
    final month = account.nextReviewDate.month.toString().padLeft(2, '0');
    final day = account.nextReviewDate.day.toString().padLeft(2, '0');
    return '${account.nextReviewDate.year}-$month-$day (${days}d)';
  }
}
