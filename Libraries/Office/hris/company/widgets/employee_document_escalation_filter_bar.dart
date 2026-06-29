import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/employee_document_escalation_filter.dart';

/// Filter controls for narrowing employee document escalation lanes.
class EmployeeDocumentEscalationFilterBar extends StatelessWidget {
  final EmployeeDocumentEscalationFilter selectedFilter;
  final Map<EmployeeDocumentEscalationFilter, int> counts;
  final int visibleCount;
  final int totalCount;
  final ValueChanged<EmployeeDocumentEscalationFilter> onFilterChanged;

  const EmployeeDocumentEscalationFilterBar({
    super.key,
    required this.selectedFilter,
    required this.counts,
    required this.visibleCount,
    required this.totalCount,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$visibleCount of $totalCount escalation lanes shown',
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                EmployeeDocumentEscalationFilter.values.map((filter) {
                  final selected = filter == selectedFilter;
                  final count = counts[filter] ?? 0;
                  return ChoiceChip(
                    key: Key('employee-escalation-filter-${filter.name}'),
                    label: Text('${filter.label} ($count)'),
                    selected: selected,
                    onSelected: (_) => onFilterChanged(filter),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    selectedColor: HrisColors.primary.withValues(alpha: 0.12),
                    side: BorderSide(
                      color: selected ? HrisColors.primary : HrisColors.border,
                    ),
                    labelStyle: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(
                      color: selected ? HrisColors.primary : HrisColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Employee document escalation filter bar')
Widget employeeDocumentEscalationFilterBarPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: EmployeeDocumentEscalationFilterBar(
          selectedFilter: EmployeeDocumentEscalationFilter.ready,
          counts: const {
            EmployeeDocumentEscalationFilter.all: 4,
            EmployeeDocumentEscalationFilter.ready: 3,
            EmployeeDocumentEscalationFilter.coolingDown: 1,
            EmployeeDocumentEscalationFilter.critical: 2,
            EmployeeDocumentEscalationFilter.high: 1,
            EmployeeDocumentEscalationFilter.digestDue: 3,
          },
          visibleCount: 3,
          totalCount: 4,
          onFilterChanged: _previewFilterChanged,
        ),
      ),
    ),
  );
}

void _previewFilterChanged(EmployeeDocumentEscalationFilter filter) {}
