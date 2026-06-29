// TimelineCardDeck — swipeable story card deck for mobile event browsing.
//
// Renders events as a stack of physical cards with:
//   • PageView-style swipe left/right to advance through events.
//   • 3D tilt: cards rotate on the Z axis (perspective transform) as they're
//     dragged, giving a tactile feel.
//   • Next card peeks behind the current card (offset + scaled down).
//   • Glassmorphism card surface: BackdropFilter blur + semi-transparent fill.
//   • Hero image header when event.images is non-empty.
//   • Category illustration strip when no image.
//   • Swipe-right gesture → bookmark.
//   • Swipe-left gesture  → dismiss / skip.
//   • Double-tap          → open full event sheet.
//   • Long-press          → peek at next card.
//   • Animated like heart on bookmark action.
//
// Components:
//   TimelineCardDeck           — main container widget
//   _DeckCard                  — single animated card
//   _CardContent               — static content inside the card
//   _GlassCardSurface          — BackdropFilter frosted glass
//   _LikeAnimation             — floating heart burst on bookmark
//   TimelineCardDeckController — event list, current index, bookmark set
//
// Usage:
//   TimelineCardDeck(
//     events: config.events,
//     onEventTap: (ev) => TimelineEventSheet.show(context, event: ev),
//     onBookmark: (ev) => myBookmarks.add(ev.id),
//     isDark: isDark,
//   )

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'timeline_event.dart';

// ---------------------------------------------------------------------------
// TimelineCardDeckController
// ---------------------------------------------------------------------------

class TimelineCardDeckController extends ChangeNotifier {
  final List<TimelineEvent> events;
  int _currentIndex = 0;
  final Set<String> _bookmarked = {};
  final Set<String> _dismissed = {};

  TimelineCardDeckController({required this.events});

  int get currentIndex => _currentIndex;
  bool get hasNext => _currentIndex < _visibleEvents.length - 1;
  bool get hasPrev => _currentIndex > 0;
  bool isBookmarked(String id) => _bookmarked.contains(id);
  List<String> get bookmarkedIds => List.unmodifiable(_bookmarked);

  List<TimelineEvent> get _visibleEvents =>
      events.where((e) => !_dismissed.contains(e.id)).toList();

  List<TimelineEvent> get visibleEvents => _visibleEvents;

  TimelineEvent? get current {
    final v = _visibleEvents;
    if (v.isEmpty || _currentIndex >= v.length) return null;
    return v[_currentIndex];
  }

  TimelineEvent? get next {
    final v = _visibleEvents;
    if (_currentIndex + 1 >= v.length) return null;
    return v[_currentIndex + 1];
  }

  void advance() {
    if (hasNext) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void goBack() {
    if (hasPrev) {
      _currentIndex--;
      notifyListeners();
    }
  }

  void dismiss(String id) {
    _dismissed.add(id);
    if (_currentIndex >= _visibleEvents.length) {
      _currentIndex = math.max(0, _visibleEvents.length - 1);
    }
    notifyListeners();
  }

  void toggleBookmark(String id) {
    if (_bookmarked.contains(id)) {
      _bookmarked.remove(id);
    } else {
      _bookmarked.add(id);
    }
    notifyListeners();
  }
}

// ---------------------------------------------------------------------------
// TimelineCardDeck — main widget
// ---------------------------------------------------------------------------

class TimelineCardDeck extends StatefulWidget {
  final List<TimelineEvent> events;
  final bool isDark;
  final ValueChanged<TimelineEvent>? onEventTap;
  final ValueChanged<TimelineEvent>? onBookmark;
  final TimelineCardDeckController? controller;

  const TimelineCardDeck({
    super.key,
    required this.events,
    this.isDark = false,
    this.onEventTap,
    this.onBookmark,
    this.controller,
  });

