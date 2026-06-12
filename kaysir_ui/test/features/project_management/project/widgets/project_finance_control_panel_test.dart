import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/services/project_budget_overview_service.dart';
import 'package:kaysir/features/project_management/project/services/project_budget_pulse_service.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_control_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_finance_control_panel.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('finance control panel renders control actions and attributes', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 760,
            child: ProjectFinanceControlPanel(
              summary: ProjectFinanceControlSummary(
                projectId: 'venue-fit-out',
                projectName: 'Venue Fit Out',
                profile: const ProjectFinanceControlProfile(
                  floatLabel: 'Project float',
                  expenseOwnerLabel: 'Field expense owner',
                  approvalLabel: 'On-site approval threshold',
                ),
                budgetOverview: const ProjectBudgetOverview(
                  projectId: 'venue-fit-out',
                  projectName: 'Venue Fit Out',
                  progress: 0.58,
                  budgetUsed: 0.74,
                  state: ProjectBudgetPulseState.pressure,
                ),
                attributes: const [
                  ProjectFinanceControlAttribute(
                    label: 'Petty Cash Limit',
                    value: '5000000 IDR',
                    role: ProjectFinanceControlRole.projectFloat,
                  ),
                ],
                signals: const [
                  ProjectFinanceControlSignal(
                    title: 'Assign field expense owner',
                    detail:
                        'Name the person accountable for reimbursements and exception handling.',
                    level: ProjectFinanceControlLevel.watch,
                    icon: Icons.person_search_outlined,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Finance controls need setup'), findsOneWidget);
    expect(find.text('Controls'), findsOneWidget);
    expect(find.text('1/3'), findsOneWidget);
    expect(find.text('Project float'), findsOneWidget);
    expect(find.text('Set'), findsOneWidget);
    expect(find.text('Expense Owner'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Project Float: 5000000 IDR'), findsOneWidget);
    expect(find.text('Assign field expense owner'), findsOneWidget);
  });
}
