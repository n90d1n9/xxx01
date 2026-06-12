import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile_signal_visibility.dart';

void main() {
  group('ProductProfileSignalVisibility', () {
    test('presets expose reusable profile signal scopes', () {
      expect(ProductProfileSignalVisibility.none.hasAny, isFalse);

      expect(ProductProfileSignalVisibility.compact.businessMotion, isTrue);
      expect(ProductProfileSignalVisibility.compact.launchComplexity, isFalse);
      expect(ProductProfileSignalVisibility.compact.hasFootprint, isFalse);

      expect(
        ProductProfileSignalVisibility.decision.hasDecisionSignals,
        isTrue,
      );
      expect(ProductProfileSignalVisibility.decision.hasFootprint, isFalse);

      expect(ProductProfileSignalVisibility.detailed.hasAny, isTrue);
      expect(ProductProfileSignalVisibility.detailed.hasFootprint, isTrue);
    });

    test('copyWith creates tailored signal visibility for product packs', () {
      final visibility = ProductProfileSignalVisibility.decision.copyWith(
        businessMotion: false,
        footprint: true,
      );

      expect(visibility.businessMotion, isFalse);
      expect(visibility.launchComplexity, isTrue);
      expect(visibility.footprint, isTrue);
      expect(visibility.hasDecisionSignals, isTrue);
      expect(visibility.hasAny, isTrue);
    });
  });
}
