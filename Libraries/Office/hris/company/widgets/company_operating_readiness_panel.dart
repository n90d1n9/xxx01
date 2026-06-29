import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_operating_readiness.dart';
import 'company_status_styles.dart';

class CompanyOperatingReadinessPanel extends StatelessWidget {
  final List<CompanyOperatingReadinessItem> items;
  final DateTime asOfDate;
  final ValueChanged<String> onMarkReady;

  const CompanyOperatingReadinessPanel({
    super.key,
    required this.items,
    required this.asOfDate,
    required this.onMarkReady,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.settings_suggest_outlined,
      title: 'Operating Readiness',
      subtitle: '${items.length} HR services',
      emptyMessage: 'No matching operating readiness items',
      children:
          items
              .map(
                (item) => _OperatingReadinessTile(
                  item: item,
                  asOfDate: asOfDate,
                  onMarkReady: () => onMarkReady(item.id),
                ),
              )
              .toList(),
    );
  }
}

class _OperatingReadinessTile extends StatelessWidget {
  final CompanyOperatingReadinessItem item;
  final DateTime asOfDate;
  final VoidCallback onMarkReady;

  const _OperatingReadinessTile({
    required this.item,
    required this.asOfDate,
    required this.onMarkReady,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = companyOperatingReadinessStatusColor(item.status);
    final issues = item.issues(asOfDate);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${item.area.label} - ${item.entityName}',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(label: item.status.label, color: statusColor),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${item.linkedModule} - ${item.ownerName}',
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Coverage',
                value: '${item.coveragePercent}%',
              ),
              HrisMetricStripItem(label: 'Review', value: _reviewLabel(item)),
              HrisMetricStripItem(
                label: 'Blocker',
                value: item.blocker.trim().isEmpty ? 'None' : item.blocker,
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: item.coveragePercent / 100,
            color: statusColor,
            label: '${item.coveragePercent}% enabled',
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
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: onMarkReady,
                icon: const Icon(Icons.verified_outlined),
                label: const Text('Mark ready'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _reviewLabel(CompanyOperatingReadinessItem item) {
    final days = item.daysUntilReview(asOfDate);
    if (days < 0) return 'Overdue ${days.abs()}d';
    if (days == 0) return 'Today';
    return '${_formatDate(item.nextReviewDate)} (${days}d)';
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
