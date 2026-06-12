import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_timeline_search_field.dart';

void main() {
  testWidgets('gantt timeline search field clears active query', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'launch');
    final focusNode = FocusNode();
    var changedValue = '';
    var clearCount = 0;
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GanttTimelineSearchField(
            controller: controller,
            focusNode: focusNode,
            query: 'launch',
            onChanged: (value) => changedValue = value,
            onClear: () => clearCount++,
          ),
        ),
      ),
    );

    expect(find.byKey(GanttTimelineSearchField.clearButtonKey), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'delivery');
    await tester.tap(find.byKey(GanttTimelineSearchField.clearButtonKey));

    expect(changedValue, 'delivery');
    expect(clearCount, 1);
  });

  testWidgets('gantt timeline search field hides clear affordance when empty', (
    tester,
  ) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GanttTimelineSearchField(
            controller: controller,
            focusNode: focusNode,
            query: '',
            onChanged: (_) {},
            onClear: () {},
          ),
        ),
      ),
    );

    expect(find.byKey(GanttTimelineSearchField.clearButtonKey), findsNothing);
  });
}