  @override
  State<TimelineCardDeck> createState() => _TimelineCardDeckState();
}

class _TimelineCardDeckState extends State<TimelineCardDeck>
    with TickerProviderStateMixin {
  late TimelineCardDeckController _ctrl;
  bool _ownsCtrl = false;

  // Drag state
  double _dragDx = 0;
  bool _isDragging = false;

  // Swipe animation
  AnimationController? _swipeCtrl;
  double _swipeTargetDx = 0;

  // Like animation
  bool _showLike = false;
  Offset _likeOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _ctrl = widget.controller!;
    } else {
      _ctrl = TimelineCardDeckController(events: widget.events);
      _ownsCtrl = true;
    }
  }

  @override
  void dispose() {
    if (_ownsCtrl) _ctrl.dispose();
    _swipeCtrl?.dispose();
    super.dispose();
  }

  // ── Gesture handlers ──────────────────────────────────────────────────────

  void _onPanStart(DragStartDetails d) {
    _isDragging = true;
    _swipeCtrl?.stop();
  }

  void _onPanUpdate(DragUpdateDetails d) {
    setState(() => _dragDx += d.delta.dx);
  }

  void _onPanEnd(DragEndDetails d) {
    _isDragging = false;
    final vx = d.velocity.pixelsPerSecond.dx;
    final threshold = MediaQuery.of(context).size.width * 0.35;

    if (_dragDx > threshold || vx > 600) {
      // Swipe right → bookmark
      _animateSwipe(direction: 1, onComplete: () {
        final ev = _ctrl.current;
        if (ev != null) {
          _ctrl.toggleBookmark(ev.id);
          widget.onBookmark?.call(ev);
          _triggerLikeAnim();
          HapticFeedback.mediumImpact();
          _ctrl.advance();
        }
      });
    } else if (_dragDx < -threshold || vx < -600) {
      // Swipe left → skip
      _animateSwipe(direction: -1, onComplete: () {
        HapticFeedback.selectionClick();
        _ctrl.advance();
      });
    } else {
      // Snap back
      _animateSnapBack();
    }
  }

  void _animateSwipe({required int direction, required VoidCallback onComplete}) {
    final screenW = MediaQuery.of(context).size.width;
    _swipeCtrl?.dispose();
    _swipeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    final start = _dragDx;
    final end = direction * screenW * 1.4;
    _swipeCtrl!.addListener(() {
      setState(() {
        _dragDx = start + (end - start) * Curves.easeIn.transform(_swipeCtrl!.value);
      });
    });
    _swipeCtrl!.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        onComplete();
        setState(() => _dragDx = 0);
      }
    });
    _swipeCtrl!.forward();
  }

  void _animateSnapBack() {
    _swipeCtrl?.dispose();
    _swipeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    final start = _dragDx;
    _swipeCtrl!.addListener(() {
      setState(() {
        _dragDx = start * (1 - Curves.elasticOut.transform(_swipeCtrl!.value));
      });
    });
    _swipeCtrl!.addStatusListener((s) {
      if (s == AnimationStatus.completed) setState(() => _dragDx = 0);
    });
    _swipeCtrl!.forward();
  }

  void _triggerLikeAnim() {
    setState(() {
      _showLike = true;
      _likeOffset = Offset(
        MediaQuery.of(context).size.width / 2,
        MediaQuery.of(context).size.height / 2,
      );
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _showLike = false);
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _ctrl,
      builder: (ctx, _) {
        final events = _ctrl.visibleEvents;
        if (events.isEmpty) {
          return _EmptyDeck(isDark: widget.isDark);
        }

        final screenSize = MediaQuery.of(ctx).size;
        final cardWidth = math.min(screenSize.width - 40, 380.0);
        final cardHeight = cardWidth * 1.5;

        return SizedBox(
          width: cardWidth,
          height: cardHeight + 60, // extra for controls
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // Next card (peek)
              if (_ctrl.hasNext)
                _buildNextCard(events, cardWidth, cardHeight),

              // Current card (draggable)
              _buildCurrentCard(events, cardWidth, cardHeight),

              // Controls row
              Positioned(
                bottom: 0,
                child: _DeckControls(
                  ctrl: _ctrl,
                  isDark: widget.isDark,
                  onTap: () {
                    final ev = _ctrl.current;
                    if (ev != null) widget.onEventTap?.call(ev);
                  },
                ),
              ),

              // Like animation
              if (_showLike)
                Positioned(
                  left: _likeOffset.dx - 30,
                  top: _likeOffset.dy - 60,
                  child: _LikeAnimation(isDark: widget.isDark),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNextCard(List<TimelineEvent> events, double w, double h) {
    final ev = _ctrl.next!;
    // Next card scales down and is offset down slightly
    final progress = (_dragDx.abs() / (w * 0.35)).clamp(0.0, 1.0);
    final scale = 0.92 + progress * 0.08;
    final ty = 16.0 * (1 - progress);

    return Transform(
      alignment: Alignment.topCenter,
      transform: Matrix4.identity()
        ..translate(0.0, ty)
        ..scale(scale),
      child: _DeckCard(
        event: ev,
        isDark: widget.isDark,
        dragDx: 0,
        isTop: false,
        isBookmarked: _ctrl.isBookmarked(ev.id),
        onDoubleTap: null,
        onLongPress: null,
      ),
    );
  }

  Widget _buildCurrentCard(List<TimelineEvent> events, double w, double h) {
    final ev = _ctrl.current!;
    // Rotation: up to ±15 degrees based on drag
    final rotZ = (_dragDx / w) * 0.26; // ~15 deg max
    // Lift: card rises slightly when dragged
    final ty = -math.min((_dragDx.abs() / w * 20), 20.0);

    // Swipe direction indicator
    final rightStrength = (_dragDx / w).clamp(0.0, 1.0);
    final leftStrength = (-_dragDx / w).clamp(0.0, 1.0);

    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onDoubleTap: () {
        widget.onEventTap?.call(ev);
        HapticFeedback.lightImpact();
      },
      onLongPress: () {
        HapticFeedback.selectionClick();
        // Peek — show bottom sheet preview
        _showPeek(context, ev);
      },
      child: Transform(
        alignment: Alignment.bottomCenter,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // perspective
          ..translate(0.0, ty)
          ..translate(_dragDx)
          ..rotateZ(rotZ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            _DeckCard(
              event: ev,
              isDark: widget.isDark,
              dragDx: _dragDx,
              isTop: true,
              isBookmarked: _ctrl.isBookmarked(ev.id),
              onDoubleTap: null,
              onLongPress: null,
            ),
            // Swipe right label
            if (rightStrength > 0.15)
              _SwipeLabel(
                label: '♥ SAVE',
                color: Colors.greenAccent,
                alignment: Alignment.topLeft,
                opacity: rightStrength,
              ),
            // Swipe left label
            if (leftStrength > 0.15)
              _SwipeLabel(
                label: 'SKIP ›',
                color: Colors.redAccent,
                alignment: Alignment.topRight,
                opacity: leftStrength,
              ),
          ],
        ),
      ),
    );
  }

  void _showPeek(BuildContext context, TimelineEvent ev) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PeekSheet(event: ev, isDark: widget.isDark),
    );
  }
}

