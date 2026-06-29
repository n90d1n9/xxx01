import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector_math;
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '3D Network Graph',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const NetworkGraphScreen(),
    );
  }
}

class NetworkGraphScreen extends StatefulWidget {
  const NetworkGraphScreen({Key? key}) : super(key: key);

  @override
  _NetworkGraphScreenState createState() => _NetworkGraphScreenState();
}

class _NetworkGraphScreenState extends State<NetworkGraphScreen>
    with SingleTickerProviderStateMixin {
  final NetworkGraph _graph = NetworkGraph();
  double _scale = 1.0;
  Offset _offset = Offset.zero;
  double _rotationX = 0.0;
  double _rotationY = 0.0;
  Offset? _lastFocalPoint;
  GraphNode? _selectedNode;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _initializeGraph();

    // Setup animation for auto-rotation
    _animationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..addListener(() {
      setState(() {
        _rotationY = _rotationAnimation.value;
      });
    });

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: math.pi * 2,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeGraph() {
    // Create some nodes
    final node1 = GraphNode(id: '1', name: 'Node 1', x: 0, y: 0, z: 0);
    final node2 = GraphNode(id: '2', name: 'Node 2', x: 100, y: 50, z: 20);
    final node3 = GraphNode(id: '3', name: 'Node 3', x: 80, y: -70, z: 40);
    final node4 = GraphNode(id: '4', name: 'Node 4', x: -90, y: 30, z: -50);
    final node5 = GraphNode(id: '5', name: 'Node 5', x: -60, y: -60, z: 30);
    final node6 = GraphNode(id: '6', name: 'Node 6', x: 30, y: 90, z: -40);

    // Add nodes to graph
    _graph.addNode(node1);
    _graph.addNode(node2);
    _graph.addNode(node3);
    _graph.addNode(node4);
    _graph.addNode(node5);
    _graph.addNode(node6);

    // Create some edges
    _graph.addEdge(node1, node2);
    _graph.addEdge(node1, node3);
    _graph.addEdge(node1, node4);
    _graph.addEdge(node2, node5);
    _graph.addEdge(node3, node5);
    _graph.addEdge(node4, node6);
    _graph.addEdge(node5, node6);
  }

  void _toggleAnimation() {
    setState(() {
      if (_isAnimating) {
        _animationController.stop();
      } else {
        _animationController.repeat();
      }
      _isAnimating = !_isAnimating;
    });
  }

  void _handleTapDown(TapDownDetails details, Size size) {
    // Convert screen coordinates to graph coordinates
    final touchPoint = details.localPosition;
    final graphCenter = Offset(
      size.width / 2 + _offset.dx,
      size.height / 2 + _offset.dy,
    );
    final scaledPoint = (touchPoint - graphCenter) / _scale;

    // Project all nodes and find the closest one
    final projectionMatrix = _createProjectionMatrix(_rotationX, _rotationY);
    GraphNode? closestNode;
    double minDistance = double.infinity;

    for (final node in _graph.nodes) {
      final vector = vector_math.Vector3(node.x, node.y, node.z);
      final transformed = projectionMatrix.transformed3(vector);
      final nodeScreenPoint = Offset(transformed.x, transformed.y);
      final distance = (nodeScreenPoint - scaledPoint).distance;

      // Check if this node is close enough to be selected (adjust threshold as needed)
      if (distance < 20 / _scale && distance < minDistance) {
        minDistance = distance;
        closestNode = node;
      }
    }

    setState(() {
      _selectedNode = closestNode;
    });

    if (_selectedNode != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected: ${_selectedNode!.name}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3D Network Graph'),
        actions: [
          IconButton(
            icon: Icon(_isAnimating ? Icons.pause : Icons.play_arrow),
            onPressed: _toggleAnimation,
            tooltip: _isAnimating ? 'Pause Rotation' : 'Auto Rotate',
          ),
        ],
      ),
      body: Listener(
        onPointerDown: (PointerDownEvent event) {
          if (_isAnimating) {
            _toggleAnimation(); // Stop animation when user interacts
          }
          _lastFocalPoint = event.position;
        },
        onPointerMove: (PointerMoveEvent event) {
          if (_lastFocalPoint != null) {
            setState(() {
              final delta = event.position - _lastFocalPoint!;

              // Handle rotation or panning based on buttons pressed
              if (event.buttons == kPrimaryButton) {
                // Left button - rotation
                _rotationY += delta.dx * 0.01;
                _rotationX += delta.dy * 0.01;
              } else if (event.buttons == kSecondaryButton) {
                // Right button or two fingers - panning
                _offset += delta;
              }

              // Update for next frame
              _lastFocalPoint = event.position;
            });
          }
        },
        onPointerUp: (PointerUpEvent event) {
          _lastFocalPoint = null;
        },
        onPointerSignal: (PointerSignalEvent event) {
          // Handle scroll wheel for zooming
          if (event is PointerScrollEvent) {
            setState(() {
              final zoomDelta = event.scrollDelta.dy > 0 ? 0.9 : 1.1;
              _scale = (_scale * zoomDelta).clamp(0.5, 5.0);
            });
          }
        },
        child: GestureDetector(
          onTapDown:
              (details) => _handleTapDown(details, MediaQuery.of(context).size),
          child: CustomPaint(
            painter: NetworkGraphPainter(
              graph: _graph,
              scale: _scale,
              offset: _offset,
              rotationX: _rotationX,
              rotationY: _rotationY,
              selectedNode: _selectedNode,
            ),
            child: Container(),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'zoom_in',
            onPressed: () {
              setState(() {
                _scale = (_scale * 1.2).clamp(0.5, 5.0);
              });
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'zoom_out',
            onPressed: () {
              setState(() {
                _scale = (_scale / 1.2).clamp(0.5, 5.0);
              });
            },
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'reset',
            onPressed: () {
              setState(() {
                _scale = 1.0;
                _offset = Offset.zero;
                _rotationX = 0.0;
                _rotationY = 0.0;
                _selectedNode = null;
                if (_isAnimating) {
                  _animationController.stop();
                  _isAnimating = false;
                }
              });
            },
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

  // Helper methods
  vector_math.Matrix4 _createProjectionMatrix(double rotX, double rotY) {
    final matrix = vector_math.Matrix4.identity();
    matrix.rotateX(rotX);
    matrix.rotateY(rotY);
    return matrix;
  }
}

class NetworkGraphPainter extends CustomPainter {
  final NetworkGraph graph;
  final double scale;
  final Offset offset;
  final double rotationX;
  final double rotationY;
  final GraphNode? selectedNode;

  NetworkGraphPainter({
    required this.graph,
    required this.scale,
    required this.offset,
    required this.rotationX,
    required this.rotationY,
    this.selectedNode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Apply transformations
    canvas.translate(size.width / 2 + offset.dx, size.height / 2 + offset.dy);
    canvas.scale(scale);

    // Define base paint styles
    final edgePaint =
        Paint()
          ..color = Colors.grey.withOpacity(0.6)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

    final nodePaint =
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.fill;

    final selectedPaint =
        Paint()
          ..color = Colors.red
          ..style = PaintingStyle.fill;

    final highlightPaint =
        Paint()
          ..color = Colors.orange.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0;

    // Create projection matrix
    final projectionMatrix = _createProjectionMatrix(rotationX, rotationY);

    // Calculate projected positions
    final projectedNodes =
        graph.nodes.map((node) {
          final vector = vector_math.Vector3(node.x, node.y, node.z);
          final transformed = projectionMatrix.transformed3(vector);
          return ProjectedNode(
            node: node,
            x: transformed.x,
            y: transformed.y,
            z: transformed.z,
          );
        }).toList();

    // Sort nodes by z-index for proper layering
    projectedNodes.sort((a, b) => b.z.compareTo(a.z));

    // Draw edges
    for (final edge in graph.edges) {
      final source = projectedNodes.firstWhere(
        (n) => n.node.id == edge.source.id,
      );
      final target = projectedNodes.firstWhere(
        (n) => n.node.id == edge.target.id,
      );

      // Adjust opacity based on z-position
      final avgZ = (source.z + target.z) / 2;
      final opacity = _mapZToOpacity(avgZ);

      // Highlight edges connected to the selected node
      if (selectedNode != null &&
          (edge.source.id == selectedNode!.id ||
              edge.target.id == selectedNode!.id)) {
        canvas.drawLine(
          Offset(source.x, source.y),
          Offset(target.x, target.y),
          highlightPaint,
        );
      } else {
        // Create a new paint for the edge with adjusted opacity
        final adjustedEdgePaint =
            Paint()
              ..color = Colors.grey.withOpacity(
                opacity * 0.6,
              ) // Apply opacity to base color
              ..strokeWidth = 1.5
              ..style = PaintingStyle.stroke;

        canvas.drawLine(
          Offset(source.x, source.y),
          Offset(target.x, target.y),
          adjustedEdgePaint,
        );
      }
    }

    // Draw nodes
    for (final projectedNode in projectedNodes) {
      final node = projectedNode.node;

      // Calculate node size based on z-position (perspective effect)
      final nodeSize = _mapZToSize(projectedNode.z);
      final opacity = _mapZToOpacity(projectedNode.z);

      // Draw node (highlight selected node)
      final isSelected = selectedNode != null && node.id == selectedNode!.id;

      // Create paint for the node with adjusted opacity
      final nodeFillPaint =
          Paint()
            ..color = (isSelected ? Colors.red : Colors.blue).withOpacity(
              opacity,
            )
            ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(projectedNode.x, projectedNode.y),
        isSelected ? nodeSize * 1.3 : nodeSize,
        nodeFillPaint,
      );

      // Draw node label
      final textSpan = TextSpan(
        text: node.name,
        style: TextStyle(
          color: Colors.black.withOpacity(opacity),
          fontSize: 12 * (nodeSize / 10),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          projectedNode.x + nodeSize + 2,
          projectedNode.y - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant NetworkGraphPainter oldDelegate) {
    return oldDelegate.scale != scale ||
        oldDelegate.offset != offset ||
        oldDelegate.rotationX != rotationX ||
        oldDelegate.rotationY != rotationY ||
        oldDelegate.selectedNode != selectedNode;
  }

  // Helper methods for 3D projection and visual effects
  vector_math.Matrix4 _createProjectionMatrix(double rotX, double rotY) {
    final matrix = vector_math.Matrix4.identity();
    matrix.rotateX(rotX);
    matrix.rotateY(rotY);
    return matrix;
  }

  double _mapZToSize(double z) {
    // Map z-coordinate to node size for perspective effect
    // Nodes that are "closer" (higher z) appear larger
    final baseSize = 10.0;
    final zFactor = math.max(0.5, (z + 150) / 300);
    return baseSize * zFactor;
  }

  double _mapZToOpacity(double z) {
    // Map z-coordinate to opacity for depth effect
    // Nodes that are "further away" (lower z) appear more transparent
    return math.max(0.3, math.min(1.0, (z + 150) / 300));
  }
}

class NetworkGraph {
  final List<GraphNode> nodes = [];
  final List<GraphEdge> edges = [];

  void addNode(GraphNode node) {
    nodes.add(node);
  }

  void addEdge(GraphNode source, GraphNode target) {
    edges.add(GraphEdge(source: source, target: target));
  }
}

class GraphNode {
  final String id;
  final String name;
  double x;
  double y;
  double z;

  GraphNode({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
    required this.z,
  });
}

class GraphEdge {
  final GraphNode source;
  final GraphNode target;

  GraphEdge({required this.source, required this.target});
}

class ProjectedNode {
  final GraphNode node;
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
