import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_switch_filter_state.dart';

void main() {
  test('switch filter state exposes initial query and status', () {
    final state = POSSwitchFilterState<_FilterStatus>(
      initialStatus: _FilterStatus.all,
      initialQuery: 'coffee',
    );
    addTearDown(state.dispose);

    expect(state.query, 'coffee');
    expect(state.searchController.text, 'coffee');
    expect(state.status, _FilterStatus.all);
    expect(state.isAtDefault, isFalse);
  });

  test('switch filter state syncs query changes and notifies', () {
    final state = POSSwitchFilterState<_FilterStatus>(
      initialStatus: _FilterStatus.all,
    );
    addTearDown(state.dispose);
    var notifications = 0;
    state.addListener(() => notifications += 1);

    state.searchController.text = 'quick';
    state.setQuery('quick');

    expect(state.query, 'quick');
    expect(notifications, 1);

    state.setQuery('espresso');

    expect(state.searchController.text, 'espresso');
    expect(notifications, 2);
  });

  test('switch filter state updates status only when changed', () {
    final state = POSSwitchFilterState<_FilterStatus>(
      initialStatus: _FilterStatus.all,
    );
    addTearDown(state.dispose);
    var notifications = 0;
    state.addListener(() => notifications += 1);

    state.setStatus(_FilterStatus.all);
    state.setStatus(_FilterStatus.ready);

    expect(state.status, _FilterStatus.ready);
    expect(notifications, 1);
  });

  test('switch filter state resets query and status', () {
    final state = POSSwitchFilterState<_FilterStatus>(
      initialStatus: _FilterStatus.all,
      initialQuery: 'quick',
    );
    addTearDown(state.dispose);
    var notifications = 0;
    state.addListener(() => notifications += 1);

    state.setStatus(_FilterStatus.ready);
    state.reset();
    state.reset();

    expect(state.query, isEmpty);
    expect(state.searchController.text, isEmpty);
    expect(state.status, _FilterStatus.all);
    expect(state.isAtDefault, isTrue);
    expect(notifications, 2);
  });
}

enum _FilterStatus { all, ready }
