import 'package:flutter/material.dart';

import '../../model/schema/node_type_config.dart';
import '../../../../model/workflow_node.dart';
import '../../../../state/workflow_state.dart';
import '../node_card/node_card_error_message.dart';
import '../node_card/node_card_port.dart';
import '../node_port/node_card_output_port.dart';

class StartShape extends StatelessWidget {
  final double width;
  final double height;
  final Color backgroundColor;
  final Color strokeColor;
  final Color circleColor;
  final Color textColor;
  final Color iconColor;
  final WorkflowNode node;
  final WorkflowState workflowState;
  final Color borderColor;
  final NodeConfig nodeConfig;
  final Widget child;
  final bool isSelected;

  const StartShape({
    super.key,
    this.width = 106,
    this.height = 59,
    this.backgroundColor = const Color(0xFF40E65F),
    this.strokeColor = const Color(0xFF979797),
    this.circleColor = const Color(0xFFD8D8D8),
    this.textColor = Colors.black,
    this.iconColor = const Color(0xFF191919),
    required this.node,
    required this.workflowState,
    this.borderColor = const Color(0xFF191919),
    required this.child,
    required this.nodeConfig,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          size: Size(width, height),
          painter: _WebhookArchivePainter(
            backgroundColor: backgroundColor,
            strokeColor: strokeColor,
            circleColor: circleColor,
            textColor: textColor,
            iconColor: iconColor,
          ),
        ),

        /*  NodeCardHeader(
          node: node,
          nodeConfig: nodeConfig,
          isSelected: isSelected,
        ), */
        child,

        if (node.outputs.isNotEmpty)
          /*  Stack(
            clipBehavior:
                Clip.none, // Important: Allow children to draw outside
            children: [ */
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: node.outputs.asMap().entries.map((entry) {
              final targetPortId = entry.value.id;
              return NodeCardOutputPort(
                nodeId: node.id,
                port: entry.value,
                index: entry.key,
                targetPortId: targetPortId,
                node: node,
              );
            }).toList(),
          ),
        //  ],
        //),
        // Node Ports
        //NodeCardPort(node: node),
        if (node.error != null) NodeCardErrorMessage(error: node.error!),
      ],
    );
  }
}

class _WebhookArchivePainter extends CustomPainter {
  final Color backgroundColor;
  final Color strokeColor;
  final Color circleColor;
  final Color textColor;
  final Color iconColor;

  _WebhookArchivePainter({
    required this.backgroundColor,
    required this.strokeColor,
    required this.circleColor,
    required this.textColor,
    required this.iconColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Create the main shape path
    final mainPath = _createMainPath();

    // Draw shadow first
    _drawShadow(canvas, mainPath);

    // Draw the main shape fill
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = backgroundColor;
    canvas.drawPath(mainPath, paint);

    // Draw the main shape stroke
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = strokeColor
      ..strokeWidth = 1.0;
    canvas.drawPath(mainPath, strokePaint);

    // Draw the circle
    _drawCircle(canvas);

    // Draw the archive icon
    _drawArchiveIcon(canvas);

    // Draw the text
    _drawText(canvas);
  }

  Path _createMainPath() {
    final path = Path();
    path.moveTo(100, 0);
    path.lineTo(100, 58);
    path.lineTo(32.9545455, 58);

    // Draw the curved left side using cubic curves to approximate the shape
    path.cubicTo(23.854399, 58, 15.6157626, 54.7540644, 9.6521629, 49.5060967);
    path.cubicTo(3.68856314, 44.2581289, 0, 37.0081289, 0, 29);
    path.cubicTo(0, 20.9918711, 3.68856314, 13.7418711, 9.6521629, 8.49390335);
    path.cubicTo(15.6157626, 3.24593556, 23.854399, 0, 32.9545455, 0);
    path.lineTo(100, 0);
    path.close();
    return path;
  }

  void _drawShadow(Canvas canvas, Path path) {
    // Create a shadow path that matches the main shape
    final shadowPath = path;

    // Draw shadow with offset and blur
    final shadowPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        4,
      ); // Gaussian blur

    // Save canvas state, apply offset, draw shadow, then restore
    canvas.save();
    canvas.translate(0, 4); // Shadow offset
    canvas.drawPath(shadowPath, shadowPaint);
    canvas.restore();
  }

