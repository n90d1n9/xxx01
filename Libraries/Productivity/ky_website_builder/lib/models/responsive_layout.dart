// Responsive Design Model
import 'package:flutter/widgets.dart';

import 'enums.dart';

class ResponsiveLayout {
  Map<ResponsiveBreakpoint, Offset> positions;
  Map<ResponsiveBreakpoint, Size> sizes;
  Map<ResponsiveBreakpoint, bool> visibility;

  ResponsiveLayout({
    required this.positions,
    required this.sizes,
    required this.visibility,
  });

  Map<String, dynamic> toJson() => {
    'positions': positions.map(
      (k, v) => MapEntry(k.toString(), {'dx': v.dx, 'dy': v.dy}),
    ),
    'sizes': sizes.map(
      (k, v) => MapEntry(k.toString(), {'width': v.width, 'height': v.height}),
    ),
    'visibility': visibility.map((k, v) => MapEntry(k.toString(), v)),
  };

  factory ResponsiveLayout.fromJson(Map<String, dynamic> json) {
    return ResponsiveLayout(
      positions: (json['positions'] as Map).map(
        (k, v) => MapEntry(
          ResponsiveBreakpoint.values.firstWhere((e) => e.toString() == k),
          Offset(v['dx'], v['dy']),
        ),
      ),
      sizes: (json['sizes'] as Map).map(
        (k, v) => MapEntry(
          ResponsiveBreakpoint.values.firstWhere((e) => e.toString() == k),
          Size(v['width'], v['height']),
        ),
      ),
      visibility: (json['visibility'] as Map).map(
        (k, v) => MapEntry(
          ResponsiveBreakpoint.values.firstWhere((e) => e.toString() == k),
          v,
        ),
      ),
    );
  }
}
