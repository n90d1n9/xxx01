import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/node_card.dart';
import '../models/canvas_transform.dart';

class CanvasTransformNotifier extends StateNotifier<CanvasTransform> {
  CanvasTransformNotifier() : super(CanvasTransform());

  void pan(Offset delta) {
    state = state.copyWith(offset: state.offset + delta);
  }

  void zoom(double delta, Offset focalPoint) {
    final newScale = (state.scale + delta).clamp(0.1, 3.0);

    // Zoom towards focal point
    final offsetAdjustment = focalPoint * (newScale - state.scale) / newScale;
    state = state.copyWith(
      scale: newScale,
      offset: state.offset - offsetAdjustment,
    );
  }

  void reset() {
    state = CanvasTransform();
  }

  void setOffset(Offset targetOffset) {
    state = state.copyWith(offset: targetOffset);
  }

  void fitToScreen(Size canvasSize, List<NodeCard> nodes) {
    if (nodes.isEmpty) {
      reset();
      return;
    }

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final node in nodes) {
      minX = math.min(minX, node.position.dx);
      minY = math.min(minY, node.position.dy);
      maxX = math.max(maxX, node.position.dx);
      maxY = math.max(maxY, node.position.dy);
    }

    final contentWidth = maxX - minX + 300;
    final contentHeight = maxY - minY + 300;

    final scaleX = canvasSize.width / contentWidth;
    final scaleY = canvasSize.height / contentHeight;
    final newScale = math.min(scaleX, scaleY).clamp(0.1, 3.0);

    final centerX = (minX + maxX) / 2;
    final centerY = (minY + maxY) / 2;

    state = CanvasTransform(
      scale: newScale,
      offset: Offset(
        canvasSize.width / 2 - centerX * newScale,
        canvasSize.height / 2 - centerY * newScale,
      ),
    );
  }
}

final canvasTransformProvider =
    StateNotifierProvider<CanvasTransformNotifier, CanvasTransform>((ref) {
      return CanvasTransformNotifier();
    });
