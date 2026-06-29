// TimelineSpotlightMode — focus lens + canvas dim for single-event deep-dive.
//
// Activates when the user double-taps a node or presses the "focus" button.
// Visual result:
//
//   ┌──────────────────────────────────────────────────────┐
//   │░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░│  ← dim overlay
//   │░░░░░░░  ╔══════╗  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░│
//   │░░░░░░░  ║ NODE ║  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░│  ← clear circle
//   │░░░░░░░  ╚══════╝  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░│     around node
//   │░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░│
//   │         ┌─────────────────────────────────────────┐ │
//   │         │ [Frosted glass panel]                   │ │  ← detail card
//   │         │  Title  •  Year  •  Category            │ │     below node
//   │         │  ██████████░░  Importance 9/10          │ │
//   │         │  Description text…                      │ │
//   │         └─────────────────────────────────────────┘ │
//   └──────────────────────────────────────────────────────┘
//
// Components:
//   SpotlightPainter        — CustomPainter: dim rect with circular cutout
//                             + radial glow ring + connecting line to panel.
//   TimelineSpotlightPanel  — Frosted glass detail card (BackdropFilter).
//   TimelineSpotlightLayer  — Stateful widget combining painter + panel.
//   TimelineSpotlightController — ValueNotifier driving open/close animation.
//
// Animation:
//   - Entry: cutout radius springs from 0 → target (spring stiffness 280).
//   - Dim opacity fades in: 0 → 0.72 over 300ms ease-out.
//   - Panel slides up from +20px offset.
//   - Exit: reverse of entry (200ms).
//
// Usage:
//   final spotCtrl = TimelineSpotlightController();
//
//   // On double-tap:
//   spotCtrl.show(event: ev, nodePosition: canvasOffset);
//
//   // In Stack:
//   TimelineSpotlightLayer(
//     controller: spotCtrl,
//     isDark: isDark,
//     onClose: spotCtrl.hide,
//     onOpenFull: () => TimelineEventSheet.show(context, event: ev),
//   )

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'timeline_event.dart';

// ---------------------------------------------------------------------------
// SpotlightState
// ---------------------------------------------------------------------------

class SpotlightState {
  final TimelineEvent? event;
  final Offset nodePosition; // canvas local coords
  final bool visible;
  final double animProgress; // 0..1

  const SpotlightState({
    this.event,
    this.nodePosition = Offset.zero,
    this.visible = false,
    this.animProgress = 0,
  });

  bool get isActive => visible || animProgress > 0;
}

// ---------------------------------------------------------------------------
// TimelineSpotlightController
// ---------------------------------------------------------------------------

class TimelineSpotlightController extends ValueNotifier<SpotlightState> {
  Ticker? _ticker;
  Duration? _lastTick;
  bool _opening = false;

  static const double _stiffness = 280;
  static const double _damping = 22;
  double _vel = 0;

  TimelineSpotlightController() : super(const SpotlightState());

  void attach(TickerProvider vsync) {
    _ticker = vsync.createTicker(_onTick)..start();
  }

  void detach() {
    _ticker?.stop();
    _ticker?.dispose();
    _ticker = null;
  }

  void show({required TimelineEvent event, required Offset nodePosition}) {
    _opening = true;
    value = SpotlightState(
      event: event,
      nodePosition: nodePosition,
      visible: true,
      animProgress: value.animProgress,
    );
  }

  void hide() {
    _opening = false;
  }

  void _onTick(Duration elapsed) {
    if (_lastTick == null) { _lastTick = elapsed; return; }
    final dt = (elapsed - _lastTick!).inMicroseconds / 1e6;
    _lastTick = elapsed;

    final target = _opening ? 1.0 : 0.0;
    final current = value.animProgress;
    if ((current - target).abs() < 0.001 && _vel.abs() < 0.001) {
      if (!_opening && value.visible) {
        value = const SpotlightState();
      }
      return;
    }

    // Spring integration
    final force = -_stiffness * (current - target) - _damping * _vel;
    _vel += force * dt;
    final newProg = (current + _vel * dt).clamp(0.0, 1.0);

    value = SpotlightState(
      event: value.event,
      nodePosition: value.nodePosition,
      visible: value.visible,
      animProgress: newProg,
    );
  }

