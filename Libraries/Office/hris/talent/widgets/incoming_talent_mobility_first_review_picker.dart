import 'package:flutter/material.dart';

import '../models/incoming_talent_succession_models.dart';

class IncomingTalentMobilityFirstReviewPicker extends StatelessWidget {
  final IncomingTalentMobilityFirstReviewDraft draft;
  final List<IncomingTalentMobilityLaunchChecklist> checklists;
  final ValueChanged<String?> onChanged;

  const IncomingTalentMobilityFirstReviewPicker({
    super.key,
    required this.draft,
    required this.checklists,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey('mobility-first-review-${draft.checklistId}'),
      initialValue: _checklistExists ? draft.checklistId : null,
      decoration: const InputDecoration(
        labelText: 'Launched mobility move',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.rocket_launch_outlined),
      ),
      items:
          checklists
              .map(
                (checklist) => DropdownMenuItem(
                  value: checklist.id,
                  child: Text(
                    '${checklist.candidateName} - ${checklist.opportunityTitle}',
                  ),
                ),
              )
              .toList(),
      onChanged: checklists.isEmpty ? null : onChanged,
      validator:
          (value) => IncomingTalentMobilityFirstReviewDraft.validateRequired(
            value,
            'a launched mobility checklist',
          ),
    );
  }

  bool get _checklistExists {
    return checklists.any((checklist) => checklist.id == draft.checklistId);
  }
}
