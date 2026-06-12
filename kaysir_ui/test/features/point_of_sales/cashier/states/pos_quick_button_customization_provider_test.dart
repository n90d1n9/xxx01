import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/pos_quick_button_customization.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/pos_touch_layout_profile.dart';
import 'package:kaysir/features/point_of_sales/cashier/repositories/pos_quick_button_customization_repository.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_quick_button_customization_provider.dart';

void main() {
  test(
    'quick button customization controller pins hides resets and persists',
    () async {
      final store = MemoryPOSQuickButtonCustomizationSnapshotStore();
      final container = ProviderContainer(
        overrides: [
          posQuickButtonCustomizationRepositoryProvider.overrideWithValue(
            POSQuickButtonCustomizationRepository(store: store),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        posQuickButtonCustomizationControllerProvider,
      );

      controller.togglePinned('scan');
      expect(
        container.read(posQuickButtonCustomizationProvider).pinnedButtonIds,
        ['scan'],
      );
      await controller.flushPersistence();
      expect(store.snapshot, {
        'pinnedButtonIds': ['scan'],
      });

      controller.toggleHidden('scan');
      final hiddenState = container.read(posQuickButtonCustomizationProvider);
      expect(hiddenState.hiddenButtonIds, ['scan']);
      expect(hiddenState.pinnedButtonIds, isEmpty);
      await controller.flushPersistence();
      expect(store.snapshot, {
        'hiddenButtonIds': ['scan'],
      });

      controller.reset();
      expect(
        container.read(posQuickButtonCustomizationProvider).isEmpty,
        isTrue,
      );
      await controller.flushPersistence();
      expect(store.snapshot, isEmpty);
    },
  );

  test(
    'quick button customization controller persists density override',
    () async {
      final store = MemoryPOSQuickButtonCustomizationSnapshotStore();
      final container = ProviderContainer(
        overrides: [
          posQuickButtonCustomizationRepositoryProvider.overrideWithValue(
            POSQuickButtonCustomizationRepository(store: store),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        posQuickButtonCustomizationControllerProvider,
      );

      controller.setDensityOverride(POSTouchLayoutDensity.spacious);
      await controller.flushPersistence();

      expect(
        container.read(posQuickButtonCustomizationProvider).densityOverride,
        POSTouchLayoutDensity.spacious,
      );
      expect(store.snapshot, {'densityOverride': 'spacious'});

      controller.setDensityOverride(null);
      await controller.flushPersistence();

      expect(
        container.read(posQuickButtonCustomizationProvider).densityOverride,
        isNull,
      );
      expect(store.snapshot, isEmpty);
    },
  );

  test('quick button customization controller persists pinned order', () async {
    final store = MemoryPOSQuickButtonCustomizationSnapshotStore();
    final container = ProviderContainer(
      overrides: [
        posQuickButtonCustomizationRepositoryProvider.overrideWithValue(
          POSQuickButtonCustomizationRepository(store: store),
        ),
      ],
    );
    addTearDown(container.dispose);

    container
        .read(posQuickButtonCustomizationProvider.notifier)
        .state = const POSQuickButtonCustomization(
      pinnedButtonIds: ['scan', 'hold', 'payment'],
    );

    final controller = container.read(
      posQuickButtonCustomizationControllerProvider,
    );

    controller.movePinned('payment', -1);
    await controller.flushPersistence();

    expect(
      container.read(posQuickButtonCustomizationProvider).pinnedButtonIds,
      ['scan', 'payment', 'hold'],
    );
    expect(store.snapshot, {
      'pinnedButtonIds': ['scan', 'payment', 'hold'],
    });
  });

  test('quick button customization hydrates persisted state', () async {
    final store = MemoryPOSQuickButtonCustomizationSnapshotStore(
      initialSnapshot: {
        'hiddenButtonIds': ['hold'],
        'pinnedButtonIds': ['payment'],
        'densityOverride': 'compact',
      },
    );
    final container = ProviderContainer(
      overrides: [
        posQuickButtonCustomizationRepositoryProvider.overrideWithValue(
          POSQuickButtonCustomizationRepository(store: store),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(posQuickButtonCustomizationHydrationProvider.future);

    final customization = container.read(posQuickButtonCustomizationProvider);
    expect(customization.hiddenButtonIds, ['hold']);
    expect(customization.pinnedButtonIds, ['payment']);
    expect(customization.densityOverride, POSTouchLayoutDensity.compact);
  });

  test(
    'quick button customization hydration keeps pre-hydration edits',
    () async {
      final store = MemoryPOSQuickButtonCustomizationSnapshotStore(
        initialSnapshot: {
          'hiddenButtonIds': ['restored'],
        },
      );
      final container = ProviderContainer(
        overrides: [
          posQuickButtonCustomizationRepositoryProvider.overrideWithValue(
            POSQuickButtonCustomizationRepository(store: store),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(posQuickButtonCustomizationProvider.notifier).state =
          const POSQuickButtonCustomization(pinnedButtonIds: ['local']);

      final controller = container.read(
        posQuickButtonCustomizationControllerProvider,
      );
      await container.read(posQuickButtonCustomizationHydrationProvider.future);
      await controller.flushPersistence();

      final customization = container.read(posQuickButtonCustomizationProvider);
      expect(customization.hiddenButtonIds, isEmpty);
      expect(customization.pinnedButtonIds, ['local']);
      expect(store.snapshot, {
        'pinnedButtonIds': ['local'],
      });
    },
  );
}
