import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_document_requirement.dart';
import 'company_status_styles.dart';

class CompanyDocumentRequirementRegistryPanel extends StatelessWidget {
  final List<CompanyDocumentRequirement> requirements;
  final DateTime asOfDate;
  final ValueChanged<String> onActivate;
  final ValueChanged<String> onMarkReviewed;

  const CompanyDocumentRequirementRegistryPanel({
    super.key,
    required this.requirements,
    required this.asOfDate,
    required this.onActivate,
    required this.onMarkReviewed,
  });

  @override
  Widget build(BuildContext context) {
    final readyCount =
        requirements
            .where((requirement) => !requirement.requiresAttention(asOfDate))
            .length;

    return HrisSectionPanel(
      icon: Icons.folder_copy_outlined,
      title: 'Document Requirement Registry',
      subtitle: '$readyCount ready of ${requirements.length} requirements',
      emptyMessage: 'No matching document requirements',
      children:
          requirements
              .map(
                (requirement) => _DocumentRequirementTile(
                  requirement: requirement,
                  asOfDate: asOfDate,
                  onActivate: () => onActivate(requirement.id),
                  onMarkReviewed: () => onMarkReviewed(requirement.id),
                ),
              )
              .toList(),
    );
  }
}

class _DocumentRequirementTile extends StatelessWidget {
  final CompanyDocumentRequirement requirement;
  final DateTime asOfDate;
  final VoidCallback onActivate;
  final VoidCallback onMarkReviewed;

  const _DocumentRequirementTile({
    required this.requirement,
    required this.asOfDate,
    required this.onActivate,
    required this.onMarkReviewed,
  });

  @override
  Widget build(BuildContext context) {
    final issues = requirement.issues(asOfDate);
    final statusColor = companyDocumentRequirementStatusColor(
      requirement.status,
    );

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
                      requirement.requirementName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${requirement.entityName} - ${requirement.stage.label}',
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
              HrisStatusPill(
                label: requirement.status.label,
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Job',
                value:
                    requirement.jobProfileCode.trim().isEmpty
                        ? 'Missing'
                        : requirement.jobProfileCode,
              ),
              HrisMetricStripItem(
                label: 'Documents',
                value:
                    requirement.requiredDocumentCount <= 0
                        ? 'Missing'
                        : '${requirement.requiredDocumentCount}',
              ),
              HrisMetricStripItem(label: 'Review', value: _reviewLabel()),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Owner',
                value:
                    requirement.ownerName.trim().isEmpty
                        ? 'Missing'
                        : requirement.ownerName,
              ),
              HrisMetricStripItem(
                label: 'Evidence',
                value:
                    requirement.evidenceOwnerName.trim().isEmpty
                        ? 'Missing'
                        : requirement.evidenceOwnerName,
              ),
              HrisMetricStripItem(
                label: 'Lifecycle',
                value: requirement.lifecycleLinkLabel,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            requirement.policyReference.trim().isEmpty
                ? 'Policy reference missing'
                : requirement.policyReference,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            requirement.collectionChannel.trim().isEmpty
                ? 'Collection channel missing'
                : requirement.collectionChannel,
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
                    requirement.storageLocation.trim().isEmpty
                        ? 'Storage missing'
                        : 'Storage',
                color: Colors.indigo,
              ),
              HrisStatusPill(
                label:
                    requirement.retentionRule.trim().isEmpty
                        ? 'Retention missing'
                        : 'Retention',
                color: Colors.blueGrey,
              ),
              HrisStatusPill(
                label: requirement.stage.label,
                color: Colors.teal,
              ),
            ],
          ),
          if (requirement.notes.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              requirement.notes,
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
                              issue ==
                                      CompanyDocumentRequirementIssue
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
                  onPressed: onMarkReviewed,
                  icon: const Icon(Icons.rate_review_outlined),
                  label: const Text('Mark reviewed'),
                ),
                FilledButton.icon(
                  onPressed: onActivate,
                  icon: const Icon(Icons.verified_outlined),
                  label: const Text('Activate requirement'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _reviewLabel() {
    final days = requirement.daysUntilReview(asOfDate);
    if (days < 0) return 'Overdue ${days.abs()}d';
    if (days == 0) return 'Today';
    final month = requirement.nextReviewDate.month.toString().padLeft(2, '0');
    final day = requirement.nextReviewDate.day.toString().padLeft(2, '0');
    return '${requirement.nextReviewDate.year}-$month-$day (${days}d)';
  }
}
