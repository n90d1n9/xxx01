import '../layout/positioning.dart';
import '../layout/transform.dart';
import '../layout/transition.dart';
import 'background.dart';
import 'border.dart';
import 'dimensions.dart';
import 'filter.dart';
import 'shadow.dart';
import 'spacing.dart';
import 'typography.dart';

/// Comprehensive styling model
class Styles {
  final Dimensions? dimensions;
  final Spacing? margin;
  final Spacing? padding;
  final Background? background;
  final Border? border;
  final Typography? typography;
  final Shadow? shadow;
  final Transform? transform;
  final String? display;
  final String? position;
  final Positioning? positioning; // top, left, right, bottom
  final String? overflow;
  final String? cursor;
  final String? opacity;
  final String? zIndex;
  final Transition? transition;
  final Filter? filter;
  final Map<String, dynamic>? customCss; // For any custom CSS properties

  Styles({
    this.dimensions,
    this.margin,
    this.padding,
    this.background,
    this.border,
    this.typography,
    this.shadow,
    this.transform,
    this.display,
    this.position,
    this.positioning,
    this.overflow,
    this.cursor,
    this.opacity,
    this.zIndex,
    this.transition,
    this.filter,
    this.customCss,
  });

  factory Styles.fromJson(Map<String, dynamic> json) {
    return Styles(
      dimensions:
          json['dimensions'] != null
              ? Dimensions.fromJson(json['dimensions'] as Map<String, dynamic>)
              : null,
      margin:
          json['margin'] != null
              ? Spacing.fromJson(json['margin'] as Map<String, dynamic>)
              : null,
      padding:
          json['padding'] != null
              ? Spacing.fromJson(json['padding'] as Map<String, dynamic>)
              : null,
      background:
          json['background'] != null
              ? Background.fromJson(json['background'] as Map<String, dynamic>)
              : null,
      border:
          json['border'] != null
              ? Border.fromJson(json['border'] as Map<String, dynamic>)
              : null,
      typography:
          json['typography'] != null
              ? Typography.fromJson(json['typography'] as Map<String, dynamic>)
              : null,
      shadow:
          json['shadow'] != null
              ? Shadow.fromJson(json['shadow'] as Map<String, dynamic>)
              : null,
      transform:
          json['transform'] != null
              ? Transform.fromJson(json['transform'] as Map<String, dynamic>)
              : null,
      display: json['display'] as String?,
      position: json['position'] as String?,
      positioning:
          json['positioning'] != null
              ? Positioning.fromJson(
                json['positioning'] as Map<String, dynamic>,
              )
              : null,
      overflow: json['overflow'] as String?,
      cursor: json['cursor'] as String?,
      opacity: json['opacity'] as String?,
      zIndex: json['zIndex'] as String?,
      transition:
          json['transition'] != null
              ? Transition.fromJson(json['transition'] as Map<String, dynamic>)
              : null,
      filter:
          json['filter'] != null
              ? Filter.fromJson(json['filter'] as Map<String, dynamic>)
              : null,
      customCss: json['customCss'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (dimensions != null) 'dimensions': dimensions!.toJson(),
    if (margin != null) 'margin': margin!.toJson(),
    if (padding != null) 'padding': padding!.toJson(),
    if (background != null) 'background': background!.toJson(),
    if (border != null) 'border': border!.toJson(),
    if (typography != null) 'typography': typography!.toJson(),
    if (shadow != null) 'shadow': shadow!.toJson(),
    if (transform != null) 'transform': transform!.toJson(),
    if (display != null) 'display': display,
    if (position != null) 'position': position,
    if (positioning != null) 'positioning': positioning!.toJson(),
    if (overflow != null) 'overflow': overflow,
    if (cursor != null) 'cursor': cursor,
    if (opacity != null) 'opacity': opacity,
    if (zIndex != null) 'zIndex': zIndex,
    if (transition != null) 'transition': transition!.toJson(),
    if (filter != null) 'filter': filter!.toJson(),
    if (customCss != null) 'customCss': customCss,
  };
}
