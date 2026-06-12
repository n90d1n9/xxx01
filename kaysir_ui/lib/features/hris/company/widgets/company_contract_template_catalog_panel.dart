import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_contract_template.dart';
import 'company_status_styles.dart';

class CompanyContractTemplateCatalogPanel extends StatelessWidget {
  final List<CompanyContractTemplate> templates;
  final DateTime asOfDate;
  final ValueChanged<String> onActivate;
  final ValueChanged<String> onMarkReviewed;

  const CompanyContractTemplateCatalogPanel({
    super.key,
    required this.templates,
    required this.asOfDate,
    required this.onActivate,
    required this.onMarkReviewed,
  });

  @override
  Widget build(BuildContext context) {
    final readyCount =
        templates
            .where((template) => !template.requiresAttention(asOfDate))
            .length;

    return HrisSectionPanel(
      icon: Icons.article_outlined,
      title: 'Contract Template Catalog',
      subtitle: '$readyCount ready of ${templates.length} templates',
      emptyMessage: 'No matching contract templates',
      children:
          templates
              .map(
                (template) => _ContractTemplateTile(
                  template: template,
                  asOfDate: asOfDate,
                  onActivate: () => onActivate(template.id),
                  onMarkReviewed: () => onMarkReviewed(template.id),
                ),
              )
              .toList(),
    );
  }
}

class _ContractTemplateTile extends StatelessWidget {
  final CompanyContractTemplate template;
  final DateTime asOfDate;
  final VoidCallback onActivate;
  final VoidCallback onMarkReviewed;

  const _ContractTemplateTile({
    required this.template,
    required this.asOfDate,
    required this.onActivate,
    required this.onMarkReviewed,
  });

  @override
  Widget build(BuildContext context) {
    final issues = template.issues(asOfDate);
    final statusColor = companyContractTemplateStatusColor(template.status);

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
                      template.templateName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${template.entityName} - ${template.type.label}',
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
              HrisStatusPill(label: template.status.label, color: statusColor),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Job',
                value:
                    template.jobProfileCode.trim().isEmpty
                        ? 'Missing'
                        : template.jobProfileCode,
              ),
              HrisMetricStripItem(
                label: 'Band',
                value:
                    template.compensationBand.trim().isEmpty
                        ? 'Missing'
                        : template.compensationBand,
              ),
              HrisMetricStripItem(
                label: 'Version',
                value:
                    template.versionLabel.trim().isEmpty
                        ? 'Missing'
                        : template.versionLabel,
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Owner',
                value:
                    template.ownerName.trim().isEmpty
                        ? 'Missing'
                        : template.ownerName,
              ),
              HrisMetricStripItem(
                label: 'Legal',
                value:
                    template.legalReviewerName.trim().isEmpty
                        ? 'Missing'
                        : template.legalReviewerName,
              ),
              HrisMetricStripItem(label: 'Review', value: _reviewLabel()),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            template.clauseSummary.trim().isEmpty
                ? 'Clause summary missing'
                : template.clauseSummary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          if (template.onboardingChecklist.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              template.onboardingChecklist,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: HrisColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              HrisStatusPill(
                label:
                    template.signatoryRole.trim().isEmpty
                        ? 'Signatory missing'
                        : template.signatoryRole,
                color: Colors.indigo,
              ),
              HrisStatusPill(
                label:
                    template.language.trim().isEmpty
                        ? 'Language missing'
                        : template.language,
                color: Colors.blueGrey,
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
                          color:
                              issue ==
                                      CompanyContractTemplateIssue.reviewOverdue
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
                  label: const Text('Activate template'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _reviewLabel() {
    final days = template.daysUntilReview(asOfDate);
    if (days < 0) return 'Overdue ${days.abs()}d';
    if (days == 0) return 'Today';
    final month = template.nextReviewDate.month.toString().padLeft(2, '0');
    final day = template.nextReviewDate.day.toString().padLeft(2, '0');
    return '${template.nextReviewDate.year}-$month-$day (${days}d)';
  }
}
