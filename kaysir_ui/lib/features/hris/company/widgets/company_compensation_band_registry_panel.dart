import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_compensation_band.dart';
import 'company_status_styles.dart';

class CompanyCompensationBandRegistryPanel extends StatelessWidget {
  final List<CompanyCompensationBand> bands;
  final DateTime asOfDate;
  final ValueChanged<String> onActivate;
  final ValueChanged<String> onMarkReviewed;

  const CompanyCompensationBandRegistryPanel({
    super.key,
    required this.bands,
    required this.asOfDate,
    required this.onActivate,
    required this.onMarkReviewed,
  });

  @override
  Widget build(BuildContext context) {
    final readyCount =
        bands.where((band) => !band.requiresAttention(asOfDate)).length;

    return HrisSectionPanel(
      icon: Icons.price_change_outlined,
      title: 'Compensation Band Catalog',
      subtitle: '$readyCount ready of ${bands.length} salary bands',
      emptyMessage: 'No matching compensation bands',
      children:
          bands
              .map(
                (band) => _CompensationBandTile(
                  band: band,
                  asOfDate: asOfDate,
                  onActivate: () => onActivate(band.id),
                  onMarkReviewed: () => onMarkReviewed(band.id),
                ),
              )
              .toList(),
    );
  }
}

class _CompensationBandTile extends StatelessWidget {
  final CompanyCompensationBand band;
  final DateTime asOfDate;
  final VoidCallback onActivate;
  final VoidCallback onMarkReviewed;

  const _CompensationBandTile({
    required this.band,
    required this.asOfDate,
    required this.onActivate,
    required this.onMarkReviewed,
  });

  @override
  Widget build(BuildContext context) {
    final issues = band.issues(asOfDate);
    final statusColor = companyCompensationBandStatusColor(band.status);

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
                      '${band.bandCode} - ${band.levelName}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${band.entityName} - ${band.family.label}',
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
              HrisStatusPill(label: band.status.label, color: statusColor),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(label: 'Min', value: _money(band.minSalary)),
              HrisMetricStripItem(
                label: 'Mid',
                value: _money(band.midpointSalary),
              ),
              HrisMetricStripItem(label: 'Max', value: _money(band.maxSalary)),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(label: 'Owner', value: band.ownerName),
              HrisMetricStripItem(
                label: 'Approver',
                value:
                    band.approverName.trim().isEmpty
                        ? 'Missing'
                        : band.approverName,
              ),
              HrisMetricStripItem(label: 'Review', value: _reviewLabel()),
            ],
          ),
          if (band.linkedPolicy.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              band.linkedPolicy,
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
                              issue ==
                                          CompanyCompensationBandIssue
                                              .reviewOverdue ||
                                      issue ==
                                          CompanyCompensationBandIssue
                                              .invalidRange
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
                  label: const Text('Activate band'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _money(int value) {
    if (value >= 1000000) {
      return '${band.currency} ${(value / 1000000).round()}M';
    }
    return '${band.currency} $value';
  }

  String _reviewLabel() {
    final days = band.daysUntilReview(asOfDate);
    if (days < 0) return 'Overdue ${days.abs()}d';
    if (days == 0) return 'Today';
    final month = band.nextReviewDate.month.toString().padLeft(2, '0');
    final day = band.nextReviewDate.day.toString().padLeft(2, '0');
    return '${band.nextReviewDate.year}-$month-$day (${days}d)';
  }
}
