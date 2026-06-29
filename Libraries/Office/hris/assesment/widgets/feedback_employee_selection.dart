import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/employee/models/employee.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import 'employee_card.dart';

class FeedbackEmployeeSelection extends StatelessWidget {
  final List<Employee> employees;
  final ValueChanged<Employee> onSelected;

  const FeedbackEmployeeSelection({
    super.key,
    required this.employees,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      title: 'Select Employee',
      icon: Icons.person_search_outlined,
      subtitle: 'Choose who you want to review',
      emptyMessage: 'No employees available for feedback',
      children:
          employees
              .map(
                (employee) => EmployeeCard(
                  employee: employee,
                  onTap: () => onSelected(employee),
                ),
              )
              .toList(),
    );
  }
}
