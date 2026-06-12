import 'package:flutter/material.dart';

import '../models/incoming_talent_succession_models.dart';

class IncomingTalentSuccessionCoverageActionOutcomeActionPicker
    extends StatelessWidget {
  final IncomingTalentSuccessionCoverageActionOutcomeDraft draft;
  final List<IncomingTalentSuccessionCoverageAction> actions;
  final ValueChanged<String?> onChanged;

  const IncomingTalentSuccessionCoverageActionOutcomeActionPicker({
    super.key,
    required this.draft,
    required this.actions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey('succession-coverage-outcome-${draft.actionId}'),
      initialValue: _actionExists(draft.actionId) ? draft.actionId : null,
      decoration: const InputDecoration(
        labelText: 'Resolved coverage action',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.task_alt_outlined),
      ),
      items:
          actions
              .map(
                (action) => DropdownMenuItem(
                  value: action.id,
                  child: Text(
                    '${action.scopeLabel} - ${action.actionType.label}',
                  ),
                ),
              )
              .toList(),
      onChanged: actions.isEmpty ? null : onChanged,
      validator: validateCoverageActionOutcomeActionId,
    );
  }

  bool _actionExists(String actionId) {
    return actions.any((action) => action.id == actionId);
  }
}
