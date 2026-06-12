import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/admin/widgets/admin_content_panel.dart';

void main() {
  testWidgets('wraps content with a reusable admin panel header', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdminContentPanel(
            title: 'Customer mix',
            subtitle: 'Source contribution.',
            leadingIcon: Icons.pie_chart_outline,
            trailing: Text('Live'),
            child: Text('Chart body'),
          ),
        ),
      ),
    );

    expect(find.text('Customer mix'), findsOneWidget);
    expect(find.text('Source contribution.'), findsOneWidget);
    expect(find.byIcon(Icons.pie_chart_outline), findsOneWidget);
    expect(find.text('Live'), findsOneWidget);
    expect(find.text('Chart body'), findsOneWidget);
  });
}
