import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/compensation_models.dart';
import 'compensation_formatters.dart';
import 'compensation_meta_label.dart';
import 'compensation_status_styles.dart';

class CompensationReviewPanel extends StatelessWidget {
  final List<CompensationReview> reviews;

  const CompensationReviewPanel({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      title: 'Compensation Reviews',
      icon: Icons.payments_outlined,
      subtitle: '${reviews.length} reviews',
      emptyMessage: 'No compensation reviews match filters',
      children: reviews.map((review) => _ReviewTile(review: review)).toList(),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final CompensationReview review;

  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    final color = compensationStatusColor(review.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.employeeName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              HrisStatusPill(
                label: compensationStatusLabel(review.status),
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${review.role} - ${compactMoney(review.currentSalary)} to ${compactMoney(review.proposedSalary)}',
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 10),
          HrisProgressBar(
            value: review.marketPercentile / 100,
            color: color,
            label: 'Market percentile ${review.marketPercentile}',
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              CompensationMetaLabel(
                icon: Icons.trending_up_outlined,
                label:
                    '${(review.increaseRate * 100).toStringAsFixed(1)}% increase',
              ),
              CompensationMetaLabel(
                icon: Icons.calendar_today_outlined,
                label: DateFormat('MMM d').format(review.effectiveDate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
