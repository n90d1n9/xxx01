import 'package:flutter/material.dart';

import '../model/anim/animated_property.dart';
import '../model/anim/easing_type.dart';
import '../model/anim/keyframe.dart';
import '../schema/animation_definition.dart';
import '../schema/layer/animated_layer.dart';
import '../schema/layer/layer.dart';
import '../schema/shape/shape_data.dart';

class AnimationBuilder {
  /// Fade in/out animation
  static SvgAnimationDefinition fade({
    required String id,
    String name = 'Fade',
    double duration = 1.0,
    bool fadeIn = true,
    Size? artboardSize,
    ShapeData? shape,
  }) {
    return SvgAnimationDefinition(
      id: id,
      name: name,
      duration: duration,
      artboardSize: artboardSize ?? const Size(200, 200),
      layers: [
        AnimatedLayer(
          id: '${id}_layer',
          name: 'Fade Layer',
          type: LayerType.shape,
          shapeData:
              shape ??
              ShapeData(
                shapeType: ShapeType.rectangle,
                width: 100,
                height: 100,
                fillColor: Colors.blue,
              ),
          properties: [
            AnimatedProperty(
              property: 'opacity',
              keyframes: [
                Keyframe(time: 0, value: fadeIn ? 0.0 : 1.0),
                Keyframe(time: duration, value: fadeIn ? 1.0 : 0.0),
              ],
              easing: EasingType.easeInOut,
            ),
          ],
        ),
      ],
    );
  }

  /// Slide animation
  static SvgAnimationDefinition slide({
    required String id,
    String name = 'Slide',
    double duration = 1.0,
    Offset from = Offset.zero,
    Offset to = const Offset(100, 0),
    Size? artboardSize,
    ShapeData? shape,
  }) {
    return SvgAnimationDefinition(
      id: id,
      name: name,
      duration: duration,
      artboardSize: artboardSize ?? const Size(300, 200),
      layers: [
        AnimatedLayer(
          id: '${id}_layer',
          name: 'Slide Layer',
          type: LayerType.shape,
          shapeData:
              shape ??
              ShapeData(
                shapeType: ShapeType.circle,
                width: 50,
                height: 50,
                fillColor: Colors.red,
              ),
          properties: [
            AnimatedProperty(
              property: 'transform.position',
              keyframes: [
                Keyframe(time: 0, value: [from.dx, from.dy]),
                Keyframe(time: duration, value: [to.dx, to.dy]),
              ],
              easing: EasingType.easeInOut,
            ),
          ],
        ),
      ],
    );
  }

  /// Rotation animation
  static SvgAnimationDefinition rotate({
    required String id,
    String name = 'Rotate',
    double duration = 2.0,
    double startAngle = 0,
    double endAngle = 360,
    bool loop = true,
    Size? artboardSize,
    ShapeData? shape,
  }) {
    return SvgAnimationDefinition(
      id: id,
      name: name,
      duration: duration,
      loop: loop,
      artboardSize: artboardSize ?? const Size(200, 200),
      layers: [
        AnimatedLayer(
          id: '${id}_layer',
          name: 'Rotate Layer',
          type: LayerType.shape,
          shapeData:
              shape ??
              ShapeData(
                shapeType: ShapeType.rectangle,
                x: 50,
                y: 50,
                width: 100,
                height: 100,
                fillColor: Colors.green,
              ),
          properties: [
            AnimatedProperty(
              property: 'transform.position',
              keyframes: [
                Keyframe(time: 0, value: [100.0, 100.0]),
              ],
            ),
            AnimatedProperty(
              property: 'transform.rotation',
              keyframes: [
                Keyframe(time: 0, value: startAngle),
                Keyframe(time: duration, value: endAngle),
              ],
              easing: EasingType.linear,
            ),
          ],
        ),
      ],
    );
  }

  /// Scale animation
  static SvgAnimationDefinition scale({
    required String id,
    String name = 'Scale',
    double duration = 1.0,
    double fromScale = 0.0,
    double toScale = 1.0,
    Size? artboardSize,
    ShapeData? shape,
  }) {
    return SvgAnimationDefinition(
      id: id,
      name: name,
      duration: duration,
      artboardSize: artboardSize ?? const Size(200, 200),
      layers: [
        AnimatedLayer(
          id: '${id}_layer',
          name: 'Scale Layer',
          type: LayerType.shape,
          shapeData:
              shape ??
              ShapeData(
                shapeType: ShapeType.circle,
                x: 75,
                y: 75,
                width: 50,
                height: 50,
                fillColor: Colors.purple,
              ),
          properties: [
            AnimatedProperty(
              property: 'transform.position',
              keyframes: [
                Keyframe(time: 0, value: [100.0, 100.0]),
              ],
            ),
            AnimatedProperty(
              property: 'transform.scale',
              keyframes: [
                Keyframe(time: 0, value: [fromScale, fromScale]),
                Keyframe(time: duration, value: [toScale, toScale]),
              ],
              easing: EasingType.easeOutCubic,
            ),
          ],
        ),
      ],
    );
  }

