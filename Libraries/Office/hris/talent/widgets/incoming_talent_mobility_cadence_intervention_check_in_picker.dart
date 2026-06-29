import 'package:flutter/material.dart';

import '../models/incoming_talent_succession_models.dart';

class IncomingTalentMobilityCadenceInterventionCheckInPicker
    extends StatelessWidget {
  final IncomingTalentMobilityCadenceInterventionDraft draft;
  final List<IncomingTalentMobilityCadenceCheckIn> checkIns;
  final ValueChanged<String?> onChanged;

  const IncomingTalentMobilityCadenceInterventionCheckInPicker({
    super.key,
    required this.draft,
    required this.checkIns,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey('mobility-cadence-intervention-${draft.checkInId}'),
      initialValue: _checkInExists ? draft.checkInId : null,
      decoration: const InputDecoration(
        labelText: 'Risky cadence check-in',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.event_repeat_outlined),
      ),
      items:
          checkIns
              .map(
                (checkIn) => DropdownMenuItem(
                  value: checkIn.id,
                  child: Text(
                    '${checkIn.candidateName} - ${checkIn.status.label}',
                  ),
                ),
              )
              .toList(),
      onChanged: checkIns.isEmpty ? null : onChanged,
      validator:
          (value) =>
              IncomingTalentMobilityCadenceInterventionDraft.validateRequired(
                value,
                'a mobility cadence check-in',
              ),
    );
  }

  bool get _checkInExists {
    return checkIns.any((checkIn) => checkIn.id == draft.checkInId);
  }
}
