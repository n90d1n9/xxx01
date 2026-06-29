import 'dart:math' as math;
import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:vector_math/vector_math_64.dart' as vector_math;

import '../models/hadith.dart';
import '../models/line.dart';
import '../models/rawi.dart';
import '../states/hadith_provider.dart';
import '../states/network_graph_provider.dart';
import 'hadith_network_dialog.dart';
import 'line_legend_painter.dart';
import 'rawi_detail_dialog.dart';

// Add these to your existing state providers:
final is3DModeProvider = StateProvider<bool>((ref) => false);
final rotationXProvider = StateProvider<double>((ref) => 0.0);
final rotationYProvider = StateProvider<double>((ref) => 0.0);
final hoveredNodeProvider = StateProvider<String?>((ref) => null);
final draggedNodeProvider = StateProvider<String?>((ref) => null);
final autoRotateProvider = StateProvider<bool>((ref) => false);

// Enhanced NetworkNode with 3D coordinates
class NetworkNode3D {
  final String id;
  final String type;
  final String label;
  final String arabicLabel;
  final String? grade;
  final List<String> connectedTo;
  double x;
  double y;
  double z;

  NetworkNode3D({
    required this.id,
    required this.type,
    required this.label,
    required this.arabicLabel,
    this.grade,
    required this.connectedTo,
    required this.x,
    required this.y,
    required this.z,
  });
}

class ProjectedNode {
  final NetworkNode3D node;
  final double x;
  final double y;
  final double z;

  ProjectedNode({
    required this.node,
    required this.x,
    required this.y,
    required this.z,
  });
}

// Replace the NetworkGraphView with this enhanced 3D version:
class NetworkGraphView extends ConsumerStatefulWidget {
  const NetworkGraphView({Key? key}) : super(key: key);

  @override
  ConsumerState<NetworkGraphView> createState() => _NetworkGraphViewState();
}

