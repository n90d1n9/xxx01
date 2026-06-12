import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../core/models/task_model.dart';
import '../../core/providers/gantt_providers.dart';
import '../../core/utils/critical_path.dart';
import '../../shared/theme/gantt_theme.dart';

// ─── Layout engine ─────────────────────────────────────────────────────────────

class _NodeLayout {
  final Task task;
  Offset position;
  final Size size;
  final bool isCritical;
  const _NodeLayout({
    required this.task,
    required this.position,
    required this.size,
    required this.isCritical,
  });
}

class _NetworkLayout {
  final List<_NodeLayout> nodes;
  final Size canvasSize;
  const _NetworkLayout({required this.nodes, required this.canvasSize});

  static const double nodeW = 180;
  static const double nodeH = 72;
  static const double hGap = 60;
  static const double vGap = 24;

  /// Sugiyama-inspired layered layout:
  /// 1. Assign layers via longest path from source
  /// 2. Sort within layers by dependencies
  /// 3. Position with centering
  factory _NetworkLayout.fromTasks(List<Task> tasks, Set<String> criticalIds) {
    if (tasks.isEmpty)
      return const _NetworkLayout(nodes: [], canvasSize: Size.zero);

    final taskMap = {for (final t in tasks) t.id: t};

    // ── Step 1: compute layer (column) for each task ──────────────────────────
    final layer = <String, int>{};
    void assignLayer(String id, [Set<String>? visiting]) {
      visiting ??= {};
      if (visiting.contains(id)) return; // cycle guard
      if (layer.containsKey(id)) return;
      visiting.add(id);
      final t = taskMap[id];
      if (t == null) return;
      int maxPredLayer = -1;
      for (final dep in t.dependencies) {
        assignLayer(dep.predecessorId, Set.from(visiting));
        maxPredLayer = math.max(maxPredLayer, layer[dep.predecessorId] ?? -1);
      }
      layer[id] = maxPredLayer + 1;
    }

    for (final t in tasks) assignLayer(t.id);

    // ── Step 2: group by layer ────────────────────────────────────────────────
    final layers = <int, List<Task>>{};
    for (final t in tasks) {
      layers.putIfAbsent(layer[t.id] ?? 0, () => []).add(t);
    }

    // ── Step 3: position nodes ────────────────────────────────────────────────
    final nodes = <_NodeLayout>[];
    double maxX = 0;
    final sortedLayerKeys = layers.keys.toList()..sort();

    for (final col in sortedLayerKeys) {
      final colTasks = layers[col]!;
      final x = col * (nodeW + hGap) + 20;
      final totalH = colTasks.length * (nodeH + vGap) - vGap;
      double y = 20;
      for (final t in colTasks) {
        nodes.add(_NodeLayout(
          task: t,
          position: Offset(x, y),
          size: const Size(nodeW, nodeH),
          isCritical: criticalIds.contains(t.id),
        ));
        y += nodeH + vGap;
        maxX = math.max(maxX, x + nodeW);
        _ = totalH; // suppress unused
      }
    }

    final maxY = nodes.map((n) => n.position.dy + nodeH).fold(0.0, math.max);
    return _NetworkLayout(
      nodes: nodes,
      canvasSize: Size(maxX + 40, maxY + 40),
    );
  }

  _NodeLayout? nodeFor(String id) {
    try {
      return nodes.firstWhere((n) => n.task.id == id);
    } catch (_) {
      return null;
    }
  }
}

// ─── Painter ──────────────────────────────────────────────────────────────────

class _NetworkPainter extends CustomPainter {
  final _NetworkLayout layout;
  final String? selectedId;
  final Set<String> criticalIds;

