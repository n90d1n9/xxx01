import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_job_profile.dart';
import 'company_status_styles.dart';

class CompanyJobProfileCatalogPanel extends StatelessWidget {
  final List<CompanyJobProfile> profiles;
  final DateTime asOfDate;
  final ValueChanged<String> onActivate;
  final ValueChanged<String> onMarkReviewed;

  const CompanyJobProfileCatalogPanel({
    super.key,
    required this.profiles,
    required this.asOfDate,
    required this.onActivate,
    required this.onMarkReviewed,
  });

  @override
  Widget build(BuildContext context) {
    final readyCount =
        profiles
            .where((profile) => !profile.requiresAttention(asOfDate))
            .length;

    return HrisSectionPanel(
      icon: Icons.badge_outlined,
      title: 'Job Architecture Catalog',
      subtitle: '$readyCount ready of ${profiles.length} job profiles',
      emptyMessage: 'No matching job profiles',
      children:
          profiles
              .map(
                (profile) => _JobProfileTile(
                  profile: profile,
                  asOfDate: asOfDate,
                  onActivate: () => onActivate(profile.id),
                  onMarkReviewed: () => onMarkReviewed(profile.id),
                ),
              )
              .toList(),
    );
  }
}

class _JobProfileTile extends StatelessWidget {
  final CompanyJobProfile profile;
  final DateTime asOfDate;
  final VoidCallback onActivate;
  final VoidCallback onMarkReviewed;

  const _JobProfileTile({
    required this.profile,
    required this.asOfDate,
    required this.onActivate,
    required this.onMarkReviewed,
  });

  @override
  Widget build(BuildContext context) {
    final issues = profile.issues(asOfDate);
    final statusColor = companyJobProfileStatusColor(profile.status);

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
                      '${profile.jobCode} - ${profile.jobTitle}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${profile.entityName} - ${profile.orgUnitName}',
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
              HrisStatusPill(label: profile.status.label, color: statusColor),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(label: 'Family', value: profile.family.label),
              HrisMetricStripItem(label: 'Level', value: profile.levelName),
              HrisMetricStripItem(
                label: 'Band',
                value:
                    profile.compensationBand.trim().isEmpty
                        ? 'Missing'
                        : profile.compensationBand,
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Owner',
                value:
                    profile.ownerName.trim().isEmpty
                        ? 'Missing'
                        : profile.ownerName,
              ),
              HrisMetricStripItem(label: 'Review', value: _reviewLabel()),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            profile.jobDescription.trim().isEmpty
                ? 'Job description missing'
                : profile.jobDescription,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 8),
          Text(
            profile.skillsSummary.trim().isEmpty
                ? 'Skills summary missing'
                : profile.skillsSummary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (profile.linkedPolicy.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            HrisStatusPill(label: profile.linkedPolicy, color: Colors.blueGrey),
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
                              issue == CompanyJobProfileIssue.reviewOverdue
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
                  onPressed: onMarkReviewed,
                  icon: const Icon(Icons.rate_review_outlined),
                  label: const Text('Mark reviewed'),
                ),
                FilledButton.icon(
                  onPressed: onActivate,
                  icon: const Icon(Icons.verified_outlined),
                  label: const Text('Activate job'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _reviewLabel() {
    final days = profile.daysUntilReview(asOfDate);
    if (days < 0) return 'Overdue ${days.abs()}d';
    if (days == 0) return 'Today';
    final month = profile.nextReviewDate.month.toString().padLeft(2, '0');
    final day = profile.nextReviewDate.day.toString().padLeft(2, '0');
    return '${profile.nextReviewDate.year}-$month-$day (${days}d)';
  }
}
