/// Unified animation system for chart transitions.
///
/// Provides:
///  - [ChartAnimationController]: manages entrance + update animations.
///  - [ChartAnimationPreset]: named presets (grow, fade, slide, morph).
///  - [AnimatedSeriesValue]: interpolates between old and new data frames.
///  - [ChartAnimationMixin]: drop-in mixin for [State] classes.
///
/// Design principles:
///  - One [AnimationController] per chart — not one per series.
///  - Data morphing (old → new values) uses [Tween] + custom lerp,
///    so bar heights, line points and pie slices all animate smoothly
///    when the underlying data changes at runtime.
///  - Entrance animation plays once on first build.
///  - Data-change animation replays whenever the series data changes.
library chart_animation_system;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// ---------------------------------------------------------------------------
// ChartAnimationPreset
// ---------------------------------------------------------------------------

/// Named animation configuration for a chart.
class ChartAnimationPreset {
  final Duration duration;
  final Curve curve;
  final ChartAnimationType type;

  const ChartAnimationPreset({
    required this.duration,
    required this.curve,
    required this.type,
  });

  // ---- Built-ins ----

  /// Bars grow upward from the baseline (default for bar charts).
  static const ChartAnimationPreset grow = ChartAnimationPreset(
    duration: Duration(milliseconds: 600),
    curve: Curves.easeOutCubic,
    type: ChartAnimationType.grow,
  );

  /// Elements fade in from transparent (good for scatter / heatmap).
  static const ChartAnimationPreset fade = ChartAnimationPreset(
    duration: Duration(milliseconds: 500),
    curve: Curves.easeIn,
    type: ChartAnimationType.fade,
  );

  /// Line/area draws from left to right.
  static const ChartAnimationPreset draw = ChartAnimationPreset(
    duration: Duration(milliseconds: 800),
    curve: Curves.easeInOut,
    type: ChartAnimationType.draw,
  );

  /// Pie/donut sweeps the arc from 0°.
  static const ChartAnimationPreset sweep = ChartAnimationPreset(
    duration: Duration(milliseconds: 700),
    curve: Curves.easeOutBack,
    type: ChartAnimationType.sweep,
  );

  /// Data values morph from old to new when the series is updated.
  static const ChartAnimationPreset morph = ChartAnimationPreset(
    duration: Duration(milliseconds: 400),
    curve: Curves.easeInOut,
    type: ChartAnimationType.morph,
  );

  /// No animation.
  static const ChartAnimationPreset none = ChartAnimationPreset(
    duration: Duration.zero,
    curve: Curves.linear,
    type: ChartAnimationType.none,
  );

  factory ChartAnimationPreset.fromJson(Map<String, dynamic>? json) {
    if (json == null) return grow;
    final typeStr = json['type']?.toString().toLowerCase() ?? 'grow';
    final type = switch (typeStr) {
      'fade' => ChartAnimationType.fade,
      'draw' => ChartAnimationType.draw,
      'sweep' => ChartAnimationType.sweep,
      'morph' => ChartAnimationType.morph,
      'none' => ChartAnimationType.none,
      _ => ChartAnimationType.grow,
    };
    final ms = (json['duration'] as int?) ?? 600;
    return ChartAnimationPreset(
      duration: Duration(milliseconds: ms),
      curve: Curves.easeOutCubic,
      type: type,
    );
  }
}

enum ChartAnimationType { grow, fade, draw, sweep, morph, none }

// ---------------------------------------------------------------------------
// ChartAnimationController
// ---------------------------------------------------------------------------

/// Manages entrance and data-update animations for one chart.
///
/// Attach to a [StatefulWidget] and call [forward()] in `initState`.
/// Listen via [addListener] — it calls the listener on every tick.
///
/// ```dart
/// late final _anim = ChartAnimationController(vsync: this);
///
/// @override
/// void initState() {
///   super.initState();
///   _anim.forward();
///   _anim.addListener(() => setState(() {}));
/// }
///
/// // In the painter: read _anim.progress to scale bar heights etc.
/// ```
class ChartAnimationController {
  final TickerProvider vsync;
  final ChartAnimationPreset preset;

  late final AnimationController _ctrl;
  late final Animation<double> _curved;

  ChartAnimationController({
    required this.vsync,
    this.preset = ChartAnimationPreset.grow,
  }) {
    _ctrl = AnimationController(duration: preset.duration, vsync: vsync);
    _curved = CurvedAnimation(parent: _ctrl, curve: preset.curve);
  }

  /// Current animation progress [0..1].
  double get progress =>
      preset.type == ChartAnimationType.none ? 1.0 : _curved.value;

  Animation<double> get animation => _curved;
  AnimationController get controller => _ctrl;

  bool get isCompleted => _ctrl.isCompleted;

  void addListener(VoidCallback cb) => _ctrl.addListener(cb);
  void removeListener(VoidCallback cb) => _ctrl.removeListener(cb);

  /// Play the entrance animation once from the beginning.
  Future<void> forward() {
    if (preset.type == ChartAnimationType.none) return Future.value();
    _ctrl.value = 0;
    return _ctrl.forward();
  }

  /// Replay the animation (e.g., after data changes).
  Future<void> replay({Duration? delay}) async {
    if (preset.type == ChartAnimationType.none) return;
    if (delay != null) await Future.delayed(delay);
    _ctrl.value = 0;
    return _ctrl.forward();
  }

  void stop() => _ctrl.stop();
  void reset() => _ctrl.reset();

