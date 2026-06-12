import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../core/providers/gantt_providers.dart';
import '../../shared/theme/gantt_theme.dart';
import '../network/network_diagram_view.dart';
import '../portfolio/portfolio_view.dart';
import '../portfolio/role_access_control.dart';
import '../notifications/notification_panel.dart';
import '../analytics/analytics_panel.dart';
import 'gantt_chart_viewport.dart';
import 'gantt_toolbar.dart';
import 'gantt_screen.dart';
import 'gantt_status_bar.dart';
import 'audit_panel.dart';
import 'snapshot_panel.dart';
import 'task_detail_panel.dart';

// ─── View mode ────────────────────────────────────────────────────────────────

enum AppViewMode { gantt, network, scurve, treemap, team }

final appViewModeProvider =
    StateProvider<AppViewMode>((ref) => AppViewMode.gantt);
final teamPanelOpenProvider = StateProvider<bool>((ref) => false);

// ─── Root app shell ────────────────────────────────────────────────────────────

class GanttAppShell extends ConsumerWidget {
  const GanttAppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(appViewModeProvider);
    final selectedId = ref.watch(selectedTaskIdProvider);
    final analyticsOpen = ref.watch(analyticsOpenProvider);
    final auditOpen = ref.watch(auditPanelOpenProvider);
    final snapshotOpen = ref.watch(snapshotPanelOpenProvider);
    final notifOpen = ref.watch(notificationPanelOpenProvider);
    final teamOpen = ref.watch(teamPanelOpenProvider);

    Widget body;
    switch (viewMode) {
      case AppViewMode.gantt:
        body = const GanttChartViewport();
      case AppViewMode.network:
        body = const NetworkDiagramView();
      case AppViewMode.scurve:
        body = const SCurveChart();
      case AppViewMode.treemap:
        body = const TreemapView();
      case AppViewMode.team:
        body = const _TeamView();
    }

    return NotificationWatcher(
      child: Scaffold(
        backgroundColor: GanttTheme.surface0,
        body: Column(children: [
          const _AppHeader(),
          Expanded(
            child: Row(children: [
              // Main content
              Expanded(child: body),

              // Right panels — animated width expansion
              if (viewMode == AppViewMode.gantt && selectedId != null)
                _panel(const TaskDetailPanel()),

              if (analyticsOpen) _panel(const AnalyticsPanel()),

              if (auditOpen) _panel(const AuditPanel()),

              if (snapshotOpen) _panel(const SnapshotPanel()),

              if (notifOpen) _panel(const NotificationPanel()),

              if (teamOpen) _panel(const TeamMembersPanel()),
            ]),
          ),
          if (viewMode == AppViewMode.gantt) const GanttStatusBar(),
        ]),
      ),
    );
  }

  Widget _panel(Widget child) => AnimatedSize(
        duration: GanttAnimations.normal,
        curve: Curves.easeInOut,
        child: child,
      );
}

// ─── App header with view switcher ────────────────────────────────────────────

