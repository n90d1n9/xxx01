import 'package:flutter/material.dart';

import '../models/incoming_talent_development_intervention_models.dart';

class IncomingTalentDevelopmentInterventionSourceField extends StatelessWidget {
  final String selectedKey;
  final List<IncomingTalentDevelopmentInterventionSourceOption> sources;
  final ValueChanged<String?> onChanged;

  const IncomingTalentDevelopmentInterventionSourceField({
    super.key,
    required this.selectedKey,
    required this.sources,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selectedSource =
        sources.any((source) => source.key == selectedKey) ? selectedKey : null;

    return DropdownButtonFormField<String>(
      key: ValueKey('intervention-source-$selectedKey'),
      initialValue: selectedSource,
      decoration: const InputDecoration(
        labelText: 'Risk source',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.account_tree_outlined),
      ),
      items:
          sources.map((source) {
            return DropdownMenuItem(
              value: source.key,
              child: Text(source.label, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
      onChanged: sources.isEmpty ? null : onChanged,
      validator: (value) => value == null ? 'Select a risk source' : null,
    );
  }
}
