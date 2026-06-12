import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/employee_provider.dart';
import 'empl_list_item.dart';

class EmployeeListPanel extends ConsumerWidget {
  const EmployeeListPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredEmployees = ref.watch(filteredEmployeesProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 12, 24),
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search and filter row
              TextField(
                onChanged:
                    (value) => ref.read(filterProvider.notifier).state = value,
                decoration: InputDecoration(
                  hintText: 'Search employees...',
                  prefixIcon: Icon(Icons.search, color: Color(0xFF9CA3AF)),
                  filled: true,
                  fillColor: Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              SizedBox(height: 16),

              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(context, ref, 'All'),
                    _buildFilterChip(context, ref, 'Developer'),
                    _buildFilterChip(context, ref, 'Designer'),
                    _buildFilterChip(context, ref, 'Manager'),
                    _buildFilterChip(context, ref, 'HR'),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Employee list
              Expanded(
                child: filteredEmployees.when(
                  data: (employees) {
                    if (employees.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: Color(0xFFD1D5DB),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No employees found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: employees.length,
                      separatorBuilder: (context, index) => Divider(height: 1),
                      itemBuilder: (context, index) {
                        final employee = employees[index];
                        return EmployeeListItem(employee: employee);
                      },
                    );
                  },
                  loading: () => Center(child: CircularProgressIndicator()),
                  error:
                      (error, stackTrace) => Center(
                        child: Text('Error loading employees: $error'),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, WidgetRef ref, String label) {
    final filter = ref.watch(filterProvider);
    final isActive =
        label == 'All'
            ? filter.isEmpty
            : filter.toLowerCase() == label.toLowerCase();

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isActive,
        showCheckmark: false,
        backgroundColor: Color(0xFFF3F4F6),
        selectedColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.1),
        labelStyle: TextStyle(
          color:
              isActive
                  ? Theme.of(context).colorScheme.primary
                  : Color(0xFF6B7280),
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
        onSelected: (selected) {
          if (selected) {
            ref.read(filterProvider.notifier).state =
                label == 'All' ? '' : label;
          } else {
            ref.read(filterProvider.notifier).state = '';
          }
        },
      ),
    );
  }
}
