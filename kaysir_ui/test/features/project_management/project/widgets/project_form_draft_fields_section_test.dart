import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_form_draft.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/widgets/project_form_draft_fields_section.dart';
import 'package:kaysir/features/project_management/project/widgets/project_form_draft_text_controllers.dart';

void main() {
  testWidgets('project form draft fields section renders reusable controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      _ProjectFormDraftFieldsSectionHarness(
        draft: _draft,
        onDraftChanged: (_) {},
      ),
    );

    expect(find.text('Project name'), findsOneWidget);
    expect(find.text('Client or business unit'), findsOneWidget);
    expect(find.text('Business domain'), findsOneWidget);
    expect(find.text('Initial health'), findsOneWidget);
    expect(find.text('Business outcome summary'), findsOneWidget);
    expect(find.text('Planned progress'), findsOneWidget);
    expect(find.text('Budget used'), findsOneWidget);
  });

  testWidgets('project form draft fields section emits text edits', (
    tester,
  ) async {
    ProjectFormDraft? changedDraft;

    await tester.pumpWidget(
      _ProjectFormDraftFieldsSectionHarness(
        draft: _draft,
        onDraftChanged: (draft) => changedDraft = draft,
      ),
    );

    await tester.enterText(
      find.widgetWithIcon(TextField, Icons.work_outline),
      'Release Cutover Phase 2',
    );

    expect(changedDraft?.name, 'Release Cutover Phase 2');
  });

  testWidgets(
    'project form draft fields section adapts business domain fields',
    (tester) async {
      ProjectFormDraft? changedDraft;

      await tester.pumpWidget(
        _ProjectFormDraftFieldsSectionHarness(
          draft: _draft.copyWith(businessDomain: 'Construction'),
          onDraftChanged: (draft) => changedDraft = draft,
        ),
      );

      await tester.tap(find.text('Construction').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Software Development').last);
      await tester.pumpAndSettle();

      expect(changedDraft?.businessDomain, 'Software Development');
      expect(
        changedDraft?.customAttributes.any(
          (attribute) => attribute.key == 'repository',
        ),
        isTrue,
      );
    },
  );

  testWidgets('project form draft fields section emits progress changes', (
    tester,
  ) async {
    ProjectFormDraft? changedDraft;

    await tester.pumpWidget(
      _ProjectFormDraftFieldsSectionHarness(
        draft: _draft,
        onDraftChanged: (draft) => changedDraft = draft,
      ),
    );

    tester.widget<Slider>(find.byType(Slider).first).onChanged?.call(0.72);

    expect(changedDraft?.progress, 0.72);
  });
}

final _draft = ProjectFormDraft.initial(today: DateTime(2026, 6)).copyWith(
  name: 'Release Cutover',
  client: 'Platform Team',
  owner: 'Alya',
  sponsor: 'Technology Office',
  businessDomain: 'Software Development',
  summary: 'Coordinates release readiness, rollback, and stakeholder rollout.',
  health: ProjectHealth.onTrack,
  progress: 0.45,
  budgetUsed: 0.25,
);

class _ProjectFormDraftFieldsSectionHarness extends StatefulWidget {
  const _ProjectFormDraftFieldsSectionHarness({
    required this.draft,
    required this.onDraftChanged,
  });

  final ProjectFormDraft draft;
  final ValueChanged<ProjectFormDraft> onDraftChanged;

  @override
  State<_ProjectFormDraftFieldsSectionHarness> createState() =>
      _ProjectFormDraftFieldsSectionHarnessState();
}

class _ProjectFormDraftFieldsSectionHarnessState
    extends State<_ProjectFormDraftFieldsSectionHarness> {
  late ProjectFormDraft _draft;
  late final ProjectFormDraftTextControllers _textControllers;

  @override
  void initState() {
    super.initState();
    _draft = widget.draft;
    _textControllers = ProjectFormDraftTextControllers.fromDraft(_draft);
  }

  @override
  void dispose() {
    _textControllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 920,
          child: SingleChildScrollView(
            child: ProjectFormDraftFieldsSection(
              draft: _draft,
              textControllers: _textControllers,
              onDraftChanged: (draft) {
                widget.onDraftChanged(draft);
                setState(() => _draft = draft);
              },
            ),
          ),
        ),
      ),
    );
  }
}
