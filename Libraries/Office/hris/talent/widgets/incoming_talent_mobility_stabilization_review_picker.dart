import 'package:flutter/material.dart';

import '../models/incoming_talent_succession_models.dart';

class IncomingTalentMobilityStabilizationReviewPicker extends StatelessWidget {
  final IncomingTalentMobilityStabilizationActionDraft draft;
  final List<IncomingTalentMobilityFirstReview> reviews;
  final ValueChanged<String?> onChanged;

  const IncomingTalentMobilityStabilizationReviewPicker({
    super.key,
    required this.draft,
    required this.reviews,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey('mobility-stabilization-review-${draft.reviewId}'),
      initialValue: _reviewExists ? draft.reviewId : null,
      decoration: const InputDecoration(
        labelText: 'Risky first review',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.rate_review_outlined),
      ),
      items:
          reviews
              .map(
                (review) => DropdownMenuItem(
                  value: review.id,
                  child: Text(
                    '${review.candidateName} - ${review.outcome.label}',
                  ),
                ),
              )
              .toList(),
      onChanged: reviews.isEmpty ? null : onChanged,
      validator:
          (value) =>
              IncomingTalentMobilityStabilizationActionDraft.validateRequired(
                value,
                'a mobility first review',
              ),
    );
  }

  bool get _reviewExists {
    return reviews.any((review) => review.id == draft.reviewId);
  }
}
