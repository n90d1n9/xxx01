import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/services/project_change_control_service.dart';
import 'package:kaysir/features/project_management/project/services/project_status_update_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_change_control_panel.dart';

void main() {
  testWidgets('project change control panel renders approval controls', (
    tester,
  ) async {
    const summary = ProjectChangeControlSummary(
      vocabulary: ProjectStatusUpdateVocabulary.software,
      audience: ProjectStatusUpdateAudience.sponsor,
      title: 'Software change control',
      subtitle: 'Recovery - release change freeze - 3 controls',
      changeWindow: 'release change freeze',
      briefText:
          'Software change control brief\n'
          'Status: Recovery\n'
          'Window: release change freeze\n'
          'Primary control\n'
          '- Lock release scope recovery: Freeze unmanaged changes.',
      items: [
        ProjectChangeControlItem(
          title: 'Lock release scope recovery',
          detail: 'Freeze unmanaged changes.',
          icon: Icons.code_outlined,
          level: ProjectChangeControlLevel.recovery,
          kind: ProjectChangeControlKind.domain,
        ),
        ProjectChangeControlItem(
          title: 'Rebaseline release plan change',
          detail: 'Confirm owner and date decisions.',
          icon: Icons.event_busy_outlined,
          level: ProjectChangeControlLevel.recovery,
          kind: ProjectChangeControlKind.schedule,
        ),
        ProjectChangeControlItem(
          title: 'Prepare sponsor approval route',
          detail: 'Make the change ask clear.',
          icon: Icons.verified_user_outlined,
          level: ProjectChangeControlLevel.approval,
          kind: ProjectChangeControlKind.approvalRoute,
        ),
      ],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProjectChangeControlPanel(summary: summary),
          ),
        ),
      ),
    );

    expect(find.text('Software change control'), findsOneWidget);
    expect(find.textContaining('release change freeze'), findsWidgets);
    expect(find.text('Lock release scope recovery'), findsOneWidget);
    expect(find.text('Rebaseline release plan change'), findsOneWidget);
    expect(find.text('Prepare sponsor approval route'), findsOneWidget);
    expect(find.text('Recovery'), findsWidgets);
    expect(find.text('Approval'), findsWidgets);
    expect(find.text('Change control brief'), findsOneWidget);
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
