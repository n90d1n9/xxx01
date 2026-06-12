import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/payroal/widgets/payroll_workspace_tabs.dart';

void main() {
  testWidgets('payroll workspace tabs switch between sections', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PayrollWorkspaceTabs(
            tabs: const [
              PayrollWorkspaceTabSpec(
                label: 'Overview',
                icon: Icons.insights_outlined,
                child: PayrollWorkspaceSection(
                  children: [Text('Overview content')],
                ),
              ),
              PayrollWorkspaceTabSpec(
                label: 'Payments',
                icon: Icons.payments_outlined,
                child: PayrollWorkspaceSection(
                  children: [Text('Payments content')],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Payments'), findsOneWidget);
    expect(find.text('Overview content'), findsOneWidget);
    expect(find.text('Payments content'), findsNothing);

    await tester.tap(find.text('Payments'));
    await tester.pumpAndSettle();

    expect(find.text('Payments content'), findsOneWidget);
  });
}
