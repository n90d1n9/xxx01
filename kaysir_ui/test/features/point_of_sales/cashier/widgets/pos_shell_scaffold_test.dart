import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_shell_scaffold.dart';

void main() {
  testWidgets('shell scaffold renders app bar, command bar, and body slots', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: POSShellScaffold(
          appBar: AppBar(title: const Text('POS Shell')),
          contentBuilder:
              (context, constraints) => const POSShellContent(
                commandBar: SizedBox(
                  height: 48,
                  child: Center(child: Text('Commands')),
                ),
                statusBanner: Center(child: Text('Switch result ready')),
                body: Center(
                  key: ValueKey('catalog'),
                  child: Text('Catalog workspace'),
                ),
              ),
        ),
      ),
    );

    expect(find.text('POS Shell'), findsOneWidget);
    expect(find.text('Commands'), findsOneWidget);
    expect(find.text('Switch result ready'), findsOneWidget);
    expect(find.text('Catalog workspace'), findsOneWidget);
  });

  testWidgets('shell scaffold wires keyboard shortcuts through focus shell', (
    tester,
  ) async {
    var shortcutInvoked = false;

    await tester.pumpWidget(
      MaterialApp(
        home: POSShellScaffold(
          shortcuts: {
            const SingleActivator(LogicalKeyboardKey.f2):
                () => shortcutInvoked = true,
          },
          appBar: AppBar(title: const Text('POS Shell')),
          contentBuilder:
              (context, constraints) => const POSShellContent(
                commandBar: SizedBox.shrink(),
                body: SizedBox.shrink(),
              ),
        ),
      ),
    );
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.f2);

    expect(shortcutInvoked, isTrue);
  });
}
