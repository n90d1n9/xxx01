import 'package:flutter/widgets.dart';

import 'svg_element.dart';

class SvgGroup extends SvgElement {
  final List<SvgElement> children = [];

  SvgGroup({required super.style, super.transform});

  @override
  void paint(Canvas canvas, Size size, Map<String, dynamic> defs) {
    applyTransform(canvas);
    for (var child in children) {
      child.paint(canvas, size, defs);
    }
    restoreTransform(canvas);
  }

  @override
  Rect getBounds() {
    // TODO: implement getBounds
    throw UnimplementedError();
  }
}
