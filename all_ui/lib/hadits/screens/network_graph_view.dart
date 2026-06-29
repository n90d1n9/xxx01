// Network Graph View with animations
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/hadith.dart';
import '../models/line.dart';
import '../models/network_mode.dart';
import '../models/rawi.dart';
import '../states/hadith_provider.dart';
import '../states/network_graph_provider.dart';
import '../widgets/hadith_network_dialog.dart';
import '../widgets/line_legend_painter.dart';
import '../widgets/network_graph_painter.dart';
import '../widgets/network_painter.dart';
import '../widgets/rawi_detail_dialog.dart';

class NetworkGraphView extends ConsumerStatefulWidget {
  const NetworkGraphView({Key? key}) : super(key: key);

  @override
  ConsumerState<NetworkGraphView> createState() => _NetworkGraphViewState();
}

class _NetworkGraphViewState extends ConsumerState<NetworkGraphView>
    with TickerProviderStateMixin {
  late AnimationController _animController;
  late AnimationController _pulseController;
  late Animation<double> _animation;
  late Animation<double> _pulseAnimation;
  Offset? _lastPanPosition;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hadiths = ref.watch(filteredHadithsProvider);
    final rawis = ref.watch(rawiListProvider);
    final locale = ref.watch(localeProvider);
    final zoom = ref.watch(networkZoomProvider);
    final offset = ref.watch(networkOffsetProvider);
    final collapsed = ref.watch(collapsedNodesProvider);
    final selectedNode = ref.watch(selectedNodeProvider);
    final hoveredNode = ref.watch(hoveredNodeProvider);
    final is3D = ref.watch(is3DModeProvider);
    final rotationX = ref.watch(rotationXProvider);
    final rotationY = ref.watch(rotationYProvider);

    if (hadiths.isEmpty) {
      return Center(child: Text(tr(ref, 'no_hadiths')));
    }

    final nodes = _buildNetworkNodes(hadiths, rawis, locale);

    return Stack(
      children: [
        MouseRegion(
          onHover: (event) {
            _handleHover(event.localPosition, nodes, zoom, offset);
          },
          onExit: (event) {
            ref.read(hoveredNodeProvider.notifier).state = null;
          },
          child: GestureDetector(
            onScaleStart: (details) {
              _lastPanPosition = details.focalPoint;
            },
            onScaleUpdate: (details) {
              if (is3D && details.pointerCount == 1) {
                // 3D rotation with single finger/mouse
                final delta =
                    details.focalPoint -
                    (_lastPanPosition ?? details.focalPoint);
                ref.read(rotationYProvider.notifier).state += delta.dx * 0.01;
                ref.read(rotationXProvider.notifier).state += delta.dy * 0.01;
                _lastPanPosition = details.focalPoint;
              } else {
                // Regular pan and zoom
                ref
                    .read(networkZoomProvider.notifier)
                    .state = (zoom * details.scale).clamp(0.3, 4.0);
                ref.read(networkOffsetProvider.notifier).state =
                    offset + details.focalPointDelta;
              }
            },
            onTapUp: (details) {
              _handleTap(details.localPosition, nodes, zoom, offset);
            },
            child: AnimatedBuilder(
              animation: Listenable.merge([_animation, _pulseAnimation]),
              builder: (context, child) {
                return CustomPaint(
                  painter: EnhancedNetworkPainter(
                    nodes: nodes,
                    zoom: zoom,
                    offset: offset,
                    collapsedNodes: collapsed,
                    selectedNode: selectedNode,
                    hoveredNode: hoveredNode,
                    animation: _animation.value,
                    pulseAnimation: _pulseAnimation.value,
                    is3D: is3D,
                    rotationX: rotationX,
                    rotationY: rotationY,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          ),
        ),

        // Enhanced Control Panel
        Positioned(
          top: 16,
          right: 16,
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  // 3D Mode Toggle
                  Container(
                    decoration: BoxDecoration(
                      color: is3D ? Colors.teal.withOpacity(0.2) : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.threed_rotation,
                        color: is3D ? Colors.teal : null,
                      ),
                      tooltip: '3D Mode',
                      onPressed: () {
                        ref.read(is3DModeProvider.notifier).state = !is3D;
                        if (!is3D) {
                          ref.read(rotationXProvider.notifier).state = 0.3;
                          ref.read(rotationYProvider.notifier).state = 0.3;
                        }
                      },
                    ),
                  ),
                  const Divider(height: 16),
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: tr(ref, 'zoom_in'),
                    onPressed: () {
                      ref
                          .read(networkZoomProvider.notifier)
                          .state = (zoom + 0.2).clamp(0.3, 4.0);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    tooltip: tr(ref, 'zoom_out'),
                    onPressed: () {
                      ref
                          .read(networkZoomProvider.notifier)
                          .state = (zoom - 0.2).clamp(0.3, 4.0);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: tr(ref, 'reset_view'),
                    onPressed: () {
                      ref.read(networkZoomProvider.notifier).state = 1.0;
                      ref.read(networkOffsetProvider.notifier).state =
                          Offset.zero;
                      ref.read(rotationXProvider.notifier).state = 0.0;
                      ref.read(rotationYProvider.notifier).state = 0.0;
                      _animController.forward(from: 0);
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      collapsed.isEmpty ? Icons.unfold_less : Icons.unfold_more,
                    ),
                    tooltip:
                        collapsed.isEmpty
                            ? tr(ref, 'collapse_all')
                            : tr(ref, 'expand_all'),
                    onPressed: () {
                      if (collapsed.isEmpty) {
                        final hadithIds =
                            nodes
                                .where((n) => n.type == 'hadith')
                                .map((n) => n.id)
                                .toSet();
                        ref.read(collapsedNodesProvider.notifier).state =
                            hadithIds;
                      } else {
                        ref.read(collapsedNodesProvider.notifier).state = {};
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

        // Hover tooltip
        if (hoveredNode != null)
          Positioned(
            top: 80,
            right: 16,
            child: Card(
              elevation: 8,
              color: Colors.black87,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _buildHoverTooltip(
                  hoveredNode,
                  nodes,
                  hadiths,
                  rawis,
                  locale,
                ),
              ),
            ),
          ),

        // Legend (updated)
        Positioned(
          bottom: 16,
          left: 16,
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Legend',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  _buildLegendItem('Mutawatir', Colors.green, LineStyle.solid),
                  _buildLegendItem('Sahih', Colors.blue, LineStyle.solid),
                  _buildLegendItem('Hasan', Colors.orange, LineStyle.dashed),
                  _buildLegendItem('Daif', Colors.red, LineStyle.dotted),
                  const Divider(height: 16),
                  _buildLegendItem(
                    tr(ref, 'prophet_muhammad'),
                    Colors.purple,
                    LineStyle.solid,
                    icon: Icons.star,
                  ),
                  _buildLegendItem(
                    tr(ref, 'from_companion'),
                    Colors.teal,
                    LineStyle.solid,
                    icon: Icons.people,
                  ),
                  _buildLegendItem(
                    'Hadith',
                    Colors.grey,
                    LineStyle.solid,
                    icon: Icons.description,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHoverTooltip(
    String nodeId,
    List<NetworkNode> nodes,
    List<Hadith> hadiths,
    List<Rawi> rawis,
    String locale,
  ) {
    final node = nodes.firstWhereOrNull((n) => n.id == nodeId);
    if (node == null) return const SizedBox.shrink();

    if (node.type == 'hadith') {
      final hadith = hadiths.firstWhereOrNull((h) => h.id == nodeId);
      if (hadith == null) return const SizedBox.shrink();

      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 250),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.description,
                  color: _getGradeColor(hadith.grade),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Hadith #${hadith.number}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getGradeColor(hadith.grade),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                hadith.grade,
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hadith.translation.get(locale),
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            const Text(
              'Click to view details',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    } else if (node.type == 'companion') {
      final rawi = rawis.firstWhereOrNull((r) => r.id == nodeId);
      if (rawi == null) return const SizedBox.shrink();

      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 250),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: Colors.teal, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rawi.name.get(locale),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              rawi.name.ar,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              '${rawi.birthYear} - ${rawi.deathYear}',
              style: const TextStyle(color: Colors.white60, fontSize: 11),
            ),
            const SizedBox(height: 8),
            const Text(
              'Click to view details',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    } else {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tr(ref, 'prophet_muhammad'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'The final messenger of Allah',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      );
    }
  }

  void _handleHover(
    Offset position,
    List<NetworkNode> nodes,
    double zoom,
    Offset offset,
  ) {
    final size = MediaQuery.of(context).size;

    for (final node in nodes) {
      final screenPos = _getScreenPosition(node.position, size, zoom, offset);
      final distance = (screenPos - position).distance;
      final radius = _getNodeSize(node.type).width / 2 * zoom;

      if (distance < radius) {
        ref.read(hoveredNodeProvider.notifier).state = node.id;
        return;
      }
    }

    ref.read(hoveredNodeProvider.notifier).state = null;
  }

  void _handleTap(
    Offset position,
    List<NetworkNode> nodes,
    double zoom,
    Offset offset,
  ) {
    final size = MediaQuery.of(context).size;
    final collapsed = ref.read(collapsedNodesProvider);
    final hadiths = ref.read(hadithListProvider);
    final rawis = ref.read(rawiListProvider);

    for (final node in nodes) {
      if (collapsed.contains(node.id)) continue;

      final screenPos = _getScreenPosition(node.position, size, zoom, offset);
      final distance = (screenPos - position).distance;
      final nodeSize = _getNodeSize(node.type);
      final radius = (nodeSize.width / 2) * zoom;

      if (distance < radius) {
        ref.read(selectedNodeProvider.notifier).state = node.id;

        if (node.type == 'hadith') {
          final hadith = hadiths.firstWhereOrNull((h) => h.id == node.id);
          if (hadith != null) {
            showDialog(
              context: context,
              builder: (_) => HadithNetworkDialog(hadith: hadith),
            );
          }
        } else if (node.type == 'companion') {
          final rawi = rawis.firstWhereOrNull((r) => r.id == node.id);
          if (rawi != null) {
            showDialog(
              context: context,
              builder: (_) => RawiDetailDialog(rawi: rawi),
            );
          }
        } else if (node.type == 'prophet') {
          // Toggle collapse hadiths connected to prophet
          final prophetHadiths =
              nodes
                  .where(
                    (n) =>
                        n.type == 'hadith' && n.connectedTo.contains('prophet'),
                  )
                  .map((n) => n.id)
                  .toSet();

          if (prophetHadiths.every((id) => collapsed.contains(id))) {
            ref.read(collapsedNodesProvider.notifier).state = collapsed
                .difference(prophetHadiths);
          } else {
            ref.read(collapsedNodesProvider.notifier).state = collapsed.union(
              prophetHadiths,
            );
          }
        }

        return;
      }
    }
  }

  Offset _getScreenPosition(
    Offset nodePos,
    Size size,
    double zoom,
    Offset offset,
  ) {
    return Offset(
      size.width / 2 + (nodePos.dx * zoom) + offset.dx,
      size.height / 2 + (nodePos.dy * zoom) + offset.dy,
    );
  }

  Size _getNodeSize(String type) {
    switch (type) {
      case 'prophet':
        return const Size(120, 60);
      case 'companion':
        return const Size(100, 50);
      case 'hadith':
        return const Size(90, 45);
      default:
        return const Size(80, 40);
    }
  }

  Widget _buildLegendItem(
    String label,
    Color color,
    LineStyle style, {
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(icon, color: color, size: 16)
          else
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          const SizedBox(width: 8),
          if (style != LineStyle.solid)
            CustomPaint(
              size: const Size(30, 2),
              painter: LineLegendPainter(color: color, style: style),
            ),
          if (style != LineStyle.solid) const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  List<NetworkNode> _buildNetworkNodes(
    List<Hadith> hadiths,
    List<Rawi> rawis,
    String locale,
  ) {
    final nodes = <NetworkNode>[];
    final centerX = 0.0;
    final centerY = 0.0;

    nodes.add(
      NetworkNode(
        id: 'prophet',
        type: 'prophet',
        label: tr(ref, 'prophet_muhammad'),
        arabicLabel: 'محمد ﷺ',
        connectedTo: [],
        position: Offset(centerX, centerY),
      ),
    );

    final rawiRadius = 250.0;
    final companions =
        rawis.where((r) => hadiths.any((h) => h.sanad.contains(r.id))).toList();

    for (var i = 0; i < companions.length; i++) {
      final angle = (2 * 3.14159 * i) / companions.length;
      final x = centerX + rawiRadius * cos(angle);
      final y = centerY + rawiRadius * sin(angle);

      nodes.add(
        NetworkNode(
          id: companions[i].id,
          type: 'companion',
          label: companions[i].name.get(locale),
          arabicLabel: companions[i].name.ar,
          connectedTo: ['prophet'],
          position: Offset(x, y),
        ),
      );
    }

    final hadithRadius = 450.0;
    for (var i = 0; i < hadiths.length; i++) {
      final angle = (2 * 3.14159 * i) / hadiths.length;
      final x = centerX + hadithRadius * cos(angle);
      final y = centerY + hadithRadius * sin(angle);

      final connected =
          hadiths[i].sanad
              .where(
                (id) => id != 'prophet' && companions.any((c) => c.id == id),
              )
              .toList();

      nodes.add(
        NetworkNode(
          id: hadiths[i].id,
          type: 'hadith',
          label: 'H${hadiths[i].number}',
          arabicLabel:
              hadiths[i].arabicText.substring(
                0,
                min(20, hadiths[i].arabicText.length),
              ) +
              '...',
          grade: hadiths[i].grade,
          connectedTo: connected.isNotEmpty ? connected : ['prophet'],
          position: Offset(x, y),
        ),
      );
    }

    return nodes;
  }

  Color _getGradeColor(String grade) {
    switch (grade.toLowerCase()) {
      case 'mutawatir':
        return Colors.green;
      case 'sahih':
        return Colors.blue;
      case 'hasan':
        return Colors.orange;
      case 'daif':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