  void _drawCircle(Canvas canvas) {
    final circlePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = circleColor;

    final circleStrokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = strokeColor
      ..strokeWidth = 1.0;

    final circleRect = Rect.fromCenter(
      center: const Offset(94 + 6, 23 + 6),
      width: 12,
      height: 12,
    );

    canvas.drawCircle(circleRect.center, 6, circlePaint);
    canvas.drawCircle(circleRect.center, 6, circleStrokePaint);
  }

  void _drawArchiveIcon(Canvas canvas) {
    final iconPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = iconColor
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = iconColor;

    // Transform for the icon group
    canvas.save();
    canvas.translate(10.5, 21);

    // Draw the top curved path
    final topPath = Path();
    topPath.moveTo(10, 0);
    topPath.lineTo(9.44349322, 7.15508717);
    topPath.cubicTo(9.3625052, 8.19636165, 8.49393456, 9, 7.44951529, 9);
    topPath.lineTo(2.55048471, 9);
    topPath.cubicTo(
      1.50606544,
      9,
      0.637494795,
      8.19636165,
      0.55650678,
      7.15508717,
    );
    topPath.lineTo(0, 0);

    canvas.drawPath(topPath, iconPaint);

    // Draw the rectangle (archive top)
    final rectPath = Path();
    rectPath.moveTo(3.15797572, 2.5);
    rectPath.lineTo(12.8420243, 2.5);
    rectPath.cubicTo(
      13.1390234,
      2.5,
      13.3254599,
      2.54641281,
      13.4884229,
      2.63356635,
    );
    rectPath.cubicTo(
      13.6513858,
      2.7207199,
      13.7792801,
      2.84861419,
      13.8664336,
      3.01157715,
    );
    rectPath.cubicTo(13.9535872, 3.17454011, 14, 3.36097661, 14, 3.65797572);
    rectPath.lineTo(14, 3.84202428);
    rectPath.cubicTo(
      14,
      4.13902339,
      13.9535872,
      4.32545989,
      13.8664336,
      4.48842285,
    );
    rectPath.cubicTo(
      13.7792801,
      4.65138581,
      13.6513858,
      4.7792801,
      13.4884229,
      4.86643365,
    );
    rectPath.cubicTo(13.3254599, 4.95358719, 13.1390234, 5, 12.8420243, 5);
    rectPath.lineTo(3.15797572, 5);
    rectPath.cubicTo(
      2.86097661,
      5,
      2.67454011,
      4.95358719,
      2.51157715,
      4.86643365,
    );
    rectPath.cubicTo(
      2.34861419,
      4.7792801,
      2.2207199,
      4.65138581,
      2.13356635,
      4.48842285,
    );
    rectPath.cubicTo(2.04641281, 4.32545989, 2, 4.13902339, 2, 3.84202428);
    rectPath.lineTo(2, 3.65797572);
    rectPath.cubicTo(
      2,
      3.36097661,
      2.04641281,
      3.17454011,
      2.13356635,
      3.01157715,
    );
    rectPath.cubicTo(
      2.2207199,
      2.84861419,
      2.34861419,
      2.7207199,
      2.51157715,
      2.63356635,
    );
    rectPath.cubicTo(2.67454011, 2.54641281, 2.86097661, 2.5, 3.15797572, 2.5);
    rectPath.close();

    canvas.drawPath(rectPath, iconPaint);

    // Draw the small rectangle at the bottom
    final smallRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(6, 7, 4, 1.5),
      const Radius.circular(0.75),
    );
    canvas.drawRRect(smallRect, fillPaint);

    canvas.restore();
  }

  void _drawText(Canvas canvas) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Webhook',
        style: TextStyle(
          fontFamily: 'Helvetica',
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, const Offset(34.5, 21));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
