// TimelineResponsiveShell — top-level adaptive container.
//
// This is the single widget a consumer mounts. It:
//   1. Detects layout mode via [TimelineLayoutAdapter].
//   2. Animates between modes (slide/fade) when the window resizes.
//   3. Composes the correct arrangement of sub-widgets per mode.
//   4. Owns the shared [TimelineScrollController], [TimelineSidePanelController],
//      and [TimelineViewfinderController] so all children stay in sync.
//
// Desktop / widescreen  (≥ 900px wide):
//   ╔══════════════════════════════════════╦══════════════╗
//   ║  Search + Scale bar                  ║              ║
//   ╠══════════════════════════════════════╣  Side panel  ║
//   ║  Horizontal timeline (flex)          ║  (resizable) ║
//   ╠══════════════════════════════════════╣              ║
//   ║  Viewfinder + Legend + Controls      ║              ║
//   ╚══════════════════════════════════════╩══════════════╝
//
// Tablet / landscape  (480–899px):
//   ╔══════════════════════════════════════╗
//   ║  Search + Scale bar                  ║
//   ╠══════════════════════════════════════╣
//   ║  Horizontal timeline (flex)          ║
//   ╠══════════════════════════════════════╣
//   ║  Viewfinder + Legend + Controls      ║
//   ╚══════════════════════════════════════╝
//   → Tapping an event opens [TimelineEventSheet] (bottom sheet)
//
// Mobile portrait  (< 480px):
//   ╔══════════════════════════════════════╗
//   ║  Search bar (collapsible)            ║
//   ╠══════════════════════════════════════╣
//   ║  Mini horizontal chart  (200px)      ║
//   ╠══════════════════════════════════════╣
//   ║  Viewfinder (36px)                   ║
//   ╠══════════════════════════════════════╣
//   ║  Vertical event list  (flex scroll)  ║
//   ╚══════════════════════════════════════╝

import 'package:flutter/material.dart';

import '../chart_theme.dart';
import 'timeline_chart_config.dart';
import 'timeline_chart_v2.dart';
import 'timeline_coordinate_system.dart';
import 'timeline_event.dart';
import 'timeline_event_sheet.dart';
import 'timeline_layout.dart';
import 'timeline_physics.dart';
import 'timeline_search_bar.dart';
import 'timeline_side_panel.dart';
import 'timeline_vertical_list.dart';
import 'timeline_viewfinder.dart';
import 'timeline_spatial_index.dart';
import 'timeline_painter_v2.dart';

// ---------------------------------------------------------------------------
// TimelineResponsiveShell
// ---------------------------------------------------------------------------

class TimelineResponsiveShell extends StatefulWidget {
  final TimelineChartConfig config;
  final ChartTheme theme;
  final List<TimelineEraBand> eraBands;
  final TimelineBreakpoints breakpoints;
  final ValueChanged<TimelineEvent>? onEventTap;
  final bool showNowMarker;

  const TimelineResponsiveShell({
    super.key,
    required this.config,
    this.theme = ChartTheme.light,
    this.eraBands = const [],
    this.breakpoints = TimelineBreakpoints.defaults,
    this.onEventTap,
    this.showNowMarker = true,
  });

  @override
  State<TimelineResponsiveShell> createState() => _TimelineResponsiveShellState();
}

