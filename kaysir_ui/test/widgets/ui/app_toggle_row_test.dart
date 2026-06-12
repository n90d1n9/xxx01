import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/widgets/ui/app_toggle_row.dart';

void main() {
  testWidgets('renders a contained toggle row and toggles from row taps', (
    tester,
  ) async {
    var enabled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: Center(
                child: AppToggleRow(
                  contained: true,
                  iconBadge: true,
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark mode',
                  subtitle: 'Switch the admin shell appearance',
                  value: enabled,
                  onChanged: (value) => setState(() => enabled = value),
                ),
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('Dark mode'), findsOneWidget);
    expect(find.text('Switch the admin shell appearance'), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);

    await tester.tap(find.text('Dark mode'));
    await tester.pump();

    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
  });

  testWidgets('disabled toggle row ignores taps', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppToggleRow(
              title: 'Offline mode',
              value: false,
              onChanged: null,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Offline mode'));
    await tester.pump();

    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
  });
}
