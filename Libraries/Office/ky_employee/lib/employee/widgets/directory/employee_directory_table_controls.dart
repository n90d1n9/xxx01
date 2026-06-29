import 'package:flutter/material.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_table_models.dart';

class EmployeeDirectoryTableControls extends StatefulWidget {
  final String query;
  final int visibleCount;
  final int candidateCount;
  final EmployeeDirectoryTableStatusFilter statusFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<EmployeeDirectoryTableStatusFilter?> onStatusChanged;
  final VoidCallback onAddEmployee;
  final VoidCallback onClearFilters;

  const EmployeeDirectoryTableControls({
    super.key,
    required this.query,
    required this.visibleCount,
    required this.candidateCount,
    required this.statusFilter,
    required this.onSearchChanged,
    required this.onStatusChanged,
    required this.onAddEmployee,
    required this.onClearFilters,
  });

  @override
  State<EmployeeDirectoryTableControls> createState() =>
      _EmployeeDirectoryTableControlsState();
}

class _EmployeeDirectoryTableControlsState
    extends State<EmployeeDirectoryTableControls> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.query);
  }

  @override
  void didUpdateWidget(EmployeeDirectoryTableControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query &&
        _searchController.text != widget.query) {
      _searchController.text = widget.query;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.manage_search_outlined,
      title: 'Table controls',
      subtitle:
          '${widget.visibleCount} visible of ${widget.candidateCount} matching profiles',
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 820;
            final searchField = TextField(
              key: const ValueKey('employee-directory-table-search-field'),
              controller: _searchController,
              onChanged: widget.onSearchChanged,
              decoration: const InputDecoration(
                labelText: 'Search employee table',
                prefixIcon: Icon(Icons.search_outlined),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            );
            final statusFilter =
                DropdownButtonFormField<EmployeeDirectoryTableStatusFilter>(
                  key: const ValueKey('employee-directory-table-status-filter'),
                  initialValue: widget.statusFilter,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(Icons.verified_user_outlined),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items:
                      EmployeeDirectoryTableStatusFilter.values
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status.label),
                            ),
                          )
                          .toList(),
                  onChanged: widget.onStatusChanged,
                );
            final clearButton = OutlinedButton.icon(
              onPressed: widget.onClearFilters,
              icon: const Icon(Icons.filter_alt_off_outlined),
              label: const Text('Clear'),
            );
            final addButton = FilledButton.icon(
              key: const ValueKey('employee-directory-table-add-button'),
              onPressed: widget.onAddEmployee,
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: const Text('Add employee'),
            );

            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  searchField,
                  const SizedBox(height: 12),
                  statusFilter,
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [clearButton, addButton],
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(flex: 3, child: searchField),
                const SizedBox(width: 12),
                SizedBox(width: 220, child: statusFilter),
                const SizedBox(width: 12),
                clearButton,
                const SizedBox(width: 10),
                addButton,
              ],
            );
          },
        ),
      ],
    );
  }
}
