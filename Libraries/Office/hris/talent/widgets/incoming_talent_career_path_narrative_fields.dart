import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/incoming_talent_career_path_models.dart';
import '../states/incoming_talent_career_path_provider.dart';
import 'incoming_talent_career_path_text_input.dart';

class IncomingTalentCareerPathNarrativeFields extends ConsumerWidget {
  final TextEditingController actionController;
  final TextEditingController evidenceController;

  const IncomingTalentCareerPathNarrativeFields({
    super.key,
    required this.actionController,
    required this.evidenceController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(incomingTalentCareerPathDraftProvider.notifier);

    return Column(
      children: [
        IncomingTalentCareerPathTextInput(
          controller: actionController,
          label: 'Development action',
          icon: Icons.menu_book_outlined,
          minLines: 3,
          onChanged: notifier.setDevelopmentAction,
          validator:
              (value) => validateIncomingTalentCareerPathLongText(
                value,
                'development action',
              ),
        ),
        const SizedBox(height: 12),
        IncomingTalentCareerPathTextInput(
          controller: evidenceController,
          label: 'Evidence requirement',
          icon: Icons.fact_check_outlined,
          minLines: 3,
          onChanged: notifier.setEvidenceRequirement,
          validator:
              (value) => validateIncomingTalentCareerPathLongText(
                value,
                'evidence requirement',
              ),
        ),
      ],
    );
  }
}
