import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/widgets/dropdown_widget.dart';

void main() {
  testWidgets('renders nothing for empty item lists', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Dropdown(items: []))),
    );

    expect(find.byType(DropdownButton<String>), findsNothing);
  });

  testWidgets('runs the selected item action and keeps the selection', (
    tester,
  ) async {
    String? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Dropdown(
            items: [
              const DropdownItem(title: 'Profile', icon: 'person'),
              DropdownItem(
                title: 'Sign out',
                icon: 'logout',
                onTap: () => selected = 'logout',
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out').last);
    await tester.pumpAndSettle();

    expect(selected, 'logout');
    expect(find.text('Sign out'), findsOneWidget);
  });
}
