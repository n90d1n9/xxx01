# Timeline Chart V3 — Responsive & Platform-Adaptive Enhancements

## New files (V3 layer)

| File | Responsibility | Lines |
|------|----------------|-------|
| `timeline_responsive_shell.dart` | Top-level adaptive container — routes to compact/horizontal/widescreen layouts | ~250 |
| `timeline_vertical_list.dart` | Mobile event feed — sticky headers, swipe gestures, search highlight, chart sync | ~380 |
| `timeline_search_bar.dart` | Search + filter overlay — fuzzy match, category chips, importance range, recent history | ~480 |
| `timeline_gesture_layer.dart` | Platform-adaptive input — scroll wheel, trackpad, right-click menu, hover tooltip | ~310 |
| `timeline_export.dart` | Export & share — screenshot PNG, CSV, JSON, deep-link URL, event card render | ~350 |
| `timeline_annotations.dart` | User annotations — pins, range highlights, connection arrows, JSON persist | ~490 |

All V1 and V2 files are **unchanged**. V3 is purely additive.

---

## Platform matrix

| Feature | Mobile portrait | Mobile landscape | Tablet | Desktop |
|---------|----------------|-----------------|--------|---------|
| Layout mode | compact | horizontal | horizontal | widescreen |
| Timeline orientation | horizontal (mini) | horizontal | horizontal | horizontal |
| Event list | **vertical scroll** | bottom sheet | bottom sheet | **side panel** |
| Minimap/viewfinder | ✓ 36px strip | ✓ 44px strip | ✓ 44px strip | ✓ 44px strip |
| Search bar | collapsible icon | toggle | toggle | always visible |
| Side panel | ✗ | ✗ | ✗ | ✓ resizable |
| Gesture zoom | pinch | pinch | pinch | scroll wheel |
| Pan | drag | drag | drag | drag + trackpad |
| Right-click menu | ✗ | ✗ | ✗ | ✓ |
| Hover crosshair | ✗ | ✗ | ✗ | ✓ |
| Keyboard shortcuts | ✗ | ✗ | partial | ✓ full |
| Annotations | ✓ | ✓ | ✓ | ✓ |
| Export | ✓ | ✓ | ✓ | ✓ |

---

## Full architecture diagram (V1 + V2 + V3)

```
TimelineResponsiveShell            ← NEW V3: single mount point
  │
  ├── TimelineLayoutAdapter        ← NEW V2: resolves breakpoints
  │     compact < 480px
  │     horizontal 480–899px
  │     widescreen ≥ 900px
  │
  ├── [compact] _CompactLayout
  │     ├── TimelineSearchBar      ← NEW V3: collapsible, filter chips
  │     ├── TimelineChartV2        ← V2: mini 200px chart
  │     │     └── TimelineGestureLayer  ← NEW V3: platform input
  │     ├── TimelineViewfinder     ← V2: drag handles, density heatmap
  │     └── TimelineVerticalList   ← NEW V3: sticky headers, swipe actions
  │
  ├── [horizontal] _HorizontalLayout
  │     ├── TimelineSearchBar
  │     ├── TimelineChartV2 (flex)
  │     │     └── TimelineGestureLayer
  │     └── TimelineViewfinder
  │
  └── [widescreen] _WidescreenLayout
        ├── ResizableSplitPane     ← V2: drag divider
        │     ├── left: Column
        │     │     ├── TimelineSearchBar (always expanded)
        │     │     ├── TimelineChartV2 (flex)
        │     │     │     ├── TimelineGestureLayer
        │     │     │     └── TimelineAnnotationLayer  ← NEW V3 overlay
        │     │     └── TimelineViewfinder
        │     └── right: TimelineSidePanel  ← V2
        │           ├── _NavBar (back/forward history)
        │           ├── _EventDetail (tabs: Detail | Media | Related)
        │           │     └── _CategoryStats mini bar chart
        │           └── _ClusterList
        │
        └── TimelineAnnotationToolbar (floating)  ← NEW V3
```

---

## Data flow

```
User gesture
    │
    ▼  TimelineGestureLayer (normalises platform input)
    │
    ▼  TimelineScrollController (physics fling / zoom animation)
    │
    ├──▶ TimelineChartV2 rebuild
    │         ├── TimelineIntervalTree.query()   O(log n)
    │         ├── TimelineViewportCache check    O(1)
    │         ├── TimelineClusterer              O(k)
    │         └── TimelineEnhancedPainter        O(clusters)
    │
    ├──▶ TimelineViewfinder sync (viewfinderCtrl.updateView)
    │
    └──▶ TimelineVerticalList sync (via scrollController listener)
              └── scrolls to first visible event section
```

---

## Quick-start usage

