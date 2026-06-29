// TimelineHaptics + TimelineThemeMorph — sensory richness layer.
//
// Part 1: TimelineHaptics
//   Centralised, platform-aware haptic feedback dispatcher.
//   Every interaction type has a named method so the "feel" can be tuned
//   globally without hunting through widget code.
//
//   Interaction → feedback mapping (defaults):
//     nodeTap          → selectionClick
//     highlightTap     → mediumImpact
//     scaleBump        → lightImpact × 2 (double-tap rhythm)
//     bookmarkSave     → heavyImpact
//     swipeCard        → selectionClick
//     dragStart        → lightImpact
//     dragEnd          → selectionClick
//     playbackMilestone→ mediumImpact
//     error / blocked  → vibrate (long)
//
//   Can be disabled entirely for kiosk / accessibility modes.
//
// Part 2: TimelineThemeMorph
//   Smoothly animates the chart theme when the user toggles dark mode or
//   picks a custom colour palette at runtime.
//
//   How it works:
//     - Holds [current] and [target] ChartTheme instances.
//     - A Ticker lerps every colour field from current → target over 400ms.
//     - Publishes a [TimelineThemeMorphState] ValueNotifier that rebuilds
//       only the widgets that subscribe to it.
//     - Interpolation is done with Color.lerp(), curve = Curves.easeInOut.
//
//   Usage:
//     final morph = TimelineThemeMorph(initial: ChartTheme.light)
//       ..attach(tickerProvider);
//
//     // Toggle dark mode:
//     morph.animateTo(ChartTheme.dark);
//
//     // In build:
//     ValueListenableBuilder<ThemeMorphState>(
//       valueListenable: morph,
//       builder: (ctx, state, _) => TimelineChartV2(
//         config: config,
//         theme: state.current,
//       ),
//     )

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';

import '../chart_theme.dart';

// ===========================================================================
// PART 1 — TimelineHaptics
// ===========================================================================

// ---------------------------------------------------------------------------
// HapticLevel — controls how strong/frequent haptics fire
// ---------------------------------------------------------------------------

enum HapticLevel {
  /// Full haptics (default).
  full,

  /// Light only — selectionClick everywhere, no impacts.
  light,

  /// Disabled — no haptics (accessibility / kiosk).
  off,
}

// ---------------------------------------------------------------------------
// TimelineHaptics
// ---------------------------------------------------------------------------

class TimelineHaptics {
  HapticLevel level;

  TimelineHaptics({this.level = HapticLevel.full});

  // ── Individual interactions ───────────────────────────────────────────────

  /// Regular event node tap.
  Future<void> nodeTap() => _click();

  /// Highlight (important) event tap — stronger feedback.
  Future<void> highlightTap() => _impact(HapticFeedbackType.medium);

  /// Scale-level bump (double-tap zoom) — two rapid clicks.
  Future<void> scaleBump() async {
    await _click();
    await Future.delayed(const Duration(milliseconds: 80));
    await _click();
  }

  /// Bookmark saved — heavy confirmation.
  Future<void> bookmarkSave() => _impact(HapticFeedbackType.heavy);

  /// Swipe card dismissed.
  Future<void> swipeCard() => _click();

  /// Drag interaction started.
  Future<void> dragStart() => _impact(HapticFeedbackType.light);

  /// Drag released.
  Future<void> dragEnd() => _click();

  /// Playback cursor crosses a milestone event.
  Future<void> playbackMilestone() => _impact(HapticFeedbackType.medium);

  /// User tried to do something blocked (e.g. pan past data boundary).
  Future<void> blocked() async {
    if (level == HapticLevel.off) return;
    await HapticFeedback.vibrate();
  }

  /// Timeline export complete.
  Future<void> exportComplete() => _impact(HapticFeedbackType.heavy);

  /// Annotation dropped on canvas.
  Future<void> annotationDrop() => _impact(HapticFeedbackType.medium);

  // ── Internal ──────────────────────────────────────────────────────────────

  Future<void> _click() async {
    if (level == HapticLevel.off) return;
    await HapticFeedback.selectionClick();
  }

