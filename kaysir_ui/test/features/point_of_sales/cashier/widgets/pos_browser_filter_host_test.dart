import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_browser_filter_host.dart';

void main() {
  testWidgets('browser filter host provides initial controller state', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSBrowserFilterHost<_Filter>(
            initialFilter: _Filter.all,
            initialQuery: ' latte ',
            builder:
                (context, controller, actions) =>
                    Text('${controller.query}/${controller.filter.name}'),
          ),
        ),
      ),
    );

    expect(find.text('latte/all'), findsOneWidget);
  });

  testWidgets(
    'browser filter host rebuilds from query, filter, and reset actions',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: POSBrowserFilterHost<_Filter>(
              initialFilter: _Filter.all,
              builder:
                  (context, controller, actions) => Column(
                    children: [
                      Text('${controller.query}/${controller.filter.name}'),
                      TextButton(
                        onPressed: () => actions.setQuery('coffee'),
                        child: const Text('Set query'),
                      ),
                      TextButton(
                        onPressed: () => actions.setFilter(_Filter.ready),
                        child: const Text('Set ready'),
                      ),
                      TextButton(
                        onPressed: actions.reset,
                        child: const Text('Reset'),
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

      await tester.tap(find.text('Reset'));
      await tester.pump();

      expect(find.text('/all'), findsOneWidget);
    },
  );

  testWidgets('browser filter host applies updated initial state from parent', (
    tester,
  ) async {
    var initialFilter = _Filter.all;
    var initialQuery = 'coffee';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  POSBrowserFilterHost<_Filter>(
                    initialFilter: initialFilter,
                    initialQuery: initialQuery,
                    builder:
                        (context, controller, actions) => Text(
                          '${controller.query}/${controller.filter.name}',
                        ),
                  ),
                  TextButton(
                    onPressed:
                        () => setState(() {
                          initialFilter = _Filter.blocked;
                          initialQuery = 'tea';
                        }),
                    child: const Text('Update parent'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('coffee/all'), findsOneWidget);

    await tester.tap(find.text('Update parent'));
    await tester.pump();

    expect(find.text('tea/blocked'), findsOneWidget);
  });
}

enum _Filter { all, ready, blocked }
