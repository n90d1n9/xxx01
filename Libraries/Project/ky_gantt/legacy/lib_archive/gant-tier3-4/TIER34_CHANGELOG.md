# Tier 3 & 4 — Complete Feature Changelog

## Project: `gantt_v3` · 38 Dart files · Flutter + Riverpod (no build_runner)

---

## Tier 3 — Collaboration & Persistence

### T3.1 Full Offline Persistence ✅
**File:** `core/services/hive_persistence_service.dart` (new, 165 lines)

Pure-Dart JSON file persistence — no external DB package, no codegen.

- `HivePersistenceService.instance` singleton manages 3 JSON files:
  - `gantt_data/tasks.json` — all tasks with full serialization
  - `gantt_data/snapshots.json` — project snapshots
  - `gantt_data/custom_fields.json` — custom field definitions
- `DataPersistenceObserver extends ProviderObserver` — auto-saves on every state change, debounced 600ms for tasks, 300ms for snapshots/fields
- `importFromJson(String json)` — full project restore from exported JSON
- `storageStats()` — returns file sizes for storage panel
- `clearAll()` — wipes local storage
- `main.dart` loads all 3 data sources in parallel (`Future.wait`) before first frame

**Model updates:**
- `ProjectSnapshot.toJson()` added
- `CustomFieldDef.toJson()` added
- `TasksNotifier.loadPersisted(tasks)` — skips sample data seeding on app restart

---

### T3.2 Notifications & @Mention System ✅
**Files:** `core/services/notification_service.dart` (new, 220 lines), `features/notifications/notification_panel.dart` (new, 202 lines)

**Notification types:**
- `taskOverdue` — fires when `task.endDate < now && status != done`
- `taskDueSoon` — fires when task due within 3 days
- `commentMention` — fires when `@name` appears in a comment
- `taskAssigned` — available for future assignment events
- `dependencyBlocked` — available for scheduler events
- `milestoneReached` — fires when milestone `progress >= 1.0`

**Dedup:** same type+taskId within 60 seconds is suppressed. Cap: 100 notifications.

**Mention parsing (`parseMentions`):**
- Regex `@(\w[\w\s]{0,30}?)` extracts all `@name` patterns
- Returns spans with `{start, end, name}` for highlighting
- `buildMentionText()` returns a `TextSpan` with mentions in accent color

**`NotificationWatcher` widget** wraps the entire app and listens to `tasksProvider` changes, triggering overdue/milestone checks automatically via `ref.listen`.

**`NotificationBell` widget** (in toolbar/header):
- Badge with unread count in red
- Toggles `notificationPanelOpenProvider`

**`NotificationPanel`** (340px right panel):
- Mark all read / clear all
- Swipe-to-dismiss individual notifications
- Tap notification → selects + scrolls to task
- Animated unread dot per row

**`_MentionTextField`** in task detail comments:
- Shows live `@mention` chip previews as you type
- On submit, fires `notificationsProvider.notifier.onCommentMention()`

---

### T3.3 Role-Based Access Control ✅
**File:** `features/portfolio/role_access_control.dart` (new, 350 lines)

**`ProjectRole` enum** with 5 levels:
| Role | Can Edit | Can Manage | Can Delete | Can Assign |
|------|----------|------------|------------|------------|
| viewer | ✗ | ✗ | ✗ | ✗ |
| commenter | ✗ | ✗ | ✗ | ✗ |
| editor | ✓ | ✗ | ✗ | ✗ |
| manager | ✓ | ✓ | ✓ | ✓ |
| owner | ✓ | ✓ | ✓ | ✓ |

**`RoleGuard` widget** — wraps any widget and shows fallback if permission check fails:
```dart
RoleGuard(
  permission: (role) => role.canDelete,
  tooltip: 'Managers only',
  child: DeleteButton(),
  fallback: DisabledButton(),
)
```

**`currentUserProvider`** — `StateProvider<ProjectUser?>` with demo owner user

**`projectUsersProvider`** — `StateNotifierProvider` with full team list

