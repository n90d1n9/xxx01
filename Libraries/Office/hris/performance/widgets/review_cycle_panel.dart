import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/performance_models.dart';
import 'performance_meta_label.dart';
import 'performance_status_styles.dart';

class ReviewCyclePanel extends StatelessWidget {
  final List<ReviewCycle> reviews;

  const ReviewCyclePanel({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      title: 'Review Cycles',
      icon: Icons.rate_review_outlined,
      subtitle: '${reviews.length} cycles',
      emptyMessage: 'No reviews match filters',
      children: reviews.map((review) => _ReviewTile(review: review)).toList(),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final ReviewCycle review;

  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    final color = reviewStatusColor(review.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              HrisStatusPill(
                label: reviewStatusLabel(review.status),
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 10),
          HrisProgressBar(
            value: review.completionRate,
            color: color,
            label:
                '${review.submittedCount}/${review.participantCount} submitted',
          ),
          const SizedBox(height: 8),
          PerformanceMetaLabel(
            icon: Icons.calendar_today_outlined,
            label: DateFormat('MMM d').format(review.dueDate),
          ),
        ],
      ),
    );
  }
}
