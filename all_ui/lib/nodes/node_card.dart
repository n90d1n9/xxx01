import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connection.dart';
import 'node.dart';
import 'node_provider.dart';
import 'node_registries.dart';

class NodeCard extends ConsumerWidget {
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Function(Offset)? onDragUpdate;
  final Function(String)? onInputPortConnected;
  final NodeData data;

  const NodeCard({
    super.key,
    required this.data,
    this.onTap,
    this.onLongPress,
    this.onDragUpdate,
    this.onInputPortConnected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    NodeSpec nodeSpec = nodeRegistries(
      data.config,
    ).firstWhere((registry) => registry.type == data.type);

    Widget cardShape = nodeSpec.shape;
    final ports = nodeSpec.ports;
    final cardHeight = nodeSpec.height;
    final cardWidth = nodeSpec.width;
    Widget shape = _buildCardContent(
      context,
      cardWidth,
      cardHeight,
      ports,
      cardShape,
    );
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Draggable(
        feedback: Transform.scale(
          scale: 1.05,
          child: Opacity(opacity: 0.8, child: shape),
        ),
        childWhenDragging: Opacity(opacity: 0.5, child: shape),
        onDragUpdate: (details) {
          onDragUpdate?.call(details.globalPosition);
        },
        onDragStarted: () {
          ref.read(nodeStateProvider.notifier).setDragging(true);
        },
        onDragEnd: (details) {
          ref.read(nodeStateProvider.notifier).setDragging(false);
        },
        child: shape,
      ),
    );
  }

