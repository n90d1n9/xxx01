import 'package:flutter/material.dart';
import 'package:ky_builder_shared/ky_builder_shared.dart';

import 'website_builder_snapshot_import_preview.dart';

/// Builds segmented selector options for shared snapshot import modes.
List<KyBuilderSegmentOption<WebsiteBuilderSnapshotImportMode>>
websiteBuilderSnapshotImportModeOptions() {
  return [
    for (final mode in WebsiteBuilderSnapshotImportMode.values)
      KyBuilderSegmentOption(
        value: mode,
        label: mode.label,
        icon: websiteBuilderSnapshotImportModeIcon(mode),
      ),
  ];
}

/// Resolves the icon used to represent each shared snapshot import mode.
IconData websiteBuilderSnapshotImportModeIcon(
  WebsiteBuilderSnapshotImportMode mode,
) {
  return switch (mode) {
    WebsiteBuilderSnapshotImportMode.replace => Icons.layers_clear_outlined,
    WebsiteBuilderSnapshotImportMode.append => Icons.add_to_photos_outlined,
  };
}
