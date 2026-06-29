import 'package:flutter/material.dart';

import '../models/incoming_talent_career_path_models.dart';
import '../models/incoming_talent_career_path_review_models.dart';

class IncomingTalentCareerPathReviewPathPicker extends StatelessWidget {
  final IncomingTalentCareerPathReviewDraft draft;
  final List<IncomingTalentCareerPath> careerPaths;
  final ValueChanged<String?> onChanged;

  const IncomingTalentCareerPathReviewPathPicker({
    super.key,
    required this.draft,
    required this.careerPaths,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey('career-path-review-${draft.careerPathId}'),
      initialValue: _careerPathExists ? draft.careerPathId : null,
      decoration: const InputDecoration(
        labelText: 'Career path',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.account_tree_outlined),
      ),
      items:
          careerPaths
              .map(
                (careerPath) => DropdownMenuItem(
                  value: careerPath.id,
                  child: Text(
                    '${careerPath.candidateName} - ${careerPath.targetRole}',
                  ),
                ),
              )
              .toList(),
      onChanged: careerPaths.isEmpty ? null : onChanged,
      validator:
          (value) => validateIncomingTalentCareerPathReviewRequired(
            value,
            'a career path',
          ),
    );
  }

  bool get _careerPathExists {
    return careerPaths.any((careerPath) => careerPath.id == draft.careerPathId);
  }
}
