import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/widgets/ui/app_checkbox_row.dart';
import 'package:kaysir/widgets/ui/app_surface.dart';

void main() {
  testWidgets('renders a checkbox row and toggles from row taps', (
    tester,
  ) async {
    var remember = false;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: Center(
                child: AppCheckboxRow(
                  contained: true,
                  icon: Icons.lock_clock_outlined,
                  iconBadge: true,
                  title: 'Remember me',
                  subtitle: 'Keep this account ready on this device',
                  value: remember,
                  onChanged:
                      (value) => setState(() => remember = value ?? false),
                ),
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('Remember me'), findsOneWidget);
    expect(find.text('Keep this account ready on this device'), findsOneWidget);
    expect(find.byIcon(Icons.lock_clock_outlined), findsOneWidget);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);

    await tester.tap(find.text('Remember me'));
    await tester.pump();

    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
  });

  testWidgets('disabled checkbox row ignores taps', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppCheckboxRow(
              title: 'Stay signed in',
              value: false,
              onChanged: null,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Stay signed in'));
    await tester.pump();

    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
  });

  testWidgets('contained row can sit inside a decorated surface', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppSurface(
            child: AppCheckboxRow(
              contained: true,
              title: 'Show overdue only',
              value: false,
              onChanged: null,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Show overdue only'), findsOneWidget);
    expect(find.byType(Material), findsWidgets);
  });

  testWidgets('supports trailing content for value rows', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppCheckboxRow(
              title: 'Bill INV-1001',
              subtitle: 'Acme Supplies',
              value: true,
              onChanged: null,
              trailing: Text('\$125.00'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Bill INV-1001'), findsOneWidget);
    expect(find.text('Acme Supplies'), findsOneWidget);
    expect(find.text('\$125.00'), findsOneWidget);
  });
}
