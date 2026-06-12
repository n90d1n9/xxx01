import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_control.dart';
import 'company_status_styles.dart';

class CompanyControlRegisterPanel extends StatelessWidget {
  final List<CompanyControl> controls;
  final DateTime asOfDate;
  final ValueChanged<String> onRemediate;
  final ValueChanged<String> onWaive;

  const CompanyControlRegisterPanel({
    super.key,
    required this.controls,
    required this.asOfDate,
    required this.onRemediate,
    required this.onWaive,
  });

  @override
  Widget build(BuildContext context) {
    final riskCount =
        controls.where((control) => control.requiresAttention(asOfDate)).length;
    final healthyCount = controls.length - riskCount;

    return HrisSectionPanel(
      icon: Icons.fact_check_outlined,
      title: 'Company Control Register',
      subtitle: '$healthyCount healthy of ${controls.length} controls',
      emptyMessage: 'No matching company controls',
      children:
          controls
              .map(
                (control) => _CompanyControlTile(
                  control: control,
                  asOfDate: asOfDate,
                  onRemediate: () => onRemediate(control.id),
                  onWaive: () => onWaive(control.id),
                ),
              )
              .toList(),
    );
  }
}

class _CompanyControlTile extends StatelessWidget {
  final CompanyControl control;
  final DateTime asOfDate;
  final VoidCallback onRemediate;
  final VoidCallback onWaive;

  const _CompanyControlTile({
    required this.control,
    required this.asOfDate,
    required this.onRemediate,
    required this.onWaive,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = companyControlStatusColor(control.status);
    final severityColor = companyControlSeverityColor(control.severity);
    final issues = control.issues(asOfDate);

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
                      control.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${control.entityName} - ${control.domain.label}',
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
                    label: control.severity.label,
                    color: severityColor,
                  ),
                  HrisStatusPill(
                    label: control.status.label,
                    color: statusColor,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(label: 'Owner', value: control.ownerName),
              HrisMetricStripItem(label: 'Review', value: _reviewLabel()),
              HrisMetricStripItem(
                label: 'Linked',
                value:
                    control.linkedRecord.trim().isEmpty
                        ? 'Unlinked'
                        : control.linkedRecord,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            control.evidenceSummary.trim().isEmpty
                ? 'Evidence not attached'
                : control.evidenceSummary,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: HrisColors.ink),
          ),
          if (control.remediationAction.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              control.remediationAction,
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
                              issue == CompanyControlIssue.criticalSeverity
                                  ? Colors.red
                                  : Colors.orange,
                        ),
                      )
                      .toList(),
            ),
          ],
          if (control.status != CompanyControlStatus.healthy &&
              control.status != CompanyControlStatus.waived) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: onWaive,
                  icon: const Icon(Icons.block_outlined),
                  label: const Text('Waive'),
                ),
                FilledButton.icon(
                  onPressed: onRemediate,
                  icon: const Icon(Icons.task_alt_outlined),
                  label: const Text('Remediate'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _reviewLabel() {
    final days = control.daysUntilReview(asOfDate);
    if (days < 0) return 'Overdue ${days.abs()}d';
    if (days == 0) return 'Today';
    final month = control.nextReviewDate.month.toString().padLeft(2, '0');
    final day = control.nextReviewDate.day.toString().padLeft(2, '0');
    return '${control.nextReviewDate.year}-$month-$day (${days}d)';
  }
}
