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
import '../widgets/hadith_network_dialog.dart';
import '../widgets/line_legend_painter.dart';
import '../widgets/network_graph_painter.dart';

class NetworkGraphView extends ConsumerStatefulWidget {
  const NetworkGraphView({Key? key}) : super(key: key);

  @override
  ConsumerState<NetworkGraphView> createState() => _NetworkGraphViewState();
}

class _NetworkGraphViewState extends ConsumerState<NetworkGraphView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;

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
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
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

    if (hadiths.isEmpty) {
      return Center(child: Text(tr(ref, 'no_hadiths')));
    }

    // Build network nodes
    final nodes = _buildNetworkNodes(hadiths, rawis, locale);

    return Stack(
      children: [
        // Network canvas
        GestureDetector(
          onScaleStart: (details) {
            // Store initial values for pan/zoom
          },
          onScaleUpdate: (details) {
            ref
                .read(networkZoomProvider.notifier)
                .state = (zoom * details.scale).clamp(0.5, 3.0);
            ref.read(networkOffsetProvider.notifier).state =
                offset + details.focalPointDelta;
          },
          child: CustomPaint(
            painter: NetworkGraphPainter(
              nodes: nodes,
              zoom: zoom,
              offset: offset,
              collapsedNodes: collapsed,
              selectedNode: selectedNode,
              animation: _animation.value,
              onNodeTap: (nodeId) {
                setState(() {
                  ref.read(selectedNodeProvider.notifier).state = nodeId;

                  // Find and show hadith details
                  final hadith = hadiths.firstWhereOrNull(
                    (h) => h.id == nodeId,
                  );
                  if (hadith != null) {
                    showDialog(
                      context: context,
                      builder: (_) => HadithNetworkDialog(hadith: hadith),
                    );
                  }
                });
              },
            ),
            child: Container(),
          ),
        ),

        // Control panel
        Positioned(
          top: 16,
          right: 16,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: tr(ref, 'zoom_in'),
                    onPressed: () {
                      ref
                          .read(networkZoomProvider.notifier)
                          .state = (zoom + 0.2).clamp(0.5, 3.0);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    tooltip: tr(ref, 'zoom_out'),
                    onPressed: () {
                      ref
                          .read(networkZoomProvider.notifier)
                          .state = (zoom - 0.2).clamp(0.5, 3.0);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: tr(ref, 'reset_view'),
                    onPressed: () {
                      ref.read(networkZoomProvider.notifier).state = 1.0;
                      ref.read(networkOffsetProvider.notifier).state =
                          Offset.zero;
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
                        ref.read(collapsedNodesProvider.notifier).state =
                            nodes.map((n) => n.id).toSet();
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

        // Legend
        Positioned(
          bottom: 16,
          left: 16,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLegendItem('Mutawatir', Colors.green, LineStyle.solid),
                  _buildLegendItem('Sahih', Colors.blue, LineStyle.solid),
                  _buildLegendItem('Hasan', Colors.orange, LineStyle.dashed),
                  _buildLegendItem('Daif', Colors.red, LineStyle.dotted),
                  const Divider(height: 16),
                  _buildLegendItem(
                    tr(ref, 'from_prophet'),
                    Colors.purple,
                    LineStyle.solid,
                    shape: NodeShape.star,
                  ),
                  _buildLegendItem(
                    tr(ref, 'from_companion'),
                    Colors.teal,
                    LineStyle.solid,
                    shape: NodeShape.circle,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    String label,
    Color color,
    LineStyle style, {
    NodeShape shape = NodeShape.circle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (shape == NodeShape.star)
            Icon(Icons.star, color: color, size: 16)
          else if (shape == NodeShape.hexagon)
            Icon(Icons.hexagon, color: color, size: 16)
          else
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
    final centerX = 400.0;
    final centerY = 300.0;

    // Add Prophet Muhammad node at center
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

    // Add companion/rawi nodes in a circle around prophet
    final rawiRadius = 200.0;
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

    // Add hadith nodes in outer circle
    final hadithRadius = 350.0;
    for (var i = 0; i < hadiths.length; i++) {
      final angle = (2 * 3.14159 * i) / hadiths.length;
      final x = centerX + hadithRadius * cos(angle);
      final y = centerY + hadithRadius * sin(angle);

      // Find connected companions
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
          arabicLabel: hadiths[i].arabicText.substring(0, 20) + '...',
          grade: hadiths[i].grade,
          connectedTo: connected.isNotEmpty ? connected : ['prophet'],
          position: Offset(x, y),
        ),
      );
    }

    return nodes;
  }
}