class _AppHeader extends ConsumerWidget {
  const _AppHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(appViewModeProvider);
    return Column(mainAxisSize: MainAxisSize.min, children: [
      // View switcher tab bar
      Container(
        height: 40,
        decoration: const BoxDecoration(
          color: GanttTheme.surface1,
          border: Border(bottom: BorderSide(color: GanttTheme.surface4)),
        ),
        child: Row(children: [
          const SizedBox(width: 12),
          // Project name / logo
          Row(children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [GanttTheme.accent, GanttTheme.accentLight]),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Icon(Icons.timeline, size: 11, color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Text('Enterprise Gantt',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: GanttTheme.textPrimary)),
          ]),
          const SizedBox(width: 20),
          // View tabs
          ...[
            (AppViewMode.gantt, Icons.calendar_view_week_outlined, 'Gantt'),
            (AppViewMode.network, Icons.account_tree_outlined, 'Network'),
            (AppViewMode.scurve, Icons.show_chart_outlined, 'S-Curve'),
            (AppViewMode.treemap, Icons.grid_view_outlined, 'Portfolio'),
          ].map((entry) => _ViewTab(
                icon: entry.$2,
                label: entry.$3,
                isActive: viewMode == entry.$1,
                onTap: () =>
                    ref.read(appViewModeProvider.notifier).state = entry.$1,
              )),
          const Spacer(),
          // Global actions
          const NotificationBell(),
          const SizedBox(width: 4),
          _HeaderIconBtn(
            icon: Icons.people_outline,
            tooltip: 'Team',
            isActive: ref.watch(teamPanelOpenProvider),
            onTap: () =>
                ref.read(teamPanelOpenProvider.notifier).update((v) => !v),
          ),
          const SizedBox(width: 4),
          _HeaderIconBtn(
            icon: Icons.analytics_outlined,
            tooltip: 'Analytics',
            isActive: ref.watch(analyticsOpenProvider),
            onTap: () =>
                ref.read(analyticsOpenProvider.notifier).update((v) => !v),
          ),
          const SizedBox(width: 4),
          _HeaderIconBtn(
            icon: Icons.history,
            tooltip: 'Audit Log',
            isActive: ref.watch(auditPanelOpenProvider),
            onTap: () =>
                ref.read(auditPanelOpenProvider.notifier).update((v) => !v),
          ),
          const SizedBox(width: 4),
          _HeaderIconBtn(
            icon: Icons.camera_outlined,
            tooltip: 'Snapshots',
            isActive: ref.watch(snapshotPanelOpenProvider),
            onTap: () =>
                ref.read(snapshotPanelOpenProvider.notifier).update((v) => !v),
          ),
          const SizedBox(width: 12),
        ]),
      ),
      // Gantt toolbar only in Gantt view
      if (viewMode == AppViewMode.gantt) const GanttToolbar(),
    ]);
  }
}

class _ViewTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _ViewTab(
      {required this.icon,
      required this.label,
      required this.isActive,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: GanttAnimations.fast,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
              color: isActive ? GanttTheme.accentLight : Colors.transparent,
              width: 2,
            )),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon,
                size: 13,
                color:
                    isActive ? GanttTheme.accentLight : GanttTheme.textMuted),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive
                        ? GanttTheme.accentLight
                        : GanttTheme.textMuted)),
          ]),
        ),
      );
}

class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isActive;
  final VoidCallback onTap;
  const _HeaderIconBtn(
      {required this.icon,
      required this.tooltip,
      required this.isActive,
      required this.onTap});

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: AnimatedContainer(
            duration: GanttAnimations.fast,
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isActive ? GanttTheme.accentDim : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon,
                size: 14,
                color:
                    isActive ? GanttTheme.accentLight : GanttTheme.textMuted),
          ),
        ),
      );
}

// ─── Team view (standalone full page) ────────────────────────────────────────

class _TeamView extends ConsumerWidget {
  const _TeamView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Row(children: [
      Expanded(flex: 2, child: _RoleLegend()),
      TeamMembersPanel(),
    ]);
  }
}

class _RoleLegend extends StatelessWidget {
  const _RoleLegend();

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Access Levels',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: GanttTheme.textPrimary)),
          const SizedBox(height: 24),
          ...ProjectRole.values.map((r) => Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                width: 340,
                decoration: BoxDecoration(
                  color: r.color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: r.color.withOpacity(0.3)),
                ),
                child: Row(children: [
                  Icon(r.icon, size: 18, color: r.color),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(r.label,
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: r.color)),
                        const SizedBox(height: 2),
                        Text(_desc(r),
                            style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                color: GanttTheme.textMuted)),
                      ])),
                ]),
              )),
        ]),
      );

  String _desc(ProjectRole r) => switch (r) {
        ProjectRole.viewer => 'Can view tasks and timeline only',
        ProjectRole.commenter => 'Can view and add comments',
        ProjectRole.editor => 'Can create, edit and move tasks',
        ProjectRole.manager => 'Can assign tasks, lock rows, set constraints',
        ProjectRole.owner => 'Full control including team management',
      };
}
