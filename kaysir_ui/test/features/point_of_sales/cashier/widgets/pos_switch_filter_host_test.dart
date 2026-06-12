import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_switch_filter_host.dart';

void main() {
  testWidgets('switch filter host provides initial filter state', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSSwitchFilterHost<_FilterStatus>(
            initialStatus: _FilterStatus.all,
            initialQuery: 'quick',
            builder:
                (context, filterState) =>
                    Text('${filterState.query}/${filterState.status.name}'),
          ),
        ),
      ),
    );

    expect(find.text('quick/all'), findsOneWidget);
  });

  testWidgets('switch filter host rebuilds when query or status changes', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSSwitchFilterHost<_FilterStatus>(
            initialStatus: _FilterStatus.all,
            builder:
                (context, filterState) => Column(
                  children: [
                    Text('${filterState.query}/${filterState.status.name}'),
                    TextButton(
                      onPressed: () => filterState.setQuery('coffee'),
                      child: const Text('Set query'),
                    ),
                    TextButton(
                      onPressed:
                          () => filterState.setStatus(_FilterStatus.ready),
                      child: const Text('Set ready'),
                    ),
                  ],
                ),
          ),
        ),
      ),
    );

    expect(find.text('/all'), findsOneWidget);

    await tester.tap(find.text('Set query'));
    await tester.pump();

    expect(find.text('coffee/all'), findsOneWidget);

    await tester.tap(find.text('Set ready'));
    await tester.pump();

    expect(find.text('coffee/ready'), findsOneWidget);
  });
}

enum _FilterStatus { all, ready }
