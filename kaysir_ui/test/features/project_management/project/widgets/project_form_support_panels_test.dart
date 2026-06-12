import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_form_draft.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/widgets/project_form_support_panels.dart';

void main() {
  testWidgets('project form support panels split on wide layouts', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_SupportPanelsHarness(width: 980));

    final domainPack = find.byKey(
      const ValueKey('project-form-support-domain-pack'),
    );
    final draftPreview = find.byKey(
      const ValueKey('project-form-support-draft-preview'),
    );

    expect(find.text('Domain Pack'), findsOneWidget);
    expect(find.text('Draft Preview'), findsOneWidget);
    expect(find.text('Software Development'), findsWidgets);
    expect(find.text('Release Cutover'), findsOneWidget);
    expect(
      tester.getTopLeft(domainPack).dy,
      tester.getTopLeft(draftPreview).dy,
    );
    expect(
      tester.getTopLeft(domainPack).dx,
      lessThan(tester.getTopLeft(draftPreview).dx),
    );
  });

  testWidgets('project form support panels stack on narrow layouts', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(640, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_SupportPanelsHarness(width: 560));

    final domainPack = find.byKey(
      const ValueKey('project-form-support-domain-pack'),
    );
    final draftPreview = find.byKey(
      const ValueKey('project-form-support-draft-preview'),
    );

    expect(
      tester.getTopLeft(domainPack).dy,
      lessThan(tester.getTopLeft(draftPreview).dy),
    );
    expect(
      tester.getTopLeft(domainPack).dx,
      tester.getTopLeft(draftPreview).dx,
    );
  });
}

class _SupportPanelsHarness extends StatelessWidget {
  const _SupportPanelsHarness({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: width,
            child: ProjectFormSupportPanels(draft: _draft),
          ),
        ),
      ),
    );
  }
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
