import 'dart:ui';

StrokeCap parseLineCap(String? value) {
  switch (value?.toLowerCase()) {
    case 'round':
      return StrokeCap.round;
    case 'square':
      return StrokeCap.square;
    default:
      return StrokeCap.butt;
  }
}

StrokeJoin parseLineJoin(String? value) {
  switch (value?.toLowerCase()) {
    case 'round':
      return StrokeJoin.round;
    case 'bevel':
      return StrokeJoin.bevel;
    default:
      return StrokeJoin.miter;
  }
}

PathFillType parseFillRule(String? value) {
  return value?.toLowerCase() == 'evenodd'
      ? PathFillType.evenOdd
      : PathFillType.nonZero;
}

List<double>? parseDashArray(String value) {
  final values = value.split(RegExp(r'[\s,]+'));
  return values.map((v) => double.tryParse(v) ?? 0).toList();
}

double? parseDouble(String? value) {
  if (value == null || value.isEmpty) return null;
  return double.tryParse(value.replaceAll(RegExp(r'[a-zA-Z%]'), ''));
}
