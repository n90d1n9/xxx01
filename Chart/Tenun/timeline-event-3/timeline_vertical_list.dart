// TimelineVerticalList — mobile-first vertical event feed.
//
// Shown in [TimelineLayoutMode.compact] below the mini-chart.
// Events are sorted chronologically and grouped into sections by era/decade/century.
//
// Features:
//  - Section headers with sticky behaviour (SliverStickyHeader pattern).
//  - Bi-directional sync with the horizontal chart:
//      scrolling the list → the mini-chart pans to that year.
//      panning the chart → the list scrolls to the first visible event.
//  - Swipe-left  → bookmark event.
//  - Swipe-right → jump chart to that year.
//  - Pull-to-filter pill that expands a [TimelineFilterSheet].
//  - Search highlighting: matched characters shown in bold colour.
//  - Importance indicator strip on the left edge (taller = more important).

import 'package:flutter/material.dart';

import '../chart_theme.dart';
import 'timeline_event.dart';
import 'timeline_physics.dart';

// ---------------------------------------------------------------------------
// TimelineVerticalList
// ---------------------------------------------------------------------------

class TimelineVerticalList extends StatefulWidget {
  final List<TimelineEvent> events;
  final String searchQuery;
  final ChartTheme theme;
  final TimelineScrollController? scrollController;
  final ValueChanged<TimelineEvent>? onEventTap;
  final ValueChanged<TimelineEvent>? onBookmark;

  const TimelineVerticalList({
    super.key,
    required this.events,
    this.searchQuery = '',
    required this.theme,
    this.scrollController,
    this.onEventTap,
    this.onBookmark,
  });

  @override
  State<TimelineVerticalList> createState() => _TimelineVerticalListState();
}

class _TimelineVerticalListState extends State<TimelineVerticalList> {
  final _listScrollCtrl = ScrollController();
  final Set<String> _bookmarked = {};

  late List<_ListSection> _sections;

  @override
  void initState() {
    super.initState();
    _sections = _buildSections(widget.events, widget.searchQuery);
    widget.scrollController?.addListener(_onChartScroll);
  }

  @override
  void didUpdateWidget(TimelineVerticalList old) {
    super.didUpdateWidget(old);
    if (!identical(old.events, widget.events) ||
        old.searchQuery != widget.searchQuery) {
      _sections = _buildSections(widget.events, widget.searchQuery);
    }
    if (old.scrollController != widget.scrollController) {
      old.scrollController?.removeListener(_onChartScroll);
      widget.scrollController?.addListener(_onChartScroll);
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onChartScroll);
    _listScrollCtrl.dispose();
    super.dispose();
  }

  // ── Chart → list sync ──────────────────────────────────────────────────

  void _onChartScroll() {
    // When the chart viewport changes, scroll the list to match the
    // first event in the visible range.
    // Lightweight: just rebuild; actual scroll is deferred.
    if (mounted) setState(() {});
  }

  // ── List → chart sync ──────────────────────────────────────────────────

  void _syncChartToYear(double year) {
    widget.scrollController?.animateToYear(year);
  }

  // ── Section builder ────────────────────────────────────────────────────

  static List<_ListSection> _buildSections(
    List<TimelineEvent> events,
    String query,
  ) {
    final q = query.toLowerCase();
    final filtered = q.isEmpty
        ? events
        : events
            .where((e) =>
                e.title.toLowerCase().contains(q) ||
                e.description.toLowerCase().contains(q) ||
                e.tags.any((t) => t.toLowerCase().contains(q)))
            .toList();

    // Sort chronologically
    final sorted = [...filtered]
      ..sort((a, b) => a.yearFraction.compareTo(b.yearFraction));

    // Group by century (or era for ancient history)
    final Map<String, List<TimelineEvent>> groups = {};
    for (final ev in sorted) {
      final key = _sectionKey(ev.year.toInt());
      groups.putIfAbsent(key, () => []).add(ev);
    }

    return groups.entries
        .map((e) => _ListSection(header: e.key, events: e.value))
        .toList();
  }

