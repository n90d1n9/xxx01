import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/admin/widgets/admin_shell_shortcuts.dart';

void main() {
  testWidgets('opens search from command K', (tester) async {
    var searches = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: AdminShellShortcuts(
          onSearchPressed: () => searches += 1,
          child: const Scaffold(body: SizedBox.shrink()),
        ),
      ),
    );
    await tester.pump();

    await _pressShortcut(tester, LogicalKeyboardKey.metaLeft);

    expect(searches, 1);
  });

  testWidgets('opens search from control K', (tester) async {
    var searches = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: AdminShellShortcuts(
          onSearchPressed: () => searches += 1,
          child: const Scaffold(body: SizedBox.shrink()),
        ),
      ),
    );
    await tester.pump();

    await _pressShortcut(tester, LogicalKeyboardKey.controlLeft);

    expect(searches, 1);
  });
}

Future<void> _pressShortcut(
  WidgetTester tester,
  LogicalKeyboardKey modifier,
) async {
  await tester.sendKeyDownEvent(modifier);
  await tester.sendKeyDownEvent(LogicalKeyboardKey.keyK);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.keyK);
  await tester.sendKeyUpEvent(modifier);
}
