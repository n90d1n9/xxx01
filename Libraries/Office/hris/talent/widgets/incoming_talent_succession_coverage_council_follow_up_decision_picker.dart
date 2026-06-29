import 'package:flutter/material.dart';

import '../models/incoming_talent_succession_models.dart';

class IncomingTalentSuccessionCoverageCouncilFollowUpDecisionPicker
    extends StatelessWidget {
  final IncomingTalentSuccessionCoverageCouncilFollowUpDraft draft;
  final List<IncomingTalentSuccessionCoverageCouncilDecision> decisions;
  final ValueChanged<String?> onChanged;

  const IncomingTalentSuccessionCoverageCouncilFollowUpDecisionPicker({
    super.key,
    required this.draft,
    required this.decisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey('coverage-council-follow-up-${draft.decisionId}'),
      initialValue: _decisionExists ? draft.decisionId : null,
      decoration: const InputDecoration(
        labelText: 'Council decision',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.fact_check_outlined),
      ),
      items:
          decisions
              .map(
                (decision) => DropdownMenuItem(
                  value: decision.id,
                  child: Text(
                    '${decision.scopeLabel} - ${decision.outcome.label}',
                  ),
                ),
              )
              .toList(),
      onChanged: decisions.isEmpty ? null : onChanged,
      validator:
          (value) => validateCoverageCouncilFollowUpRequired(
            value,
            'a council decision',
          ),
    );
  }

  bool get _decisionExists {
    return decisions.any((decision) => decision.id == draft.decisionId);
  }
}