```dart
// Minimal — auto-adapts to screen size
TimelineResponsiveShell(
  config: TimelineChartConfig(
    events: myEvents,
    initialScale: TimelineScale.century,
  ),
  eraBands: const [
    TimelineEraBand(startYear: -3000, endYear: 500,  label: 'Ancient',  color: Color(0x08E53935)),
    TimelineEraBand(startYear:   500, endYear: 1500, label: 'Medieval', color: Color(0x08FB8C00)),
    TimelineEraBand(startYear:  1500, endYear: 2025, label: 'Modern',   color: Color(0x081E88E5)),
  ],
)
```

```dart
// With annotations
final annotationStore = TimelineAnnotationStore();

Stack(
  children: [
    TimelineResponsiveShell(config: config),
    Positioned.fill(
      child: TimelineAnnotationLayer(
        store: annotationStore,
        axisYFraction: 0.5,
        viewState: scrollCtrl.value,
      ),
    ),
    Positioned(
      bottom: 120, right: 16,
      child: TimelineAnnotationToolbar(
        store: annotationStore,
        getCurrentYear: () => scrollCtrl.value.offsetYears,
      ),
    ),
  ],
)
```

```dart
// Export button in app bar
IconButton(
  icon: const Icon(Icons.ios_share),
  onPressed: () => TimelineExportSheet.show(
    context,
    visibleEvents: visibleEvents,
    allEvents: config.events,
    viewState: scrollCtrl.value,
    chartKey: chartRepaintKey,
  ),
)
```

---

## Vertical list (mobile) — what it does

The `TimelineVerticalList` is not just a plain `ListView`. It gives mobile users
a full-featured event browser that stays in sync with the mini-chart above it:

- **Sticky section headers** via `SliverPersistentHeader` — century/era grouping
- **Swipe right** → animates the mini-chart to that year (`scrollCtrl.animateToYear`)
- **Swipe left** → bookmarks the event (in-memory; host can persist)
- **Search highlight** — matched substrings rendered in bold with colour background
- **Importance strip** — left-edge vertical bar whose height encodes importance (1–10)
- **Bi-directional sync** — chart pan updates list scroll position and vice versa

---

## Gesture layer — platform differences

### Desktop / Web
```
Mouse wheel up/down    → zoom in/out at pointer position
Mouse wheel left/right → pan (trackpad horizontal swipe)  
Left drag              → pan with fling
Double click           → zoom 2.5× at click position
Right click            → context menu (copy year, zoom, fit)
Hover                  → crosshair + 500ms dwell tooltip
```

### Mobile / Touch
```
Single finger drag  → pan with fling
Two finger pinch    → zoom (auto-advances TimelineScale)
Double tap          → zoom 2.5× at tap position
Long press          → tooltip / context popup
```

---

## Annotations JSON schema

```json
{
  "pins": [
    { "id": "abc123", "year": 1066, "label": "Norman Conquest",
      "color": 4294951175, "icon": 983750 }
  ],
  "ranges": [
    { "id": "def456", "startYear": 1337, "endYear": 1453,
      "label": "Hundred Years War", "color": 571674624 }
  ],
  "connections": [
    { "id": "ghi789", "fromYear": 1776, "toYear": 1789,
      "label": "Revolutionary wave", "color": 4281626795 }
  ]
}
```

Save:  `prefs.setString('annotations', store.toJson())`  
Restore: `TimelineAnnotationStore.fromJson(prefs.getString('annotations') ?? '{}')`

---

## Export capabilities

| Format | What's included | How delivered |
|--------|----------------|---------------|
| Screenshot PNG | Entire chart widget at 2× pixel ratio | Clipboard (data URL) or host share |
| Visible events CSV | id, title, year, category, importance, description, tags | Clipboard text |
| All events JSON | Full event objects with media/references | Clipboard text |
| Event card PNG | Single event rendered as 400×200 styled card | Bytes (host can share) |
| Deep link URL | `#tl!{scale}!{offset}!{zoom}` fragment | Clipboard text |

---

## Extending further (V4 ideas)

| Feature | Where to add |
|---------|-------------|
| Multi-timeline (compare two datasets) | Add `List<TimelineChartConfig>` to shell, stack painters |
| Gantt rows (row-per-category) | Add `rowIndex` to `TimelineEvent`, extend lane layout |
| Collaborative annotations | Swap `TimelineAnnotationStore` for a real-time backend |
| Accessibility / screen reader | Wrap each cluster node in `Semantics` |
| Offline tile caching | Extend `TimelineIntervalTree` with paged data loading |
| Full video playback | Replace `_VideoThumbnail` with `video_player` |
| Print stylesheet | Add `TimelineExporter.renderFullTimeline()` at higher DPI |
