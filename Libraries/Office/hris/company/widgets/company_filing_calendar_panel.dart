import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_filing.dart';
import 'company_status_styles.dart';

class CompanyFilingCalendarPanel extends StatelessWidget {
  final List<CompanyFiling> filings;
  final DateTime asOfDate;
  final ValueChanged<String> onMarkFiled;
  final ValueChanged<String> onEscalate;

  const CompanyFilingCalendarPanel({
    super.key,
    required this.filings,
    required this.asOfDate,
    required this.onMarkFiled,
    required this.onEscalate,
  });

  @override
  Widget build(BuildContext context) {
    final dueSoon =
        filings
            .where(
              (filing) =>
                  filing.status != CompanyFilingStatus.filed &&
                  filing.daysUntilDue(asOfDate) >= 0 &&
                  filing.daysUntilDue(asOfDate) <= 14,
            )
            .length;

    return HrisSectionPanel(
      icon: Icons.event_note_outlined,
      title: 'Company Filing Calendar',
      subtitle: '$dueSoon due soon of ${filings.length} filings',
      emptyMessage: 'No matching company filings',
      children:
          filings
              .map(
                (filing) => _CompanyFilingTile(
                  filing: filing,
                  asOfDate: asOfDate,
                  onMarkFiled: () => onMarkFiled(filing.id),
                  onEscalate: () => onEscalate(filing.id),
                ),
              )
              .toList(),
    );
  }
}

class _CompanyFilingTile extends StatelessWidget {
  final CompanyFiling filing;
  final DateTime asOfDate;
  final VoidCallback onMarkFiled;
  final VoidCallback onEscalate;

  const _CompanyFilingTile({
    required this.filing,
    required this.asOfDate,
    required this.onMarkFiled,
    required this.onEscalate,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = companyFilingStatusColor(filing.status);
    final issues = filing.issues(asOfDate);

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
                      filing.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${filing.entityName} - ${filing.type.label}',
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
                    label: filing.cadence.label,
                    color: Colors.indigo,
                  ),
                  HrisStatusPill(
                    label: filing.status.label,
                    color: statusColor,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(label: 'Owner', value: filing.ownerName),
              HrisMetricStripItem(label: 'Due', value: _dueLabel()),
              HrisMetricStripItem(
                label: 'Authority',
                value: filing.authorityName,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            filing.nextStep,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: HrisColors.ink),
          ),
          if (filing.evidenceSummary.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              filing.evidenceSummary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: HrisColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (filing.linkedRecord.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            HrisStatusPill(label: filing.linkedRecord, color: Colors.blueGrey),
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
                              issue == CompanyFilingIssue.overdueDueDate ||
                                      issue == CompanyFilingIssue.blocked
                                  ? Colors.red
                                  : Colors.orange,
                        ),
                      )
                      .toList(),
            ),
          ],
          if (filing.status != CompanyFilingStatus.filed) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: onEscalate,
                  icon: const Icon(Icons.priority_high_outlined),
                  label: const Text('Escalate'),
                ),
                FilledButton.icon(
                  onPressed: onMarkFiled,
                  icon: const Icon(Icons.task_alt_outlined),
                  label: const Text('Mark filed'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _dueLabel() {
    final days = filing.daysUntilDue(asOfDate);
    if (days < 0) return 'Overdue ${days.abs()}d';
    if (days == 0) return 'Today';
    final month = filing.dueDate.month.toString().padLeft(2, '0');
    final day = filing.dueDate.day.toString().padLeft(2, '0');
    return '${filing.dueDate.year}-$month-$day (${days}d)';
  }
}
