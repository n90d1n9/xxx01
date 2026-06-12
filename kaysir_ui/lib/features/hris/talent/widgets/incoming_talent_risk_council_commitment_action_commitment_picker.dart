import 'package:flutter/material.dart';

import '../models/incoming_talent_risk_council_commitment_action_models.dart';
import '../models/incoming_talent_risk_council_commitment_log_models.dart';

class IncomingTalentRiskCouncilCommitmentActionCommitmentPicker
    extends StatelessWidget {
  final IncomingTalentRiskCouncilCommitmentActionDraft draft;
  final List<IncomingTalentRiskCouncilCommitmentLogItem> commitments;
  final ValueChanged<String?> onChanged;

  const IncomingTalentRiskCouncilCommitmentActionCommitmentPicker({
    super.key,
    required this.draft,
    required this.commitments,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey('risk-council-commitment-action-${draft.commitmentId}'),
      initialValue: _commitmentExists ? draft.commitmentId : null,
      decoration: const InputDecoration(
        labelText: 'Council commitment',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.assignment_turned_in_outlined),
      ),
      items:
          commitments
              .map(
                (commitment) => DropdownMenuItem(
                  value: commitment.id,
                  child: Text(
                    '${commitment.title} - ${commitment.status.label}',
                  ),
                ),
              )
              .toList(),
      onChanged: commitments.isEmpty ? null : onChanged,
      validator:
          (value) => validateRiskCouncilCommitmentActionRequired(
            value,
            'a council commitment',
          ),
    );
  }

  bool get _commitmentExists {
    return commitments.any((commitment) => commitment.id == draft.commitmentId);
  }
}
