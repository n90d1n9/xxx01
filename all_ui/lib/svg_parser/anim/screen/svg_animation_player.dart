import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../schema/animation_definition.dart';
import '../schema/layer/animated_layer.dart';
import '../schema/layer/layer.dart';
import '../schema/shape/shape_data.dart';

class SvgAnimationPlayer extends StatefulWidget {
  final SvgAnimationDefinition animation;
  final bool autoPlay;
  final VoidCallback? onComplete;
  final ValueChanged<double>? onProgress;

  const SvgAnimationPlayer({
    Key? key,
    required this.animation,
    this.autoPlay = true,
    this.onComplete,
    this.onProgress,
  }) : super(key: key);

  @override
  State<SvgAnimationPlayer> createState() => SvgAnimationPlayerState();
}

class SvgAnimationPlayerState extends State<SvgAnimationPlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(
        milliseconds: (widget.animation.duration * 1000).round(),
      ),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.linear);

    _controller.addListener(() {
      widget.onProgress?.call(_controller.value);
    });

    if (widget.animation.loop) {
      _controller.repeat();
    } else {
      _controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onComplete?.call();
        }
      });
    }

    if (widget.autoPlay) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void play() => _controller.forward();
  void pause() => _controller.stop();
  void reset() => _controller.reset();
  void stop() {
    _controller.stop();
    _controller.reset();
  }

  void seekTo(double progress) => _controller.value = progress.clamp(0.0, 1.0);
  void setSpeed(double speed) =>
      _controller.duration = Duration(
        milliseconds: ((widget.animation.duration * 1000) / speed).round(),
      );

  bool get isPlaying => _controller.isAnimating;
  double get progress => _controller.value;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _OptimizedAnimationPainter(
              animation: widget.animation,
              progress: _animation.value,
            ),
            size: widget.animation.artboardSize,
          );
        },
      ),
    );
  }
}

// ============================================================================
// OPTIMIZED PAINTER WITH CACHING
// ============================================================================

class _OptimizedAnimationPainter extends CustomPainter {
  final SvgAnimationDefinition animation;
  final double progress;

  // Cache for paths and paints
  static final Map<String, Path> _pathCache = {};
  static final Map<int, Paint> _paintCache = {};

