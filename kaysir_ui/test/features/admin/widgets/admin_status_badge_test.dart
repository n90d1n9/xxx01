import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/admin/widgets/admin_status_badge.dart';

void main() {
  testWidgets('renders a reusable status badge with a dot', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AdminStatusBadge(label: 'Live'))),
    );

    expect(find.text('Live'), findsOneWidget);
  });

  testWidgets('renders icon status badge with tooltip', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdminStatusBadge(
            label: 'Live retail signal',
            icon: Icons.sensors_outlined,
            tooltip: 'Latest signal',
          ),
        ),
      ),
    );

    expect(find.text('Live retail signal'), findsOneWidget);
    expect(find.byIcon(Icons.sensors_outlined), findsOneWidget);
    expect(find.byTooltip('Latest signal'), findsOneWidget);
  });
}