// ---------------------------------------------------------------------------
// _DeckCard — glass card surface
// ---------------------------------------------------------------------------

class _DeckCard extends StatelessWidget {
  final TimelineEvent event;
  final bool isDark;
  final double dragDx;
  final bool isTop;
  final bool isBookmarked;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;

  const _DeckCard({
    required this.event,
    required this.isDark,
    required this.dragDx,
    required this.isTop,
    required this.isBookmarked,
    this.onDoubleTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final color = event.effectiveColor;
    final cardBg = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.82);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: color.withValues(alpha: isTop ? 0.4 : 0.2),
              width: 1.5,
            ),
            boxShadow: isTop
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.22),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    )
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hero area
              if (event.images.isNotEmpty)
                _HeroImage(url: event.images.first, color: color)
              else
                _CategoryHero(event: event, isDark: isDark),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: _CardContent(
                  event: event,
                  isDark: isDark,
                  isBookmarked: isBookmarked,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _CardContent
// ---------------------------------------------------------------------------

class _CardContent extends StatelessWidget {
  final TimelineEvent event;
  final bool isDark;
  final bool isBookmarked;

  const _CardContent({
    required this.event,
    required this.isDark,
    required this.isBookmarked,
  });

  @override
  Widget build(BuildContext context) {
    final color = event.effectiveColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white60 : Colors.black54;
    final y = event.year.toInt();
    final yearLabel = y < 0 ? '${-y} BC' : '$y AD';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category + bookmark row
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              event.category.label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          if (isBookmarked)
            Icon(Icons.bookmark, size: 16, color: color),
        ]),
        const SizedBox(height: 10),

        // Year
        Text(
          yearLabel,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: -0.5,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 6),

        // Title
        Text(
          event.title,
          style: TextStyle(
            fontSize: 18,
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
              fontSize: 13,
              color: subColor,
              height: 1.55,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        // Tags
        if (event.tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            children: event.tags
                .take(4)
                .map((t) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: subColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        t,
                        style: TextStyle(fontSize: 10, color: subColor),
                      ),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Support widgets
// ---------------------------------------------------------------------------

class _HeroImage extends StatelessWidget {
  final String url;
  final Color color;
  const _HeroImage({required this.url, required this.color});

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Image.network(
          url,
          height: 160,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _CategoryHero(
            event: null,
            isDark: false,
            color: color,
          ),
        ),
      );
}

class _CategoryHero extends StatelessWidget {
  final TimelineEvent? event;
  final bool isDark;
  final Color? color;

  const _CategoryHero({this.event, required this.isDark, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? event?.effectiveColor ?? Colors.blue;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [c.withValues(alpha: 0.85), c.withValues(alpha: 0.35)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: event != null
            ? Center(
                child: Icon(
                  _catIcon(event!.category),
                  size: 48,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              )
            : null,
      ),
    );
  }

  static IconData _catIcon(EventCategory c) {
    switch (c) {
      case EventCategory.political: return Icons.account_balance;
      case EventCategory.cultural: return Icons.palette_outlined;
      case EventCategory.scientific: return Icons.science_outlined;
      case EventCategory.religious: return Icons.temple_buddhist_outlined;
      case EventCategory.military: return Icons.shield_outlined;
      case EventCategory.economic: return Icons.trending_up;
      case EventCategory.natural: return Icons.terrain_outlined;
      case EventCategory.technological: return Icons.computer_outlined;
    }
  }
}

class _SwipeLabel extends StatelessWidget {
  final String label;
  final Color color;
  final AlignmentGeometry alignment;
  final double opacity;

  const _SwipeLabel({
    required this.label,
    required this.color,
    required this.alignment,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      left: alignment == Alignment.topLeft ? 20 : null,
      right: alignment == Alignment.topRight ? 20 : null,
      child: Opacity(
        opacity: opacity.clamp(0, 1),
        child: Transform.rotate(
          angle: alignment == Alignment.topLeft ? -0.35 : 0.35,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 2.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DeckControls extends StatelessWidget {
  final TimelineCardDeckController ctrl;
  final bool isDark;
  final VoidCallback onTap;

  const _DeckControls({required this.ctrl, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dim = isDark ? Colors.white30 : Colors.black26;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: ctrl.hasPrev ? dim.withValues(alpha: 1) : dim.withValues(alpha: 0.3),
          onPressed: ctrl.hasPrev ? ctrl.goBack : null,
          iconSize: 20,
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: (ctrl.current?.effectiveColor ?? Colors.blue).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: (ctrl.current?.effectiveColor ?? Colors.blue).withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              'Open detail',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: ctrl.current?.effectiveColor ?? Colors.blue,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          color: ctrl.hasNext ? dim.withValues(alpha: 1) : dim.withValues(alpha: 0.3),
          onPressed: ctrl.hasNext ? ctrl.advance : null,
          iconSize: 20,
        ),
      ],
    );
  }
}

class _LikeAnimation extends StatefulWidget {
  final bool isDark;
  const _LikeAnimation({required this.isDark});

  @override
  State<_LikeAnimation> createState() => _LikeAnimationState();
}

class _LikeAnimationState extends State<_LikeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.4), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.1), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _opacity = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.6, 1.0)),
    );
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Opacity(
          opacity: _opacity.value,
          child: Transform.scale(
            scale: _scale.value,
            child: const Icon(Icons.favorite, size: 60, color: Colors.redAccent),
          ),
        ),
      );
}

class _EmptyDeck extends StatelessWidget {
  final bool isDark;
  const _EmptyDeck({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history_toggle_off,
            size: 52,
            color: isDark ? Colors.white24 : Colors.black24,
          ),
          const SizedBox(height: 12),
          Text(
            'No more events',
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _PeekSheet extends StatelessWidget {
  final TimelineEvent event;
  final bool isDark;

  const _PeekSheet({required this.event, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final color = event.effectiveColor;
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36, height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(children: [
            Container(
              width: 10, height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              event.category.label,
              style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold),
            ),
          ]),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              event.title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          if (event.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              event.description,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white60 : Colors.black54,
                height: 1.5,
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