  _OptimizedAnimationPainter({required this.animation, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final currentTime = progress * animation.duration;

    // Clip to artboard
    canvas.clipRect(Offset.zero & animation.artboardSize);

    for (var layer in animation.layers) {
      if (!layer.visible) continue;

      canvas.save();
      _paintLayer(canvas, layer, currentTime);
      canvas.restore();
    }
  }

  void _paintLayer(Canvas canvas, AnimatedLayer layer, double time) {
    // Apply transform properties
    final positionProp = layer.getProperty('transform.position');
    final rotationProp = layer.getProperty('transform.rotation');
    final scaleProp = layer.getProperty('transform.scale');
    final opacityProp = layer.getProperty('opacity');

    if (positionProp != null) {
      final pos = positionProp.interpolate(time);
      if (pos is List && pos.length >= 2) {
        canvas.translate(pos[0].toDouble(), pos[1].toDouble());
      }
    }

    if (rotationProp != null) {
      final rotation = rotationProp.interpolate(time);
      if (rotation is num) {
        canvas.rotate(rotation * math.pi / 180);
      }
    }

    if (scaleProp != null) {
      final scale = scaleProp.interpolate(time);
      if (scale is List && scale.length >= 2) {
        canvas.scale(scale[0].toDouble(), scale[1].toDouble());
      } else if (scale is num) {
        canvas.scale(scale.toDouble());
      }
    }

    final opacity =
        opacityProp != null
            ? (opacityProp.interpolate(time) as num).toDouble()
            : layer.opacity;

    // Paint layer based on type
    switch (layer.type) {
      case LayerType.shape:
        _paintShape(canvas, layer, opacity);
        break;
      case LayerType.image:
        _paintImage(canvas, layer, opacity);
        break;
      case LayerType.text:
        _paintText(canvas, layer, opacity);
        break;
      case LayerType.group:
        break;
      case LayerType.rectangle:
        // TODO: Handle this case.
        throw UnimplementedError();
      case LayerType.circle:
        // TODO: Handle this case.
        throw UnimplementedError();
      case LayerType.path:
        // TODO: Handle this case.
        throw UnimplementedError();
      case LayerType.particle:
        // TODO: Handle this case.
        throw UnimplementedError();
      case LayerType.ellipse:
        // TODO: Handle this case.
        throw UnimplementedError();
      case LayerType.bone:
        // TODO: Handle this case.
        throw UnimplementedError();
    }

    // Paint children recursively
    for (var child in layer.children) {
      canvas.save();
      _paintLayer(canvas, child, time);
      canvas.restore();
    }
  }

  void _paintShape(Canvas canvas, AnimatedLayer layer, double opacity) {
    final shapeData = layer.shapeData;
    if (shapeData == null) return;

    final cacheKey = '${layer.id}_${shapeData.shapeType}';
    Path? path = _pathCache[cacheKey];

    if (path == null) {
      path = Path();
      switch (shapeData.shapeType) {
        case ShapeType.rectangle:
          final rect = Rect.fromLTWH(
            shapeData.x,
            shapeData.y,
            shapeData.width,
            shapeData.height,
          );
          if (shapeData.cornerRadius > 0) {
            path.addRRect(
              RRect.fromRectAndRadius(
                rect,
                Radius.circular(shapeData.cornerRadius),
              ),
            );
          } else {
            path.addRect(rect);
          }
          break;

        case ShapeType.circle:
          path.addOval(
            Rect.fromCircle(
              center: Offset(
                shapeData.x + shapeData.width / 2,
                shapeData.y + shapeData.height / 2,
              ),
              radius: shapeData.width / 2,
            ),
          );
          break;

        case ShapeType.ellipse:
          path.addOval(
            Rect.fromLTWH(
              shapeData.x,
              shapeData.y,
              shapeData.width,
              shapeData.height,
            ),
          );
          break;

        case ShapeType.path:
          if (shapeData.pathData != null) {
            path = _parseSvgPath(shapeData.pathData!);
          }
          break;
      }
      _pathCache[cacheKey] = path;
    }

    // Fill
    final fillColor = shapeData.fillColor;
    final fillPaint = _getPaint(fillColor.value, PaintingStyle.fill, opacity);
    canvas.drawPath(path, fillPaint);

    // Stroke
    if (shapeData.strokeColor != null) {
      final strokePaint = _getPaint(
        shapeData.strokeColor!.value,
        PaintingStyle.stroke,
        opacity,
      )..strokeWidth = shapeData.strokeWidth;
      canvas.drawPath(path, strokePaint);
    }
  }

  void _paintImage(Canvas canvas, AnimatedLayer layer, double opacity) {
    final imageData = layer.imageData;
    if (imageData == null) return;

    // Placeholder for image
    final rect = Rect.fromLTWH(
      imageData.x,
      imageData.y,
      imageData.width,
      imageData.height,
    );

    final paint = _getPaint(
      Colors.grey.withOpacity(0.3).value,
      PaintingStyle.fill,
      opacity,
    );
    canvas.drawRect(rect, paint);
  }

  void _paintText(Canvas canvas, AnimatedLayer layer, double opacity) {
    final textData = layer.textData;
    if (textData == null) return;

    final textSpan = TextSpan(
      text: textData.text,
      style: TextStyle(
        fontSize: textData.fontSize,
        fontFamily: textData.fontFamily,
        fontWeight: textData.fontWeight,
        color: textData.color.withOpacity(opacity),
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: textData.align,
    );

    textPainter.layout();
    textPainter.paint(canvas, Offset.zero);
  }

  Paint _getPaint(int colorValue, PaintingStyle style, double opacity) {
    final key = colorValue ^ style.hashCode ^ opacity.hashCode;

    return _paintCache.putIfAbsent(key, () {
      final color = Color(colorValue);
      return Paint()
        ..color = color.withOpacity(color.opacity * opacity)
        ..style = style
        ..isAntiAlias = true;
    });
  }

  Path _parseSvgPath(String pathData) {
    final path = Path();
    // Simple path parser - extend as needed
    return path;
  }

  @override
  bool shouldRepaint(_OptimizedAnimationPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
