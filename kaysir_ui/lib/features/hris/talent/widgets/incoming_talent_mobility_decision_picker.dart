import 'package:flutter/material.dart';

import '../models/incoming_talent_succession_models.dart';

class IncomingTalentMobilityDecisionPicker extends StatelessWidget {
  final IncomingTalentMobilityMatchDraft draft;
  final List<IncomingTalentSuccessionPanelDecision> decisions;
  final ValueChanged<String?> onChanged;

  const IncomingTalentMobilityDecisionPicker({
    super.key,
    required this.draft,
    required this.decisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey('mobility-decision-${draft.decisionId}'),
      initialValue: _decisionExists ? draft.decisionId : null,
      decoration: const InputDecoration(
        labelText: 'Approved panel decision',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.how_to_reg_outlined),
      ),
      items:
          decisions
              .map(
                (decision) => DropdownMenuItem(
                  value: decision.id,
                  child: Text(
                    '${decision.candidateName} - ${decision.targetRole}',
                  ),
                ),
              )
              .toList(),
      onChanged: decisions.isEmpty ? null : onChanged,
      validator:
          (value) =>
              validateIncomingTalentMobilityRequired(value, 'a panel decision'),
    );
  }

  bool get _decisionExists {
    return decisions.any((decision) => decision.id == draft.decisionId);
  }
}
