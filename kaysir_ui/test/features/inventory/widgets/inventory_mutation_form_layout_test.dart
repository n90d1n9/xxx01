import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/widgets/inventory_mutation_form_layout.dart';

void main() {
  testWidgets('inventory mutation form layout wires body error and actions', (
    tester,
  ) async {
    var cancelled = false;
    var submitted = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryMutationFormLayout(
            formKey: GlobalKey<FormState>(),
            formError: 'Resolve the quantity issue.',
            confirmLabel: 'Apply change',
            confirmIcon: Icons.check_rounded,
            onCancel: () => cancelled = true,
            onSubmit: () => submitted = true,
            children: const [Text('Mutation fields')],
          ),
        ),
      ),
    );

    expect(find.text('Mutation fields'), findsOneWidget);
    expect(find.text('Resolve the quantity issue.'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Apply change'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pump();
    expect(cancelled, isTrue);

    await tester.tap(find.text('Apply change'));
    await tester.pump();
    expect(submitted, isTrue);
  });
}
