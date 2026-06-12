import '../styles/styles.dart';
import 'layout.dart';

class ResponsiveBreakpoint {
  final String minWidth; // e.g., "768px", "1024px"
  final String? maxWidth;
  final Styles? styles;
  final Layout? layout;
  final Map<String, dynamic>? props; // Override component props
  final bool? hidden;

  ResponsiveBreakpoint({
    required this.minWidth,
    this.maxWidth,
    this.styles,
    this.layout,
    this.props,
    this.hidden,
  });

  factory ResponsiveBreakpoint.fromJson(Map<String, dynamic> json) {
    return ResponsiveBreakpoint(
      minWidth: json['minWidth'] as String,
      maxWidth: json['maxWidth'] as String?,
      styles:
          json['styles'] != null
              ? Styles.fromJson(json['styles'] as Map<String, dynamic>)
              : null,
      layout:
          json['layout'] != null
              ? Layout.fromJson(json['layout'] as Map<String, dynamic>)
              : null,
      props: json['props'] as Map<String, dynamic>?,
      hidden: json['hidden'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
    'minWidth': minWidth,
    if (maxWidth != null) 'maxWidth': maxWidth,
    if (styles != null) 'styles': styles!.toJson(),
    if (layout != null) 'layout': layout!.toJson(),
    if (props != null) 'props': props,
    if (hidden != null) 'hidden': hidden,
  };
}
