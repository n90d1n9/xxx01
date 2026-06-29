import 'package:flutter/material.dart';

import '../models/incoming_talent_succession_models.dart';

class IncomingTalentMobilityCadenceOutcomePicker extends StatelessWidget {
  final IncomingTalentMobilityCadenceCheckInDraft draft;
  final List<IncomingTalentMobilityStabilizationOutcome> outcomes;
  final ValueChanged<String?> onChanged;

  const IncomingTalentMobilityCadenceOutcomePicker({
    super.key,
    required this.draft,
    required this.outcomes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey('mobility-cadence-${draft.outcomeId}'),
      initialValue: _outcomeExists ? draft.outcomeId : null,
      decoration: const InputDecoration(
        labelText: 'Mobility outcome',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.fact_check_outlined),
      ),
      items:
          outcomes
              .map(
                (outcome) => DropdownMenuItem(
                  value: outcome.id,
                  child: Text(
                    '${outcome.candidateName} - ${outcome.decision.label}',
                  ),
                ),
              )
              .toList(),
      onChanged: outcomes.isEmpty ? null : onChanged,
      validator:
          (value) => IncomingTalentMobilityCadenceCheckInDraft.validateRequired(
            value,
            'a mobility outcome',
          ),
    );
  }

  bool get _outcomeExists {
    return outcomes.any((outcome) => outcome.id == draft.outcomeId);
  }
}
