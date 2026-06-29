// TimelineSearchBar — floating search overlay for all layout modes.
//
// Compact mode  : icon button → expands to full-width field.
// Horizontal    : icon toggle in top-right corner.
// Widescreen    : always-expanded inline bar below the title.
//
// Features:
//  - Fuzzy substring search across title, description, tags.
//  - Filter chips: category multi-select, importance range, year range.
//  - Result count badge.
//  - Recent searches (in-memory, last 8).
//  - Animated expand/collapse (SizeTransition + FadeTransition).
//  - Clear button inside field.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../chart_theme.dart';
import 'timeline_event.dart';

// ---------------------------------------------------------------------------
// TimelineSearchBar
// ---------------------------------------------------------------------------

class TimelineSearchBar extends StatefulWidget {
  final bool visible;
  final bool alwaysExpanded;
  final bool compact;
  final ChartTheme theme;
  final VoidCallback onToggle;
  final ValueChanged<String> onChanged;
  final ValueChanged<TimelineSearchFilters>? onFiltersChanged;
  final int? resultCount;

  const TimelineSearchBar({
    super.key,
    required this.visible,
    required this.onToggle,
    required this.onChanged,
    required this.theme,
    this.alwaysExpanded = false,
    this.compact = false,
    this.onFiltersChanged,
    this.resultCount,
  });

  @override
  State<TimelineSearchBar> createState() => _TimelineSearchBarState();
}

