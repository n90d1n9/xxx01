import '../styles/styles.dart';

class NavigationStyle {
  final String layout; // horizontal, vertical, dropdown
  final Styles? itemStyles;
  final Styles? activeItemStyles;
  final Styles? containerStyles;

  NavigationStyle({
    required this.layout,
    this.itemStyles,
    this.activeItemStyles,
    this.containerStyles,
  });

  factory NavigationStyle.fromJson(Map<String, dynamic> json) {
    return NavigationStyle(
      layout: json['layout'] as String,
      itemStyles:
          json['itemStyles'] != null
              ? Styles.fromJson(json['itemStyles'] as Map<String, dynamic>)
              : null,
      activeItemStyles:
          json['activeItemStyles'] != null
              ? Styles.fromJson(
                json['activeItemStyles'] as Map<String, dynamic>,
              )
              : null,
      containerStyles:
          json['containerStyles'] != null
              ? Styles.fromJson(json['containerStyles'] as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'layout': layout,
    if (itemStyles != null) 'itemStyles': itemStyles!.toJson(),
    if (activeItemStyles != null)
      'activeItemStyles': activeItemStyles!.toJson(),
    if (containerStyles != null) 'containerStyles': containerStyles!.toJson(),
  };
}
