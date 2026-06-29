import 'responsive_breakpoint.dart';

class Responsive {
  final Map<String, ResponsiveBreakpoint>? breakpoints;

  Responsive({this.breakpoints});

  factory Responsive.fromJson(Map<String, dynamic> json) {
    return Responsive(
      breakpoints:
          json['breakpoints'] != null
              ? (json['breakpoints'] as Map<String, dynamic>).map(
                (k, v) => MapEntry(
                  k,
                  ResponsiveBreakpoint.fromJson(v as Map<String, dynamic>),
                ),
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (breakpoints != null)
      'breakpoints': breakpoints!.map((k, v) => MapEntry(k, v.toJson())),
  };
}
