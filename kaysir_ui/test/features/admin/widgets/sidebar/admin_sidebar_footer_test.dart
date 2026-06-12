import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/admin/widgets/sidebar/admin_sidebar_footer.dart';

void main() {
  testWidgets('expanded footer shows status and version', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AdminSidebarFooter(isCompact: false)),
      ),
    );

    expect(find.text('Workspace ready'), findsOneWidget);
    expect(find.text('v0.1.0'), findsOneWidget);
    expect(find.byTooltip('Help and support'), findsOneWidget);
  });

  testWidgets('compact footer keeps the help action available', (tester) async {
    var helpPressed = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdminSidebarFooter(
            isCompact: true,
            onHelpPressed: () => helpPressed += 1,
          ),
        ),
      ),
    );

    expect(find.text('Workspace ready'), findsNothing);
    expect(find.text('v0.1.0'), findsNothing);

    await tester.tap(find.byTooltip('Help and support'));

    expect(helpPressed, 1);
  });
}
