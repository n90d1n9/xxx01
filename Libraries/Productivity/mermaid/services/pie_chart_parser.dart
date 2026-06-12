import 'package:flutter/material.dart';

import '../models/diagram_type.dart';
import '../models/mermaid_diagram.dart';
import '../models/pie_slice.dart';
import 'base_parser.dart';

class PieChartParser implements DiagramParser {
  @override
  bool canParse(List<String> lines) {
    if (lines.isEmpty) return false;
    final firstLine = lines[0].toLowerCase();
    return firstLine.startsWith('pie');
  }

  @override
  MermaidDiagram parse(List<String> lines, String code) {
    final slices = <PieSlice>[];
    final colors = _generateColors();

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i];
      _parseSlice(line, slices, colors);
    }

    // Calculate percentages
    final slicesWithPercentages = _calculatePercentages(slices);

    return MermaidDiagram(
      type: DiagramType.pie,
      pieSlices: slicesWithPercentages,
      rawCode: code,
    );
  }

  void _parseSlice(String line, List<PieSlice> slices, List<Color> colors) {
    final patterns = [
      RegExp(r'"([^"]+)"\s*:\s*(\d+(?:\.\d+)?)'),
      RegExp(r'(\w+)\s*:\s*(\d+(?:\.\d+)?)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(line);
      if (match != null) {
        slices.add(
          PieSlice(
            label: match.group(1)!,
            value: double.parse(match.group(2)!),
            color: colors[slices.length % colors.length],
            percentage: 0, // Initialize with 0, will be calculated later
          ),
        );
        return;
      }
    }
  }

  List<PieSlice> _calculatePercentages(List<PieSlice> slices) {
    if (slices.isEmpty) return slices;

    final total = slices.fold(0.0, (sum, slice) => sum + slice.value);
    final updatedSlices = <PieSlice>[];

    for (final slice in slices) {
      final percentage = (slice.value / total * 100).round();
      updatedSlices.add(
        slice.copyWith(percentage: percentage), // Using copyWith
      );
    }

    return updatedSlices;
  }

  List<Color> _generateColors() {
    return [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.amber,
      Colors.pink,
      Colors.indigo,
      Colors.cyan,
      Colors.lightBlue,
      Colors.deepOrange,
      Colors.lightGreen,
      Colors.deepPurple,
      Colors.brown,
    ];
  }
}
