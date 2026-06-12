import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/admin/widgets/admin_section_header.dart';

void main() {
  testWidgets('renders section metadata and trailing content', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            child: AdminSectionHeader(
              title: 'Revenue trend',
              subtitle: 'Current and previous sales movement.',
              leadingIcon: Icons.show_chart_outlined,
              trailing: Text('This week'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Revenue trend'), findsOneWidget);
    expect(find.text('Current and previous sales movement.'), findsOneWidget);
    expect(find.byIcon(Icons.show_chart_outlined), findsOneWidget);
    expect(find.text('This week'), findsOneWidget);
  });
}
