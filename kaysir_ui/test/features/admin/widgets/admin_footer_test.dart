import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/admin/widgets/admin_footer.dart';

void main() {
  testWidgets('wide footer shows status metadata and opens support dialog', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: Size(900, 600)),
          child: Scaffold(body: Align(child: AdminFooter())),
        ),
      ),
    );

    expect(find.textContaining('Kayys Tech'), findsOneWidget);
    expect(find.textContaining('Workspace ready'), findsOneWidget);
    expect(find.text('Privacy'), findsOneWidget);
    expect(find.text('Terms'), findsOneWidget);

    await tester.tap(find.byTooltip('Contact support'));
    await tester.pumpAndSettle();

    expect(find.text('Support'), findsOneWidget);
    expect(find.textContaining('Kaysir administrator'), findsOneWidget);
  });

  testWidgets('compact footer keeps legal links out of the status bar', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: Size(500, 600)),
          child: Scaffold(body: Align(child: AdminFooter())),
        ),
      ),
    );

    expect(find.text('Kayys Tech'), findsOneWidget);
    expect(find.textContaining('Workspace ready'), findsNothing);
    expect(find.text('Privacy'), findsNothing);
    expect(find.text('Terms'), findsNothing);
    expect(find.byTooltip('Contact support'), findsOneWidget);
  });
}
