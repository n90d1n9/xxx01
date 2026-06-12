import 'package:flutter/material.dart';

import '../tabel_controller.dart';

class TableFilterPanel extends StatelessWidget {
  final TableController controller;

  const TableFilterPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final filters = controller.filters;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _searchForm(filters),
              const SizedBox(width: 16),
              _buildCategoryDropdown(filters),
              const SizedBox(width: 16),
              _buildStatusDropdown(filters),
              const SizedBox(width: 16),
              _buildActiveFilter(filters),
            ],
          ),
        ],
      ),
    );
  }

  Widget _searchForm(Map<String, dynamic> filters) => Expanded(
    child: TextField(
      decoration: const InputDecoration(
        labelText: 'Search',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        final currentFilters = Map<String, dynamic>.from(filters);
        currentFilters['search'] = value.isNotEmpty ? value : null;
        controller.setFilters(currentFilters);
      },
    ),
  );

  Widget _buildCategoryDropdown(Map<String, dynamic> filters) {
    final categories = [
      'All',
      'Hardware',
      'Software',
      'Services',
      'Infrastructure',
    ];
    final selectedCategory = filters['category'] ?? 'All';

    return DropdownButton<String>(
      value: selectedCategory,
      hint: const Text('Category'),
      onChanged: (value) {
        final currentFilters = Map<String, dynamic>.from(filters);
        currentFilters['category'] = value != 'All' ? value : null;
        controller.setFilters(currentFilters);
      },
      items:
          categories.map((category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
    );
  }

  Widget _buildStatusDropdown(Map<String, dynamic> filters) {
    final statuses = ['All', 'Pending', 'Approved', 'Rejected', 'On Hold'];
    final selectedStatus = filters['status'] ?? 'All';

    return DropdownButton<String>(
      value: selectedStatus,
      hint: const Text('Status'),
      onChanged: (value) {
        final currentFilters = Map<String, dynamic>.from(filters);
        currentFilters['status'] = value != 'All' ? value : null;
        controller.setFilters(currentFilters);
      },
      items:
          statuses.map((status) {
            return DropdownMenuItem<String>(value: status, child: Text(status));
          }).toList(),
    );
  }

  Widget _buildActiveFilter(Map<String, dynamic> filters) {
    return ToggleButtons(
      isSelected: [
        filters['active'] == null,
        filters['active'] == true,
        filters['active'] == false,
      ],
      onPressed: (index) {
        final currentFilters = Map<String, dynamic>.from(filters);
        switch (index) {
          case 0:
            currentFilters['active'] = null;
            break;
          case 1:
            currentFilters['active'] = true;
            break;
          case 2:
            currentFilters['active'] = false;
            break;
        }
        controller.setFilters(currentFilters);
      },
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('All'),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('Active'),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('Inactive'),
        ),
      ],
    );
  }
}
