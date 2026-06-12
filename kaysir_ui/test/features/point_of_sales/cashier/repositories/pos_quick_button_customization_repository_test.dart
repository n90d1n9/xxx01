import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/pos_quick_button_customization.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/pos_touch_layout_profile.dart';
import 'package:kaysir/features/point_of_sales/cashier/repositories/pos_quick_button_customization_repository.dart';

void main() {
  test(
    'quick button customization repository loads stored snapshots',
    () async {
      final repository = POSQuickButtonCustomizationRepository(
        store: MemoryPOSQuickButtonCustomizationSnapshotStore(
          initialSnapshot: {
            'hiddenButtonIds': ['scan'],
            'pinnedButtonIds': ['payment'],
            'densityOverride': 'kiosk',
          },
        ),
      );

      final customization = await repository.load();

      expect(customization.hiddenButtonIds, ['scan']);
      expect(customization.pinnedButtonIds, ['payment']);
      expect(customization.densityOverride, POSTouchLayoutDensity.kiosk);
    },
  );

  test(
    'quick button customization repository saves serialized snapshots',
    () async {
      final store = MemoryPOSQuickButtonCustomizationSnapshotStore();
      final repository = POSQuickButtonCustomizationRepository(store: store);

      await repository.save(
        const POSQuickButtonCustomization(
          hiddenButtonIds: ['hold'],
          pinnedButtonIds: ['payment'],
          densityOverride: POSTouchLayoutDensity.spacious,
        ),
      );

      expect(store.snapshot, {
        'hiddenButtonIds': ['hold'],
        'pinnedButtonIds': ['payment'],
        'densityOverride': 'spacious',
      });
    },
  );

  test('quick button customization scope isolates preference keys', () {
    const scope = POSQuickButtonCustomizationScope(
      tenantId: 'tenant-a',
      outletId: 'outlet-1',
      operatorId: 'cashier-7',
    );

    expect(
      scope.storageKey,
      'pos.quick_button_customization.v1.tenant-a.outlet-1.cashier-7',
    );
  });
}
