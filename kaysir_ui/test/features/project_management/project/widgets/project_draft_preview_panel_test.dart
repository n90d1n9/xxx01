import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_form_draft.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/widgets/project_draft_preview_panel.dart';

void main() {
  testWidgets('project draft preview panel renders reusable draft signals', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProjectDraftPreviewPanel(draft: _draft),
          ),
        ),
      ),
    );

    expect(find.text('Draft Preview'), findsOneWidget);
    expect(find.text('Software Development'), findsOneWidget);
    expect(find.text('Release Cutover'), findsOneWidget);
    expect(find.text('10 days'), findsOneWidget);
    expect(find.text('1 custom'), findsOneWidget);
    expect(find.textContaining('starter roles'), findsOneWidget);
  });
}

final _draft = ProjectFormDraft(
  name: 'Release Cutover',
  client: 'Platform Team',
  owner: 'Alya',
  sponsor: 'Technology Office',
  businessDomain: 'Software Development',
  summary: 'Coordinates release readiness, rollback, and stakeholder rollout.',
  startDate: DateTime(2026, 6),
  endDate: DateTime(2026, 6, 10),
  health: ProjectHealth.onTrack,
  progress: 0.45,
  budgetUsed: 0.25,
  customAttributes: const [
    ProjectCustomAttribute(
      key: 'repository',
      label: 'Repository',
      type: ProjectCustomAttributeType.url,
      value: 'https://example.test/release',
    ),
  ],
);
