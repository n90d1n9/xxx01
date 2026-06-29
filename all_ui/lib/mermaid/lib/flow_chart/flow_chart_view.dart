import 'package:flutter/material.dart';

import '../form_designer/model/condition_operator.dart';

class FlowchartView extends StatefulWidget {
  final List<ConditionalRule> rules;

  const FlowchartView({Key? key, required this.rules}) : super(key: key);

  @override
  State<FlowchartView> createState() => _FlowchartViewState();
}

class _FlowchartViewState extends State<FlowchartView> {
  double scale = 1.0;
  Offset offset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildToolbar(),
          Expanded(
            child: InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(double.infinity),
              minScale: 0.1,
              maxScale: 4.0,
              onInteractionUpdate: (details) {
                setState(() {
                  scale = details.scale;
                });
              },
              child: CustomPaint(
                painter: FlowchartPainter(widget.rules),
                child: Container(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        border: Border(bottom: BorderSide(color: Colors.white24)),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_tree, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          const Text(
            'Flowchart View',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(
            'Zoom: ${(scale * 100).toInt()}%',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.zoom_in, color: Colors.white70, size: 20),
            onPressed: () =>
                setState(() => scale = (scale * 1.2).clamp(0.1, 4.0)),
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out, color: Colors.white70, size: 20),
            onPressed: () =>
                setState(() => scale = (scale / 1.2).clamp(0.1, 4.0)),
          ),
          IconButton(
            icon: const Icon(Icons.fit_screen, color: Colors.white70, size: 20),
            onPressed: () => setState(() => scale = 1.0),
          ),
        ],
      ),
    );
  }
}

class FlowchartPainter extends CustomPainter {
  final List<ConditionalRule> rules;

  FlowchartPainter(this.rules);

  @override
  void paint(Canvas canvas, Size size) {
    final startX = size.width / 2;
    const startY = 50.0;

    // Draw start node
    _drawNode(canvas, Offset(startX, startY), 'Start', Colors.green);

    // Draw rules
    var currentY = startY + 100;
    for (var i = 0; i < rules.length; i++) {
      final rule = rules[i];

      // Draw condition diamond
      _drawDiamond(
        canvas,
        Offset(startX, currentY),
        'Condition ${i + 1}',
        Colors.orange,
      );

      // Draw yes/no branches
      _drawBranch(
        canvas,
        Offset(startX, currentY),
        Offset(startX - 150, currentY + 100),
        'Yes',
      );
      _drawBranch(
        canvas,
        Offset(startX, currentY),
        Offset(startX + 150, currentY + 100),
        'No',
      );

      // Draw action nodes
      _drawNode(
        canvas,
        Offset(startX - 150, currentY + 100),
        rule.action.type.toString(),
        Colors.blue,
      );

      currentY += 200;
    }

    // Draw end node
    _drawNode(canvas, Offset(startX, currentY), 'End', Colors.red);
  }

  void _drawNode(Canvas canvas, Offset position, String label, Color color) {
    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const radius = 40.0;
    canvas.drawCircle(position, radius, paint);
    canvas.drawCircle(position, radius, borderPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawDiamond(Canvas canvas, Offset position, String label, Color color) {
    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const size = 60.0;
    final path = Path()
      ..moveTo(position.dx, position.dy - size)
      ..lineTo(position.dx + size, position.dy)
      ..lineTo(position.dx, position.dy + size)
      ..lineTo(position.dx - size, position.dy)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: size * 1.5);

    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawBranch(Canvas canvas, Offset from, Offset to, String label) {
    final paint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(from, to, paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(color: Colors.white70, fontSize: 11),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final midPoint = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
    textPainter.paint(canvas, midPoint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
