import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/services/local_database/local_storage_service.dart';

import '../models/component_preset.dart';

const _componentPresetStorageKey = 'layout_builder.component_presets.v1';

final componentPresetRepositoryProvider =
    Provider<LayoutComponentPresetRepository>((ref) {
      return LayoutComponentPresetRepository();
    });

final componentPresetProvider = FutureProvider<List<ComponentPreset>>(
  (ref) => ref.watch(componentPresetRepositoryProvider).loadPresets(),
);

class LayoutComponentPresetRepository {
  Future<List<ComponentPreset>> loadPresets() async {
    await _ensureDatabase();

    final stored = await LocalDBService.getPreference(
      key: _componentPresetStorageKey,
    );
    final rawPresets = stored is List ? stored : const [];

    final presets =
        rawPresets
            .whereType<Map>()
            .map(
              (item) =>
                  ComponentPreset.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return presets;
  }

  Future<void> savePreset(ComponentPreset preset) async {
    final presets = await loadPresets();
    final now = DateTime.now();
    final nextPreset = preset.copyWith(updatedAt: now);
    final nextPresets = [
      nextPreset,
      ...presets.where((item) => item.id != preset.id),
    ];

    await _savePresets(nextPresets);
  }

  Future<void> deletePreset(String presetId) async {
    final presets = await loadPresets();
    await _savePresets(
      presets.where((preset) => preset.id != presetId).toList(),
    );
  }

  Future<void> _savePresets(List<ComponentPreset> presets) async {
    await _ensureDatabase();
    await LocalDBService.savePreference(
      key: _componentPresetStorageKey,
      value: presets.map((preset) => preset.toJson()).toList(),
    );
  }

  Future<void> _ensureDatabase() async {
    await LocalDBService.initialize(encryptionPassword: 'your-secure-password');
  }
}
