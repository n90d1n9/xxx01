import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/admin/widgets/admin_page_scaffold.dart';

void main() {
  testWidgets('renders a reusable scrollable admin page frame', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdminPageScaffold(
            header: Text('Page header'),
            children: [Text('First section'), Text('Second section')],
          ),
        ),
      ),
    );

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.text('Page header'), findsOneWidget);
    expect(find.text('First section'), findsOneWidget);
    expect(find.text('Second section'), findsOneWidget);
  });
}
