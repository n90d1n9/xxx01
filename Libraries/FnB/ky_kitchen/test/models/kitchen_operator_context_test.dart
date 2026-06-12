import 'package:flutter_test/flutter_test.dart';
import 'package:ky_kitchen/ky_kitchen.dart';

void main() {
  test('operator context normalizes display labels for audit records', () {
    final operator = KitchenOperatorContext.fromLabel('  Expo Lead  ');

    expect(operator.id, 'expo-lead');
    expect(operator.normalizedId, 'expo-lead');
    expect(operator.verifierLabel, 'Expo Lead');
    expect(operator.roleBadgeLabel, isNull);
  });

  test('operator context preserves staff identity metadata', () {
    const operator = KitchenOperatorContext(
      id: 'staff-7',
      displayName: 'Dimas',
      roleLabel: 'Expo lead',
      stationId: 'pass',
    );

    expect(operator.normalizedId, 'staff-7');
    expect(operator.verifierLabel, 'Dimas');
    expect(operator.roleBadgeLabel, 'Expo lead');
    expect(
      operator.copyWith(displayName: 'Ayu'),
      const KitchenOperatorContext(
        id: 'staff-7',
        displayName: 'Ayu',
        roleLabel: 'Expo lead',
        stationId: 'pass',
      ),
    );
  });
}