  @override
  void dispose() {
    detach();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// SpotlightPainter — dim + cutout + glow ring
// ---------------------------------------------------------------------------

class SpotlightPainter extends CustomPainter {
  final SpotlightState state;
  final double dimOpacity;
  final bool isDark;

  static const double _cutoutRadius = 52.0;

  const SpotlightPainter({
    required this.state,
    required this.isDark,
    this.dimOpacity = 0.72,
    super.repaint,
  });

  @override
  bool shouldRepaint(SpotlightPainter old) =>
      old.state.animProgress != state.animProgress ||
      old.state.nodePosition != state.nodePosition;

  @override
  void paint(Canvas canvas, Size size) {
    final t = state.animProgress;
    if (t < 0.01) return;

    final center = state.nodePosition;
    final cutR = _cutoutRadius * _easeOutBack(t);

    // Full-canvas dim using a "subtract" path trick:
    // draw a rect with a circular hole cut out.
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: center, radius: cutR))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(
      path,
      Paint()
        ..color = (isDark ? Colors.black : const Color(0xFF0A0A1E))
            .withValues(alpha: dimOpacity * t),
    );

    // Glow ring
    if (t > 0.3) {
      final glowT = ((t - 0.3) / 0.7).clamp(0.0, 1.0);
      canvas.drawCircle(
        center,
        cutR + 4,
        Paint()
          ..color = (state.event?.effectiveColor ?? Colors.white)
              .withValues(alpha: 0.4 * glowT)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      // Crisp ring
      canvas.drawCircle(
        center,
        cutR,
        Paint()
          ..color = (state.event?.effectiveColor ?? Colors.white)
              .withValues(alpha: 0.6 * glowT)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    // Connector line from cutout bottom to panel
    if (t > 0.5) {
      final lineT = ((t - 0.5) / 0.5).clamp(0.0, 1.0);
      final lineStart = Offset(center.dx, center.dy + cutR + 4);
      final lineEnd = Offset(center.dx, center.dy + cutR + 24);
      canvas.drawLine(
        lineStart,
        Offset.lerp(lineStart, lineEnd, lineT)!,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.3 * lineT)
          ..strokeWidth = 1,
      );
    }
  }

  static double _easeOutBack(double t) {
    const c1 = 1.70158;
    const c3 = c1 + 1;
    return 1 + c3 * math.pow(t - 1, 3) + c1 * math.pow(t - 1, 2);
  }
}

// ---------------------------------------------------------------------------
// TimelineSpotlightPanel — frosted glass detail card
// ---------------------------------------------------------------------------

class TimelineSpotlightPanel extends StatelessWidget {
  final TimelineEvent event;
  final double animProgress;
  final Offset nodePosition;
  final bool isDark;
  final VoidCallback? onClose;
  final VoidCallback? onOpenFull;

  static const double _panelWidth = 280.0;
  static const double _panelTopOffset = 72.0;

  const TimelineSpotlightPanel({
    super.key,
    required this.event,
    required this.animProgress,
    required this.nodePosition,
    required this.isDark,
    this.onClose,
    this.onOpenFull,
  });

  @override
  Widget build(BuildContext context) {
    if (animProgress < 0.3) return const SizedBox.shrink();
    final panelT = ((animProgress - 0.3) / 0.7).clamp(0.0, 1.0);
    final color = event.effectiveColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white60 : Colors.black54;

    // Position panel below the node, clamped to screen
    final screenSize = MediaQuery.of(context).size;
    double left = nodePosition.dx - _panelWidth / 2;
    left = left.clamp(12, screenSize.width - _panelWidth - 12);
    double top = nodePosition.dy + _panelTopOffset;
    if (top + 220 > screenSize.height - 60) {
      top = nodePosition.dy - _panelTopOffset - 220;
    }

    return Positioned(
      left: left,
      top: top,
      width: _panelWidth,
      child: Transform.translate(
        offset: Offset(0, 12 * (1 - panelT)),
        child: Opacity(
          opacity: panelT.clamp(0, 1),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: color.withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header row
                    Row(children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        event.category.label,
                        style: TextStyle(
                          fontSize: 10,
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // Close button
                      GestureDetector(
                        onTap: onClose,
                        child: Icon(Icons.close, size: 16, color: subColor),
                      ),
                    ]),

                    const SizedBox(height: 10),

                    // Year
                    Text(
                      _fmtYear(event),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: color,
                        letterSpacing: -0.5,
                        height: 1.0,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Title
                    Text(
                      event.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    if (event.description.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        event.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: subColor,
                          height: 1.55,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Importance bar
                    _ImportanceBar(value: event.importance, color: color),

                    const SizedBox(height: 12),

                    // Open full button
                    GestureDetector(
                      onTap: onOpenFull,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: color.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Open full detail',
                            style: TextStyle(
                              fontSize: 12,
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _fmtYear(TimelineEvent e) {
    final y = e.year.toInt();
    return y < 0 ? '${-y} BC' : '$y AD';
  }
}

class _ImportanceBar extends StatelessWidget {
  final double value;
  final Color color;
  const _ImportanceBar({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(
            'Importance',
            style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.7)),
          ),
          const Spacer(),
          Text(
            '${value.round()}/10',
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ]),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: value / 10,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 5,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// TimelineSpotlightLayer — composites painter + panel
// ---------------------------------------------------------------------------

/// Drop-in overlay — place at the top of the chart Stack.
///
/// ```dart
/// Stack(children: [
///   TimelineChartV2(config: config),
///   Positioned.fill(
///     child: TimelineSpotlightLayer(
///       controller: spotlightCtrl,
///       isDark: isDark,
///       onOpenFull: (ev) => TimelineEventSheet.show(context, event: ev),
///     ),
///   ),
/// ])
/// ```
class TimelineSpotlightLayer extends StatefulWidget {
  final TimelineSpotlightController controller;
  final bool isDark;
  final VoidCallback? onClose;
  final ValueChanged<TimelineEvent>? onOpenFull;

  const TimelineSpotlightLayer({
    super.key,
    required this.controller,
    this.isDark = false,
    this.onClose,
    this.onOpenFull,
  });

  @override
  State<TimelineSpotlightLayer> createState() => _TimelineSpotlightLayerState();
}

class _TimelineSpotlightLayerState extends State<TimelineSpotlightLayer>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    widget.controller.attach(this);
  }

  @override
  void dispose() {
    widget.controller.detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SpotlightState>(
      valueListenable: widget.controller,
      builder: (ctx, state, _) {
        if (!state.isActive) return const SizedBox.shrink();
        return Stack(children: [
          // Dim + cutout painter
          Positioned.fill(
            child: IgnorePointer(
              ignoring: state.animProgress < 0.05,
              child: GestureDetector(
                onTap: () {
                  widget.controller.hide();
                  widget.onClose?.call();
                },
                child: CustomPaint(
                  painter: SpotlightPainter(
                    state: state,
                    isDark: widget.isDark,
                    repaint: widget.controller,
                  ),
                ),
              ),
            ),
          ),
          // Frosted panel
          if (state.event != null)
            TimelineSpotlightPanel(
              event: state.event!,
              animProgress: state.animProgress,
              nodePosition: state.nodePosition,
              isDark: widget.isDark,
              onClose: () {
                widget.controller.hide();
                widget.onClose?.call();
              },
              onOpenFull: state.event == null
                  ? null
                  : () => widget.onOpenFull?.call(state.event!),
            ),
        ]);
      },
    );
  }
}
