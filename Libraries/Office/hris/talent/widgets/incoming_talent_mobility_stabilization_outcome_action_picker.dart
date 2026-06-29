import 'package:flutter/material.dart';

import '../models/incoming_talent_succession_models.dart';

class IncomingTalentMobilityStabilizationOutcomeActionPicker
    extends StatelessWidget {
  final IncomingTalentMobilityStabilizationOutcomeDraft draft;
  final List<IncomingTalentMobilityStabilizationAction> actions;
  final ValueChanged<String?> onChanged;

  const IncomingTalentMobilityStabilizationOutcomeActionPicker({
    super.key,
    required this.draft,
    required this.actions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey('mobility-stabilization-outcome-${draft.actionId}'),
      initialValue: _actionExists ? draft.actionId : null,
      decoration: const InputDecoration(
        labelText: 'Completed mobility action',
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
          (value) =>
              IncomingTalentMobilityStabilizationOutcomeDraft.validateRequired(
                value,
                'a completed stabilization action',
              ),
    );
  }

  bool get _actionExists {
    return actions.any((action) => action.id == draft.actionId);
  }
}
