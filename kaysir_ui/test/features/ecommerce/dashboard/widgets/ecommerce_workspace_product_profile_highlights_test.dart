import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/product_profile_highlights.dart';

import '../fixtures/widget_test_harness.dart';

void main() {
  testWidgets('ProductProfileHighlights can render chips only', (tester) async {
    await tester.pumpWorkspaceWidget(
      ProductProfileHighlights(
        profile: ProductProfile.standard,
        chipLimits: const ProductProfileChipLimits(
          channels: 1,
          capabilities: 1,
          requirements: 1,
        ),
      ),
    );

    expect(find.text('Standard commerce'), findsNothing);
    expect(find.text('Web store'), findsOneWidget);
    expect(find.text('+2 channels'), findsOneWidget);
    expect(find.text('Storefront'), findsOneWidget);
    expect(find.text('+4 more'), findsOneWidget);
    expect(find.text('Payments'), findsOneWidget);
    expect(find.text('+2 rules'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('productProfileHasHighlights detects empty profiles', () {
    final profile = ProductProfile.standard.copyWith(
      capabilities: const [],
      salesChannels: const [],
      channelCoverageRequirements: const [],
    );

    expect(productProfileHasHighlights(profile), isFalse);
    expect(productProfileHasHighlights(ProductProfile.standard), isTrue);
  });
}
