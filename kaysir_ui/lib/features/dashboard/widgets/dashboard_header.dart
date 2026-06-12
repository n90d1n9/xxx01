import 'package:flutter/material.dart';
import 'package:ky_admin/widgets/admin_page_header.dart';
import 'package:ky_admin/widgets/admin_page_toolbar.dart';
import 'package:ky_admin/widgets/admin_status_badge.dart';

import 'filter_dropdown.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    this.compact = false,
  });

  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return AdminPageHeader(
      breadcrumbs: const ['Admin', 'Dashboard'],
      eyebrow: 'Retail intelligence',
      leadingIcon: Icons.dashboard_customize_outlined,
      title: 'Sales dashboard',
      subtitle:
          'Track store performance, product movement, and customer activity.',
      compact: compact,
      toolbar: AdminPageToolbar(
        trailing: AdminStatusBadge(
          label: 'Live retail signal',
          icon: Icons.sensors_outlined,
          color: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
          tooltip: 'Dashboard metrics are using the latest retail signal.',
        ),
        children: [
          FilterDropdown(
            initialValue: selectedFilter,
            onChanged: onFilterChanged,
          ),
        ],
      ),
    );
  }
}