class _NetworkGraphViewState extends ConsumerState<NetworkGraphView>
    with TickerProviderStateMixin {
  late AnimationController _animController;
  late AnimationController _pulseController;
  late AnimationController _autoRotateController;
  late Animation<double> _animation;
  late Animation<double> _pulseAnimation;

  double _scale = 1.0;
  Offset _offset = Offset.zero;
  Offset? _lastPanPosition;
  String? _draggedNodeId;
  Offset? _dragStartPos;

  // Store nodes locally to preserve positions
  List<NetworkNode3D> _nodes = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeNodes();
  }

  void _initializeAnimations() {
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

    _autoRotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..addListener(() {
      if (ref.read(autoRotateProvider)) {
        ref.read(rotationYProvider.notifier).state =
            _autoRotateController.value * 2 * math.pi;
      }
    });

    _animController.forward();
  }

  void _initializeNodes() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateNodes();
    });
  }

  void _updateNodes() {
    final hadiths = ref.read(filteredHadithsProvider);
    final rawis = ref.read(rawiListProvider);
    final locale = ref.read(localeProvider);
    final nodePositions = ref.read(nodePositionsProvider);

    final newNodes = _buildNetworkNodes(hadiths, rawis, locale);

    // Apply saved positions if they exist
    for (final node in newNodes) {
      if (nodePositions.containsKey(node.id)) {
        final savedPos = nodePositions[node.id]!;
        node.x = savedPos.dx;
        node.y = savedPos.dy;
      }
    }

    setState(() {
      _nodes = newNodes;
    });
  }

  @override
  void didUpdateWidget(NetworkGraphView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update nodes when data changes
    final hadiths = ref.read(filteredHadithsProvider);
    if (hadiths.length != _nodes.where((n) => n.type == 'hadith').length) {
      _updateNodes();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _pulseController.dispose();
    _autoRotateController.dispose();
    super.dispose();
  }

  void _toggleAutoRotate() {
    final current = ref.read(autoRotateProvider);
    ref.read(autoRotateProvider.notifier).state = !current;

    if (!current) {
      _autoRotateController.repeat();
    } else {
      _autoRotateController.stop();
    }
  }

  void _applyForceDirectedLayout(List<NetworkNode3D> nodes) {
    const iterations = 50;
    const repulsionStrength = 5000.0;
    const attractionStrength = 0.01;
    const damping = 0.9;

    for (var iter = 0; iter < iterations; iter++) {
      final velocities = <String, vector_math.Vector3>{};

      for (final node in nodes) {
        velocities[node.id] = vector_math.Vector3.zero();
      }

      // Repulsion between all nodes
      for (var i = 0; i < nodes.length; i++) {
        for (var j = i + 1; j < nodes.length; j++) {
          final node1 = nodes[i];
          final node2 = nodes[j];

          final dx = node1.x - node2.x;
          final dy = node1.y - node2.y;
          final dz = node1.z - node2.z;
          final distSq = dx * dx + dy * dy + dz * dz + 0.1;
          final dist = math.sqrt(distSq);

          final force = repulsionStrength / distSq;
          final fx = (dx / dist) * force;
          final fy = (dy / dist) * force;
          final fz = (dz / dist) * force;

          velocities[node1.id] =
              velocities[node1.id]! + vector_math.Vector3(fx, fy, fz);
          velocities[node2.id] =
              velocities[node2.id]! - vector_math.Vector3(fx, fy, fz);
        }
      }

      // Attraction along edges
      for (final node in nodes) {
        for (final targetId in node.connectedTo) {
          final target = nodes.firstWhereOrNull((n) => n.id == targetId);
          if (target != null) {
            final dx = target.x - node.x;
            final dy = target.y - node.y;
            final dz = target.z - node.z;

            final fx = dx * attractionStrength;
            final fy = dy * attractionStrength;
            final fz = dz * attractionStrength;

            velocities[node.id] =
                velocities[node.id]! + vector_math.Vector3(fx, fy, fz);
            velocities[target.id] =
                velocities[target.id]! - vector_math.Vector3(fx, fy, fz);
          }
        }
      }

      // Apply velocities
      for (final node in nodes) {
        final vel = velocities[node.id]! * damping;
        node.x += vel.x;
        node.y += vel.y;
        node.z += vel.z;
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hadiths = ref.watch(filteredHadithsProvider);
    final rawis = ref.watch(rawiListProvider);
    final locale = ref.watch(localeProvider);
    final collapsed = ref.watch(collapsedNodesProvider);
    final selectedNode = ref.watch(selectedNodeProvider);
    final hoveredNode = ref.watch(hoveredNodeProvider);
    final is3D = ref.watch(is3DModeProvider);
    final rotationX = ref.watch(rotationXProvider);
    final rotationY = ref.watch(rotationYProvider);
    final autoRotate = ref.watch(autoRotateProvider);

    if (hadiths.isEmpty) {
      return Center(child: Text(tr(ref, 'no_hadiths')));
    }

    // Use local _nodes instead of rebuilding every time
    final nodes = _nodes;

    return Stack(
      children: [
        MouseRegion(
          onHover: (event) {
            if (_draggedNodeId == null) {
              _handleHover(event.localPosition, nodes);
            }
          },
          onExit: (event) {
            if (_draggedNodeId == null) {
              ref.read(hoveredNodeProvider.notifier).state = null;
            }
          },
          child: Listener(
            onPointerDown: (event) {
              _lastPanPosition = event.position;
              _handlePointerDown(event.localPosition, nodes);
            },
            onPointerMove: (event) {
              if (_draggedNodeId != null) {
                _handleDrag(event.localPosition, nodes);
              } else if (_lastPanPosition != null) {
                final delta = event.position - _lastPanPosition!;

                if (is3D) {
                  ref.read(rotationYProvider.notifier).state += delta.dx * 0.01;
                  ref.read(rotationXProvider.notifier).state += delta.dy * 0.01;
                } else {
                  _offset += delta;
                }

                _lastPanPosition = event.position;
                setState(() {});
              }
            },
            onPointerUp: (event) {
              _draggedNodeId = null;
              _dragStartPos = null;
              _lastPanPosition = null;
              ref.read(draggedNodeProvider.notifier).state = null;
              setState(() {});
            },
            onPointerSignal: (event) {
              if (event is PointerScrollEvent) {
                setState(() {
                  final zoomDelta = event.scrollDelta.dy > 0 ? 0.9 : 1.1;
                  _scale = (_scale * zoomDelta).clamp(0.3, 4.0);
                });
              }
            },
            child: GestureDetector(
              onTapUp: (details) {
                if (_draggedNodeId == null) {
                  _handleTap(details.localPosition, nodes);
                }
              },
              child: AnimatedBuilder(
                animation: Listenable.merge([_animation, _pulseAnimation]),
                builder: (context, child) {
                  return CustomPaint(
                    painter: Enhanced3DNetworkPainter(
                      nodes: nodes,
                      scale: _scale,
                      offset: _offset,
                      collapsedNodes: collapsed,
                      selectedNode: selectedNode,
                      hoveredNode: hoveredNode,
                      draggedNode: _draggedNodeId,
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
                  // Auto Rotate
                  Container(
                    decoration: BoxDecoration(
                      color: autoRotate ? Colors.purple.withOpacity(0.2) : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(
                        autoRotate ? Icons.pause : Icons.play_arrow,
                        color: autoRotate ? Colors.purple : null,
                      ),
                      tooltip: autoRotate ? 'Pause' : 'Auto Rotate',
                      onPressed: _toggleAutoRotate,
                    ),
                  ),
                  const Divider(height: 16),
                  // Auto Layout
                  IconButton(
                    icon: const Icon(Icons.auto_fix_high),
                    tooltip: 'Auto Layout',
                    onPressed: () => _applyForceDirectedLayout(nodes),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: tr(ref, 'zoom_in'),
                    onPressed: () {
                      setState(() {
                        _scale = (_scale + 0.2).clamp(0.3, 4.0);
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    tooltip: tr(ref, 'zoom_out'),
                    onPressed: () {
                      setState(() {
                        _scale = (_scale - 0.2).clamp(0.3, 4.0);
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: tr(ref, 'reset_view'),
                    onPressed: () {
                      setState(() {
                        _scale = 1.0;
                        _offset = Offset.zero;
                        ref.read(rotationXProvider.notifier).state = 0.0;
                        ref.read(rotationYProvider.notifier).state = 0.0;
                        if (autoRotate) {
                          _toggleAutoRotate();
                        }
                      });
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
        if (hoveredNode != null && _draggedNodeId == null)
          Positioned(
            top: 80,
            right: 16,
            child: Card(
              elevation: 8,
              color: Colors.black87,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _buildHoverTooltip(hoveredNode, nodes),
              ),
            ),
          ),

        // Drag indicator
        if (_draggedNodeId != null)
          Positioned(
            top: 80,
            right: 16,
            child: Card(
              elevation: 8,
              color: Colors.amber.shade900,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.pan_tool, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Dragging node...',
                      style: TextStyle(color: Colors.white, fontSize: 12),
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
                  const Text(
                    'Tip: Drag nodes to rearrange',
                    style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHoverTooltip(String nodeId, List<NetworkNode3D> nodes) {
    final node = nodes.firstWhereOrNull((n) => n.id == nodeId);
    if (node == null) return const SizedBox.shrink();

    final hadiths = ref.read(hadithListProvider);
    final rawis = ref.read(rawiListProvider);
    final locale = ref.read(localeProvider);

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
              'Click to view • Drag to move',
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
              'Click to view • Drag to move',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  //--2--

  void _handlePointerDown(Offset position, List<NetworkNode3D> nodes) {
    _lastPanPosition = position;

    print('Pointer down at: $position');

    // First try to find a node at the position
    final node = _findNodeAtScreenPosition(position, nodes);
    if (node != null) {
      print('Found node: ${node.id} at position (${node.x}, ${node.y})');
      _draggedNodeId = node.id;
      _dragStartPos = position;
      ref.read(draggedNodeProvider.notifier).state = node.id;
      setState(() {});
      return;
    } else {
      print('No node found at position');
    }
  }

  void _handleDrag(Offset position, List<NetworkNode3D> nodes) {
    if (_draggedNodeId == null || _dragStartPos == null) return;

    final node = nodes.firstWhereOrNull((n) => n.id == _draggedNodeId);
    if (node == null) return;

    final delta = position - _dragStartPos!;

    // Convert screen delta to graph space
    final graphDeltaX = delta.dx / (_scale * 3);
    final graphDeltaY = delta.dy / (_scale * 3);

    // Update node position
    node.x += graphDeltaX;
    node.y += graphDeltaY;

    // Save the position to provider
    ref.read(nodePositionsProvider.notifier).update((state) {
      return {...state, node.id: Offset(node.x, node.y)};
    });

    _dragStartPos = position;
    setState(() {});
  }

  NetworkNode3D? _findNodeAtScreenPosition(
    Offset position,
    List<NetworkNode3D> nodes,
  ) {
    final size = MediaQuery.of(context).size;
    final is3D = ref.read(is3DModeProvider);

    if (is3D) {
      final projected = _projectNodes(nodes);
      final sorted = List<ProjectedNode>.from(projected)
        ..sort((a, b) => b.z.compareTo(a.z)); // Front to back

      for (final proj in sorted) {
        final screenPos = _getScreenPosition(Offset(proj.x, proj.y), size);
        final distance = (screenPos - position).distance;
        final nodeSize = _getNodeSize(proj.node.type);
        final hitRadius = (nodeSize.width / 2) * _scale;

        if (distance < hitRadius) {
          return proj.node;
        }
      }
    } else {
      // 2D mode
      for (final node in nodes) {
        final screenPos = _getScreenPosition(Offset(node.x, node.y), size);
        final distance = (screenPos - position).distance;
        final nodeSize = _getNodeSize(node.type);
        final hitRadius = (nodeSize.width / 2) * _scale;

        if (distance < hitRadius) {
          return node;
        }
      }
    }

    return null;
  }

  Offset _getScreenPosition(Offset nodePos, Size size) {
    return Offset(
      size.width / 2 + (nodePos.dx * _scale) + _offset.dx,
      size.height / 2 + (nodePos.dy * _scale) + _offset.dy,
    );
  }

  //--2

  void _handleHover(Offset position, List<NetworkNode3D> nodes) {
    final size = MediaQuery.of(context).size;
    final is3D = ref.read(is3DModeProvider);

    if (_draggedNodeId != null) return; // Don't change hover during drag

    ProjectedNode? hoveredProjected;

    if (is3D) {
      final projected = _projectNodes(nodes);
      hoveredProjected = _findNodeAtPosition(position, projected, size);
    } else {
      for (final node in nodes) {
        final screenPos = _get2DScreenPosition(Offset(node.x, node.y), size);
        final distance = (screenPos - position).distance;
        final nodeSize = _getNodeSize(node.type);

        if (distance < nodeSize.width / 2) {
          ref.read(hoveredNodeProvider.notifier).state = node.id;
          return;
        }
      }
    }

    if (hoveredProjected != null) {
      ref.read(hoveredNodeProvider.notifier).state = hoveredProjected.node.id;
    } else {
      ref.read(hoveredNodeProvider.notifier).state = null;
    }
  }

  ProjectedNode? _findNodeAtPosition(
    Offset position,
    List<ProjectedNode> projected,
    Size size,
  ) {
    // Sort by Z to check front nodes first
    final sorted = List<ProjectedNode>.from(projected)
      ..sort((a, b) => b.z.compareTo(a.z));

    for (final proj in sorted) {
      final screenPos = _get3DScreenPosition(Offset(proj.x, proj.y), size);
      final distance = (screenPos - position).distance;
      final nodeSize = _getNodeSize(proj.node.type);
      final hitRadius = nodeSize.width / 2 * _mapZToSize(proj.z, 1.0);

      if (distance < hitRadius) {
        return proj;
      }
    }
    return null;
  }

  Offset _get2DScreenPosition(Offset nodePos, Size size) {
    return Offset(
      size.width / 2 + (nodePos.dx * _scale) + _offset.dx,
      size.height / 2 + (nodePos.dy * _scale) + _offset.dy,
    );
  }

  Offset _get3DScreenPosition(Offset nodePos, Size size) {
    return Offset(
      size.width / 2 + (nodePos.dx * _scale) + _offset.dx,
      size.height / 2 + (nodePos.dy * _scale) + _offset.dy,
    );
  }

  //--

  double _mapZToSize(double z, double baseSize) {
    // Adjust this formula to make hit detection more accurate
    final zFactor = math.max(0.3, (z + 300) / 600);
    return baseSize * zFactor;
  }

  void _handleTap(Offset position, List<NetworkNode3D> nodes) {
    final size = MediaQuery.of(context).size;
    final is3D = ref.read(is3DModeProvider);
    final hadiths = ref.read(hadithListProvider);
    final rawis = ref.read(rawiListProvider);

    ProjectedNode? clickedProjected;

    if (is3D) {
      final projected = _projectNodes(nodes);
      clickedProjected = _findNodeAtPosition(position, projected, size);
    } else {
      for (final node in nodes) {
        final screenPos = _get2DScreenPosition(Offset(node.x, node.y), size);
        final distance = (screenPos - position).distance;
        final nodeSize = _getNodeSize(node.type);

        if (distance < nodeSize.width / 2) {
          _showNodeDialog(node, hadiths, rawis);
          return;
        }
      }
    }

    if (clickedProjected != null) {
      _showNodeDialog(clickedProjected.node, hadiths, rawis);
    }
  }

  void _showNodeDialog(
    NetworkNode3D node,
    List<Hadith> hadiths,
    List<Rawi> rawis,
  ) {
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
    }
  }

  List<ProjectedNode> _projectNodes(List<NetworkNode3D> nodes) {
    final rotX = ref.read(rotationXProvider);
    final rotY = ref.read(rotationYProvider);
    final matrix = _createProjectionMatrix(rotX, rotY);

    return nodes.map((node) {
      final vec = vector_math.Vector3(node.x, node.y, node.z);
      final transformed = matrix.transformed3(vec);
      return ProjectedNode(
        node: node,
        x: transformed.x,
        y: transformed.y,
        z: transformed.z,
      );
    }).toList();
  }

  vector_math.Matrix4 _createProjectionMatrix(double rotX, double rotY) {
    final matrix = vector_math.Matrix4.identity();
    matrix.rotateX(rotX);
    matrix.rotateY(rotY);
    return matrix;
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

  Widget _buildLegendItem(String label, Color color, LineStyle style) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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

  List<NetworkNode3D> _buildNetworkNodes(
    List<Hadith> hadiths,
    List<Rawi> rawis,
    String locale,
  ) {
    final nodes = <NetworkNode3D>[];

    // Create prophet node
    nodes.add(
      NetworkNode3D(
        id: 'prophet',
        type: 'prophet',
        label: tr(ref, 'prophet_muhammad'),
        arabicLabel: 'محمد ﷺ',
        connectedTo: [],
        x: 0,
        y: 0,
        z: 0,
      ),
    );

    final rawiRadius = 250.0;
    final companions =
        rawis.where((r) => hadiths.any((h) => h.sanad.contains(r.id))).toList();

    for (var i = 0; i < companions.length; i++) {
      final angle = (2 * math.pi * i) / companions.length;
      final x = rawiRadius * math.cos(angle);
      final y = rawiRadius * math.sin(angle);
      final z = math.sin(angle * 2) * 50;

      nodes.add(
        NetworkNode3D(
          id: companions[i].id,
          type: 'companion',
          label: companions[i].name.get(locale),
          arabicLabel: companions[i].name.ar,
          connectedTo: ['prophet'],
          x: x,
          y: y,
          z: z,
        ),
      );
    }

    final hadithRadius = 450.0;
    for (var i = 0; i < hadiths.length; i++) {
      final angle = (2 * math.pi * i) / hadiths.length;
      final x = hadithRadius * math.cos(angle);
      final y = hadithRadius * math.sin(angle);
      final z = math.cos(angle * 3) * 80;

      final connected =
          hadiths[i].sanad
              .where(
                (id) => id != 'prophet' && companions.any((c) => c.id == id),
              )
              .toList();

      nodes.add(
        NetworkNode3D(
          id: hadiths[i].id,
          type: 'hadith',
          label: 'H${hadiths[i].number}',
          arabicLabel:
              hadiths[i].arabicText.substring(
                0,
                math.min(20, hadiths[i].arabicText.length),
              ) +
              '...',
          grade: hadiths[i].grade,
          connectedTo: connected.isNotEmpty ? connected : ['prophet'],
          x: x,
          y: y,
          z: z,
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

// Enhanced 3D Network Painter
class Enhanced3DNetworkPainter extends CustomPainter {
  final List<NetworkNode3D> nodes;
  final double scale;
  final Offset offset;
  final Set<String> collapsedNodes;
  final String? selectedNode;
  final String? hoveredNode;
  final String? draggedNode;
  final double animation;
  final double pulseAnimation;
  final bool is3D;
  final double rotationX;
  final double rotationY;

  Enhanced3DNetworkPainter({
    required this.nodes,
    required this.scale,
    required this.offset,
    required this.collapsedNodes,
    required this.selectedNode,
    required this.hoveredNode,
    required this.draggedNode,
    required this.animation,
    required this.pulseAnimation,
    required this.is3D,
    required this.rotationX,
    required this.rotationY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2 + offset.dx, size.height / 2 + offset.dy);
    canvas.scale(scale);

    List<ProjectedNode> projectedNodes;

    if (is3D) {
      projectedNodes = _projectNodes3D();
      projectedNodes.sort((a, b) => b.z.compareTo(a.z)); // Sort by depth
    } else {
      projectedNodes = _projectNodes2D();
    }

    // Draw connections
    for (final proj in projectedNodes) {
      if (collapsedNodes.contains(proj.node.id)) continue;

      for (final targetId in proj.node.connectedTo) {
        final target = projectedNodes.firstWhereOrNull(
          (n) => n.node.id == targetId,
        );
        if (target != null && !collapsedNodes.contains(targetId)) {
          _drawConnection(canvas, proj, target);
        }
      }
    }

    // Draw nodes
    for (final proj in projectedNodes) {
      if (collapsedNodes.contains(proj.node.id)) continue;
      _drawNode(canvas, proj);
    }
  }

  List<ProjectedNode> _projectNodes3D() {
    final matrix = _createProjectionMatrix(rotationX, rotationY);

    return nodes.map((node) {
      final vec = vector_math.Vector3(node.x, node.y, node.z);
      final transformed = matrix.transformed3(vec);
      return ProjectedNode(
        node: node,
        x: transformed.x,
        y: transformed.y,
        z: transformed.z,
      );
    }).toList();
  }

  List<ProjectedNode> _projectNodes2D() {
    return nodes.map((node) {
      return ProjectedNode(node: node, x: node.x, y: node.y, z: node.z);
    }).toList();
  }

  vector_math.Matrix4 _createProjectionMatrix(double rotX, double rotY) {
    final matrix = vector_math.Matrix4.identity();
    matrix.rotateX(rotX);
    matrix.rotateY(rotY);
    return matrix;
  }

  void _drawConnection(Canvas canvas, ProjectedNode from, ProjectedNode to) {
    final isConnected =
        from.node.id == selectedNode ||
        to.node.id == selectedNode ||
        from.node.id == hoveredNode ||
        to.node.id == hoveredNode;

    final paint =
        Paint()
          ..strokeWidth = isConnected ? 3.0 : 2.0
          ..style = PaintingStyle.stroke;

    final grade = from.node.grade?.toLowerCase() ?? '';
    final color = _getGradeColor(grade);
    final style = _getLineStyle(grade);

    final opacity = is3D ? _mapZToOpacity((from.z + to.z) / 2) : 1.0;
    paint.color = color.withOpacity(
      (isConnected ? 0.9 : 0.5) * opacity * animation,
    );

    final path =
        Path()
          ..moveTo(from.x, from.y)
          ..lineTo(to.x, to.y);

    if (style == LineStyle.dashed) {
      _drawDashedPath(canvas, path, paint, dashLength: 10, gapLength: 5);
    } else if (style == LineStyle.dotted) {
      _drawDashedPath(canvas, path, paint, dashLength: 3, gapLength: 3);
    } else {
      canvas.drawPath(path, paint);
    }
  }

  void _drawNode(Canvas canvas, ProjectedNode proj) {
    final node = proj.node;
    final isSelected = selectedNode == node.id;
    final isHovered = hoveredNode == node.id;
    final isDragged = draggedNode == node.id;
    final scale = (isSelected || isHovered || isDragged) ? pulseAnimation : 1.0;

    final size = _getNodeSize(node.type);
    final opacity = is3D ? _mapZToOpacity(proj.z) : 1.0;
    final perspectiveScale = is3D ? _mapZToSize(proj.z, 1.0) : 1.0;

    final width = size.width * scale * animation * perspectiveScale;
    final height = size.height * scale * animation * perspectiveScale;

    // Ensure minimum dimensions
    final finalWidth = math.max(width, 20.0);
    final finalHeight = math.max(height, 20.0);

    // Shadow for depth
    if (isHovered || isSelected || isDragged) {
      final shadowPaint =
          Paint()
            ..color = Colors.black.withOpacity(0.4 * opacity)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      final shadowRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(proj.x + 5, proj.y + 5),
          width: finalWidth,
          height: finalHeight,
        ),
        Radius.circular(node.type == 'prophet' ? 30 : 12),
      );
      canvas.drawRRect(shadowRect, shadowPaint);
    }

    // Node background with gradient
    final rect = Rect.fromCenter(
      center: Offset(proj.x, proj.y),
      width: finalWidth,
      height: finalHeight,
    );

    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(node.type == 'prophet' ? 30 : 12),
    );

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        _getNodeColor(node).withOpacity(opacity),
        _getNodeColor(node).withOpacity(0.7 * opacity),
      ],
    );

    final bgPaint =
        Paint()
          ..style = PaintingStyle.fill
          ..shader = gradient.createShader(rect);

    canvas.drawRRect(rrect, bgPaint);

    // Border
    final borderPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth =
              isDragged
                  ? 5.0
                  : isSelected
                  ? 4.0
                  : isHovered
                  ? 3.0
                  : 2.0
          ..color =
              (isDragged
                  ? Colors.amber
                  : isSelected
                  ? Colors.amber
                  : isHovered
                  ? Colors.white
                  : Colors.white.withOpacity(0.5 * opacity));

    canvas.drawRRect(rrect, borderPaint);

    // Icon
    if (node.type == 'prophet') {
      _drawIcon(
        canvas,
        Offset(proj.x, proj.y),
        Icons.star,
        Colors.white,
        24 * perspectiveScale,
        opacity,
      );
    } else if (node.type == 'companion') {
      _drawIcon(
        canvas,
        Offset(proj.x, proj.y),
        Icons.person,
        Colors.white,
        20 * perspectiveScale,
        opacity,
      );
    } else {
      _drawIcon(
        canvas,
        Offset(proj.x, proj.y),
        Icons.description,
        Colors.white,
        18 * perspectiveScale,
        opacity,
      );
    }

    // Label with safe layout
    final fontSize = (node.type == 'prophet' ? 12.0 : 10.0) * perspectiveScale;
    final maxTextWidth = math.max(
      finalWidth - 8,
      10.0,
    ); // Ensure minimum text width

    if (maxTextWidth > 10.0 && fontSize > 5.0) {
      // Only draw text if dimensions are reasonable
      final textPainter = TextPainter(
        text: TextSpan(
          text: node.label,
          style: TextStyle(
            color: Colors.white.withOpacity(opacity),
            fontSize: fontSize,
            fontWeight:
                node.type == 'prophet' ? FontWeight.bold : FontWeight.w600,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.7),
                offset: const Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 2,
        textAlign: TextAlign.center,
      );

      textPainter.layout(maxWidth: maxTextWidth);
      textPainter.paint(
        canvas,
        Offset(proj.x - textPainter.width / 2, proj.y - textPainter.height / 2),
      );
    }

    // Pulse ring for selected/dragged node
    if (isSelected || isDragged) {
      final pulsePaint =
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = (isDragged ? Colors.amber : Colors.amber).withOpacity(
              0.5 * pulseAnimation * opacity,
            );

      final pulseRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(proj.x, proj.y),
          width: finalWidth * (1 + pulseAnimation * 0.3),
          height: finalHeight * (1 + pulseAnimation * 0.3),
        ),
        Radius.circular(node.type == 'prophet' ? 35 : 15),
      );

      canvas.drawRRect(pulseRect, pulsePaint);
    }
  }

  void _drawIcon(
    Canvas canvas,
    Offset center,
    IconData icon,
    Color color,
    double size,
    double opacity,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: size,
          fontFamily: icon.fontFamily,
          color: color.withOpacity(opacity),
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint, {
    required double dashLength,
    required double gapLength,
  }) {
    final metrics = path.computeMetrics().first;
    var distance = 0.0;

    while (distance < metrics.length) {
      final start = metrics.getTangentForOffset(distance);
      final end = metrics.getTangentForOffset(distance + dashLength);

      if (start != null && end != null) {
        canvas.drawLine(start.position, end.position, paint);
      }

      distance += dashLength + gapLength;
    }
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

  Color _getNodeColor(NetworkNode3D node) {
    if (node.type == 'prophet') return Colors.purple.shade700;
    if (node.type == 'companion') return Colors.teal.shade600;
    return _getGradeColor(node.grade?.toLowerCase() ?? '');
  }

  Color _getGradeColor(String grade) {
    switch (grade.toLowerCase()) {
      case 'mutawatir':
        return Colors.green.shade700;
      case 'sahih':
        return Colors.blue.shade700;
      case 'hasan':
        return Colors.orange.shade700;
      case 'daif':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  LineStyle _getLineStyle(String grade) {
    switch (grade.toLowerCase()) {
      case 'mutawatir':
      case 'sahih':
        return LineStyle.solid;
      case 'hasan':
        return LineStyle.dashed;
      case 'daif':
        return LineStyle.dotted;
      default:
        return LineStyle.solid;
    }
  }

  double _mapZToSize(double z, double baseFactor) {
    final zFactor = math.max(0.5, (z + 200) / 400);
    return baseFactor * zFactor;
  }

  double _mapZToOpacity(double z) {
    return math.max(0.3, math.min(1.0, (z + 200) / 400));
  }

  @override
  bool shouldRepaint(Enhanced3DNetworkPainter oldDelegate) {
    return oldDelegate.scale != scale ||
        oldDelegate.offset != offset ||
        oldDelegate.selectedNode != selectedNode ||
        oldDelegate.hoveredNode != hoveredNode ||
        oldDelegate.draggedNode != draggedNode ||
        oldDelegate.animation != animation ||
        oldDelegate.pulseAnimation != pulseAnimation ||
        oldDelegate.is3D != is3D ||
        oldDelegate.rotationX != rotationX ||
        oldDelegate.rotationY != rotationY ||
        !_setEquals(oldDelegate.collapsedNodes, collapsedNodes);
  }

  bool _setEquals(Set<String> a, Set<String> b) {
    if (a.length != b.length) return false;
    return a.every(b.contains);
  }
}
