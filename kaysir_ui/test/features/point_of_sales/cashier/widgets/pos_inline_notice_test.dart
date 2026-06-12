import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_inline_notice.dart';

void main() {
  testWidgets('inline notice renders optional footer content', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: POSInlineNotice(
            tone: POSInlineNoticeTone.info,
            icon: Icons.info_outline,
            title: 'Queue health',
            message: 'Orders are waiting to sync.',
            footer: Wrap(children: [Text('1 queued')]),
          ),
        ),
      ),
    );

    expect(find.text('Queue health'), findsOneWidget);
    expect(find.text('1 queued'), findsOneWidget);
  });
}
