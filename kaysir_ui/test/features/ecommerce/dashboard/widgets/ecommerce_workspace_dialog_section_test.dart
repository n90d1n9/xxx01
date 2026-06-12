import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/dialog_section.dart';

void main() {
  testWidgets('DialogSection renders reusable section chrome', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DialogSection(
            title: 'Coverage',
            trailing: const Icon(Icons.info_outline),
            child: const Text('Section body'),
          ),
        ),
      ),
    );

    expect(find.text('Coverage'), findsOneWidget);
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
    expect(find.text('Section body'), findsOneWidget);

    final title = tester.widget<Text>(find.text('Coverage'));
    expect(title.maxLines, 1);
    expect(title.overflow, TextOverflow.ellipsis);
    expect(title.style?.fontWeight, FontWeight.w900);
    expect(tester.takeException(), isNull);
  });
}
