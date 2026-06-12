import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

void main() {
  testWidgets('renders eyebrow, title, and constrained subtitle', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppTextCluster(
            eyebrow: 'Retail intelligence',
            title: 'Sales dashboard',
            subtitle: 'Track store performance and product movement.',
            subtitleMaxWidth: 240,
          ),
        ),
      ),
    );

    expect(find.text('Retail intelligence'), findsOneWidget);
    expect(find.text('Sales dashboard'), findsOneWidget);
    expect(
      find.text('Track store performance and product movement.'),
      findsOneWidget,
    );
    final constrainedBoxes = tester.widgetList<ConstrainedBox>(
      find.byType(ConstrainedBox),
    );

    expect(
      constrainedBoxes.any((box) => box.constraints.maxWidth == 240),
      isTrue,
    );
  });

  testWidgets('respects one-line overflow settings', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 120,
            child: AppTextCluster(
              title: 'Very long operational signal',
              subtitle: 'Secondary detail that should remain compact',
              titleMaxLines: 1,
              subtitleMaxLines: 1,
              titleOverflow: TextOverflow.ellipsis,
              subtitleOverflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );

    final title = tester.widget<Text>(
      find.text('Very long operational signal'),
    );
    final subtitle = tester.widget<Text>(
      find.text('Secondary detail that should remain compact'),
    );

    expect(title.maxLines, 1);
    expect(title.overflow, TextOverflow.ellipsis);
    expect(subtitle.maxLines, 1);
    expect(subtitle.overflow, TextOverflow.ellipsis);
  });
}
