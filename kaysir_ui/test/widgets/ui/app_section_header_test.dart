import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/widgets/ui/app_section_header.dart';

void main() {
  testWidgets('renders title, subtitle, eyebrow, icon, and action', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppSectionHeader(
            eyebrow: 'Retail intelligence',
            leadingIcon: Icons.dashboard_customize_outlined,
            title: 'Sales dashboard',
            subtitle: 'Track store performance.',
            action: Text('This Week'),
          ),
        ),
      ),
    );

    expect(find.text('Retail intelligence'), findsOneWidget);
    expect(find.text('Sales dashboard'), findsOneWidget);
    expect(find.text('Track store performance.'), findsOneWidget);
    expect(find.text('This Week'), findsOneWidget);
    expect(find.byIcon(Icons.dashboard_customize_outlined), findsOneWidget);
  });
}
