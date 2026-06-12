import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'gantt_chart_screen_actions.dart';
import 'gantt_chart_shortcuts.dart';

/// Full-screen frame that hosts the Gantt workspace and its floating layers.
class GanttChartScreenShell extends StatelessWidget {
  const GanttChartScreenShell({
    required this.workspace,
    required this.actions,
    this.foregroundLayers = const [],
    super.key,
  });

  final Widget workspace;
  final GanttChartScreenActions actions;
  final List<Widget> foregroundLayers;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GanttChartShortcuts(
        onDismissPressed: actions.onDismiss,
        onSearchPressed: actions.onSearch,
        onToggleControlsPressed: actions.onToggleControls,
        onOpenSettingsPressed: actions.onOpenSettings,
        onClearFiltersPressed: actions.onClearFilters,
        onUndoPressed: actions.onUndo,
        onPreviousTaskPressed: actions.onPreviousTask,
        onNextTaskPressed: actions.onNextTask,
        child: SafeArea(
          child: Stack(children: [workspace, ...foregroundLayers]),
        ),
      ),
    );
  }
}

@Preview(name: 'Gantt chart screen shell')
Widget ganttChartScreenShellPreview() {
  return MaterialApp(
    home: GanttChartScreenShell(
      workspace: const ColoredBox(
        color: Color(0xFFF8FAFC),
        child: SizedBox.expand(),
      ),
      foregroundLayers: const [
        Positioned(
          left: 24,
          right: 24,
          bottom: 24,
          child: _PreviewSurface(height: 56),
        ),
        Positioned(
          top: 24,
          right: 24,
          bottom: 24,
          child: _PreviewSurface(width: 360),
        ),
      ],
      actions: GanttChartScreenActions.disabled,
    ),
  );
}

/// Lightweight placeholder surface used by the shell preview.
class _PreviewSurface extends StatelessWidget {
  const _PreviewSurface({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A0F172A),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
      ),
    );
  }
}
