import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/utils/pos_shell_action_layout.dart';

void main() {
  test(
    'shell action layout collapses secondary actions on compact screens',
    () {
      final layout = POSShellActionLayout.resolve(640);

      expect(layout.density, POSShellActionDensity.compact);
      expect(layout.showTerminalInline, isFalse);
      expect(layout.showSecondaryActionsInline, isFalse);
    },
  );

  test(
    'shell action layout keeps terminal but overflows secondary actions on tablet widths',
    () {
      final layout = POSShellActionLayout.resolve(900);

      expect(layout.density, POSShellActionDensity.balanced);
      expect(layout.showTerminalInline, isTrue);
      expect(layout.showSecondaryActionsInline, isFalse);
    },
  );

  test('shell action layout shows full controls on wide screens', () {
    final layout = POSShellActionLayout.resolve(1280);

    expect(layout.density, POSShellActionDensity.expanded);
    expect(layout.showTerminalInline, isTrue);
    expect(layout.showSecondaryActionsInline, isTrue);
  });
}
