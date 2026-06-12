
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'filter_options.dart';
import '../task/task.dart';

class FilterButton extends StatefulWidget {
  final Function(FilterOptions) onFilterChange;
  final FilterOptions currentFilters;

  const FilterButton({
    super.key,
    required this.onFilterChange,
    required this.currentFilters,
  });

  @override
  FilterButtonState createState() => FilterButtonState();
}

class FilterButtonState extends State<FilterButton> {
  void _showFilterDialog() {
    FilterOptions tempFilters = widget.currentFilters.copy();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filter Tasks'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Range Filter
                Text('Date Range', style: Theme.of(context).textTheme.titleMedium),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          tempFilters.startDate != null
                              ? DateFormat('MMM dd, yyyy').format(tempFilters.startDate!)
                              : 'Start Date',
                        ),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: tempFilters.startDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setState(() => tempFilters.startDate = date);
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          tempFilters.endDate != null
                              ? DateFormat('MMM dd, yyyy').format(tempFilters.endDate!)
                              : 'End Date',
                        ),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: tempFilters.endDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setState(() => tempFilters.endDate = date);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Priority Filter
                Text('Priority', style: Theme.of(context).textTheme.titleMedium),
                Wrap(
                  spacing: 8,
                  children: TaskPriority.values.map((priority) {
                    return FilterChip(
                      label: Text(priority.label),
                      selected: tempFilters.priorities.contains(priority),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            tempFilters.priorities.add(priority);
                          } else {
                            tempFilters.priorities.remove(priority);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 16),
                
                // Status Filter
                Text('Status', style: Theme.of(context).textTheme.titleMedium),
                Wrap(
                  spacing: 8,
                  children: TaskStatus.values.map((status) {
                    return FilterChip(
                      label: Text(status.label),
                      selected: tempFilters.statuses.contains(status),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            tempFilters.statuses.add(status);
                          } else {
                            tempFilters.statuses.remove(status);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 16),
                
                // Assigned To Filter
                Text('Assigned To', style: Theme.of(context).textTheme.titleMedium),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() => tempFilters.assignedToSearch = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Clear All'),
              onPressed: () {
                setState(() => tempFilters = FilterOptions());
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            FilledButton(
              child: const Text('Apply'),
              onPressed: () {
                widget.onFilterChange(tempFilters);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = widget.currentFilters.isActive;

    return Tooltip(
      message: 'Filter Tasks',
      child: Badge(
        isLabelVisible: hasActiveFilters,
        label: Text(widget.currentFilters.activeFilterCount.toString()),
        child: IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: _showFilterDialog,
        ),
      ),
    );
  }
}

