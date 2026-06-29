import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../content/model/content_type_schema.dart';
import '../models/diagram_node.dart';
import '../schema/model/diagram_connection.dart';
import '../models/relation_type.dart';

class ConnectionPainter extends CustomPainter {
  final List<DiagramConnection> connections;
  final Map<String, DiagramNode> nodes;
  final List<ContentTypeSchema> schemas;
  ConnectionPainter({
    required this.connections,
    required this.nodes,
    required this.schemas,
  });
  @override
  void paint(Canvas canvas, Size size) {
    for (var connection in connections) {
      final fromNode = nodes[connection.fromSchemaId];
      final toNode = nodes[connection.toSchemaId];
      if (fromNode == null || toNode == null) continue;
      final fromCenter = Offset(
        fromNode.position.dx + fromNode.size.width / 2,
        fromNode.position.dy + fromNode.size.height / 2,
      );
      final toCenter = Offset(
        toNode.position.dx + toNode.size.width / 2,
        toNode.position.dy + toNode.size.height / 2,
      );
      final paint =
          Paint()
            ..color = _getRelationshipColor(connection.type)
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke;
      canvas.drawLine(fromCenter, toCenter, paint);
      _drawArrow(canvas, fromCenter, toCenter, paint, connection.type);
      final midPoint = Offset(
        (fromCenter.dx + toCenter.dx) / 2,
        (fromCenter.dy + toCenter.dy) / 2,
      );
      final textPainter = TextPainter(
        text: TextSpan(
          text: _getRelationshipLabel(connection.type),
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 10,
            backgroundColor: Colors.white,
          ),
        ),
        textDirection: TextDirection.LTR,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        midPoint - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  void _drawArrow(
    Canvas canvas,
    Offset from,
    Offset to,
    Paint paint,
    RelationType type,
  ) {
    final direction = to - from;
    final angle = atan2(direction.dy, direction.dx);
    const arrowSize = 10.0;
    final arrowP1 = Offset(
      to.dx - arrowSize * cos(angle - pi / 6),
      to.dy - arrowSize * sin(angle - pi / 6),
    );
    final arrowP2 = Offset(
      to.dx - arrowSize * cos(angle + pi / 6),
      to.dy - arrowSize * sin(angle + pi / 6),
    );
    final path = Path();
    path.moveTo(to.dx, to.dy);
    path.lineTo(arrowP1.dx, arrowP1.dy);
    path.moveTo(to.dx, to.dy);
    path.lineTo(arrowP2.dx, arrowP2.dy);
    canvas.drawPath(path, paint);
  }

  Color _getRelationshipColor(RelationType type) {
    switch (type) {
      case RelationType.oneToOne:
        return Colors.blue;
      case RelationType.oneToMany:
        return Colors.green;
      case RelationType.manyToOne:
        return Colors.orange;
      case RelationType.manyToMany:
        return Colors.purple;
    }
  }

  String _getRelationshipLabel(RelationType type) {
    switch (type) {
      case RelationType.oneToOne:
        return '1:1';
      case RelationType.oneToMany:
        return '1:N';
      case RelationType.manyToOne:
        return 'N:1';
      case RelationType.manyToMany:
        return 'N:M';
    }
  }

  @override
  bool shouldRepaint(ConnectionPainter oldDelegate) => true;
}
