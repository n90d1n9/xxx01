import 'package:flutter/material.dart';

import '../models/management_pack.dart';
import '../models/management_pack_field_group_progress.dart';

/// Shared visual tokens for product management capability surfaces.
class ProductManagementPackCapabilityVisuals {
  const ProductManagementPackCapabilityVisuals._();

  static IconData capabilityIcon(ProductManagementCapability capability) {
    return switch (capability) {
      ProductManagementCapability.catalogBasics => Icons.inventory_2_rounded,
      ProductManagementCapability.scanReadiness =>
        Icons.qr_code_scanner_rounded,
      ProductManagementCapability.stockTracking => Icons.warehouse_rounded,
      ProductManagementCapability.omniChannelReadiness => Icons.hub_rounded,
      ProductManagementCapability.expiryTracking =>
        Icons.event_available_rounded,
      ProductManagementCapability.batchTracking => Icons.fact_check_rounded,
      ProductManagementCapability.weightedInventory => Icons.scale_rounded,
      ProductManagementCapability.freshnessQueue => Icons.eco_rounded,
    };
  }

  static Color capabilityColor(
    ProductManagementCapability capability,
    ColorScheme colorScheme,
  ) {
    return switch (capability) {
      ProductManagementCapability.catalogBasics => colorScheme.primary,
      ProductManagementCapability.scanReadiness => Colors.indigo.shade600,
      ProductManagementCapability.stockTracking => Colors.teal.shade700,
      ProductManagementCapability.omniChannelReadiness => colorScheme.tertiary,
      ProductManagementCapability.expiryTracking => Colors.green.shade700,
      ProductManagementCapability.batchTracking => Colors.blueGrey.shade700,
      ProductManagementCapability.weightedInventory =>
        Colors.deepOrange.shade700,
      ProductManagementCapability.freshnessQueue => Colors.lightGreen.shade800,
    };
  }

  static Color progressColor(
    ProductManagementPackFieldGroupProgress progress,
    ColorScheme colorScheme,
  ) {
    return switch (progress.readiness) {
      ProductManagementPackFieldGroupReadiness.invalid => colorScheme.error,
      ProductManagementPackFieldGroupReadiness.ready => Colors.teal.shade700,
      ProductManagementPackFieldGroupReadiness.needsRequired =>
        colorScheme.error,
      ProductManagementPackFieldGroupReadiness.optionalOnly =>
        colorScheme.outline,
    };
  }

  static IconData progressIcon(
    ProductManagementPackFieldGroupProgress progress,
  ) {
    return switch (progress.readiness) {
      ProductManagementPackFieldGroupReadiness.invalid =>
        Icons.error_outline_rounded,
      ProductManagementPackFieldGroupReadiness.ready => Icons.verified_rounded,
      ProductManagementPackFieldGroupReadiness.needsRequired =>
        Icons.error_outline_rounded,
      ProductManagementPackFieldGroupReadiness.optionalOnly =>
        Icons.tune_rounded,
    };
  }
}
