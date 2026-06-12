import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/services/project_status_update_service.dart';
import 'package:kaysir/features/project_management/project/services/project_value_realization_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_value_realization_panel.dart';

void main() {
  testWidgets('project value realization panel renders outcome signals', (
    tester,
  ) async {
    const summary = ProjectValueRealizationSummary(
      vocabulary: ProjectStatusUpdateVocabulary.software,
      audience: ProjectStatusUpdateAudience.sponsor,
      title: 'Software value realization',
      subtitle: 'Recover - release outcome - 3 signals',
      valueThesis:
          'Mobile Field App should produce release adoption, user readiness, and operational confidence for Service Team.',
      briefText:
          'Software value realization brief\n'
          'Status: Recover\n'
          'Primary value signal\n'
          '- Recover release adoption value: Recover dependency proof.',
      items: [
        ProjectValueRealizationItem(
          title: 'Recover release adoption value',
          detail: 'Recover dependency proof.',
          icon: Icons.code_outlined,
          level: ProjectValueRealizationLevel.recover,
          kind: ProjectValueRealizationKind.domainOutcome,
        ),
        ProjectValueRealizationItem(
          title: 'Recover delayed release plan value path',
          detail: 'Overdue work is delaying adoption proof.',
          icon: Icons.event_busy_outlined,
          level: ProjectValueRealizationLevel.recover,
          kind: ProjectValueRealizationKind.deliveryPath,
        ),
        ProjectValueRealizationItem(
          title: 'Confirm sponsor value decision',
          detail: 'Show where value is protected.',
          icon: Icons.verified_user_outlined,
          level: ProjectValueRealizationLevel.protect,
          kind: ProjectValueRealizationKind.audienceSignal,
        ),
      ],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProjectValueRealizationPanel(summary: summary),
          ),
        ),
      ),
    );

    expect(find.text('Software value realization'), findsOneWidget);
    expect(find.textContaining('release outcome'), findsWidgets);
    expect(find.text('Value thesis'), findsOneWidget);
    expect(find.textContaining('release adoption'), findsWidgets);
    expect(find.text('Recover release adoption value'), findsOneWidget);
    expect(
      find.text('Recover delayed release plan value path'),
      findsOneWidget,
    );
    expect(find.text('Confirm sponsor value decision'), findsOneWidget);
    expect(find.text('Recover'), findsWidgets);
    expect(find.text('Protect'), findsWidgets);
    expect(find.text('Value realization brief'), findsOneWidget);
    expect(find.text('Copy ready'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);

    final copyButton = find.widgetWithText(OutlinedButton, 'Copy');
    expect(copyButton, findsOneWidget);

    await tester.ensureVisible(copyButton);
    await tester.tap(copyButton);
    await tester.pumpAndSettle();

    expect(find.text('Copied'), findsOneWidget);
  });
}
