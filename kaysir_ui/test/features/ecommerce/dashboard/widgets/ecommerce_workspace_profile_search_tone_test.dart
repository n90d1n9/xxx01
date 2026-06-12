import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile_search.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/profile_search_tone.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/tone.dart';

void main() {
  test('profileSearchVisualTone maps match types', () {
    expect(
      profileSearchVisualTone(ProductProfileSearchMatchType.profile),
      VisualTone.primary,
    );
    expect(
      profileSearchVisualTone(ProductProfileSearchMatchType.orderWorkspace),
      VisualTone.primary,
    );
    expect(
      profileSearchVisualTone(ProductProfileSearchMatchType.salesChannel),
      VisualTone.secondary,
    );
    expect(
      profileSearchVisualTone(
        ProductProfileSearchMatchType.channelCoverageRequirement,
      ),
      VisualTone.success,
    );
    expect(
      profileSearchVisualTone(ProductProfileSearchMatchType.recommendation),
      VisualTone.danger,
    );
    expect(
      profileSearchIcon(ProductProfileSearchMatchType.orderWorkspace),
      Icons.receipt_long_outlined,
    );
  });

  test('profileSearchMatchBadgeColors uses badge density', () {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.indigo);

    final profileColors = profileSearchMatchBadgeColors(
      scheme,
      ProductProfileSearchMatchType.profile,
    );
    final recommendationColors = profileSearchMatchBadgeColors(
      scheme,
      ProductProfileSearchMatchType.recommendation,
    );

    expect(
      profileColors.background,
      scheme.primaryContainer.withValues(alpha: 0.24),
    );
    expect(profileColors.border, scheme.primary.withValues(alpha: 0.16));
    expect(recommendationColors.foreground, scheme.error);
    expect(recommendationColors.border, scheme.error.withValues(alpha: 0.14));
  });

  test('profileSearchSuggestionColors uses light tints', () {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.teal);

    final channelColors = profileSearchSuggestionColors(
      scheme,
      ProductProfileSearchMatchType.salesChannel,
    );
    final capabilityColors = profileSearchSuggestionColors(
      scheme,
      ProductProfileSearchMatchType.capability,
    );

    expect(channelColors.background, scheme.secondary.withValues(alpha: 0.08));
    expect(channelColors.border, scheme.secondary.withValues(alpha: 0.16));
    expect(
      capabilityColors.background,
      scheme.primaryContainer.withValues(alpha: 0.3),
    );
  });
}
