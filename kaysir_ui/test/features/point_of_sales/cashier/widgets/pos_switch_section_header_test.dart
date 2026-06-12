import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_mode_switch_option_tile.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_switch_section_header.dart';

void main() {
  testWidgets('switch section header renders title and count label', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _HeaderHost(
        child: POSSwitchSectionHeader(
          title: 'Kaysir Core',
          countLabel: '3 modes',
        ),
      ),
    );

    expect(find.text('Kaysir Core'), findsOneWidget);
    expect(find.text('3 modes'), findsOneWidget);
  });

  testWidgets('mode section header uses singular count copy', (tester) async {
    await tester.pumpWidget(
      const _HeaderHost(
        child: POSModeSwitchSectionHeader(title: 'Kaysir Core', count: 1),
      ),
    );

    expect(find.text('1 mode'), findsOneWidget);
    expect(find.text('1 modes'), findsNothing);
  });
}

class _HeaderHost extends StatelessWidget {
  final Widget child;

  const _HeaderHost({required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: child));
  }
}