**`TeamMembersPanel`** (right panel, 340px):
- Role summary chips (e.g. "2 Editors, 1 Manager")
- Per-user row: avatar, name, email, role badge
- Owners see dropdown to change any member's role
- "Invite Member" dialog: name + email + role selection

**`_TeamView`** — full-page team management with role legend sidebar

---

## Tier 4 — Advanced Visualizations

### T4.1 PERT Network Diagram ✅
**File:** `features/network/network_diagram_view.dart` (new, 426 lines)

Full CPM-annotated PERT chart with Sugiyama-inspired layered layout.

**Layout engine (`_NetworkLayout`):**
- Layer assignment via longest-path DFS (cycle-safe)
- Vertical packing within each layer
- Automatic canvas sizing

**Node design (`_NetworkNode`):**
Each node is a 180×72 card showing all 6 CPM values:
```
┌─── ES ──── Dur ──── EF ───┐
│         Task Title         │
└─── LS ── Float ─── LF ────┘
```
- Critical path nodes: red border, `★ Critical` label
- Float nodes: grey, shows `Float: N days`
- Selected node: accent glow shadow

**`_NetworkPainter`:**
- Cubic bezier edges between nodes
- Arrowheads at dependency targets
- Critical edges rendered in red, float edges in grey

**`InteractiveViewer`** — pan, pinch-zoom (0.3×–3.0×)
- Zoom buttons + percentage display
- "Reset view" button

