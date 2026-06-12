import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

void main() {
  testWidgets('renders icon, tooltip, and constrained label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppStatusPill(
              label: 'Open invoice count',
              color: Colors.blue,
              icon: Icons.receipt_long_rounded,
              tooltip: 'Customer activity',
              maxWidth: 120,
            ),
          ),
        ),
      ),
    );

    expect(find.byTooltip('Customer activity'), findsOneWidget);
    expect(find.byIcon(Icons.receipt_long_rounded), findsOneWidget);
    expect(find.text('Open invoice count'), findsOneWidget);
    expect(
      tester.getSize(find.byType(AppStatusPill)).width,
      lessThanOrEqualTo(120),
    );
  });

  testWidgets('can render a status dot without an icon', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppStatusPill(
              label: 'Balanced',
              color: Colors.teal,
              showDot: true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Balanced'), findsOneWidget);
    expect(find.byIcon(Icons.receipt_long_rounded), findsNothing);
  });

  testWidgets('can render inside intrinsic table cells', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [DataColumn(label: Text('Status'))],
              rows: [
                DataRow(
                  cells: [
                    DataCell(
                      AppStatusPill(
                        label: 'Ready for review',
                        color: Colors.green,
                        icon: Icons.verified_rounded,
                        maxWidth: 130,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(DataTable), findsOneWidget);
    expect(find.text('Ready for review'), findsOneWidget);
  });
}
