import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/action.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/module.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/registry_diagnostics.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/action_button.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/dialog_close_button.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/dialog_header.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/dialog_section.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/empty_state.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/notice_pill.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/registry_notice.dart';

void main() {
  testWidgets('RegistryNotice stays quiet without issues', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RegistryNotice(
            diagnostics: RegistryDiagnostics.fromIssues(
              moduleIssues: const [],
              actionRuleIssues: const [],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Workspace registries need review'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('RegistryNotice summarizes mixed issues', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RegistryNotice(
            maxVisibleIssues: 3,
            diagnostics: RegistryDiagnostics.fromIssues(
              moduleIssues: const [
                ModuleIssue(
                  type: ModuleIssueType.blankModuleId,
                  message: 'Blank module id',
                ),
                ModuleIssue(
                  type: ModuleIssueType.blankDestinationRoute,
                  message: 'Blank destination route',
                ),
              ],
              actionRuleIssues: const [
                ActionRuleIssue(
                  type: ActionRuleIssueType.blankActionId,
                  message: 'Blank action id',
                ),
                ActionRuleIssue(
                  type: ActionRuleIssueType.invalidActionRoute,
                  message: 'Invalid action route',
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Workspace registries need review'), findsOneWidget);
    expect(
      find.text(
        '4 registry issues can affect Commerce Workspace navigation and priority actions.',
      ),
      findsOneWidget,
    );
    expect(find.text('Module'), findsNWidgets(2));
    expect(find.text('Action'), findsOneWidget);
    expect(find.text('Blank module id'), findsOneWidget);
    expect(find.text('Blank destination route'), findsOneWidget);
    expect(find.text('Blank action id'), findsOneWidget);
    expect(find.text('Invalid action route'), findsNothing);
    expect(find.text('+1 more'), findsOneWidget);
    expect(find.byType(NoticePill), findsNWidgets(4));
    expect(find.byType(NoticeOverflowPill), findsOneWidget);
  });

  testWidgets('RegistryNotice opens diagnostics details', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RegistryNotice(
            maxVisibleIssues: 1,
            diagnostics: RegistryDiagnostics.fromIssues(
              moduleIssues: const [
                ModuleIssue(
                  type: ModuleIssueType.blankModuleId,
                  message: 'Blank module id',
                ),
              ],
              actionRuleIssues: const [
                ActionRuleIssue(
                  type: ActionRuleIssueType.invalidActionRoute,
                  message: 'Invalid action route',
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Invalid action route'), findsNothing);
    expect(find.byType(ActionButton), findsOneWidget);

    await tester.tap(find.text('View details'));
    await tester.pumpAndSettle();

    expect(find.text('Registry diagnostics'), findsOneWidget);
    expect(find.byType(DialogCloseButton), findsOneWidget);
    expect(find.byType(DialogHeader), findsOneWidget);
    expect(find.byType(DialogSection), findsNWidgets(2));
    expect(find.byType(EmptyState), findsNothing);
    expect(find.text('Sources'), findsOneWidget);
    expect(find.text('Issues'), findsOneWidget);
    expect(find.text('Modules | 1'), findsOneWidget);
    expect(find.text('Actions | 1'), findsOneWidget);
    expect(find.text('Blank module id'), findsWidgets);
    expect(find.text('Invalid action route'), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(find.text('Registry diagnostics'), findsNothing);
  });
}