  Future<void> _impact(HapticFeedbackType type) async {
    if (level == HapticLevel.off) return;
    if (level == HapticLevel.light) {
      await HapticFeedback.lightImpact();
      return;
    }
    switch (type) {
      case HapticFeedbackType.light:
        await HapticFeedback.lightImpact();
      case HapticFeedbackType.medium:
        await HapticFeedback.mediumImpact();
      case HapticFeedbackType.heavy:
        await HapticFeedback.heavyImpact();
    }
  }
}

enum HapticFeedbackType { light, medium, heavy }

// ===========================================================================
// PART 2 — TimelineThemeMorph
// ===========================================================================

// ---------------------------------------------------------------------------
// ThemeMorphState
// ---------------------------------------------------------------------------

class ThemeMorphState {
  /// The live interpolated theme — use this to drive all painters.
  final ChartTheme current;

  /// Whether an animation is in progress.
  final bool isAnimating;

  const ThemeMorphState({
    required this.current,
    this.isAnimating = false,
  });
}

// ---------------------------------------------------------------------------
// TimelineThemeMorph
// ---------------------------------------------------------------------------

class TimelineThemeMorph extends ValueNotifier<ThemeMorphState> {
  ChartTheme _from;
  ChartTheme _to;
  double _t = 0; // animation progress 0..1
  double _vel = 0;
  Ticker? _ticker;
  Duration? _lastTick;

  static const double _durationSec = 0.4;
  static const Curve _curve = Curves.easeInOut;

  TimelineThemeMorph({required ChartTheme initial})
      : _from = initial,
        _to = initial,
        super(ThemeMorphState(current: initial));

  // ── Attach ────────────────────────────────────────────────────────────────

  void attach(TickerProvider vsync) {
    _ticker = vsync.createTicker(_onTick)..start();
  }

  void detach() {
    _ticker?.stop();
    _ticker?.dispose();
    _ticker = null;
  }

  // ── API ───────────────────────────────────────────────────────────────────

  /// Animate from the current theme to [target].
  void animateTo(ChartTheme target) {
    if (identical(_to, target)) return;
    // Snapshot the current interpolated state as the new "from"
    _from = value.current;
    _to = target;
    _t = 0;
    _vel = 0;
  }

  /// Snap to [target] immediately (no animation).
  void snapTo(ChartTheme target) {
    _from = target;
    _to = target;
    _t = 1;
    value = ThemeMorphState(current: target, isAnimating: false);
  }

  ChartTheme get targetTheme => _to;

  // ── Ticker ────────────────────────────────────────────────────────────────

  void _onTick(Duration elapsed) {
    if (_lastTick == null) { _lastTick = elapsed; return; }
    final dt = (elapsed - _lastTick!).inMicroseconds / 1e6;
    _lastTick = elapsed;

    if (_t >= 1.0) return;

    _t = (_t + dt / _durationSec).clamp(0.0, 1.0);
    final eased = _curve.transform(_t);
    final interpolated = _lerp(_from, _to, eased);

    value = ThemeMorphState(
      current: interpolated,
      isAnimating: _t < 1.0,
    );
  }

  // ── Colour lerp ───────────────────────────────────────────────────────────

  static ChartTheme _lerp(ChartTheme a, ChartTheme b, double t) {
    Color c(Color ac, Color bc) => Color.lerp(ac, bc, t)!;

    return ChartTheme(
      palette: t < 0.5 ? a.palette : b.palette,
      typography: t < 0.5 ? a.typography : b.typography,
      spacing: t < 0.5 ? a.spacing : b.spacing,
      backgroundColor: c(a.backgroundColor, b.backgroundColor),
      gridColor: c(a.gridColor, b.gridColor),
      axisColor: c(a.axisColor, b.axisColor),
      axisLabelColor: c(a.axisLabelColor, b.axisLabelColor),
      titleColor: c(a.titleColor, b.titleColor),
      legendTextColor: c(a.legendTextColor, b.legendTextColor),
      tooltipBackgroundColor: c(a.tooltipBackgroundColor, b.tooltipBackgroundColor),
      tooltipTextColor: c(a.tooltipTextColor, b.tooltipTextColor),
      tooltipBorderColor: c(a.tooltipBorderColor, b.tooltipBorderColor),
      crosshairColor: c(a.crosshairColor, b.crosshairColor),
    );
  }

