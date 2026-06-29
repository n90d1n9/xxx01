import 'package:flutter/material.dart';

import '../models/incoming_talent_succession_models.dart';

class IncomingTalentSuccessionCoverageCouncilDecisionAgendaPicker
    extends StatelessWidget {
  final IncomingTalentSuccessionCoverageCouncilDecisionDraft draft;
  final List<IncomingTalentSuccessionCoverageCouncilAgendaItem> items;
  final ValueChanged<String?> onChanged;

  const IncomingTalentSuccessionCoverageCouncilDecisionAgendaPicker({
    super.key,
    required this.draft,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey('coverage-council-decision-${draft.agendaItemId}'),
      initialValue: _itemExists(draft.agendaItemId) ? draft.agendaItemId : null,
      decoration: const InputDecoration(
        labelText: 'Council agenda item',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.groups_2_outlined),
      ),
      items:
          items
              .map(
                (item) => DropdownMenuItem(
                  value: item.id,
                  child: Text('${item.scopeLabel} - ${item.lane.label}'),
                ),
              )
              .toList(),
      onChanged: items.isEmpty ? null : onChanged,
      validator:
          (value) => validateCoverageCouncilDecisionRequired(
            value,
            'a council agenda item',
          ),
    );
  }

  bool _itemExists(String itemId) {
    return items.any((item) => item.id == itemId);
  }
}
