import 'package:ky_builder_shared/ky_builder_shared.dart';

const websiteBuilderLayoutKindMappings = <String, String>{
  'custom_button': 'button',
  'text_label': 'text_block',
  'image_holder': 'image',
  'cart_panel': 'product_card',
  'button_grid': 'section',
  'function_panel': 'section',
};

class WebsiteBuilderSnapshotImportPreview {
  final BuilderSharedSnapshot snapshot;
  final List<WebsiteBuilderSnapshotComponentPreview> components;

  const WebsiteBuilderSnapshotImportPreview({
    required this.snapshot,
    required this.components,
  });

  String get name => snapshot.name;
  int get componentCount => components.length;
  int get nativeCount =>
      components.where((component) => component.isNative).length;
  int get mappedCount =>
      components.where((component) => component.isMapped).length;
  int get unknownCount =>
      components.where((component) => component.isUnknown).length;
  bool get hasUnknownComponents => unknownCount > 0;

  List<String> get mappedKindLabels {
    return _distinctLabels(
      components
          .where((component) => component.isMapped)
          .map(
            (component) =>
                '${component.sourceKindKey} to ${component.targetKindKey}',
          ),
    );
  }

  List<String> get unknownKindKeys {
    return _distinctLabels(
      components
          .where((component) => component.isUnknown)
          .map((component) => component.sourceKindKey),
    );
  }

  int importedCount({bool includeUnknownComponents = true}) {
    return normalizedComponents(
      includeUnknownComponents: includeUnknownComponents,
    ).length;
  }

  WebsiteBuilderSnapshotImportImpact impact({
    required int existingComponentCount,
    required WebsiteBuilderSnapshotImportOptions options,
  }) {
    final importedComponentCount = importedCount(
      includeUnknownComponents: options.includeUnknownComponents,
    );
    return WebsiteBuilderSnapshotImportImpact(
      existingComponentCount: existingComponentCount,
      importedComponentCount: importedComponentCount,
      skippedComponentCount: componentCount - importedComponentCount,
      resultComponentCount:
          options.mode == WebsiteBuilderSnapshotImportMode.append
              ? existingComponentCount + importedComponentCount
              : importedComponentCount,
      mode: options.mode,
    );
  }

  List<BuilderComponentGeometry> normalizedComponents({
    bool includeUnknownComponents = true,
  }) {
    return [
      for (final component in components)
        if (includeUnknownComponents || !component.isUnknown)
          component.geometry.copyWith(kindKey: component.targetKindKey),
    ];
  }

  factory WebsiteBuilderSnapshotImportPreview.fromSnapshot(
    BuilderSharedSnapshot snapshot, {
    BuilderComponentCatalog catalog = websiteBuilderCatalog,
  }) {
    return WebsiteBuilderSnapshotImportPreview(
      snapshot: snapshot,
      components: [
        for (final component in snapshot.components)
          WebsiteBuilderSnapshotComponentPreview.fromGeometry(
            component,
            catalog: catalog,
          ),
      ],
    );
  }
}

class WebsiteBuilderSnapshotImportOptions {
  final bool includeUnknownComponents;
  final WebsiteBuilderSnapshotImportMode mode;

  const WebsiteBuilderSnapshotImportOptions({
    this.includeUnknownComponents = true,
    this.mode = WebsiteBuilderSnapshotImportMode.replace,
  });
}

class WebsiteBuilderSnapshotImportImpact {
  final int existingComponentCount;
  final int importedComponentCount;
  final int skippedComponentCount;
  final int resultComponentCount;
  final WebsiteBuilderSnapshotImportMode mode;

  const WebsiteBuilderSnapshotImportImpact({
    required this.existingComponentCount,
    required this.importedComponentCount,
    required this.skippedComponentCount,
    required this.resultComponentCount,
    required this.mode,
  });

  bool get replacesExistingComponents {
    return mode == WebsiteBuilderSnapshotImportMode.replace &&
        existingComponentCount > 0;
  }
}

enum WebsiteBuilderSnapshotImportMode {
  replace('Replace'),
  append('Append');

  final String label;

  const WebsiteBuilderSnapshotImportMode(this.label);
}

class WebsiteBuilderSnapshotComponentPreview {
  final BuilderComponentGeometry geometry;
  final String sourceKindKey;
  final String targetKindKey;
  final bool isNative;
  final bool isMapped;

  const WebsiteBuilderSnapshotComponentPreview({
    required this.geometry,
    required this.sourceKindKey,
    required this.targetKindKey,
    required this.isNative,
    required this.isMapped,
  });

  bool get isUnknown => !isNative && !isMapped;

  factory WebsiteBuilderSnapshotComponentPreview.fromGeometry(
    BuilderComponentGeometry geometry, {
    BuilderComponentCatalog catalog = websiteBuilderCatalog,
  }) {
    final isNative = catalog.byKey(geometry.kindKey) != null;
    final mappedKindKey = websiteBuilderLayoutKindMappings[geometry.kindKey];
    final isMapped = !isNative && mappedKindKey != null;
    return WebsiteBuilderSnapshotComponentPreview(
      geometry: geometry,
      sourceKindKey: geometry.kindKey,
      targetKindKey:
          isNative ? geometry.kindKey : mappedKindKey ?? geometry.kindKey,
      isNative: isNative,
      isMapped: isMapped,
    );
  }
}

List<String> _distinctLabels(Iterable<String> labels) {
  final seen = <String>{};
  return [
    for (final label in labels)
      if (seen.add(label)) label,
  ];
}
