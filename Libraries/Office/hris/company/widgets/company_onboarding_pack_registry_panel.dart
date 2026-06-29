import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_onboarding_pack.dart';
import 'company_status_styles.dart';

class CompanyOnboardingPackRegistryPanel extends StatelessWidget {
  final List<CompanyOnboardingPack> packs;
  final DateTime asOfDate;
  final ValueChanged<String> onActivate;
  final ValueChanged<String> onMarkReviewed;

  const CompanyOnboardingPackRegistryPanel({
    super.key,
    required this.packs,
    required this.asOfDate,
    required this.onActivate,
    required this.onMarkReviewed,
  });

  @override
  Widget build(BuildContext context) {
    final readyCount =
        packs.where((pack) => !pack.requiresAttention(asOfDate)).length;

    return HrisSectionPanel(
      icon: Icons.playlist_add_check_outlined,
      title: 'Onboarding Pack Registry',
      subtitle: '$readyCount ready of ${packs.length} packs',
      emptyMessage: 'No matching onboarding packs',
      children:
          packs
              .map(
                (pack) => _OnboardingPackTile(
                  pack: pack,
                  asOfDate: asOfDate,
                  onActivate: () => onActivate(pack.id),
                  onMarkReviewed: () => onMarkReviewed(pack.id),
                ),
              )
              .toList(),
    );
  }
}

class _OnboardingPackTile extends StatelessWidget {
  final CompanyOnboardingPack pack;
  final DateTime asOfDate;
  final VoidCallback onActivate;
  final VoidCallback onMarkReviewed;

  const _OnboardingPackTile({
    required this.pack,
    required this.asOfDate,
    required this.onActivate,
    required this.onMarkReviewed,
  });

  @override
  Widget build(BuildContext context) {
    final issues = pack.issues(asOfDate);
    final statusColor = companyOnboardingPackStatusColor(pack.status);

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
                      pack.packName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pack.entityName} - ${pack.type.label}',
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
              HrisStatusPill(label: pack.status.label, color: statusColor),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Job',
                value:
                    pack.jobProfileCode.trim().isEmpty
                        ? 'Missing'
                        : pack.jobProfileCode,
              ),
              HrisMetricStripItem(
                label: 'Tasks',
                value: '${pack.requiredTaskCount}',
              ),
              HrisMetricStripItem(
                label: 'SLA',
                value: pack.slaDays <= 0 ? 'Missing' : '${pack.slaDays}d',
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Owner',
                value:
                    pack.ownerName.trim().isEmpty ? 'Missing' : pack.ownerName,
              ),
              HrisMetricStripItem(
                label: 'Automation',
                value: '${pack.automationCoveragePercent.clamp(0, 100)}%',
              ),
              HrisMetricStripItem(label: 'Review', value: _reviewLabel()),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            pack.contractTemplateName.trim().isEmpty
                ? 'Contract template missing'
                : pack.contractTemplateName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            pack.managerHandoff.trim().isEmpty
                ? 'Manager handoff missing'
                : pack.managerHandoff,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              HrisStatusPill(
                label:
                    pack.documentChecklist.trim().isEmpty
                        ? 'Documents missing'
                        : 'Documents',
                color: Colors.indigo,
              ),
              HrisStatusPill(
                label:
                    pack.accessChecklist.trim().isEmpty
                        ? 'Access missing'
                        : 'Access',
                color: Colors.blueGrey,
              ),
              HrisStatusPill(
                label:
                    pack.equipmentChecklist.trim().isEmpty
                        ? 'Equipment missing'
                        : 'Equipment',
                color: Colors.teal,
              ),
            ],
          ),
          if (pack.notes.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              pack.notes,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
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
                              issue == CompanyOnboardingPackIssue.reviewOverdue
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
                  label: const Text('Activate pack'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _reviewLabel() {
    final days = pack.daysUntilReview(asOfDate);
    if (days < 0) return 'Overdue ${days.abs()}d';
    if (days == 0) return 'Today';
    final month = pack.nextReviewDate.month.toString().padLeft(2, '0');
    final day = pack.nextReviewDate.day.toString().padLeft(2, '0');
    return '${pack.nextReviewDate.year}-$month-$day (${days}d)';
  }
}