  const _NetworkPainter(
      {required this.layout, this.selectedId, required this.criticalIds});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw edges first
    for (final node in layout.nodes) {
      for (final dep in node.task.dependencies) {
        final pred = layout.nodeFor(dep.predecessorId);
        if (pred == null) continue;

        final isCrit = criticalIds.contains(node.task.id) &&
            criticalIds.contains(dep.predecessorId);
        final paint = Paint()
          ..color = isCrit ? const Color(0xFFEF4444) : const Color(0xFF334155)
          ..strokeWidth = isCrit ? 2.0 : 1.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

        final from = Offset(pred.position.dx + _NetworkLayout.nodeW,
            pred.position.dy + _NetworkLayout.nodeH / 2);
        final to = Offset(
            node.position.dx, node.position.dy + _NetworkLayout.nodeH / 2);
        final dx = (to.dx - from.dx) * 0.5;
        final path = Path()
          ..moveTo(from.dx, from.dy)
          ..cubicTo(from.dx + dx, from.dy, to.dx - dx, to.dy, to.dx, to.dy);
        canvas.drawPath(path, paint);

        // Arrowhead
        final angle = math.atan2(to.dy - from.dy, to.dx - from.dx);
        const aLen = 8.0;
        final arrowPaint = Paint()
          ..color = isCrit ? const Color(0xFFEF4444) : const Color(0xFF334155)
          ..style = PaintingStyle.fill;
        final arrowPath = Path()
          ..moveTo(to.dx, to.dy)
          ..lineTo(to.dx - aLen * math.cos(angle - 0.4),
              to.dy - aLen * math.sin(angle - 0.4))
          ..lineTo(to.dx - aLen * math.cos(angle + 0.4),
              to.dy - aLen * math.sin(angle + 0.4))
          ..close();
        canvas.drawPath(arrowPath, arrowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_NetworkPainter old) =>
      old.layout != layout || old.selectedId != selectedId;
}

// ─── Node widget ──────────────────────────────────────────────────────────────

class _NetworkNode extends StatelessWidget {
  final _NodeLayout layout;
  final bool isSelected;
  final VoidCallback onTap;

  const _NetworkNode(
      {required this.layout, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = layout.task;
    final color = t.displayColor;
    final early = t.customFields['es'] as int? ?? 0;
    final earlyF = t.customFields['ef'] as int? ?? (early + t.durationDays - 1);
    final late = t.customFields['ls'] as int? ?? early;
    final lateF = t.customFields['lf'] as int? ?? earlyF;
    final float = late - early;

    return Positioned(
      left: layout.position.dx,
      top: layout.position.dy,
      width: _NetworkLayout.nodeW,
      height: _NetworkLayout.nodeH,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: GanttAnimations.fast,
          decoration: BoxDecoration(
            color: GanttTheme.surface2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? GanttTheme.accentLight
                  : layout.isCritical
                      ? const Color(0xFFEF4444)
                      : GanttTheme.surface4,
              width: isSelected || layout.isCritical ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? GanttTheme.accent.withOpacity(0.3)
                    : Colors.black26,
                blurRadius: isSelected ? 12 : 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Column(children: [
            // Top row: ES | Duration | EF
            Container(
              height: 20,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(7)),
              ),
              child: Row(children: [
                Expanded(
                    child: Center(
                        child: Text('$early',
                            style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: GanttTheme.textSecondary)))),
                Container(width: 1, height: 14, color: GanttTheme.surface4),
                Expanded(
                    flex: 2,
                    child: Center(
                        child: Text('${t.durationDays}d',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: color)))),
                Container(width: 1, height: 14, color: GanttTheme.surface4),
                Expanded(
                    child: Center(
                        child: Text('$earlyF',
                            style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: GanttTheme.textSecondary)))),
              ]),
            ),
            // Middle: task title
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Center(
                    child: Text(t.title,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: GanttTheme.textPrimary),
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis)),
              ),
            ),
            // Bottom row: LS | Float | LF
            Container(
              height: 20,
              decoration: BoxDecoration(
                color: float == 0
                    ? const Color(0xFFEF4444).withOpacity(0.1)
                    : GanttTheme.surface3,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(7)),
              ),
              child: Row(children: [
                Expanded(
                    child: Center(
                        child: Text('$late',
                            style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: GanttTheme.textMuted)))),
                Container(width: 1, height: 14, color: GanttTheme.surface4),
                Expanded(
                    flex: 2,
                    child: Center(
                        child: Text(float == 0 ? '★ Critical' : 'Float: $float',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: float == 0
                                    ? const Color(0xFFEF4444)
                                    : GanttTheme.textMuted)))),
                Container(width: 1, height: 14, color: GanttTheme.surface4),
                Expanded(
                    child: Center(
                        child: Text('$lateF',
                            style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: GanttTheme.textMuted)))),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─── Main view ────────────────────────────────────────────────────────────────

class NetworkDiagramView extends ConsumerStatefulWidget {
  const NetworkDiagramView({super.key});
  @override
  ConsumerState<NetworkDiagramView> createState() => _NetworkDiagramViewState();
}

class _NetworkDiagramViewState extends ConsumerState<NetworkDiagramView> {
  final _transformCtrl = TransformationController();
  double _zoom = 1.0;

