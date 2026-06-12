import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/widgets/form/textfield_widget.dart';

void main() {
  testWidgets('does not fail validation when no validator is provided', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(key: formKey, child: const TextFieldWidget()),
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isTrue);
  });

  testWidgets('shows password visibility action inside the input', (
    tester,
  ) async {
    var toggled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TextFieldWidget(
            hint: 'Password',
            isObscure: true,
            showEye: true,
            isEyeOpen: false,
            onEyePressed: () => toggled = true,
          ),
        ),
      ),
    );

    expect(find.byTooltip('Show password'), findsOneWidget);

    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();

    expect(toggled, isTrue);
  });
}
