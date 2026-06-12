import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/widgets/project_form_percent_slider.dart';

void main() {
  testWidgets('project form percent slider renders and emits changes', (
    tester,
  ) async {
    double? changedValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectFormPercentSlider(
            label: 'Planned progress',
            value: 0.35,
            color: Colors.blue,
            onChanged: (value) => changedValue = value,
          ),
        ),
      ),
    );

    expect(find.text('Planned progress'), findsOneWidget);
    expect(find.text('35%'), findsOneWidget);

    tester.widget<Slider>(find.byType(Slider)).onChanged?.call(0.6);

    expect(changedValue, 0.6);
  });
}