class _TimelineSearchBarState extends State<TimelineSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _expandCtrl;
  late Animation<double> _expandAnim;
  final _textCtrl = TextEditingController();
  final _focusNode = FocusNode();
  final _recentSearches = <String>[];
  bool _showRecent = false;
  TimelineSearchFilters _filters = const TimelineSearchFilters();

  @override
  void initState() {
    super.initState();
    _expandCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: widget.alwaysExpanded || widget.visible ? 1.0 : 0.0,
    );
    _expandAnim = CurvedAnimation(parent: _expandCtrl, curve: Curves.easeOutCubic);

    if (widget.visible || widget.alwaysExpanded) {
      _expandCtrl.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(TimelineSearchBar old) {
    super.didUpdateWidget(old);
    if (!widget.alwaysExpanded) {
      if (widget.visible && !old.visible) {
        _expandCtrl.forward();
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) _focusNode.requestFocus();
        });
      } else if (!widget.visible && old.visible) {
        _expandCtrl.reverse();
        _focusNode.unfocus();
      }
    }
  }

  @override
  void dispose() {
    _expandCtrl.dispose();
    _textCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSubmit(String value) {
    if (value.isNotEmpty && !_recentSearches.contains(value)) {
      setState(() {
        _recentSearches.insert(0, value);
        if (_recentSearches.length > 8) _recentSearches.removeLast();
      });
    }
    setState(() => _showRecent = false);
  }

  void _clearSearch() {
    _textCtrl.clear();
    widget.onChanged('');
    setState(() => _showRecent = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.theme.isDark;
    final bg = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF0F0F8);
    final fieldBg = isDark ? const Color(0xFF252540) : Colors.white;
    final iconColor = isDark ? Colors.white60 : Colors.black45;

    return Container(
      color: bg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Top row: field + toggle ──────────────────────────────────
          SizeTransition(
            sizeFactor: _expandAnim,
            axisAlignment: -1,
            child: FadeTransition(
              opacity: _expandAnim,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 4),
                child: Row(
                  children: [
                    // Search field
                    Expanded(
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: fieldBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? Colors.white12 : Colors.black12,
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            Icon(Icons.search, size: 16, color: iconColor),
                            const SizedBox(width: 6),
                            Expanded(
                              child: TextField(
                                controller: _textCtrl,
                                focusNode: _focusNode,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search events…',
                                  hintStyle: TextStyle(
                                    fontSize: 13,
                                    color: iconColor,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (v) {
                                  widget.onChanged(v);
                                  setState(() => _showRecent = v.isEmpty);
                                },
                                onSubmitted: _onSubmit,
                                onTap: () {
                                  if (_textCtrl.text.isEmpty) {
                                    setState(() => _showRecent = true);
                                  }
                                },
                              ),
                            ),
                            if (_textCtrl.text.isNotEmpty)
                              GestureDetector(
                                onTap: _clearSearch,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Icon(Icons.close, size: 14, color: iconColor),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Result count badge
                    if (widget.resultCount != null && _textCtrl.text.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      _CountBadge(count: widget.resultCount!, isDark: isDark),
                    ],

                    // Filter button
                    const SizedBox(width: 6),
                    _FilterButton(
                      filters: _filters,
                      isDark: isDark,
                      onFiltersChanged: (f) {
                        setState(() => _filters = f);
                        widget.onFiltersChanged?.call(f);
                      },
                    ),

                    // Close (non-always-expanded mode)
                    if (!widget.alwaysExpanded) ...[
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: widget.onToggle,
                        child: Icon(Icons.keyboard_arrow_up, size: 20, color: iconColor),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // ── Filter chip row ──────────────────────────────────────────
          if (_filters.hasActiveFilters)
            SizeTransition(
              sizeFactor: _expandAnim,
              child: _ActiveFilterChips(
                filters: _filters,
                isDark: isDark,
                onRemoveCategory: (cat) {
                  setState(() {
                    final newCats = Set<EventCategory>.from(_filters.categories)..remove(cat);
                    _filters = _filters.copyWith(categories: newCats);
                  });
                  widget.onFiltersChanged?.call(_filters);
                },
                onClearAll: () {
                  setState(() => _filters = const TimelineSearchFilters());
                  widget.onFiltersChanged?.call(_filters);
                },
              ),
            ),

          // ── Recent searches dropdown ─────────────────────────────────
          if (_showRecent && _recentSearches.isNotEmpty)
            _RecentSearches(
              searches: _recentSearches,
              isDark: isDark,
              onSelect: (s) {
                _textCtrl.text = s;
                widget.onChanged(s);
                setState(() => _showRecent = false);
              },
              onRemove: (s) {
                setState(() => _recentSearches.remove(s));
              },
            ),

          // ── Toggle button (when collapsed) ───────────────────────────
          if (!widget.alwaysExpanded && !widget.visible)
            GestureDetector(
              onTap: widget.onToggle,
              child: Container(
                width: double.infinity,
                height: 32,
                color: bg,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search, size: 14, color: iconColor),
                    const SizedBox(width: 6),
                    Text(
                      'Search events',
                      style: TextStyle(fontSize: 12, color: iconColor),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TimelineSearchFilters
// ---------------------------------------------------------------------------

class TimelineSearchFilters {
  final Set<EventCategory> categories;
  final double minImportance;
  final double maxImportance;
  final double? minYear;
  final double? maxYear;

  const TimelineSearchFilters({
    this.categories = const {},
    this.minImportance = 1,
    this.maxImportance = 10,
    this.minYear,
    this.maxYear,
  });

  bool get hasActiveFilters =>
      categories.isNotEmpty ||
      minImportance > 1 ||
      maxImportance < 10 ||
      minYear != null ||
      maxYear != null;

  bool matches(TimelineEvent event) {
    if (categories.isNotEmpty && !categories.contains(event.category)) return false;
    if (event.importance < minImportance || event.importance > maxImportance) return false;
    if (minYear != null && event.yearFraction < minYear!) return false;
    if (maxYear != null && event.yearFraction > maxYear!) return false;
    return true;
  }

  TimelineSearchFilters copyWith({
    Set<EventCategory>? categories,
    double? minImportance,
    double? maxImportance,
    double? minYear,
    double? maxYear,
  }) {
    return TimelineSearchFilters(
      categories: categories ?? this.categories,
      minImportance: minImportance ?? this.minImportance,
      maxImportance: maxImportance ?? this.maxImportance,
      minYear: minYear ?? this.minYear,
      maxYear: maxYear ?? this.maxYear,
    );
  }
}

// ---------------------------------------------------------------------------
// _FilterButton — opens filter bottom sheet
// ---------------------------------------------------------------------------

class _FilterButton extends StatelessWidget {
  final TimelineSearchFilters filters;
  final bool isDark;
  final ValueChanged<TimelineSearchFilters> onFiltersChanged;

  const _FilterButton({
    required this.filters,
    required this.isDark,
    required this.onFiltersChanged,
  });

  @override
  Widget build(BuildContext context) {
    final active = filters.hasActiveFilters;
    return GestureDetector(
      onTap: () => _showFilterSheet(context),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF2196F3).withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? const Color(0xFF2196F3) : (isDark ? Colors.white24 : Colors.black16),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.tune,
              size: 16,
              color: active ? const Color(0xFF2196F3) : (isDark ? Colors.white60 : Colors.black45),
            ),
            if (active)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2196F3),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _FilterSheet(
        filters: filters,
        isDark: isDark,
        onApply: (f) {
          Navigator.pop(context);
          onFiltersChanged(f);
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _FilterSheet
// ---------------------------------------------------------------------------

class _FilterSheet extends StatefulWidget {
  final TimelineSearchFilters filters;
  final bool isDark;
  final ValueChanged<TimelineSearchFilters> onApply;

  const _FilterSheet({
    required this.filters,
    required this.isDark,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late Set<EventCategory> _cats;
  late RangeValues _importance;

  @override
  void initState() {
    super.initState();
    _cats = Set.from(widget.filters.categories);
    _importance = RangeValues(widget.filters.minImportance, widget.filters.maxImportance);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final bg = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white54 : Colors.black45;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Text('Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() {
                  _cats.clear();
                  _importance = const RangeValues(1, 10);
                }),
                child: Text('Reset', style: TextStyle(fontSize: 12, color: const Color(0xFF2196F3))),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Category
          Text('Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: subColor, letterSpacing: 0.6)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: EventCategory.values.map((cat) {
              final selected = _cats.contains(cat);
              return FilterChip(
                label: Text(cat.label, style: const TextStyle(fontSize: 11)),
                selected: selected,
                onSelected: (v) => setState(() {
                  if (v) _cats.add(cat); else _cats.remove(cat);
                }),
                selectedColor: cat.color.withValues(alpha: 0.2),
                checkmarkColor: cat.color,
                side: BorderSide(color: selected ? cat.color : Colors.transparent),
                labelStyle: TextStyle(color: selected ? cat.color : subColor),
                backgroundColor: isDark ? const Color(0xFF252540) : const Color(0xFFF4F4F8),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Importance
          Text('Importance: ${_importance.start.toInt()}–${_importance.end.toInt()}',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: subColor, letterSpacing: 0.6)),
          RangeSlider(
            values: _importance,
            min: 1,
            max: 10,
            divisions: 9,
            activeColor: const Color(0xFF2196F3),
            onChanged: (v) => setState(() => _importance = v),
          ),
          const SizedBox(height: 16),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onApply(
                TimelineSearchFilters(
                  categories: _cats,
                  minImportance: _importance.start,
                  maxImportance: _importance.end,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
              child: const Text('Apply Filters', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _ActiveFilterChips — horizontal row showing applied filters
// ---------------------------------------------------------------------------

class _ActiveFilterChips extends StatelessWidget {
  final TimelineSearchFilters filters;
  final bool isDark;
  final ValueChanged<EventCategory> onRemoveCategory;
  final VoidCallback onClearAll;

  const _ActiveFilterChips({
    required this.filters,
    required this.isDark,
    required this.onRemoveCategory,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final subColor = isDark ? Colors.white38 : Colors.black38;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 6),
      child: Row(
        children: [
          ...filters.categories.map((cat) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _Chip(
                  label: cat.label,
                  color: cat.color,
                  onRemove: () => onRemoveCategory(cat),
                  isDark: isDark,
                ),
              )),
          if (filters.minImportance > 1 || filters.maxImportance < 10)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _Chip(
                label: 'Imp ${filters.minImportance.toInt()}–${filters.maxImportance.toInt()}',
                color: const Color(0xFF2196F3),
                onRemove: onClearAll,
                isDark: isDark,
              ),
            ),
          GestureDetector(
            onTap: onClearAll,
            child: Text('Clear all', style: TextStyle(fontSize: 11, color: const Color(0xFF2196F3))),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onRemove;
  final bool isDark;

  const _Chip({required this.label, required this.color, required this.onRemove, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 3, 4, 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: 12, color: color),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _RecentSearches
// ---------------------------------------------------------------------------

class _RecentSearches extends StatelessWidget {
  final List<String> searches;
  final bool isDark;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onRemove;

  const _RecentSearches({
    required this.searches,
    required this.isDark,
    required this.onSelect,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF252540) : Colors.white;
    final border = isDark ? Colors.white12 : Colors.black12;
    final textColor = isDark ? Colors.white70 : Colors.black87;
    final iconColor = isDark ? Colors.white38 : Colors.black38;

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: searches.take(6).map((s) => ListTile(
          dense: true,
          leading: Icon(Icons.history, size: 14, color: iconColor),
          title: Text(s, style: TextStyle(fontSize: 13, color: textColor)),
          trailing: GestureDetector(
            onTap: () => onRemove(s),
            child: Icon(Icons.close, size: 14, color: iconColor),
          ),
          onTap: () => onSelect(s),
          minLeadingWidth: 16,
        )).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _CountBadge
// ---------------------------------------------------------------------------

class _CountBadge extends StatelessWidget {
  final int count;
  final bool isDark;
  const _CountBadge({required this.count, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF2196F3).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2196F3).withValues(alpha: 0.4)),
      ),
      child: Text(
        '$count',
        style: const TextStyle(fontSize: 11, color: Color(0xFF2196F3), fontWeight: FontWeight.bold),
      ),
    );
  }
}