  /// Bounce animation
  static SvgAnimationDefinition bounce({
    required String id,
    String name = 'Bounce',
    double duration = 1.0,
    double height = 100,
    bool loop = true,
    Size? artboardSize,
    ShapeData? shape,
  }) {
    return SvgAnimationDefinition(
      id: id,
      name: name,
      duration: duration,
      loop: loop,
      artboardSize: artboardSize ?? const Size(200, 300),
      layers: [
        AnimatedLayer(
          id: '${id}_layer',
          name: 'Bounce Layer',
          type: LayerType.shape,
          shapeData:
              shape ??
              ShapeData(
                shapeType: ShapeType.circle,
                width: 50,
                height: 50,
                fillColor: Colors.orange,
              ),
          properties: [
            AnimatedProperty(
              property: 'transform.position',
              keyframes: [
                Keyframe(time: 0, value: [100.0, 250.0]),
                Keyframe(time: duration * 0.5, value: [100.0, 250.0 - height]),
                Keyframe(time: duration, value: [100.0, 250.0]),
              ],
              easing: EasingType.easeInOut,
            ),
          ],
        ),
      ],
    );
  }

  /// Pulse animation
  static SvgAnimationDefinition pulse({
    required String id,
    String name = 'Pulse',
    double duration = 1.0,
    double minScale = 0.8,
    double maxScale = 1.2,
    bool loop = true,
    Size? artboardSize,
    ShapeData? shape,
  }) {
    return SvgAnimationDefinition(
      id: id,
      name: name,
      duration: duration,
      loop: loop,
      artboardSize: artboardSize ?? const Size(200, 200),
      layers: [
        AnimatedLayer(
          id: '${id}_layer',
          name: 'Pulse Layer',
          type: LayerType.shape,
          shapeData:
              shape ??
              ShapeData(
                shapeType: ShapeType.circle,
                x: 75,
                y: 75,
                width: 50,
                height: 50,
                fillColor: Colors.pink,
              ),
          properties: [
            AnimatedProperty(
              property: 'transform.position',
              keyframes: [
                Keyframe(time: 0, value: [100.0, 100.0]),
              ],
            ),
            AnimatedProperty(
              property: 'transform.scale',
              keyframes: [
                Keyframe(time: 0, value: [minScale, minScale]),
                Keyframe(time: duration * 0.5, value: [maxScale, maxScale]),
                Keyframe(time: duration, value: [minScale, minScale]),
              ],
              easing: EasingType.easeInOut,
            ),
          ],
        ),
      ],
    );
  }

  /// Loading spinner
  static SvgAnimationDefinition spinner({
    required String id,
    String name = 'Spinner',
    double duration = 1.0,
    Size? artboardSize,
  }) {
    return SvgAnimationDefinition(
      id: id,
      name: name,
      duration: duration,
      loop: true,
      artboardSize: artboardSize ?? const Size(100, 100),
      layers: List.generate(8, (index) {
        final angle = (index * 45.0);
        final opacity = 0.2 + (index * 0.1);

        return AnimatedLayer(
          id: '${id}_bar_$index',
          name: 'Bar $index',
          type: LayerType.shape,
          shapeData: ShapeData(
            shapeType: ShapeType.rectangle,
            x: 45,
            y: 10,
            width: 10,
            height: 30,
            cornerRadius: 5,
            fillColor: Colors.blue,
          ),
          properties: [
            AnimatedProperty(
              property: 'transform.position',
              keyframes: [
                Keyframe(time: 0, value: [50.0, 50.0]),
              ],
            ),
            AnimatedProperty(
              property: 'transform.rotation',
              keyframes: [Keyframe(time: 0, value: angle)],
            ),
            AnimatedProperty(
              property: 'opacity',
              keyframes: [
                Keyframe(time: 0, value: opacity),
                Keyframe(time: duration, value: 1.0),
              ],
              easing: EasingType.linear,
            ),
          ],
        );
      }),
    );
  }
}
