import 'dart:convert';
import 'package:flutter/material.dart';

// Data model for Sankey node
class SankeyNode {
  final String name;
  double value = 0;  // Will be calculated from links
  double x = 0;
  double y = 0;
  double height = 0;

  SankeyNode(this.name);

  factory SankeyNode.fromJson(Map<String, dynamic> json) {
    return SankeyNode(json['name'] as String);
  }
}

// Data model for Sankey link
class SankeyLink {
  final SankeyNode source;
  final SankeyNode target;
  final double value;

  SankeyLink(this.source, this.target, this.value);

  factory SankeyLink.fromJson(Map<String, dynamic> json, Map<String, SankeyNode> nodeMap) {
    return SankeyLink(
      nodeMap[json['source']]!,
      nodeMap[json['target']]!,
      (json['value'] as num).toDouble(),
    );
  }
}

// Data model for Sankey data
class SankeyData {
  final List<SankeyNode> nodes;
  final List<SankeyLink> links;

  SankeyData(this.nodes, this.links) {
    _calculateNodeValues();
  }

  factory SankeyData.fromJson(String jsonString) {
    final data = json.decode(jsonString);
    print('++++++++++++++++++++++++++++++++');
    print(data);
    // Create nodes map for easy lookup
    final nodeMap = <String, SankeyNode>{};
    for (var nodeData in data['nodes']) {
      final node = SankeyNode.fromJson(nodeData);
      nodeMap[node.name] = node;
    }

    // Create links
    final links = data['links'].map<SankeyLink>((linkData) {
      return SankeyLink.fromJson(linkData, nodeMap);
    }).toList();

    return SankeyData(nodeMap.values.toList(), links);
  }

  void _calculateNodeValues() {
    // Calculate node values based on incoming or outgoing links
    for (var node in nodes) {
      double outgoing = links
          .where((link) => link.source == node)
          .fold(0, (sum, link) => sum + link.value);
      
      double incoming = links
          .where((link) => link.target == node)
          .fold(0, (sum, link) => sum + link.value);
      
      // Use the larger of incoming or outgoing values
      node.value = outgoing > incoming ? outgoing : incoming;
    }
  }
}

class SankeyPainter extends CustomPainter {
  final SankeyData data;
  final double padding;
  final Color nodeColor;
  final Color linkColor;

  SankeyPainter({
    required this.data,
    this.padding = 20,
    this.nodeColor = Colors.blue,
    this.linkColor = Colors.blue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = nodeColor;

    final linkPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = linkColor.withOpacity(0.3);

    _calculateNodePositions(size);

    // Draw links
    for (var link in data.links) {
      final path = Path();
      final startY = link.source.y + (link.source.height * (link.value / link.source.value)) / 2;
      final endY = link.target.y + (link.target.height * (link.value / link.target.value)) / 2;
      
      final linkHeight = (link.value / link.source.value) * link.source.height;
      
      // Draw curved path
      path.moveTo(link.source.x + 20, startY); // Add node width (20)
      
      final controlPoint1 = Offset(
        link.source.x + 20 + (link.target.x - link.source.x - 20) / 3,
        startY
      );
      final controlPoint2 = Offset(
        link.source.x + 20 + 2 * (link.target.x - link.source.x - 20) / 3,
        endY
      );
      
      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        link.target.x,
        endY,
      );
      
      path.lineTo(link.target.x, endY + linkHeight);
      
      final controlPoint3 = Offset(
        link.source.x + 20 + 2 * (link.target.x - link.source.x - 20) / 3,
        endY + linkHeight
      );
      final controlPoint4 = Offset(
        link.source.x + 20 + (link.target.x - link.source.x - 20) / 3,
        startY + linkHeight
      );
      
      path.cubicTo(
        controlPoint3.dx,
        controlPoint3.dy,
        controlPoint4.dx,
        controlPoint4.dy,
        link.source.x + 20,
        startY + linkHeight,
      );
      
      path.close();
      canvas.drawPath(path, linkPaint);
    }

    // Draw nodes and labels
    for (var node in data.nodes) {
      final rect = Rect.fromLTWH(node.x, node.y, 20, node.height);
      canvas.drawRect(rect, paint);

      // Draw labels
      final textSpan = TextSpan(
        text: node.name,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        maxLines: 2,
        ellipsis: '...',
      );
      textPainter.layout(maxWidth: 100);
      
      // Position labels based on whether node is on left or right side
      final isLeftSide = node.x < size.width / 2;
      final textX = isLeftSide 
          ? node.x - textPainter.width - 5
          : node.x + 25;
          
      textPainter.paint(
        canvas,
        Offset(textX, node.y + node.height / 2 - textPainter.height / 2),
      );
    }
  }

  void _calculateNodePositions(Size size) {
    // Find all unique levels (columns)
    final levels = <List<SankeyNode>>[];
    final processed = <SankeyNode>{};
    
    // First level - nodes with no incoming links
    final firstLevel = data.nodes.where((node) {
      return !data.links.any((link) => link.target == node);
    }).toList();
    levels.add(firstLevel);
    processed.addAll(firstLevel);

    // Subsequent levels
    while (processed.length < data.nodes.length) {
      final nextLevel = data.nodes.where((node) {
        if (processed.contains(node)) return false;
        return data.links.where((link) => link.target == node)
            .every((link) => processed.contains(link.source));
      }).toList();
      
      if (nextLevel.isEmpty && processed.length < data.nodes.length) {
        // Handle cycles by adding remaining nodes
        final remaining = data.nodes.where((node) => !processed.contains(node)).toList();
        levels.add(remaining);
        processed.addAll(remaining);
        break;
      }
      
      levels.add(nextLevel);
      processed.addAll(nextLevel);
    }

    // Calculate positions
    final columnWidth = (size.width - 2 * padding) / (levels.length - 1);
    for (var i = 0; i < levels.length; i++) {
      final levelNodes = levels[i];
      final totalValue = levelNodes.fold<double>(0, (sum, node) => sum + node.value);
      final availableHeight = size.height - 2 * padding;
      var currentY = padding;

      for (var node in levelNodes) {
        node.x = padding + i * columnWidth;
        node.y = currentY;
        node.height = (node.value / totalValue) * availableHeight;
        currentY += node.height + 5; // Reduced spacing between nodes
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SankeyDiagram extends StatelessWidget {
  final String jsonData;
  final double width;
  final double height;

  const SankeyDiagram({
    Key? key,
    required this.jsonData,
    this.width = 800,
    this.height = 600,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sankeyData = SankeyData.fromJson(jsonData);
    
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: SankeyPainter(
          data: sankeyData,
          nodeColor: Colors.blue.shade300,
          linkColor: Colors.blue.shade200,
        ),
      ),
    );
  }
}