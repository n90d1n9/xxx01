import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_readiness_score_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_readiness_score_panel.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('project readiness score panel renders score and factors', (
    tester,
  ) async {
    final summary = ProjectReadinessScoreSummary(
      project: _project(),
      score: 42,
      level: ProjectReadinessLevel.blocked,
      factors: const [
        ProjectReadinessFactor(
          title: 'Delivery blocker',
          detail: 'Project health is blocked.',
          level: ProjectReadinessFactorLevel.critical,
          icon: Icons.block_outlined,
          scoreImpact: -30,
        ),
        ProjectReadinessFactor(
          title: 'Budget watch',
          detail: 'Budget usage is ahead of progress.',
          level: ProjectReadinessFactorLevel.warning,
          icon: Icons.account_balance_wallet_outlined,
          scoreImpact: -9,
        ),
        ProjectReadinessFactor(
          title: 'Cadence stable',
          detail: 'The team has a stable delivery rhythm.',
          level: ProjectReadinessFactorLevel.positive,
          icon: Icons.check_circle_outline,
          scoreImpact: 0,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 900,
              child: ProjectReadinessScorePanel(summary: summary),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Readiness Blocked'), findsOneWidget);
    expect(
      find.text('42/100 confidence score for Mobile Field App'),
      findsOneWidget,
    );
    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Delivery blocker'), findsOneWidget);
    expect(find.text('Budget watch'), findsOneWidget);
    expect(find.text('Cadence stable'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'All'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Critical'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Watch'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Stable'), findsOneWidget);
    expect(find.text('Critical'), findsWidgets);
    expect(find.text('Watch'), findsWidgets);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Critical'));
    await tester.pump();

    expect(find.text('Delivery blocker'), findsOneWidget);
    expect(find.text('Budget watch'), findsNothing);
    expect(find.text('Cadence stable'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Stable'));
    await tester.pump();

    expect(find.text('Delivery blocker'), findsNothing);
    expect(find.text('Budget watch'), findsNothing);
    expect(find.text('Cadence stable'), findsOneWidget);
  });
}

ProjectPortfolioItem _project() {
  return ProjectPortfolioItem(
    id: 'mobile-field-app',
    name: 'Mobile Field App',
    owner: 'Nadia Putri',
    client: 'Service Team',
    startDate: DateTime(2026, 5, 1),
    endDate: DateTime(2026, 7, 1),
    progress: 0.2,
    budgetUsed: 0.48,
    health: ProjectHealth.blocked,
    milestones: const [],
  );
}
