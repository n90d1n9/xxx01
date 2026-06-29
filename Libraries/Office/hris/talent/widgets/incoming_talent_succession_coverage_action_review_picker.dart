import 'package:flutter/material.dart';

import '../models/incoming_talent_succession_models.dart';

class IncomingTalentSuccessionCoverageActionReviewPicker
    extends StatelessWidget {
  final IncomingTalentSuccessionCoverageActionDraft draft;
  final List<IncomingTalentSuccessionCoverageReview> reviews;
  final ValueChanged<String?> onChanged;

  const IncomingTalentSuccessionCoverageActionReviewPicker({
    super.key,
    required this.draft,
    required this.reviews,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey('succession-coverage-action-${draft.coverageReviewId}'),
      initialValue:
          _reviewExists(reviews, draft.coverageReviewId)
              ? draft.coverageReviewId
              : null,
      decoration: const InputDecoration(
        labelText: 'Coverage review',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.fact_check_outlined),
      ),
      items:
          reviews
              .map(
                (review) => DropdownMenuItem(
                  value: review.id,
                  child: Text(
                    '${review.scopeLabel} - ${review.decision.label}',
                  ),
                ),
              )
              .toList(),
      onChanged: reviews.isEmpty ? null : onChanged,
      validator:
          (value) =>
              IncomingTalentSuccessionCoverageActionDraft.validateRequired(
                value,
                'a coverage review',
              ),
    );
  }

  bool _reviewExists(
    List<IncomingTalentSuccessionCoverageReview> reviews,
    String reviewId,
  ) {
    return reviews.any((review) => review.id == reviewId);
  }
}
