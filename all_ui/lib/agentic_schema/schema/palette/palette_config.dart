import 'palette_section.dart';

class PaletteConfig {
  final bool? visible;
  final String? position;
  final bool? collapsible;
  final List<PaletteSection>? sections;

  PaletteConfig({
    this.visible = true,
    this.position = 'left',
    this.collapsible = true,
    this.sections,
  });

  factory PaletteConfig.fromJson(Map<String, dynamic> json) {
    return PaletteConfig(
      visible: json['visible'] as bool?,
      position: json['position'] as String?,
      collapsible: json['collapsible'] as bool?,
      sections: json['sections'] != null
          ? (json['sections'] as List)
                .map((e) => PaletteSection.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (visible != null) 'visible': visible,
      if (position != null) 'position': position,
      if (collapsible != null) 'collapsible': collapsible,
      if (sections != null)
        'sections': sections!.map((e) => e.toJson()).toList(),
    };
  }
}
