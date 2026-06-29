import 'package:flutter/material.dart';

class DashboardWorkspaceSearchField extends StatelessWidget {
  final TextEditingController controller;
  final bool hasQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const DashboardWorkspaceSearchField({
    super.key,
    required this.controller,
    required this.hasQuery,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search workspaces',
        prefixIcon: const Icon(Icons.search_outlined),
        suffixIcon:
            hasQuery
                ? IconButton(
                  tooltip: 'Clear workspace search',
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded),
                )
                : null,
      ),
    );
  }
}