  Widget _buildCardContent(
    BuildContext context,
    double cardWidth,
    double cardHeight,
    List<PortConfig> ports,
    Widget cardShape,
  ) {
    // Get the shape widget first to determine its dimensions
    final totalWidth = cardWidth + 32;
    final totalHeight = cardHeight + 32;

    // Calculate positions relative to card dimensions
    final cardLeft = (totalWidth - cardWidth) / 2;
    final cardTop = (totalHeight - cardHeight) / 2;

    // Filter ports by position
    final leftPorts =
        ports.where((port) => port.portPosition == PortPosition.left).toList();
    final rightPorts =
        ports.where((port) => port.portPosition == PortPosition.right).toList();
    final topPorts =
        ports.where((port) => port.portPosition == PortPosition.top).toList();
    final bottomPorts =
        ports
            .where((port) => port.portPosition == PortPosition.bottom)
            .toList();

    // Label position - centered in card
    final labelLeft = cardLeft + (cardWidth / 2) - 20;
    final labelTop = cardTop + (cardHeight / 2) - 10;

    return SizedBox(
      width: totalWidth,
      height: totalHeight,
      child: Stack(
        children: [
          // Main Card Shape
          Positioned(left: cardLeft, top: cardTop, child: cardShape),

          // Label - Centered in card
          Positioned(
            left: labelLeft,
            top: labelTop,
            child: Text(data.label, style: data.config.labelStyle),
          ),

          // Left Ports - Distributed vertically
          ..._buildLeftPorts(leftPorts, cardLeft, cardTop, cardHeight),

          // Right Ports - Distributed vertically
          ..._buildRightPorts(
            rightPorts,
            cardLeft + cardWidth,
            cardTop,
            cardHeight,
          ),

          // Top Ports - Distributed horizontally
          ..._buildTopPorts(topPorts, cardLeft, cardTop, cardWidth),

          // Bottom Ports - Distributed horizontally
          ..._buildBottomPorts(
            bottomPorts,
            cardLeft,
            cardTop + cardHeight,
            cardWidth,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLeftPorts(
    List<PortConfig> ports,
    double cardLeft,
    double cardTop,
    double cardHeight,
  ) {
    if (ports.isEmpty) return [];

    final portSize = 16.0;
    final portHalfSize = portSize / 2;
    final spacing = cardHeight / (ports.length + 1);

    return List<Widget>.generate(ports.length, (index) {
      final portTop = cardTop + (spacing * (index + 1)) - portHalfSize;
      final portLeft = cardLeft - portHalfSize;

      return Positioned(
        left: portLeft,
        top: portTop,
        child: _buildPortByType(ports[index]),
      );
    });
  }

  List<Widget> _buildRightPorts(
    List<PortConfig> ports,
    double cardRight,
    double cardTop,
    double cardHeight,
  ) {
    if (ports.isEmpty) return [];

    final portSize = 16.0;
    final portHalfSize = portSize / 2;
    final spacing = cardHeight / (ports.length + 1);

    return List<Widget>.generate(ports.length, (index) {
      final portTop = cardTop + (spacing * (index + 1)) - portHalfSize;
      final portLeft = cardRight - portHalfSize;

      return Positioned(
        left: portLeft,
        top: portTop,
        child: _buildPortByType(ports[index]),
      );
    });
  }

  List<Widget> _buildTopPorts(
    List<PortConfig> ports,
    double cardLeft,
    double cardTop,
    double cardWidth,
  ) {
    if (ports.isEmpty) return [];

    final portSize = 16.0;
    final portHalfSize = portSize / 2;
    final spacing = cardWidth / (ports.length + 1);

    return List<Widget>.generate(ports.length, (index) {
      final portLeft = cardLeft + (spacing * (index + 1)) - portHalfSize;
      final portTop = cardTop - portHalfSize - 24;

      return Positioned(
        left: portLeft,
        top: portTop,
        child: _buildPortByType(ports[index]),
      );
    });
  }

  List<Widget> _buildBottomPorts(
    List<PortConfig> ports,
    double cardLeft,
    double cardBottom,
    double cardWidth,
  ) {
    if (ports.isEmpty) return [];

    final portSize = 16.0;
    final portHalfSize = portSize / 2;
    final spacing = cardWidth / (ports.length + 1);

    return List<Widget>.generate(ports.length, (index) {
      final portLeft = cardLeft + (spacing * (index + 1)) - portHalfSize;
      final portTop = cardBottom - portHalfSize - 22;

      return Positioned(
        left: portLeft,
        top: portTop,
        child: _buildPortByType(ports[index]),
      );
    });
  }

  Widget _buildPortByType(PortConfig portConfig) {
    switch (portConfig.portType) {
      case PortType.input:
        return _buildInputPort(portConfig);
      case PortType.output:
        return _buildOutputPort(portConfig);
      case PortType.feature:
        return _buildFeaturePort(portConfig);
      default:
        return _buildInputPort(portConfig);
    }
  }

  Widget _buildInputPort(PortConfig portConfig) {
    return DragTarget<ConnectionData>(
      onAccept: (data) {
        onInputPortConnected?.call(portConfig.portId);
      },
      builder: (context, candidateData, rejectedData) {
        return Transform.rotate(
          angle: math.pi / 4, // 45 degrees rotation for diamond
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color:
                  candidateData.isNotEmpty
                      ? const Color(0xFFA0D8A0)
                      : const Color(0xFFD8D8D8),
              border: Border.all(
                color:
                    candidateData.isNotEmpty
                        ? Colors.green
                        : const Color(0xFF979797),
                width: candidateData.isNotEmpty ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOutputPort(PortConfig portConfig) {
    return Draggable<ConnectionData>(
      data: ConnectionData(sourceId: portConfig.portId),
      feedback: Material(
        type: MaterialType.transparency,
        child: Transform.rotate(
          angle: math.pi / 2, // 90 degrees rotation for triangle
          child: Container(
            width: 16,
            height: 16,
            color: Colors.transparent,
            child: CustomPaint(
              painter: _TrianglePainter(
                color: const Color(0xFFD8D8D8),
                borderColor: Colors.green,
              ),
            ),
          ),
        ),
      ),
      child: Transform.rotate(
        angle: math.pi / 2,
        child: Container(
          width: 16,
          height: 16,
          color: Colors.transparent,
          child: CustomPaint(
            painter: _TrianglePainter(
              color: const Color(0xFFD8D8D8),
              borderColor: const Color(0xFF979797),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturePort(PortConfig portConfig) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(nodeStateProvider);
        final isSelected = state.selectedFeatures.contains(portConfig.portId);

        return CirclePort(
          label: portConfig.label ?? 'Feature',
          isSelected: isSelected,
          onTap:
              () => ref
                  .read(nodeStateProvider.notifier)
                  .toggleFeature(portConfig.portId),
        );
      },
    );
  }
}

class TrianglePort extends StatelessWidget {
  final String portId;
  final Color borderColor;
  final Color fillColor;
  const TrianglePort({
    super.key,
    required this.portId,
    this.borderColor = const Color(0xFF979797),
    this.fillColor = const Color(0xFFD8D8D8),
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<ConnectionData>(
      data: ConnectionData(sourceId: portId),
      feedback: Material(
        type: MaterialType.transparency,
        child: Transform.rotate(
          angle: math.pi / 2, // 90 degrees rotation
          child: Container(
            width: 16,
            height: 16,
            color: Colors.transparent,
            child: CustomPaint(
              painter: _TrianglePainter(
                color: const Color(0xFFD8D8D8),
                borderColor: Colors.green,
              ),
            ),
          ),
        ),
      ),
      child: Transform.rotate(
        angle: math.pi / 2, // 90 degrees rotation
        child: Container(
          width: 16,
          height: 16,
          color: Colors.transparent,
          child: CustomPaint(
            painter: _TrianglePainter(
              color: fillColor,
              borderColor: borderColor,
            ),
          ),
        ),
      ),
    );
  }
}

// Feature Port Widget
class CirclePort extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CirclePort({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center, // Center align
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4), // Reduced spacing
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? const Color(0xFFA0A0A0)
                      : const Color(0xFFD8D8D8),
              border: Border.all(color: const Color(0xFF979797), width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}

// Triangle Painter for Output Port
class _TrianglePainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  _TrianglePainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    final paint =
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    // Original SVG Path Definition
    final path =
        Path()
          ..moveTo(283.29268, 53.3500186)
          ..cubicTo(
            284.169926,
            53.1689996,
            285.116229,
            53.3226387,
            285.923658,
            53.8538421,
          )
          ..cubicTo(
            286.321703,
            54.1157137,
            286.662088,
            54.4560993,
            286.92396,
            54.8541441,
          )
          ..lineTo(292.004353, 62.5763422)
          ..cubicTo(
            292.535557,
            63.3837714,
            292.689196,
            64.3300741,
            292.508177,
            65.2073204,
          )
          ..cubicTo(
            292.327158,
            66.0845666,
            291.81148,
            66.8927564,
            291.004051,
            67.4239598,
          )
          ..cubicTo(290.43286, 67.7997432, 289.764113, 68, 289.080394, 68)
          ..lineTo(278.919606, 68)
          ..cubicTo(
            277.953108,
            68,
            277.078108,
            67.6082492,
            276.444733,
            66.9748737,
          )
          ..cubicTo(
            275.811357,
            66.3414983,
            275.419606,
            65.4664983,
            275.419606,
            64.5,
          )
          ..cubicTo(
            275.419606,
            63.8162806,
            275.619863,
            63.1475331,
            275.995647,
            62.5763422,
          )
          ..lineTo(281.07604, 54.8541441)
          ..cubicTo(
            281.607244,
            54.0467149,
            282.415433,
            53.5310377,
            283.29268,
            53.3500186,
          )
          ..close();

    // Bounding Box Dimensions (pre-rotation)
    const double pathMinY = 53.3500186;
    const double pathHeight = 68.0 - pathMinY; // ~14.65

    // Calculate scale factor: Path height (~14.65) becomes final canvas width.
    final double scaleFactor = size.width / pathHeight;

    // Rotation center for the SVG transform: translate(284, 59) rotate(90) translate(-284, -59)
    /*  const double rotationCenterX = 284.0;
    const double rotationCenterY = 59.0;
 */
    final matrix4 = Matrix4.identity();

    // 1. Move to the center of rotation (284, 59)
    // matrix4.translate(rotationCenterX, rotationCenterY);

    // 2. Rotate 90 degrees clockwise (pi/2)
    // matrix4.rotateZ(90 * (3.1415926535 / 180));

    // 3. Move back (this compensates for the SVG's -284, -59 translate *after* rotation)
    // matrix4.translate(-rotationCenterX, -rotationCenterY);

    // 4. Transform the path using the matrix to get the rotated path
    final transformedPath = path.transform(matrix4.storage);

    // 5. Create a new matrix for scaling and final positioning (to fit the size box)
    final outputMatrix = Matrix4.identity();

    // Scale to fit the target width/height
    outputMatrix.scale(scaleFactor, scaleFactor);

    // Since the path is now rotated, the bounding box minX/minY must be recalculated.
    // The final shape's top edge (the point) should be at y=0.
    // The point of the shape (283.29, 53.35) should map to the top center of the final canvas.
    // We translate the scaled path back to the origin (0,0) of the canvas.
    // After rotation and scaling, the point (283.29, 53.35) maps to:
    // (59 - 53.35) * scaleFactor + (284 - 283.29) * scaleFactor
    // To simplify: we find the path's new bounding box and translate it to (0,0).
    final bounds = transformedPath.getBounds();
    outputMatrix.translate(-bounds.left, -bounds.top);

    // 6. Apply the final scaling/positioning matrix to the canvas
    canvas.transform(outputMatrix.storage);

    // 7. Draw the final path
    canvas.drawPath(transformedPath, fillPaint);
    canvas.drawPath(transformedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
