import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/grid_setting.dart';
import 'package:kaysir/features/layout_builder/models/layout_config.dart';
import 'package:kaysir/features/layout_builder/models/layout_rule_preset.dart';

void main() {
  group('LayoutRulePreset', () {
    test('applies responsive column rules while preserving canvas size', () {
      final preset = layoutRulePresets.firstWhere(
        (preset) => preset.id == 'responsive-columns',
      );
      const config = LayoutConfig(canvasWidth: 1440, canvasHeight: 900);
      const settings = GridSettings(opacity: 0.45);

      final nextConfig = preset.applyToConfig(config);
      final nextSettings = preset.applyToGridSettings(settings);

      expect(nextConfig.canvasWidth, 1440);
      expect(nextConfig.canvasHeight, 900);
      expect(nextConfig.layoutMechanism, LayoutMechanism.tabularColumns);
      expect(nextConfig.tabularColumnCount, 12);
      expect(nextConfig.tabularColumnGap, 24);
      expect(nextConfig.tabularRowHeight, 72);
      expect(nextSettings.gridSize, 24);
      expect(nextSettings.opacity, 0.45);
      expect(nextSettings.snapToGrid, isTrue);
    });

    test('detects selected preset from matching config and settings', () {
      final preset = layoutRulePresets.firstWhere(
        (preset) => preset.id == 'auto-dense',
      );
      final config = preset.applyToConfig(const LayoutConfig());
      final settings = preset.applyToGridSettings(const GridSettings());

      expect(selectedLayoutRulePresetId(config, settings), 'auto-dense');
      expect(
        selectedLayoutRulePresetId(
          config.copyWith(autoGridColumnCount: 5),
          settings,
        ),
        isNull,
      );
    });
  });
}
