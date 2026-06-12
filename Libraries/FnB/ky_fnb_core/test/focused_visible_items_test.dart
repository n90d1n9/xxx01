import 'package:flutter_test/flutter_test.dart';
import 'package:ky_fnb_core/ky_fnb_core.dart';

void main() {
  test('focused visible items keep focused entries inside capped lists', () {
    final visible = fnbFocusedVisibleItems(
      items: _items,
      limit: 2,
      focusedId: 'dessert',
      idOf: (item) => item.id,
    );

    expect(visible.map((item) => item.id), ['risk', 'dessert']);
  });

  test('focused visible items preserve visible capped order without focus', () {
    final visible = fnbFocusedVisibleItems(
      items: _items,
      limit: 2,
      focusedId: null,
      idOf: (item) => item.id,
    );

    expect(visible.map((item) => item.id), ['risk', 'quick']);
  });

  test('visible items with focus prepends hidden focused source items', () {
    final visible = fnbVisibleItemsWithFocus(
      visibleItems: _items.where((item) => item.group == 'done'),
      sourceItems: _items,
      focusedId: 'risk',
      idOf: (item) => item.id,
    );

    expect(visible.map((item) => item.id), ['risk', 'dessert']);
  });

  test(
    'visible items with focus preserves visible list when focus is absent',
    () {
      final visible = fnbVisibleItemsWithFocus(
        visibleItems: _items.where((item) => item.group == 'done'),
        sourceItems: _items,
        focusedId: 'missing',
        idOf: (item) => item.id,
      );

      expect(visible.map((item) => item.id), ['dessert']);
    },
  );
}

const _items = [
  _FocusedItem(id: 'risk', group: 'attention'),
  _FocusedItem(id: 'quick', group: 'active'),
  _FocusedItem(id: 'dessert', group: 'done'),
];

class _FocusedItem {
  const _FocusedItem({required this.id, required this.group});

  final String id;
  final String group;
}