  @override
  void dispose() {
    detach();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// TimelineThemeSwitcher — animated toggle widget
// ---------------------------------------------------------------------------

/// A pill-shaped toggle that smoothly transitions between light and dark.
///
/// ```dart
/// TimelineThemeSwitcher(
///   morph: themeMorph,
///   isDark: isDark,
///   onChanged: (dark) => setState(() => isDark = dark),
/// )
/// ```
class TimelineThemeSwitcher extends StatefulWidget {
  final TimelineThemeMorph morph;
  final bool isDark;
  final ValueChanged<bool>? onChanged;

  const TimelineThemeSwitcher({
    super.key,
    required this.morph,
    required this.isDark,
    this.onChanged,
  });

  @override
  State<TimelineThemeSwitcher> createState() => _TimelineThemeSwitcherState();
}

class _TimelineThemeSwitcherState extends State<TimelineThemeSwitcher>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _iconRotation;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: widget.isDark ? 1.0 : 0.0,
    );
    _iconRotation = Tween<double>(begin: 0, end: 0.5)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(TimelineThemeSwitcher old) {
    super.didUpdateWidget(old);
    if (old.isDark != widget.isDark) {
      widget.isDark ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final newDark = !widget.isDark;
        widget.morph.animateTo(newDark ? ChartTheme.dark : ChartTheme.light);
        widget.onChanged?.call(newDark);
        HapticFeedback.selectionClick();
      },
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          final t = _ctrl.value;
          final bg = Color.lerp(const Color(0xFFF0F0F8), const Color(0xFF1E1E2E), t)!;
          final thumbBg = Color.lerp(Colors.white, const Color(0xFF252540), t)!;
          final iconColor = Color.lerp(const Color(0xFFF59E0B), const Color(0xFF818CF8), t)!;

          return Container(
            width: 72,
            height: 36,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Sliding thumb
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 380),
                  curve: Curves.easeInOutCubic,
                  left: widget.isDark ? 36 : 0,
                  top: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: thumbBg,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: RotationTransition(
                        turns: _iconRotation,
                        child: Icon(
                          widget.isDark ? Icons.nightlight_round : Icons.wb_sunny,
                          size: 16,
                          color: iconColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TimelineThemeMorphProvider — InheritedWidget
// ---------------------------------------------------------------------------

/// Provide [TimelineThemeMorph] to the widget tree so any descendant can
/// read the live interpolated theme.
///
/// ```dart
/// TimelineThemeMorphProvider(
///   morph: themeMorph,
///   child: TimelineResponsiveShell(config: config),
/// )
/// ```
class TimelineThemeMorphProvider extends InheritedWidget {
  final TimelineThemeMorph morph;

  const TimelineThemeMorphProvider({
    super.key,
    required this.morph,
    required super.child,
  });

  static TimelineThemeMorph? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<TimelineThemeMorphProvider>()
      ?.morph;

  static TimelineThemeMorph of(BuildContext context) =>
      maybeOf(context) ??
      (throw FlutterError(
          'TimelineThemeMorphProvider not found in widget tree.'));

  @override
  bool updateShouldNotify(TimelineThemeMorphProvider old) =>
      !identical(morph, old.morph);
}

// ---------------------------------------------------------------------------
// TimelineThemeAwareBuilder — convenience builder
// ---------------------------------------------------------------------------

/// Rebuilds its [builder] whenever the morphed theme changes.
///
/// ```dart
/// TimelineThemeAwareBuilder(
///   builder: (context, theme) => TimelineChartV2(
///     config: config,
///     theme: theme,
///   ),
/// )
/// ```
class TimelineThemeAwareBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ChartTheme theme) builder;

  const TimelineThemeAwareBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final morph = TimelineThemeMorphProvider.maybeOf(context);
    if (morph == null) {
      return builder(context, ChartTheme.light);
    }
    return ValueListenableBuilder<ThemeMorphState>(
      valueListenable: morph,
      builder: (ctx, state, _) => builder(ctx, state.current),
    );
  }
}
