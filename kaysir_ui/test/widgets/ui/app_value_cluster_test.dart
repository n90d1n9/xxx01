import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/widgets/ui/app_value_cluster.dart';

void main() {
  testWidgets('renders label, value, and detail text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppValueCluster(
            label: 'Transactions',
            value: '127K',
            detail: '+ 2% than last week',
          ),
        ),
      ),
    );

    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('127K'), findsOneWidget);
    expect(find.text('+ 2% than last week'), findsOneWidget);
  });

  testWidgets('respects compact overflow and alignment settings', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 120,
            child: AppValueCluster(
              label: 'Long operational metric',
              value: 'Rp 123.456.789',
              detail: 'Secondary operational detail',
              crossAxisAlignment: CrossAxisAlignment.end,
              textAlign: TextAlign.end,
            ),
          ),
        ),
      ),
    );

    final value = tester.widget<Text>(find.text('Rp 123.456.789'));
    final detail = tester.widget<Text>(
      find.text('Secondary operational detail'),
    );
    final column = tester.widget<Column>(find.byType(Column));

    expect(column.crossAxisAlignment, CrossAxisAlignment.end);
    expect(value.maxLines, 1);
    expect(value.overflow, TextOverflow.ellipsis);
    expect(value.textAlign, TextAlign.end);
    expect(detail.maxLines, 1);
    expect(detail.overflow, TextOverflow.ellipsis);
  });

  testWidgets('can render detail without a primary value', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppValueCluster(detail: '1276 sold')),
      ),
    );

    expect(find.text('1276 sold'), findsOneWidget);
    expect(find.byType(Text), findsOneWidget);
  });
}