class _TimelineResponsiveShellState extends State<TimelineResponsiveShell>
    with TickerProviderStateMixin {
  // ── Shared controllers (one instance, all children share) ──────────────
  late TimelineScrollController _scrollCtrl;
  late TimelineSidePanelController _sideCtrl;
  late TimelineViewfinderController _viewfinderCtrl;
  late TimelineIntervalTree _index;

  // ── Layout transition ───────────────────────────────────────────────────
  TimelineLayoutMode? _prevMode;
  late AnimationController _modeTransCtrl;
  late Animation<double> _modeOpacity;

  // ── Search ─────────────────────────────────────────────────────────────
  String _searchQuery = '';
  bool _searchVisible = false;

  @override
  void initState() {
    super.initState();
    _index = TimelineIntervalTree.build(widget.config.events);
    final (_, offset, zoom) = TimelineCoordinateSystem.fitToData(
      widget.config.events, 600,
    );
    _scrollCtrl = TimelineScrollController(
      initial: TimelineViewState(
        scale: widget.config.initialScale,
        zoom: zoom,
        offsetYears: offset,
      ),
    )..attach(this);

    _sideCtrl = TimelineSidePanelController();

    final (min, max) = TimelineCoordinateSystem.dataRange(widget.config.events);
    _viewfinderCtrl = TimelineViewfinderController(
      dataStart: min,
      dataEnd: max,
      viewStart: offset,
      viewEnd: offset + 100,
    );

    _modeTransCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      value: 1.0,
    );
    _modeOpacity = CurvedAnimation(
      parent: _modeTransCtrl,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollCtrl
      ..detach()
      ..dispose();
    _sideCtrl.dispose();
    _viewfinderCtrl.dispose();
    _modeTransCtrl.dispose();
    super.dispose();
  }

  // ── Event tap routing ──────────────────────────────────────────────────

  void _handleEventTap(TimelineEvent event, TimelineLayoutMode mode) {
    widget.onEventTap?.call(event);

    final related = _index
        .query(event.yearFraction - 100, event.yearFraction + 100)
        .where((e) => e.id != event.id && e.category == event.category)
        .take(12)
        .toList();

    if (mode == TimelineLayoutMode.widescreen) {
      _sideCtrl.showEvent(event, related: related);
    } else {
      TimelineEventSheet.show(
        context,
        event: event,
        relatedEvents: related,
        onRelatedTap: (rel) {
          Navigator.of(context).pop();
          _scrollCtrl.animateToYear(rel.yearFraction);
        },
      );
    }
  }

  // ── Mode change animation ──────────────────────────────────────────────

  void _onModeChange(TimelineLayoutMode newMode) {
    if (newMode != _prevMode) {
      _prevMode = newMode;
      _modeTransCtrl.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.theme.isDark;

    return TimelineLayoutBuilder(
      breakpoints: widget.breakpoints,
      builder: (ctx, metrics) {
        _onModeChange(metrics.mode);

        return FadeTransition(
          opacity: _modeOpacity,
          child: _buildForMode(metrics, isDark),
        );
      },
    );
  }

  Widget _buildForMode(TimelineLayoutMetrics metrics, bool isDark) {
    switch (metrics.mode) {
      case TimelineLayoutMode.compact:
        return _CompactLayout(
          metrics: metrics,
          config: widget.config,
          theme: widget.theme,
          eraBands: widget.eraBands,
          scrollCtrl: _scrollCtrl,
          viewfinderCtrl: _viewfinderCtrl,
          index: _index,
          searchQuery: _searchQuery,
          searchVisible: _searchVisible,
          showNowMarker: widget.showNowMarker,
          onSearchToggle: () => setState(() => _searchVisible = !_searchVisible),
          onSearchChanged: (q) => setState(() => _searchQuery = q),
          onEventTap: (ev) => _handleEventTap(ev, metrics.mode),
        );

      case TimelineLayoutMode.horizontal:
        return _HorizontalLayout(
          metrics: metrics,
          config: widget.config,
          theme: widget.theme,
          eraBands: widget.eraBands,
          scrollCtrl: _scrollCtrl,
          viewfinderCtrl: _viewfinderCtrl,
          searchQuery: _searchQuery,
          searchVisible: _searchVisible,
          showNowMarker: widget.showNowMarker,
          onSearchToggle: () => setState(() => _searchVisible = !_searchVisible),
          onSearchChanged: (q) => setState(() => _searchQuery = q),
          onEventTap: (ev) => _handleEventTap(ev, metrics.mode),
        );

      case TimelineLayoutMode.widescreen:
        return _WidescreenLayout(
          metrics: metrics,
          config: widget.config,
          theme: widget.theme,
          eraBands: widget.eraBands,
          scrollCtrl: _scrollCtrl,
          viewfinderCtrl: _viewfinderCtrl,
          sideCtrl: _sideCtrl,
          searchQuery: _searchQuery,
          searchVisible: _searchVisible,
          showNowMarker: widget.showNowMarker,
          onSearchToggle: () => setState(() => _searchVisible = !_searchVisible),
          onSearchChanged: (q) => setState(() => _searchQuery = q),
          onEventTap: (ev) => _handleEventTap(ev, metrics.mode),
          onJumpToEvent: () {
            final ev = _sideCtrl.event;
            if (ev != null) _scrollCtrl.animateToYear(ev.yearFraction);
          },
        );
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// _CompactLayout  (mobile portrait)
// ═══════════════════════════════════════════════════════════════════════════

class _CompactLayout extends StatelessWidget {
  final TimelineLayoutMetrics metrics;
  final TimelineChartConfig config;
  final ChartTheme theme;
  final List<TimelineEraBand> eraBands;
  final TimelineScrollController scrollCtrl;
  final TimelineViewfinderController viewfinderCtrl;
  final TimelineIntervalTree index;
  final String searchQuery;
  final bool searchVisible;
  final bool showNowMarker;
  final VoidCallback onSearchToggle;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<TimelineEvent> onEventTap;

  const _CompactLayout({
    required this.metrics,
    required this.config,
    required this.theme,
    required this.eraBands,
    required this.scrollCtrl,
    required this.viewfinderCtrl,
    required this.index,
    required this.searchQuery,
    required this.searchVisible,
    required this.showNowMarker,
    required this.onSearchToggle,
    required this.onSearchChanged,
    required this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar (collapsible)
        TimelineSearchBar(
          visible: searchVisible,
          onToggle: onSearchToggle,
          onChanged: onSearchChanged,
          theme: theme,
          compact: true,
        ),

        // Mini horizontal chart
        SizedBox(
          height: metrics.chartHeight,
          child: TimelineChartV2(
            config: config,
            theme: theme,
            eraBands: eraBands,
            scrollController: scrollCtrl,
            showNowMarker: showNowMarker,
            onEventTap: onEventTap,
          ),
        ),

        // Viewfinder strip
        TimelineViewfinder(
          controller: viewfinderCtrl,
          events: config.events,
          eraBands: eraBands,
          height: metrics.viewfinderHeight,
          theme: theme,
          onViewChanged: (pair) {
            scrollCtrl.animateToYear(pair.$1);
          },
        ),

        // Vertical event list (flex)
        Expanded(
          child: TimelineVerticalList(
            events: config.events,
            searchQuery: searchQuery,
            theme: theme,
            scrollController: scrollCtrl,
            onEventTap: onEventTap,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// _HorizontalLayout  (tablet / small desktop)
// ═══════════════════════════════════════════════════════════════════════════

class _HorizontalLayout extends StatelessWidget {
  final TimelineLayoutMetrics metrics;
  final TimelineChartConfig config;
  final ChartTheme theme;
  final List<TimelineEraBand> eraBands;
  final TimelineScrollController scrollCtrl;
  final TimelineViewfinderController viewfinderCtrl;
  final String searchQuery;
  final bool searchVisible;
  final bool showNowMarker;
  final VoidCallback onSearchToggle;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<TimelineEvent> onEventTap;

  const _HorizontalLayout({
    required this.metrics,
    required this.config,
    required this.theme,
    required this.eraBands,
    required this.scrollCtrl,
    required this.viewfinderCtrl,
    required this.searchQuery,
    required this.searchVisible,
    required this.showNowMarker,
    required this.onSearchToggle,
    required this.onSearchChanged,
    required this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TimelineSearchBar(
          visible: searchVisible,
          onToggle: onSearchToggle,
          onChanged: onSearchChanged,
          theme: theme,
          compact: false,
        ),
        Expanded(
          child: TimelineChartV2(
            config: config,
            theme: theme,
            eraBands: eraBands,
            scrollController: scrollCtrl,
            showNowMarker: showNowMarker,
            onEventTap: onEventTap,
          ),
        ),
        TimelineViewfinder(
          controller: viewfinderCtrl,
          events: config.events,
          eraBands: eraBands,
          height: metrics.viewfinderHeight,
          theme: theme,
          onViewChanged: (pair) => scrollCtrl.animateToYear(pair.$1),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// _WidescreenLayout  (desktop)
// ═══════════════════════════════════════════════════════════════════════════

class _WidescreenLayout extends StatelessWidget {
  final TimelineLayoutMetrics metrics;
  final TimelineChartConfig config;
  final ChartTheme theme;
  final List<TimelineEraBand> eraBands;
  final TimelineScrollController scrollCtrl;
  final TimelineViewfinderController viewfinderCtrl;
  final TimelineSidePanelController sideCtrl;
  final String searchQuery;
  final bool searchVisible;
  final bool showNowMarker;
  final VoidCallback onSearchToggle;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<TimelineEvent> onEventTap;
  final VoidCallback onJumpToEvent;

  const _WidescreenLayout({
    required this.metrics,
    required this.config,
    required this.theme,
    required this.eraBands,
    required this.scrollCtrl,
    required this.viewfinderCtrl,
    required this.sideCtrl,
    required this.searchQuery,
    required this.searchVisible,
    required this.showNowMarker,
    required this.onSearchToggle,
    required this.onSearchChanged,
    required this.onEventTap,
    required this.onJumpToEvent,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.isDark;

    final chartColumn = Column(
      children: [
        TimelineSearchBar(
          visible: true, // always visible on desktop
          onToggle: onSearchToggle,
          onChanged: onSearchChanged,
          theme: theme,
          compact: false,
          alwaysExpanded: true,
        ),
        Expanded(
          child: TimelineChartV2(
            config: config,
            theme: theme,
            eraBands: eraBands,
            scrollController: scrollCtrl,
            showNowMarker: showNowMarker,
            onEventTap: onEventTap,
          ),
        ),
        TimelineViewfinder(
          controller: viewfinderCtrl,
          events: config.events,
          eraBands: eraBands,
          height: metrics.viewfinderHeight,
          theme: theme,
          onViewChanged: (pair) => scrollCtrl.animateToYear(pair.$1),
        ),
      ],
    );

    final sidePanel = TimelineSidePanel(
      controller: sideCtrl,
      allEvents: config.events,
      isDark: isDark,
      onJumpToEvent: onJumpToEvent,
      onRelatedTap: (ev) {
        scrollCtrl.animateToYear(ev.yearFraction);
      },
    );

    return ResizableSplitPane(
      initialLeftFraction: 1 - (metrics.sidePanelWidth / metrics.totalWidth),
      minLeftWidth: 320,
      left: chartColumn,
      right: sidePanel,
      dividerColor: isDark ? Colors.white12 : Colors.black10,
    );
  }
}
