import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: Text('Grouped Bar Chart with Tooltip')),
      body: GroupedBarChart2(),
    ),
  ));
}

class GroupedBarChart2 extends StatefulWidget {
  @override
  _GroupedBarChartState createState() => _GroupedBarChartState();
}

class _GroupedBarChartState extends State<GroupedBarChart2> {
  Offset? _hoverPosition;
  String? _tooltipValue;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (details) {
        setState(() {
          _hoverPosition = details.localPosition;
        });
      },
      onPanCancel: () {
        setState(() {
          _hoverPosition = null;
          _tooltipValue = null;
        });
      },
      onPanEnd: (_) {
        setState(() {
          _hoverPosition = null;
          _tooltipValue = null;
        });
      },
      child: Stack(
        children: [
          CustomPaint(
            size: Size(double.infinity, 400),
            painter: GroupedBarChartPainter(
              hoverPosition: _hoverPosition,
              onValueHover: (value) {
                setState(() {
                  _tooltipValue = value;
                });
              },
            ),
          ),
          if (_hoverPosition != null && _tooltipValue != null)
            Positioned(
              left: _hoverPosition!.dx + 10,
              top: _hoverPosition!.dy - 30,
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.white,
                  child: Text(
                    _tooltipValue!,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class GroupedBarChartPainter extends CustomPainter {
  final Offset? hoverPosition;
  final Function(String) onValueHover;

  GroupedBarChartPainter({this.hoverPosition, required this.onValueHover});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final Paint barPaint = Paint()
      ..style = PaintingStyle.fill;

    final double padding = 40;
    final double chartWidth = size.width - padding * 2;
    final double chartHeight = size.height - padding * 2;

    final int gridLines = 5;
    final double maxValue = 400;

    // Draw grid lines
    for (int i = 0; i <= gridLines; i++) {
      final double y = padding + (chartHeight / gridLines) * i;
      canvas.drawLine(Offset(padding, y), Offset(size.width - padding, y), gridPaint);

      // Draw Y-axis labels
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: '${(maxValue - (maxValue / gridLines) * i).toInt()}',
          style: TextStyle(color: Colors.grey[700], fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(padding - textPainter.width - 5, y - textPainter.height / 2));
    }

    // Draw axes
    final Paint axisPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    canvas.drawLine(Offset(padding, padding), Offset(padding, size.height - padding), axisPaint);
    canvas.drawLine(Offset(padding, size.height - padding), Offset(size.width - padding, size.height - padding), axisPaint);

    // Data for the chart
    final List<String> years = ['2012', '2013', '2014', '2015', '2016'];
    final List<String> categories = ['Forest', 'Steppe', 'Desert', 'Wetland'];
    final List<List<double>> values = [
      [300, 200, 50, 80],
      [350, 250, 70, 90],
      [320, 220, 60, 85],
      [340, 240, 75, 95],
      [400, 300, 90, 100],
    ];

    // Bar chart configuration
    final double groupSpacing = 20;
    final double barSpacing = 10;
    final double barWidth = (chartWidth / years.length - groupSpacing) / categories.length;

    final List<Color> barColors = [
      Colors.green[400]!,
      Colors.green[700]!,
      Colors.orange[400]!,
      Colors.purple[400]!,
    ];

    // Draw bars and handle hover detection
    for (int i = 0; i < years.length; i++) {
      final double groupStartX = padding + i * (chartWidth / years.length) + groupSpacing / 2;

      for (int j = 0; j < categories.length; j++) {
        final double barHeight = (values[i][j] / maxValue) * chartHeight;
        final double barStartX = groupStartX + j * (barWidth + barSpacing);
        final double barStartY = size.height - padding - barHeight;

        barPaint.color = barColors[j];
        final Rect barRect = Rect.fromLTWH(barStartX, barStartY, barWidth, barHeight);
        canvas.drawRect(barRect, barPaint);

        // Detect hover over bar
        if (hoverPosition != null && barRect.contains(hoverPosition!)) {
          onValueHover('${categories[j]}: ${values[i][j]}');
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
