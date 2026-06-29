import 'package:flutter/material.dart';

import '../../../shared/widgets/hris_ui.dart';

class EmployeeDirectorySearchPanel extends StatelessWidget {
  final String query;
  final int resultCount;
  final ValueChanged<String> onChanged;
  final VoidCallback onAddEmployee;

  const EmployeeDirectorySearchPanel({
    super.key,
    required this.query,
    required this.resultCount,
    required this.onChanged,
    required this.onAddEmployee,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.manage_search_outlined,
      title: 'Directory search',
      subtitle: '$resultCount profiles match the current view',
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final searchField = TextFormField(
              key: ValueKey(query),
              initialValue: query,
              onChanged: onChanged,
              decoration: const InputDecoration(
                labelText: 'Search employees',
                prefixIcon: Icon(Icons.search_outlined),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            );
            final addButton = FilledButton.icon(
              onPressed: onAddEmployee,
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: const Text('Add employee'),
            );

            if (constraints.maxWidth < 720) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [searchField, const SizedBox(height: 12), addButton],
              );
            }

            return Row(
              children: [
                Expanded(child: searchField),
                const SizedBox(width: 12),
                addButton,
              ],
            );
          },
        ),
      ],
    );
  }
}
