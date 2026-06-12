import 'package:flutter/material.dart';

import '../models/incoming_talent_career_path_review_models.dart';
import '../models/incoming_talent_career_path_support_action_models.dart';

class IncomingTalentCareerPathSupportActionReviewPicker
    extends StatelessWidget {
  final IncomingTalentCareerPathSupportActionDraft draft;
  final List<IncomingTalentCareerPathReview> reviews;
  final ValueChanged<String?> onChanged;

  const IncomingTalentCareerPathSupportActionReviewPicker({
    super.key,
    required this.draft,
    required this.reviews,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey('career-support-${draft.reviewId}'),
      initialValue: _reviewExists ? draft.reviewId : null,
      decoration: const InputDecoration(
        labelText: 'Career review',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.fact_check_outlined),
      ),
      items:
          reviews
              .map(
                (review) => DropdownMenuItem(
                  value: review.id,
                  child: Text(
                    '${review.candidateName} - ${review.decision.label}',
                  ),
                ),
              )
              .toList(),
      onChanged: reviews.isEmpty ? null : onChanged,
      validator:
          (value) => validateIncomingTalentCareerPathSupportActionRequired(
            value,
            'a career path review',
          ),
    );
  }

  bool get _reviewExists {
    return reviews.any((review) => review.id == draft.reviewId);
  }
}
