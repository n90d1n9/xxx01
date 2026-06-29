import 'package:flutter/material.dart';

import '../models/incoming_talent_succession_models.dart';

class IncomingTalentMobilityCadenceInterventionOutcomePicker
    extends StatelessWidget {
  final IncomingTalentMobilityCadenceInterventionOutcomeDraft draft;
  final List<IncomingTalentMobilityCadenceIntervention> interventions;
  final ValueChanged<String?> onChanged;

  const IncomingTalentMobilityCadenceInterventionOutcomePicker({
    super.key,
    required this.draft,
    required this.interventions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey('mobility-intervention-outcome-${draft.interventionId}'),
      initialValue: _interventionExists ? draft.interventionId : null,
      decoration: const InputDecoration(
        labelText: 'Resolved intervention',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.task_alt_outlined),
      ),
      items:
          interventions
              .map(
                (intervention) => DropdownMenuItem(
                  value: intervention.id,
                  child: Text(
                    '${intervention.candidateName} - ${intervention.interventionType.label}',
                  ),
                ),
              )
              .toList(),
      onChanged: interventions.isEmpty ? null : onChanged,
      validator:
          (value) =>
              IncomingTalentMobilityCadenceInterventionOutcomeDraft.validateRequired(
                value,
                'a resolved intervention',
              ),
    );
  }

  bool get _interventionExists {
    return interventions.any((item) => item.id == draft.interventionId);
  }
}
