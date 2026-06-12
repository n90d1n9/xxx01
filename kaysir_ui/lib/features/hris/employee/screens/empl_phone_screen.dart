import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/states/employee_provider.dart';

import '../widgets/dempl_detail_panel.dart';
import '../widgets/empl_list_panel.dart';
import '../widgets/empty_detail_panel.dart';

class EmployeeScreen extends ConsumerWidget {
  const EmployeeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;
    final selectedEmployee = ref.watch(selectedEmployeeProvider2);

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // Side navigation (only visible on large screens)
            // if (isLargeScreen) NavigationSidebar(width: 240),

            // Main content area
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App bar / header
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      children: [
                        if (!isLargeScreen)
                          IconButton(
                            icon: Icon(Icons.menu),
                            onPressed: () {
                              // Show drawer on medium screens
                              Scaffold.of(context).openDrawer();
                            },
                          ),
                        Expanded(
                          child: Text(
                            'Employees',
                            style: Theme.of(context).appBarTheme.titleTextStyle,
                          ),
                        ),
                        CircleAvatar(
                          radius: 20,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  // Main content
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Employee list panel
                        Flexible(
                          flex: isLargeScreen ? 3 : 5,
                          child: EmployeeListPanel(),
                        ),

                        // Employee detail panel
                        if (selectedEmployee != null || isLargeScreen)
                          Flexible(
                            flex: isLargeScreen ? 7 : 5,
                            child:
                                selectedEmployee == null
                                    ? EmptyDetailPanel()
                                    : EmployeeDetailPanel(
                                      employeeId: selectedEmployee.id,
                                    ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // drawer: isLargeScreen ? null : NavigationDrawer(),
    );
  }
}