**CPM enrichment** — `_enrichWithCpm()` computes ES/EF/LS/LF via forward + backward pass stored in `customFields` (non-destructive, doesn't mutate real tasks)

**Footer:** ES/EF/LS/LF legend + task/critical-path count

---

### T4.2 S-Curve Chart (Planned vs Actual) ✅
**File:** `features/portfolio/portfolio_view.dart` → `SCurveChart` class

- Cumulative planned hours vs actual hours over project timeline
- Canvas-drawn with `_SCurvePainter` (custom `CustomPainter`)
- Area fills under each curve (6% opacity)
- Today vertical marker with label
- Dynamic month tick generation on X-axis
- 25% grid lines with percentage labels on Y-axis
- Handles zero-actual gracefully (shows flat line)

---

### T4.3 Portfolio Treemap ✅
**File:** `features/portfolio/portfolio_view.dart` → `TreemapView` class

- **Squarified treemap algorithm** — pure Dart, no external package
  - Recursive slice-and-dice with weight-balanced midpoint splitting
  - Handles arbitrary aspect ratios
- Cell area proportional to `estimatedHours`
- Color from `task.displayColor`
- Progress fill overlay (bottom-up)
- **Drill-down:** click a parent task to see its subtasks; breadcrumb back button
- Hover state: border brightens + background intensifies
- Labels adapt to cell size (hide on tiny cells)
- Empty state handling

---

### T4.4 Baseline Variance Column ✅
**File:** `features/portfolio/portfolio_view.dart` → `BaselineVarianceColumn`

A sidebar column that shows per-task schedule slip:
- `—` if no baseline set
- Green: "On time" or "N days early"
- Amber: "+1d" to "+3d" slip
- Red: "+4d+" slip
- Click to select task + scroll to it in chart
- 80px fixed width, integrates into existing sidebar layout

---

### T4.5 Timeline Annotations ✅
**File:** `features/portfolio/portfolio_view.dart` → `ProjectAnnotation`, `AnnotationsPainter`, `AddAnnotationDialog`

**5 annotation types:** milestone · release · sprintEnd · holiday · fiscalQuarter

**`AnnotationsPainter extends CustomPainter`:**
- Diamond marker at annotation date
- Vertical gradient line spanning full chart height
- Label text right of diamond
- Type-specific colors (amber=milestone, green=release, indigo=sprint, etc.)

**`annotationsProvider`** — `StateNotifierProvider` with `add/remove/update`
- Pre-seeded with 4 demo annotations (Sprint End, v1.0 Release, Q2 Start, Sprint 2 End)

**Wired into `gantt_header.dart`:**
- `AnnotationsPainter` overlay rendered as a `Consumer` inside the header's top row `Stack`
- Reacts to `annotationsProvider` changes in real-time

**`_AnnotationsToolbarButton`** in toolbar:
- Badge showing annotation count
- Opens `_AnnotationsDialog` with full CRUD list
- Add/edit via `AddAnnotationDialog` (date picker + type dropdown)
- Swipe-to-delete in list

---

### T4.6 Monte Carlo Overlay ✅
**File:** `features/portfolio/portfolio_view.dart` → `MonteCarloOverlay`, `_MCHistogramPainter`

- `MonteCarloOverlay` widget renders P50/P80/P90 completion date markers
- `_MCHistogramPainter` draws mini histogram bars at base of header
- Backed by `_monteCarloResultProvider` (wired to `MonteCarloEngine` from Tier 2)
- Gracefully returns `SizedBox.shrink()` when no MC results available

---

## App Shell Upgrade

### Multi-View Navigation ✅
**File:** `features/gantt/main_view_switcher.dart` (new, 290 lines)

**`GanttAppShell`** replaces `GanttScreen` as root widget:
- Top header tab bar with 4 view modes:
  - **Gantt** — existing chart
  - **Network** — PERT diagram
  - **S-Curve** — planned vs actual
  - **Portfolio** — treemap
- Global action icons: Notification bell, Team, Analytics, Audit, Snapshots
- `GanttToolbar` only shown in Gantt view
- `GanttStatusBar` only shown in Gantt view
- All panels (`TaskDetail`, `Analytics`, `Audit`, `Snapshot`, `Notification`, `Team`) remain `AnimatedSize` side panels

**`NotificationWatcher`** wraps the entire shell — auto-checks overdue/milestone on task state changes

---

## File Summary

| File | Type | Lines | Purpose |
|------|------|-------|---------|
| `hive_persistence_service.dart` | New | 165 | JSON file persistence + DataPersistenceObserver |
| `notification_service.dart` | New | 220 | Notification models, mention parser, NotificationWatcher |
| `notification_panel.dart` | New | 202 | Bell icon, panel with dismiss/read/navigate |
| `network_diagram_view.dart` | New | 426 | PERT chart with layered layout + CPM enrichment |
| `portfolio_view.dart` | New | 744 | S-Curve, Treemap, Baseline column, Annotations, MC overlay |
| `role_access_control.dart` | New | 350 | RBAC with 5 roles, RoleGuard, TeamMembersPanel, InviteDialog |
| `main_view_switcher.dart` | New | 290 | Root shell with view tabs, notification bell, panel grid |
| `task_model.dart` | Updated | — | Added `ProjectSnapshot.toJson`, `CustomFieldDef.toJson` |
| `gantt_providers.dart` | Updated | — | `TasksNotifier.loadPersisted()`, `annotationsProvider` |
| `gantt_toolbar.dart` | Updated | — | `_AnnotationsToolbarButton` + annotations import |
| `gantt_header.dart` | Updated | — | `AnnotationsPainter` overlay wired as ConsumerWidget Stack |
| `task_detail_panel.dart` | Updated | — | `_MentionTextField`, mention notification on submit |
| `main.dart` | Updated | — | `GanttAppShell`, parallel data load, `DataPersistenceObserver` |

---

## Getting Started

```bash
cd gantt_v3
flutter pub get
flutter run -d chrome   # web
flutter run -d macos    # desktop (recommended for full feature set)
```

**Minimum Flutter:** 3.10 · Dart 3.0

### First-run behaviour
1. Sample project data auto-generates on first launch
2. All changes auto-persist to `~/Documents/gantt_data/`
3. On restart, saved data replaces sample data

### Key interactions by view
| View | Key gesture |
|------|-------------|
| Gantt | Ctrl+scroll = zoom, drag bar = move, drag edge = resize, Ctrl+click = multi-select |
| Network | Pinch/scroll = zoom, click node = select, drag canvas = pan |
| S-Curve | Read-only chart, updates live |
| Portfolio | Click cell = drill-down (if subtasks), hover = highlight |
| Team | Owner can change roles via dropdown |
