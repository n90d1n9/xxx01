import 'package:flutter/material.dart';

import '../models/incoming_talent_succession_models.dart';

class IncomingTalentMobilityLaunchMatchPicker extends StatelessWidget {
  final IncomingTalentMobilityLaunchChecklistDraft draft;
  final List<IncomingTalentMobilityMatch> matches;
  final ValueChanged<String?> onChanged;

  const IncomingTalentMobilityLaunchMatchPicker({
    super.key,
    required this.draft,
    required this.matches,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey('mobility-launch-match-${draft.matchId}'),
      initialValue: _matchExists ? draft.matchId : null,
      decoration: const InputDecoration(
        labelText: 'Accepted mobility match',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.verified_user_outlined),
      ),
      items:
          matches
              .map(
                (match) => DropdownMenuItem(
                  value: match.id,
                  child: Text(
                    '${match.candidateName} - ${match.opportunityTitle}',
                  ),
                ),
              )
              .toList(),
      onChanged: matches.isEmpty ? null : onChanged,
      validator:
          (value) =>
              IncomingTalentMobilityLaunchChecklistDraft.validateRequired(
                value,
                'a mobility match',
              ),
    );
  }

  bool get _matchExists {
    return matches.any((match) => match.id == draft.matchId);
  }
}
