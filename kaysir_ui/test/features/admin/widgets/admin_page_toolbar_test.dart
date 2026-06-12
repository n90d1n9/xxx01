import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/admin/widgets/admin_page_toolbar.dart';

void main() {
  testWidgets('lays out toolbar controls and trailing content', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1000,
            child: AdminPageToolbar(
              trailing: Text('Live signal'),
              children: [Text('Search'), Text('Period')],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Period'), findsOneWidget);
    expect(find.text('Live signal'), findsOneWidget);
  });

  testWidgets('renders nothing when no controls are supplied', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AdminPageToolbar(children: []))),
    );

    expect(find.byType(SizedBox), findsOneWidget);
  });
}
