import 'dart:convert';

import 'website_builder_component_presets.dart';

class WebsiteBuilderContentPresetLibrary {
  static const schemaId = 'ky.website_builder.content_presets.v1';

  final String kindKey;
  final String kindLabel;
  final List<WebsiteBuilderComponentPreset> presets;

  WebsiteBuilderContentPresetLibrary({
    required this.kindKey,
    required this.kindLabel,
    required List<WebsiteBuilderComponentPreset> presets,
  }) : presets = List.unmodifiable(
         presets.map((preset) => preset.copyWith(isCustom: true)),
       );

  int get presetCount => presets.length;

  Map<String, dynamic> toJson() {
    return {
      'schema': schemaId,
      'version': '1.0',
      'kindKey': kindKey,
      'kindLabel': kindLabel,
      'presets': presets.map((preset) => preset.toJson()).toList(),
    };
  }

  String toPrettyJson() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }

  factory WebsiteBuilderContentPresetLibrary.fromJson(
    Map<String, dynamic> json,
  ) {
    return WebsiteBuilderContentPresetLibrary(
      kindKey: json['kindKey'] as String? ?? '',
      kindLabel: json['kindLabel'] as String? ?? '',
      presets: [
        for (final item in json['presets'] as List? ?? const [])
          WebsiteBuilderComponentPreset.fromJson(
            Map<String, dynamic>.from(item as Map? ?? const {}),
          ),
      ],
    );
  }
}

class WebsiteBuilderContentPresetLibraryImportResult {
  final String targetKindKey;
  final String libraryKindKey;
  final int addedCount;
  final int updatedCount;
  final int skippedCount;
  final bool kindMismatch;

  const WebsiteBuilderContentPresetLibraryImportResult({
    required this.targetKindKey,
    required this.libraryKindKey,
    this.addedCount = 0,
    this.updatedCount = 0,
    this.skippedCount = 0,
    this.kindMismatch = false,
  });

  int get importedCount => addedCount + updatedCount;
  bool get didChange => importedCount > 0;
}
