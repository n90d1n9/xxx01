// parsers/gradient_parser.dart
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import '../models/gradient_stop.dart';
import '../models/svg_linear_gradient.dart';
import '../models/svg_radial_gradient.dart';
import 'color_parser.dart';
import 'transform_parser.dart';

class GradientParser {
  static SvgLinearGradient parseLinearGradient(XmlElement element) {
    final stops = <GradientStop>[];

    for (var stop in element.findElements('stop')) {
      final offset =
          _parseDouble(stop.getAttribute('offset')?.replaceAll('%', '')) ?? 0.0;
      final stopColor = stop.getAttribute('stop-color');
      final stopOpacity =
          _parseDouble(stop.getAttribute('stop-opacity')) ?? 1.0;

      final style = stop.getAttribute('style');
      Color? color;

      if (style != null) {
        final colorMatch = RegExp(r'stop-color:\s*([^;]+)').firstMatch(style);
        if (colorMatch != null) {
          color = ColorParser.parse(colorMatch.group(1)!.trim());
        }
      }

      color ??= ColorParser.parse(stopColor);

      if (color != null) {
        stops.add(
          GradientStop(
            offset: offset / 100.0,
            color: color.withOpacity(color.opacity * stopOpacity),
          ),
        );
      }
    }

    return SvgLinearGradient(
      id: element.getAttribute('id') ?? '',
      x1: _parsePercentage(element.getAttribute('x1')) ?? 0.0,
      y1: _parsePercentage(element.getAttribute('y1')) ?? 0.0,
      x2: _parsePercentage(element.getAttribute('x2')) ?? 1.0,
      y2: _parsePercentage(element.getAttribute('y2')) ?? 0.0,
      stops: stops,
      gradientUnits:
          element.getAttribute('gradientUnits') ?? 'objectBoundingBox',
      gradientTransform: TransformParser.parse(
        element.getAttribute('gradientTransform'),
      ),
    );
  }

  static SvgRadialGradient parseRadialGradient(XmlElement element) {
    final stops = <GradientStop>[];

    for (var stop in element.findElements('stop')) {
      final offset =
          _parseDouble(stop.getAttribute('offset')?.replaceAll('%', '')) ?? 0.0;
      final stopColor = stop.getAttribute('stop-color');
      final stopOpacity =
          _parseDouble(stop.getAttribute('stop-opacity')) ?? 1.0;

      final style = stop.getAttribute('style');
      Color? color;

      if (style != null) {
        final colorMatch = RegExp(r'stop-color:\s*([^;]+)').firstMatch(style);
        if (colorMatch != null) {
          color = ColorParser.parse(colorMatch.group(1)!.trim());
        }
      }

      color ??= ColorParser.parse(stopColor);

      if (color != null) {
        stops.add(
          GradientStop(
            offset: offset / 100.0,
            color: color.withOpacity(color.opacity * stopOpacity),
          ),
        );
      }
    }

    return SvgRadialGradient(
      id: element.getAttribute('id') ?? '',
      cx: _parsePercentage(element.getAttribute('cx')) ?? 0.5,
      cy: _parsePercentage(element.getAttribute('cy')) ?? 0.5,
      r: _parsePercentage(element.getAttribute('r')) ?? 0.5,
      fx: _parsePercentage(element.getAttribute('fx')),
      fy: _parsePercentage(element.getAttribute('fy')),
      stops: stops,
      gradientUnits:
          element.getAttribute('gradientUnits') ?? 'objectBoundingBox',
      gradientTransform: TransformParser.parse(
        element.getAttribute('gradientTransform'),
      ),
    );
  }

  static double? _parsePercentage(String? value) {
    if (value == null) return null;
    if (value.endsWith('%')) {
      final number = double.tryParse(value.replaceAll('%', ''));
      return number != null ? number / 100.0 : null;
    }
    return double.tryParse(value);
  }

  static double? _parseDouble(String? value) {
    if (value == null || value.isEmpty) return null;
    return double.tryParse(value.replaceAll(RegExp(r'[a-zA-Z%]'), ''));
  }
}
