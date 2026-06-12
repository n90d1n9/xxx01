import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/module.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/module_notice.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/notice_pill.dart';

void main() {
  testWidgets('ModuleNotice stays quiet without issues', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ModuleNotice(issues: []))),
    );

    expect(find.text('Workspace modules need review'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ModuleNotice summarizes visible issues', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ModuleNotice(
            issues: const [
              ModuleIssue(
                type: ModuleIssueType.blankModuleId,
                message: 'Blank module id',
              ),
              ModuleIssue(
                type: ModuleIssueType.duplicateModuleId,
                message: 'Duplicate module id',
              ),
              ModuleIssue(
                type: ModuleIssueType.blankDestinationRoute,
                message: 'Blank route',
              ),
              ModuleIssue(
                type: ModuleIssueType.blankActionLabel,
                message: 'Blank action',
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Workspace modules need review'), findsOneWidget);
    expect(
      find.text('4 module issues can affect Commerce Workspace navigation.'),
      findsOneWidget,
    );
    expect(find.text('Blank module id'), findsOneWidget);
    expect(find.text('Duplicate module id'), findsOneWidget);
    expect(find.text('Blank route'), findsOneWidget);
    expect(find.text('Blank action'), findsNothing);
    expect(find.text('+1 more'), findsOneWidget);
    expect(find.byType(NoticePill), findsNWidgets(4));
    expect(find.byType(NoticeOverflowPill), findsOneWidget);
  });
}
