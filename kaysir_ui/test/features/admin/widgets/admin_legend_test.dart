import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/admin/widgets/admin_legend.dart';

void main() {
  testWidgets('renders reusable legend entries', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdminLegend(
            entries: [
              AdminLegendEntry(color: Color(0xFF2E7D32), label: 'This week'),
              AdminLegendEntry(color: Color(0xFF1769AA), label: 'Last week'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('This week'), findsOneWidget);
    expect(find.text('Last week'), findsOneWidget);
  });
}
