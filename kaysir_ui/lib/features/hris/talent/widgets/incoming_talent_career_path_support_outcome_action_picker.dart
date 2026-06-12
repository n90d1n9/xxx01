import 'package:flutter/material.dart';

import '../models/incoming_talent_career_path_support_action_models.dart';
import '../models/incoming_talent_career_path_support_outcome_models.dart';

class IncomingTalentCareerPathSupportOutcomeActionPicker
    extends StatelessWidget {
  final IncomingTalentCareerPathSupportOutcomeDraft draft;
  final List<IncomingTalentCareerPathSupportAction> actions;
  final ValueChanged<String?> onChanged;

  const IncomingTalentCareerPathSupportOutcomeActionPicker({
    super.key,
    required this.draft,
    required this.actions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey('career-support-outcome-${draft.actionId}'),
      initialValue: _actionExists ? draft.actionId : null,
      decoration: const InputDecoration(
        labelText: 'Resolved support action',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.task_alt_outlined),
      ),
      items:
          actions
              .map(
                (action) => DropdownMenuItem(
                  value: action.id,
                  child: Text(
                    '${action.candidateName} - ${action.actionType.label}',
                  ),
                ),
              )
              .toList(),
      onChanged: actions.isEmpty ? null : onChanged,
      validator:
          (value) => validateIncomingTalentCareerPathSupportOutcomeRequired(
            value,
            'a resolved support action',
          ),
    );
  }

  bool get _actionExists {
    return actions.any((action) => action.id == draft.actionId);
  }
}
