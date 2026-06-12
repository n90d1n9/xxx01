import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/utils/pos_command_bar_layout.dart';

void main() {
  test('command bar layout stacks actions on compact screens', () {
    final layout = POSCommandBarLayout.resolve(480);

    expect(layout.density, POSCommandBarDensity.compact);
    expect(layout.stacksActions, isTrue);
    expect(layout.usesCompactControls, isTrue);
  });

  test(
    'command bar layout keeps actions inline with compact controls on medium screens',
    () {
      final layout = POSCommandBarLayout.resolve(
        POSCommandBarLayout.stackedBreakpoint,
      );

      expect(layout.density, POSCommandBarDensity.balanced);
      expect(layout.stacksActions, isFalse);
      expect(layout.usesCompactControls, isTrue);
    },
  );

  test('command bar layout expands control labels on wide screens', () {
    final layout = POSCommandBarLayout.resolve(
      POSCommandBarLayout.expandedBreakpoint,
    );

    expect(layout.density, POSCommandBarDensity.expanded);
    expect(layout.stacksActions, isFalse);
    expect(layout.usesCompactControls, isFalse);
  });

  test('command bar layout treats unbounded widths as expanded', () {
    final layout = POSCommandBarLayout.resolve(double.infinity);

    expect(layout.density, POSCommandBarDensity.expanded);
    expect(layout.stacksActions, isFalse);
    expect(layout.usesCompactControls, isFalse);
  });
}
