import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/request_time_off_draft.dart';

class RequestTimeOffReviewPanel extends StatelessWidget {
  final RequestTimeOffReview review;
  final VoidCallback onSubmit;

  const RequestTimeOffReviewPanel({
    super.key,
    required this.review,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor =
        review.canSubmit
            ? const Color(0xFF15803D)
            : review.exceedsBalance
            ? const Color(0xFFDC2626)
            : const Color(0xFFD97706);

    return HrisSectionPanel(
      icon: Icons.fact_check_outlined,
      title: 'Request preview',
      subtitle: 'Eligibility and manager review snapshot',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Duration',
              value: '${review.durationDays} days',
            ),
            HrisMetricStripItem(
              label: 'Remaining',
              value: '${review.remainingAfterRequest} days',
            ),
            HrisMetricStripItem(label: 'Type', value: review.draft.type),
          ],
        ),
        HrisListSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HrisStatusPill(label: review.guidance, color: statusColor),
              const SizedBox(height: 12),
              _ReviewLine(
                icon: Icons.date_range_outlined,
                label: 'Dates',
                value:
                    '${DateFormat('MMM d').format(review.draft.startDate)} - ${DateFormat('MMM d, yyyy').format(review.draft.endDate)}',
              ),
              _ReviewLine(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Balance',
                value:
                    '${review.balance.remainingDays} ${review.balance.type} days available',
              ),
              _ReviewLine(
                icon: Icons.notes_outlined,
                label: 'Reason',
                value:
                    review.draft.reason.trim().isEmpty
                        ? 'Not provided yet'
                        : review.draft.reason.trim(),
              ),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: review.canSubmit ? onSubmit : null,
          icon: const Icon(Icons.send_outlined),
          label: const Text('Submit request'),
        ),
      ],
    );
  }
}

class _ReviewLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ReviewLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: HrisColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: HrisColors.muted),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
