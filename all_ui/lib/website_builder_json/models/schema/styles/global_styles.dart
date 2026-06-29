import 'styles.dart';

class GlobalStyles {
  final Map<String, Styles>? presets; // Named style presets
  final Map<String, String>? colorPalette;
  final Map<String, String>? typography; // Typography scale
  final Map<String, String>? spacing; // Spacing scale
  final Styles? defaultStyles;
  final Map<String, dynamic>? cssVariables;

  GlobalStyles({
    this.presets,
    this.colorPalette,
    this.typography,
    this.spacing,
    this.defaultStyles,
    this.cssVariables,
  });

  factory GlobalStyles.fromJson(Map<String, dynamic> json) {
    return GlobalStyles(
      presets:
          json['presets'] != null
              ? (json['presets'] as Map<String, dynamic>).map(
                (k, v) =>
                    MapEntry(k, Styles.fromJson(v as Map<String, dynamic>)),
              )
              : null,
      colorPalette:
          json['colorPalette'] != null
              ? Map<String, String>.from(json['colorPalette'] as Map)
              : null,
      typography:
          json['typography'] != null
              ? Map<String, String>.from(json['typography'] as Map)
              : null,
      spacing:
          json['spacing'] != null
              ? Map<String, String>.from(json['spacing'] as Map)
              : null,
      defaultStyles:
          json['defaultStyles'] != null
              ? Styles.fromJson(json['defaultStyles'] as Map<String, dynamic>)
              : null,
      cssVariables: json['cssVariables'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (presets != null)
      'presets': presets!.map((k, v) => MapEntry(k, v.toJson())),
    if (colorPalette != null) 'colorPalette': colorPalette,
    if (typography != null) 'typography': typography,
    if (spacing != null) 'spacing': spacing,
    if (defaultStyles != null) 'defaultStyles': defaultStyles!.toJson(),
    if (cssVariables != null) 'cssVariables': cssVariables,
  };
}
