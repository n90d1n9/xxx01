import 'employee_document_escalation_plan.dart';

/// Filter options for narrowing employee document owner escalation lanes.
enum EmployeeDocumentEscalationFilter {
  all('All'),
  ready('Ready'),
  coolingDown('Cooling down'),
  critical('Critical'),
  high('High'),
  digestDue('Digest due');

  final String label;

  const EmployeeDocumentEscalationFilter(this.label);
}

/// Filters employee document owner escalation plans for the selected view.
List<EmployeeDocumentEscalationPlan> filterEmployeeDocumentEscalationPlans({
  required List<EmployeeDocumentEscalationPlan> plans,
  required EmployeeDocumentEscalationFilter filter,
}) {
  return plans.where((plan) => _matchesFilter(plan, filter)).toList();
}

/// Counts available escalation plans for every filter option.
Map<EmployeeDocumentEscalationFilter, int>
countEmployeeDocumentEscalationFilters(
  List<EmployeeDocumentEscalationPlan> plans,
) {
  return {
    for (final filter in EmployeeDocumentEscalationFilter.values)
      filter: plans.where((plan) => _matchesFilter(plan, filter)).length,
  };
}

bool _matchesFilter(
  EmployeeDocumentEscalationPlan plan,
  EmployeeDocumentEscalationFilter filter,
) {
  switch (filter) {
    case EmployeeDocumentEscalationFilter.all:
      return true;
    case EmployeeDocumentEscalationFilter.ready:
      return !plan.escalationCoolingDown;
    case EmployeeDocumentEscalationFilter.coolingDown:
      return plan.escalationCoolingDown;
    case EmployeeDocumentEscalationFilter.critical:
      return plan.priority == EmployeeDocumentEscalationPriority.critical;
    case EmployeeDocumentEscalationFilter.high:
      return plan.priority == EmployeeDocumentEscalationPriority.high;
    case EmployeeDocumentEscalationFilter.digestDue:
      return plan.digestDue;
  }
}