  void dispose() {
    _ctrl.dispose();
    _curved.dispose();
  }
}

// ---------------------------------------------------------------------------
// AnimatedSeriesValue — interpolates old→new data for morph animation
// ---------------------------------------------------------------------------

/// Holds the current interpolated state between [oldValues] and [newValues].
///
/// Painters read [currentValues] rather than raw data during a morph animation.
///
/// ```dart
/// final animated = AnimatedSeriesValue(
///   oldValues: previousData,
///   newValues: currentData,
/// );
///
/// // In paint():
/// final vals = animated.evaluate(animProgress);
/// for (int i = 0; i < vals.length; i++) {
///   _drawBar(i, vals[i]);
/// }
/// ```
class AnimatedSeriesValue {
  final List<double> oldValues;
  final List<double> newValues;

  const AnimatedSeriesValue({
    required this.oldValues,
    required this.newValues,
  });

  /// Interpolated values at [t] in [0..1].
  List<double> evaluate(double t) {
    final len = math.max(oldValues.length, newValues.length);
    return List.generate(len, (i) {
      final from = i < oldValues.length ? oldValues[i] : 0.0;
      final to = i < newValues.length ? newValues[i] : 0.0;
      return _lerp(from, to, t);
    });
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;
}

// ---------------------------------------------------------------------------
// PathAnimator — draws a partial Path for line/draw animation
// ---------------------------------------------------------------------------

/// Draws the first [progress] fraction of [path] onto [canvas].
///
/// Used for the "draw" animation type where a line is drawn left-to-right.
class PathAnimator {
  /// Draw [progress] (0..1) fraction of [path] using [paint].
  ///
  /// Internally uses [ui.PathMetrics] to extract a partial subpath.
  static void drawPartial(
    Canvas canvas,
    Path path,
    Paint paint,
    double progress, {
    bool reverse = false,
  }) {
    if (progress <= 0) return;
    if (progress >= 1) {
      canvas.drawPath(path, paint);
      return;
    }

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      final len = metric.length * progress;
      final partial = metric.extractPath(0, len);
      canvas.drawPath(partial, paint);
    }
  }
}

// ---------------------------------------------------------------------------
// SweepAnimator — for pie / donut / gauge entrance
// ---------------------------------------------------------------------------

/// Constrains an arc sweep to [progress] * fullSweep.
class SweepAnimator {
  /// Returns the sweep angle for [progress] of [fullSweepRadians].
  static double sweepAngle(double progress, double fullSweepRadians) {
    return fullSweepRadians * progress.clamp(0.0, 1.0);
  }
}

// ---------------------------------------------------------------------------
// ChartAnimationMixin — drop-in for State<T> with TickerProviderStateMixin
// ---------------------------------------------------------------------------

/// Mixin for [State] classes that adds one-line chart animation.
///
/// ```dart
/// class _BarChartState extends State<BarChartWidget>
///     with TickerProviderStateMixin, ChartAnimationMixin {
///
///   @override
///   ChartAnimationPreset get animPreset => ChartAnimationPreset.grow;
///
///   @override
///   void initState() {
///     super.initState();
///     initAnimation();   // sets up controller + listener
///   }
///
///   @override
///   void dispose() {
///     disposeAnimation();
///     super.dispose();
///   }
/// }
/// ```
mixin ChartAnimationMixin<T extends StatefulWidget> on State<T>
    implements TickerProvider {
  late ChartAnimationController _chartAnimCtrl;

  /// Override to use a different preset.
  ChartAnimationPreset get animPreset => ChartAnimationPreset.grow;

  /// The current animation progress [0..1] — read this in painters.
  double get animProgress => _chartAnimCtrl.progress;

  Animation<double> get chartAnimation => _chartAnimCtrl.animation;

  void initAnimation() {
    _chartAnimCtrl = ChartAnimationController(vsync: this, preset: animPreset);
    _chartAnimCtrl.addListener(() {
      if (mounted) setState(() {});
    });
    _chartAnimCtrl.forward();
  }

  void replayAnimation() => _chartAnimCtrl.replay();

  void disposeAnimation() => _chartAnimCtrl.dispose();
}

// ---------------------------------------------------------------------------
// StaggeredAnimationBuilder — staggers multiple series
// ---------------------------------------------------------------------------

/// Builds a list of [Animation<double>] values where each series starts
/// [staggerMs] milliseconds after the previous, creating a cascade effect.
///
/// ```dart
/// final animations = StaggeredAnimationBuilder.build(
///   controller: animCtrl,
///   seriesCount: 3,
///   staggerMs: 80,
///   curve: Curves.easeOutCubic,
/// );
///
/// // In paint():
/// for (int s = 0; s < series.length; s++) {
///   final progress = animations[s].value;
///   _drawSeries(s, progress);
/// }
/// ```
class StaggeredAnimationBuilder {
  static List<Animation<double>> build({
    required AnimationController controller,
    required int seriesCount,
    int staggerMs = 60,
    Curve curve = Curves.easeOutCubic,
  }) {
    if (seriesCount == 0) return [];
    final totalMs = controller.duration?.inMilliseconds ?? 600;
    final stepFrac = staggerMs / totalMs;

    return List.generate(seriesCount, (i) {
      final start = (i * stepFrac).clamp(0.0, 0.8);
      final end = (start + (1.0 - start * 0.3)).clamp(start + 0.1, 1.0);
      return CurvedAnimation(
        parent: controller,
        curve: Interval(start, end, curve: curve),
      );
    });
  }
}
