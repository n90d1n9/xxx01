import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test('controlled panel value resolves local and controlled values', () {
    final value = RestaurantControlledPanelValue('all');

    expect(value.resolve(null), 'all');
    expect(value.resolve('risk'), 'risk');
  });

  test('controlled panel value syncs initial value while untouched', () {
    final value = RestaurantControlledPanelValue('all');

    expect(
      value.syncInitial(previousInitialValue: 'all', initialValue: 'risk'),
      isTrue,
    );
    expect(value.resolve(null), 'risk');
  });

  test(
    'controlled panel value preserves local edits across initial changes',
    () {
      final value = RestaurantControlledPanelValue('all');

      value.select(value: 'risk', controlledValue: null);

      expect(
        value.syncInitial(previousInitialValue: 'all', initialValue: 'margin'),
        isFalse,
      );
      expect(value.resolve(null), 'risk');
    },
  );

  test(
    'controlled panel value reports selections without mutating controlled state',
    () {
      final value = RestaurantControlledPanelValue('all');
      final changes = <String>[];
      var localChanged = false;

      final changed = value.select(
        value: 'risk',
        controlledValue: 'all',
        onChanged: changes.add,
        onLocalChanged: () => localChanged = true,
      );

      expect(changed, isTrue);
      expect(changes, ['risk']);
      expect(localChanged, isFalse);
      expect(value.resolve(null), 'all');
    },
  );
}