  @override
  void dispose() {
    _transformCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasks =
        ref.watch(tasksProvider).where((t) => !_isGroupHeader(t)).toList();
    final criticalIds = ref.watch(criticalPathIdsProvider);
    final selectedId = ref.watch(selectedTaskIdProvider);

    // Enrich tasks with CPM ES/EF/LS/LF values
    final enriched = _enrichWithCpm(tasks);
    final layout = _NetworkLayout.fromTasks(enriched, criticalIds);

    if (tasks.isEmpty) {
      return const Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.account_tree_outlined,
            size: 48, color: GanttTheme.textDisabled),
        SizedBox(height: 12),
        Text('No tasks to display',
            style: TextStyle(fontSize: 14, color: GanttTheme.textMuted)),
      ]));
    }

    return Column(children: [
      // Header
      Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
            color: GanttTheme.surface1,
            border: Border(bottom: BorderSide(color: GanttTheme.surface4))),
        child: Row(children: [
          const Icon(Icons.account_tree_outlined,
              size: 15, color: GanttTheme.textSecondary),
          const SizedBox(width: 8),
          const Text('Network Diagram (PERT)',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: GanttTheme.textPrimary)),
          const SizedBox(width: 16),
          _Legend(color: const Color(0xFFEF4444), label: 'Critical path'),
          const SizedBox(width: 12),
          _Legend(color: GanttTheme.surface4, label: 'Float path'),
          const Spacer(),
          // Zoom controls
          IconButton(
              icon: const Icon(Icons.zoom_out, size: 14),
              color: GanttTheme.textMuted,
              onPressed: () => _setZoom(_zoom - 0.1),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24)),
          Text('${(_zoom * 100).toInt()}%',
              style:
                  const TextStyle(fontSize: 10, color: GanttTheme.textMuted)),
          IconButton(
              icon: const Icon(Icons.zoom_in, size: 14),
              color: GanttTheme.textMuted,
              onPressed: () => _setZoom(_zoom + 0.1),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24)),
          const SizedBox(width: 8),
          TextButton(
              onPressed: _resetView,
              child: const Text('Reset view', style: TextStyle(fontSize: 11))),
        ]),
      ),

      // Diagram
      Expanded(
        child: InteractiveViewer(
          transformationController: _transformCtrl,
          minScale: 0.3,
          maxScale: 3.0,
          boundaryMargin: const EdgeInsets.all(200),
          onInteractionUpdate: (d) =>
              setState(() => _zoom = _transformCtrl.value.getMaxScaleOnAxis()),
          child: SizedBox(
            width: layout.canvasSize.width,
            height: layout.canvasSize.height,
            child: Stack(children: [
              // Edge layer (canvas)
              CustomPaint(
                size: layout.canvasSize,
                painter: _NetworkPainter(
                    layout: layout,
                    selectedId: selectedId,
                    criticalIds: criticalIds),
              ),
              // Node widgets
              ...layout.nodes.map((n) => _NetworkNode(
                    layout: n,
                    isSelected: selectedId == n.task.id,
                    onTap: () => ref
                        .read(selectedTaskIdProvider.notifier)
                        .state = n.task.id,
                  )),
            ]),
          ),
        ),
      ),

      // Legend footer
      Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
            color: GanttTheme.surface1,
            border: Border(top: BorderSide(color: GanttTheme.surface4))),
        child: Row(children: [
          const Text(
              'ES = Early Start  ·  EF = Early Finish  ·  LS = Late Start  ·  LF = Late Finish  ·  Float = LS − ES',
              style: TextStyle(fontSize: 9, color: GanttTheme.textDisabled)),
          const Spacer(),
          Text(
              '${tasks.length} tasks  ·  ${criticalIds.length} on critical path',
              style:
                  const TextStyle(fontSize: 9, color: GanttTheme.textDisabled)),
        ]),
      ),
    ]);
  }

  void _setZoom(double z) {
    final clamped = z.clamp(0.3, 3.0);
    final m = Matrix4.identity()..scale(clamped);
    _transformCtrl.value = m;
    setState(() => _zoom = clamped);
  }

  void _resetView() {
    _transformCtrl.value = Matrix4.identity();
    setState(() => _zoom = 1.0);
  }

  /// Enriches tasks with CPM early/late start/finish stored in customFields
  /// so nodes can display them without mutating the real model.
  List<Task> _enrichWithCpm(List<Task> tasks) {
    final taskMap = {for (final t in tasks) t.id: t};
    final es = <String, int>{};
    final ef = <String, int>{};

    // Forward pass
    for (final t in tasks) {
      int maxPred = -1;
      for (final dep in t.dependencies) {
        maxPred = math.max(maxPred, ef[dep.predecessorId] ?? -1);
      }
      es[t.id] = maxPred + 1;
      ef[t.id] = es[t.id]! + t.durationDays - 1;
    }

    final projectEnd = ef.values.fold(0, math.max);
    final ls = <String, int>{};
    final lf = <String, int>{};

    // Backward pass (reversed topological order)
    final reversed = tasks.reversed.toList();
    for (final t in reversed) {
      final successors = tasks
          .where((s) => s.dependencies.any((d) => d.predecessorId == t.id));
      if (successors.isEmpty) {
        lf[t.id] = projectEnd;
      } else {
        lf[t.id] = successors
            .map((s) => ls[s.id] ?? projectEnd)
            .fold(projectEnd, math.min);
      }
      ls[t.id] = lf[t.id]! - t.durationDays + 1;
    }

    return tasks.map((t) {
      final fields = Map<String, dynamic>.from(t.customFields)
        ..['es'] = es[t.id] ?? 0
        ..['ef'] = ef[t.id] ?? 0
        ..['ls'] = ls[t.id] ?? 0
        ..['lf'] = lf[t.id] ?? 0;
      return t.copyWith(customFields: fields);
    }).toList();
  }

  bool _isGroupHeader(Task t) => t.customFields['__isGroupHeader'] == true;
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 20, height: 2, color: color),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(fontSize: 10, color: GanttTheme.textMuted)),
      ]);
}