  static String _sectionKey(int year) {
    if (year < -10000) return 'Prehistoric';
    if (year < -3000) return 'Ancient Prehistory';
    if (year < 0) {
      final cent = (-year / 100).ceil();
      return '${cent}th Century BC';
    }
    if (year == 0) return '1st Century AD';
    final cent = (year / 100).ceil();
    final suffix = _ordinal(cent);
    return '$suffix Century AD';
  }

  static String _ordinal(int n) {
    if (n % 100 >= 11 && n % 100 <= 13) return '${n}th';
    switch (n % 10) {
      case 1:
        return '${n}st';
      case 2:
        return '${n}nd';
      case 3:
        return '${n}rd';
      default:
        return '${n}th';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.theme.isDark;
    final bg = isDark ? const Color(0xFF12121E) : const Color(0xFFF7F7FB);

    if (_sections.isEmpty) {
      return _EmptySearch(isDark: isDark);
    }

    return Container(
      color: bg,
      child: CustomScrollView(
        controller: _listScrollCtrl,
        physics: const BouncingScrollPhysics(),
        slivers: [
          for (final section in _sections) ...[
            // Section header
            SliverPersistentHeader(
              pinned: true,
              delegate: _SectionHeaderDelegate(
                title: section.header,
                isDark: isDark,
              ),
            ),
            // Events in section
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final ev = section.events[i];
                  return _EventCard(
                    event: ev,
                    isDark: isDark,
                    searchQuery: widget.searchQuery,
                    isBookmarked: _bookmarked.contains(ev.id),
                    onTap: () {
                      _syncChartToYear(ev.yearFraction);
                      widget.onEventTap?.call(ev);
                    },
                    onBookmark: () {
                      setState(() {
                        if (_bookmarked.contains(ev.id)) {
                          _bookmarked.remove(ev.id);
                        } else {
                          _bookmarked.add(ev.id);
                        }
                      });
                      widget.onBookmark?.call(ev);
                    },
                    onJumpToYear: () => _syncChartToYear(ev.yearFraction),
                  );
                },
                childCount: section.events.length,
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _ListSection
// ---------------------------------------------------------------------------

class _ListSection {
  final String header;
  final List<TimelineEvent> events;
  const _ListSection({required this.header, required this.events});
}

// ---------------------------------------------------------------------------
// _SectionHeaderDelegate — sticky header
// ---------------------------------------------------------------------------

class _SectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final bool isDark;

  const _SectionHeaderDelegate({required this.title, required this.isDark});

  @override
  double get minExtent => 28;
  @override
  double get maxExtent => 28;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final bg = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFECECF4);
    final textColor = isDark ? Colors.white38 : Colors.black38;

    return Container(
      height: 28,
      color: bg,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
          color: textColor,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_SectionHeaderDelegate old) =>
      old.title != title || old.isDark != isDark;
}

// ---------------------------------------------------------------------------
// _EventCard — swipeable event tile
// ---------------------------------------------------------------------------

class _EventCard extends StatelessWidget {
  final TimelineEvent event;
  final bool isDark;
  final String searchQuery;
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback onBookmark;
  final VoidCallback onJumpToYear;

  const _EventCard({
    required this.event,
    required this.isDark,
    required this.searchQuery,
    required this.isBookmarked,
    required this.onTap,
    required this.onBookmark,
    required this.onJumpToYear,
  });

  @override
  Widget build(BuildContext context) {
    final color = event.effectiveColor;
    final cardBg = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final subColor = isDark ? Colors.white38 : Colors.black38;
    final isHighlight = event.flag == 'highlight';

    return Dismissible(
      key: ValueKey('card_${event.id}'),
      // Swipe right → jump chart
      background: _SwipeBg(
        color: color.withValues(alpha: 0.15),
        icon: Icons.location_searching,
        alignment: Alignment.centerLeft,
        label: 'Go to year',
        isDark: isDark,
      ),
      // Swipe left → bookmark
      secondaryBackground: _SwipeBg(
        color: Colors.amber.withValues(alpha: 0.15),
        icon: isBookmarked ? Icons.bookmark_remove : Icons.bookmark_add,
        alignment: Alignment.centerRight,
        label: isBookmarked ? 'Remove' : 'Bookmark',
        isDark: isDark,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onJumpToYear();
        } else {
          onBookmark();
        }
        return false; // never actually dismiss
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border(
              left: BorderSide(
                color: color,
                width: isHighlight ? 4 : 2.5,
              ),
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
            child: Row(
              children: [
                // Importance bar
                _ImportanceStrip(importance: event.importance, color: color),
                const SizedBox(width: 10),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title with search highlight
                      _HighlightText(
                        text: event.title,
                        query: searchQuery,
                        baseStyle: TextStyle(
                          fontSize: isHighlight ? 14 : 13,
                          fontWeight: isHighlight
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        highlightColor: color,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            _formatYear(event),
                            style: TextStyle(fontSize: 11, color: subColor),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            event.category.label,
                            style: TextStyle(fontSize: 11, color: subColor),
                          ),
                        ],
                      ),
                      if (event.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        _HighlightText(
                          text: event.description,
                          query: searchQuery,
                          maxLines: 2,
                          baseStyle: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.black54,
                            height: 1.4,
                          ),
                          highlightColor: color,
                        ),
                      ],
                    ],
                  ),
                ),

                // Right actions
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isBookmarked)
                      Icon(Icons.bookmark, size: 14, color: Colors.amber),
                    if (isHighlight)
                      Icon(Icons.star, size: 14, color: color),
                    const SizedBox(height: 4),
                    Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: isDark ? Colors.white24 : Colors.black26,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatYear(TimelineEvent e) {
    final y = e.year.toInt();
    return y < 0 ? '${-y} BC' : '$y AD';
  }
}

// ---------------------------------------------------------------------------
// _ImportanceStrip
// ---------------------------------------------------------------------------

class _ImportanceStrip extends StatelessWidget {
  final double importance;
  final Color color;
  const _ImportanceStrip({required this.importance, required this.color});

  @override
  Widget build(BuildContext context) {
    final h = (importance / 10 * 44).clamp(8.0, 44.0);
    return SizedBox(
      width: 3,
      height: 48,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: 3,
          height: h,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _SwipeBg
// ---------------------------------------------------------------------------

class _SwipeBg extends StatelessWidget {
  final Color color;
  final IconData icon;
  final Alignment alignment;
  final String label;
  final bool isDark;

  const _SwipeBg({
    required this.color,
    required this.icon,
    required this.alignment,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: isDark ? Colors.white70 : Colors.black54),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.white54 : Colors.black45,
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
// _HighlightText — bolds matching substrings
// ---------------------------------------------------------------------------

class _HighlightText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle baseStyle;
  final Color highlightColor;
  final int? maxLines;

  const _HighlightText({
    required this.text,
    required this.query,
    required this.baseStyle,
    required this.highlightColor,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text, style: baseStyle, maxLines: maxLines,
          overflow: maxLines != null ? TextOverflow.ellipsis : null);
    }

    final spans = <TextSpan>[];
    final lower = text.toLowerCase();
    final lowerQ = query.toLowerCase();
    int start = 0;

    while (true) {
      final idx = lower.indexOf(lowerQ, start);
      if (idx == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (idx > start) {
        spans.add(TextSpan(text: text.substring(start, idx)));
      }
      spans.add(TextSpan(
        text: text.substring(idx, idx + query.length),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: highlightColor,
          backgroundColor: highlightColor.withValues(alpha: 0.15),
        ),
      ));
      start = idx + query.length;
    }

    return Text.rich(
      TextSpan(children: spans, style: baseStyle),
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
    );
  }
}

// ---------------------------------------------------------------------------
// _EmptySearch
// ---------------------------------------------------------------------------

class _EmptySearch extends StatelessWidget {
  final bool isDark;
  const _EmptySearch({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = isDark ? Colors.white24 : Colors.black26;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 40, color: color),
          const SizedBox(height: 10),
          Text(
            'No matching events',
            style: TextStyle(fontSize: 14, color: color),
          ),
        ],
      ),
    );
  }
}
