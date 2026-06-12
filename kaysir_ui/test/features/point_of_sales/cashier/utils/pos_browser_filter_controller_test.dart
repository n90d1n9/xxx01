import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/utils/pos_browser_filter_controller.dart';

void main() {
  test('initializes selected filter and trimmed initial query', () {
    final controller = POSBrowserFilterController<_Filter>(
      initialFilter: _Filter.all,
      initialQuery: ' latte ',
    );
    addTearDown(controller.dispose);

    expect(controller.initialFilter, _Filter.all);
    expect(controller.filter, _Filter.all);
    expect(controller.query, 'latte');
    expect(controller.hasQuery, isTrue);
    expect(controller.isAtInitialState, isFalse);
  });

  test('updates filter and query while preserving typed query text', () {
    final controller = POSBrowserFilterController<_Filter>(
      initialFilter: _Filter.all,
    );
    addTearDown(controller.dispose);

    expect(controller.setFilter(_Filter.all), isFalse);
    expect(controller.setFilter(_Filter.ready), isTrue);
    expect(controller.setQuery(' espresso '), isTrue);
    expect(controller.setQuery(' espresso '), isFalse);

    expect(controller.filter, _Filter.ready);
    expect(controller.query, ' espresso ');
    expect(controller.normalizedQuery, 'espresso');
  });

  test('clears search and resets to initial or explicit filters', () {
    final controller = POSBrowserFilterController<_Filter>(
      initialFilter: _Filter.all,
    );
    addTearDown(controller.dispose);

    controller.setFilter(_Filter.ready);
    controller.setQuery('latte');

    expect(controller.clearSearch(), isTrue);
    expect(controller.query, isEmpty);
    expect(controller.reset(), isTrue);
    expect(controller.filter, _Filter.all);
    expect(controller.isAtInitialState, isTrue);

    controller.setFilter(_Filter.ready);
    controller.setQuery('mocha');

    expect(
      controller.reset(filter: _Filter.blocked, query: '  syrup  '),
      isTrue,
    );
    expect(controller.filter, _Filter.blocked);
    expect(controller.query, 'syrup');
  });

  test('can replace initial state for deep link or parent updates', () {
    final controller = POSBrowserFilterController<_Filter>(
      initialFilter: _Filter.all,
    );
    addTearDown(controller.dispose);

    controller.setFilter(_Filter.ready);
    controller.setQuery('latte');

    expect(
      controller.replaceInitial(
        initialFilter: _Filter.blocked,
        initialQuery: ' mocha ',
      ),
      isTrue,
    );
    expect(controller.initialFilter, _Filter.blocked);
    expect(controller.filter, _Filter.blocked);
    expect(controller.query, 'mocha');

    expect(
      controller.replaceInitial(initialFilter: _Filter.ready, apply: false),
      isFalse,
    );
    expect(controller.initialFilter, _Filter.ready);
    expect(controller.filter, _Filter.blocked);
    expect(controller.query, 'mocha');
  });
}

enum _Filter { all, ready, blocked }
