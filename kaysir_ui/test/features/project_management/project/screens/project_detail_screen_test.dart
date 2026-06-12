import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_baseline_variance_panel.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_schedule_focus_panel.dart';
import 'package:kaysir/features/project_management/project/data/project_status_update_preferences_repository.dart';
import 'package:kaysir/features/project_management/project/screens/project_detail_screen.dart';
import 'package:kaysir/features/project_management/project/states/project_status_update_provider.dart';
import 'package:kaysir/features/project_management/project/widgets/project_budget_overview_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_cash_flow_forecast_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_change_control_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_cost_structure_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_custom_attributes_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_decision_governance_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_detail_components.dart';
import 'package:kaysir/features/project_management/project/widgets/project_domain_playbook_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_evidence_pack_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_expense_intake_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_finance_control_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_finance_ledger_snapshot_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_finance_reconciliation_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_handoff_brief_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_next_decision_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_operating_cadence_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_readiness_score_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_spend_authority_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_stakeholder_alignment_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_status_update_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_timeline_health_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_value_realization_panel.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('project detail renders portfolio context and linked timeline', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [_statusUpdatePreferencesOverride()],
        child: const MaterialApp(
          home: ProjectDetailScreen(projectId: 'retail-modernization'),
        ),
      ),
    );

    expect(find.text('Retail Modernization'), findsWidgets);
    expect(find.text('Kaysir Retail'), findsOneWidget);
    expect(find.byType(AppMetricGrid), findsNWidgets(16));
    expect(find.byType(ProjectMilestoneTimeline), findsOneWidget);
    expect(find.byType(ProjectCustomAttributesPanel), findsOneWidget);
    expect(find.byType(ProjectNextDecisionPanel), findsOneWidget);
    expect(find.byType(GanttScheduleFocusPanel), findsOneWidget);
    expect(find.byType(ProjectTimelineHealthPanel), findsOneWidget);
    expect(find.byType(GanttBaselineVariancePanel), findsOneWidget);
    expect(find.byType(ProjectReadinessScorePanel), findsOneWidget);
    expect(find.byType(ProjectBudgetOverviewPanel), findsOneWidget);
    expect(find.byType(ProjectFinanceLedgerSnapshotPanel), findsOneWidget);
    expect(find.byType(ProjectCostStructurePanel), findsOneWidget);
    expect(find.byType(ProjectFinanceControlPanel), findsOneWidget);
    expect(find.byType(ProjectSpendAuthorityPanel), findsOneWidget);
    expect(find.byType(ProjectCashFlowForecastPanel), findsOneWidget);
    expect(find.byType(ProjectExpenseIntakePanel), findsOneWidget);
    expect(find.byType(ProjectFinanceReconciliationPanel), findsOneWidget);
    expect(find.byType(ProjectValueRealizationPanel), findsOneWidget);
    expect(find.byType(ProjectStatusUpdateComposerPanel), findsOneWidget);
    expect(find.byType(ProjectDomainPlaybookPanel), findsOneWidget);
    expect(find.byType(ProjectStakeholderAlignmentPanel), findsOneWidget);
    expect(find.byType(ProjectDecisionGovernancePanel), findsOneWidget);
    expect(find.byType(ProjectOperatingCadencePanel), findsOneWidget);
    expect(find.byType(ProjectChangeControlPanel), findsOneWidget);
    expect(find.byType(ProjectEvidencePackPanel), findsOneWidget);
    expect(find.byType(ProjectHandoffBriefPanel), findsOneWidget);
    expect(find.byType(ProjectAttentionPanel), findsOneWidget);
    expect(find.byType(ProjectLinkedTimelinePanel), findsOneWidget);
    expect(find.text('Project Planning'), findsWidgets);
    expect(find.text('Domain Extensions'), findsOneWidget);
    expect(find.text('Store Cluster'), findsWidgets);
    expect(find.text('Jakarta pilot'), findsWidgets);
    expect(find.text('Next Decisions'), findsOneWidget);
    expect(find.text('Schedule Focus'), findsOneWidget);
    expect(find.text('Timeline Health'), findsOneWidget);
    expect(find.text('Baseline Variance'), findsOneWidget);
    expect(find.text('Readiness Score'), findsOneWidget);
    expect(find.text('Budget Overview'), findsOneWidget);
    expect(find.text('Finance Ledger'), findsOneWidget);
    expect(find.text('Cost Structure'), findsOneWidget);
    expect(find.text('Finance Controls'), findsOneWidget);
    expect(find.text('Spend Authority'), findsOneWidget);
    expect(find.text('Cash Flow Forecast'), findsOneWidget);
    expect(find.text('Expense Intake'), findsOneWidget);
    expect(find.text('Finance Reconciliation'), findsOneWidget);
    expect(find.text('Value Realization'), findsOneWidget);
    expect(find.text('Status Update Composer'), findsOneWidget);
    expect(find.text('Domain Playbook'), findsOneWidget);
    expect(find.text('Stakeholder Alignment'), findsOneWidget);
    expect(find.text('Decision Governance'), findsOneWidget);
    expect(find.text('Operating Cadence'), findsOneWidget);
    expect(find.text('Change Control'), findsOneWidget);
    expect(find.text('Evidence Pack'), findsOneWidget);
    expect(find.text('Handoff Brief'), findsOneWidget);
    expect(find.text('Attention Plan'), findsOneWidget);
    expect(find.text('Delivery Risks'), findsWidgets);
    expect(find.text('Maya Santoso'), findsWidgets);
    expect(find.text('Focus Gantt'), findsOneWidget);
  });

  testWidgets('project detail handles missing projects', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [_statusUpdatePreferencesOverride()],
        child: const MaterialApp(
          home: ProjectDetailScreen(projectId: 'missing'),
        ),
      ),
    );

    expect(find.text('Project not found'), findsOneWidget);
    expect(find.text('Back to Projects'), findsOneWidget);
  });

  testWidgets('project detail restores preferred status update domain', (
    tester,
  ) async {
    final store = MemoryProjectStatusUpdatePreferencesSnapshotStore();
    await store.write(const {
      'projectSelections': {
        'retail-modernization': {
          'vocabularyId': 'wedding',
          'audienceId': 'client',
        },
      },
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [_statusUpdatePreferencesOverride(store)],
        child: const MaterialApp(
          home: ProjectDetailScreen(projectId: 'retail-modernization'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('wedding production'), findsWidgets);
    expect(find.textContaining('client delivery update'), findsWidgets);
    expect(find.text('Wedding operating playbook'), findsOneWidget);
    expect(find.text('Wedding stakeholder alignment'), findsOneWidget);
    expect(find.text('Wedding decision governance'), findsOneWidget);
    expect(find.text('Wedding operating cadence'), findsOneWidget);
    expect(find.text('Wedding value realization'), findsOneWidget);
    expect(find.text('Wedding change control'), findsOneWidget);
    expect(find.text('Wedding evidence pack'), findsOneWidget);
  });
}

Override _statusUpdatePreferencesOverride([
  MemoryProjectStatusUpdatePreferencesSnapshotStore? store,
]) {
  return projectStatusUpdatePreferencesRepositoryProvider.overrideWithValue(
    ProjectStatusUpdatePreferencesRepository(
      store: store ?? MemoryProjectStatusUpdatePreferencesSnapshotStore(),
    ),
  );
}
