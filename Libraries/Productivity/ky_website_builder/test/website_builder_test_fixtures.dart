import 'dart:ui';

import 'package:ky_website_builder/ky_website_builder.dart';

/// Deterministic component id sequence for website builder tests.
class WebsiteBuilderTestIdSequence {
  final String prefix;
  int _next = 0;

  WebsiteBuilderTestIdSequence({this.prefix = 'component'});

  String next() => '${prefix}_${++_next}';
}

/// Creates a website builder controller with deterministic component ids.
WebsiteBuilderController websiteBuilderTestController({
  String projectId = 'website-builder-project',
  String projectName = 'Untitled Website',
  BuilderCanvasConfig? canvasConfig,
  List<BuilderComponentGeometry> components = const [],
  List<WebsiteBuilderComponentPreset> customContentPresets = const [],
  String idPrefix = 'component',
}) {
  final ids = WebsiteBuilderTestIdSequence(prefix: idPrefix);
  return WebsiteBuilderController(
    projectId: projectId,
    projectName: projectName,
    canvasConfig: canvasConfig,
    components: components,
    customContentPresets: customContentPresets,
    idFactory: ids.next,
  );
}

/// Looks up a catalog kind and fails fast when a test references a bad key.
BuilderComponentKind websiteBuilderTestKind(String key) {
  final kind = websiteBuilderCatalog.byKey(key);
  if (kind == null) {
    throw ArgumentError.value(key, 'key', 'Unknown website builder kind');
  }
  return kind;
}

/// Adds a catalog component by kind key using the real website builder API.
String addWebsiteBuilderTestComponent(
  WebsiteBuilderController controller,
  String kindKey, {
  Offset? position,
  WebsiteBuilderComponentPreset? contentPreset,
}) {
  return controller.addComponent(
    websiteBuilderTestKind(kindKey),
    position: position,
    contentPreset: contentPreset,
  );
}

/// Returns a component by id from a test controller.
BuilderComponentGeometry websiteBuilderTestComponent(
  WebsiteBuilderController controller,
  String id,
) {
  return controller.components.singleWhere((component) => component.id == id);
}

/// Returns a component z-index by id from a test controller.
int websiteBuilderTestComponentZIndex(
  WebsiteBuilderController controller,
  String id,
) {
  return websiteBuilderTestComponent(controller, id).zIndex;
}

/// Provides a button with empty and unsafe content for health/export tests.
const websiteBuilderUnsafeButtonFixture = BuilderComponentGeometry(
  id: 'button-1',
  kindKey: 'button',
  position: Offset(20, 40),
  size: Size(160, 52),
  properties: {'label': '', 'href': 'javascript:alert(1)'},
);

/// Provides an image missing required content for health tests.
const websiteBuilderEmptyImageFixture = BuilderComponentGeometry(
  id: 'image-1',
  kindKey: 'image',
  position: Offset(20, 120),
  size: Size(220, 160),
  properties: {'imageUrl': '', 'altText': ''},
);

/// Provides a shared snapshot with one mappable legacy kind and one unknown kind.
const websiteBuilderLegacySharedSnapshotFixture = BuilderSharedSnapshot(
  id: 'layout-1',
  name: 'Register Layout',
  canvasConfig: BuilderCanvasConfig(),
  selectedComponentId: 'image_1',
  components: [
    BuilderComponentGeometry(
      id: 'image_1',
      kindKey: 'image_holder',
      position: Offset(20, 40),
      size: Size(220, 160),
    ),
    BuilderComponentGeometry(
      id: 'legacy_1',
      kindKey: 'legacy_widget',
      position: Offset(260, 40),
      size: Size(180, 120),
    ),
  ],
);

/// Creates a reusable custom button preset for preset-library tests.
WebsiteBuilderComponentPreset websiteBuilderQuoteButtonPreset({
  String id = 'custom_button_quote',
  String label = 'Quote CTA',
  Map<String, String> properties = const {
    'label': 'Request quote',
    'href': '/quote',
  },
}) {
  return WebsiteBuilderComponentPreset(
    id: id,
    kindKey: 'button',
    label: label,
    description: 'Reusable quote action.',
    properties: properties,
    isCustom: true,
  );
}
