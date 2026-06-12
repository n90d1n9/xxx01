import 'package:flutter/material.dart';

import '../models/product_profile_search.dart';
import 'tone.dart';

ToneColors profileSearchMatchBadgeColors(
  ColorScheme scheme,
  ProductProfileSearchMatchType type,
) {
  return toneColors(
    scheme,
    profileSearchVisualTone(type),
    backgroundAlpha: _badgeBackgroundAlpha(type),
    borderAlpha: _badgeBorderAlpha(type),
  );
}

ToneColors profileSearchSuggestionColors(
  ColorScheme scheme,
  ProductProfileSearchMatchType type,
) {
  final usesContainer = type == ProductProfileSearchMatchType.capability;

  return toneColors(
    scheme,
    profileSearchVisualTone(type),
    backgroundAlpha: usesContainer ? 0.3 : 0.08,
    borderAlpha: 0.16,
    backgroundSource:
        usesContainer
            ? ToneBackgroundSource.container
            : ToneBackgroundSource.foreground,
  );
}

VisualTone profileSearchVisualTone(ProductProfileSearchMatchType type) {
  return switch (type) {
    ProductProfileSearchMatchType.profile ||
    ProductProfileSearchMatchType.orderWorkspace ||
    ProductProfileSearchMatchType.capability => VisualTone.primary,
    ProductProfileSearchMatchType.salesChannel => VisualTone.secondary,
    ProductProfileSearchMatchType.channelCoverageRequirement =>
      VisualTone.success,
    ProductProfileSearchMatchType.recommendation => VisualTone.danger,
  };
}

IconData profileSearchIcon(ProductProfileSearchMatchType type) {
  return switch (type) {
    ProductProfileSearchMatchType.profile => Icons.view_quilt_outlined,
    ProductProfileSearchMatchType.orderWorkspace => Icons.receipt_long_outlined,
    ProductProfileSearchMatchType.salesChannel => Icons.storefront_outlined,
    ProductProfileSearchMatchType.capability => Icons.extension_outlined,
    ProductProfileSearchMatchType.channelCoverageRequirement =>
      Icons.rule_outlined,
    ProductProfileSearchMatchType.recommendation => Icons.lightbulb_outline,
  };
}

double _badgeBackgroundAlpha(ProductProfileSearchMatchType type) {
  return switch (type) {
    ProductProfileSearchMatchType.profile ||
    ProductProfileSearchMatchType.orderWorkspace ||
    ProductProfileSearchMatchType.channelCoverageRequirement => 0.24,
    ProductProfileSearchMatchType.salesChannel => 0.28,
    ProductProfileSearchMatchType.capability => 0.18,
    ProductProfileSearchMatchType.recommendation => 0.16,
  };
}

double _badgeBorderAlpha(ProductProfileSearchMatchType type) {
  return switch (type) {
    ProductProfileSearchMatchType.capability ||
    ProductProfileSearchMatchType.recommendation => 0.14,
    _ => 0.16,
  };
}
