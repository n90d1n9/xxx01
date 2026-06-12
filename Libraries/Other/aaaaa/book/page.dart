import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:math' as math;

class PageCurlWidget extends StatefulWidget {
  final Widget currentPage;
  final Widget? nextPage;
  final VoidCallback? onPageTurn;
  final double sensitivity;

  const PageCurlWidget({
    Key? key,
    required this.currentPage,
    this.nextPage,
    this.onPageTurn,
    this.sensitivity = 0.3,
  }) : super(key: key);

  @override
  State<PageCurlWidget> createState() => _PageCurlWidgetState();
}

class _PageCurlWidgetState extends State<PageCurlWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  Offset _curlPosition = Offset.zero;
  bool _isDragging = false;
  double _curlRadius = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _animation.addListener(() {
      setState(() {});
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onPageTurn?.call();
        _resetCurl();
      } else if (status == AnimationStatus.dismissed) {
        _resetCurl();
      }
    });
  }

  void _resetCurl() {
    setState(() {
      _curlPosition = Offset.zero;
      _curlRadius = 0.0;
      _isDragging = false;
    });
    _controller.reset();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final size = box.size;
    final position = details.localPosition;

    // Only start curl if touching bottom-right corner area
    if (position.dx > size.width * 0.7 && position.dy > size.height * 0.7) {
      setState(() {
        _isDragging = true;
        _curlPosition = position;
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    final RenderBox box = context.findRenderObject() as RenderBox;
    final size = box.size;
    final position = details.localPosition;

    // Calculate curl radius based on distance from bottom-right corner
    final bottomRight = Offset(size.width, size.height);
    final distance = (bottomRight - position).distance;
    final maxDistance = math.sqrt(
      size.width * size.width + size.height * size.height,
    );

    setState(() {
      _curlPosition = position;
      _curlRadius = (distance / maxDistance * 300).clamp(0.0, 200.0);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isDragging) return;

    final RenderBox box = context.findRenderObject() as RenderBox;
    final size = box.size;

    // Check if dragged far enough to turn page
    final dragDistance =
        (Offset(size.width, size.height) - _curlPosition).distance;
    final threshold = math.min(size.width, size.height) * widget.sensitivity;

    if (dragDistance > threshold) {
      _controller.forward();
    } else {
      _controller.reverse().then((_) => _resetCurl());
    }

    setState(() {
      _isDragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Stack(
        children: [
          // Next page (underneath)
          if (widget.nextPage != null) widget.nextPage!,

          // Current page with curl effect
          CustomPaint(
            painter: PageCurlPainter(
              currentPage: widget.currentPage,
              curlPosition: _curlPosition,
              curlRadius: _isDragging ? _curlRadius : _animation.value * 200,
              animationProgress: _controller.value,
            ),
            size: Size.infinite,
          ),
        ],
      ),
    );
  }
}

class PageCurlPainter extends CustomPainter {
  final Widget currentPage;
  final Offset curlPosition;
  final double curlRadius;
  final double animationProgress;

  PageCurlPainter({
    required this.currentPage,
    required this.curlPosition,
    required this.curlRadius,
    required this.animationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (curlRadius <= 0) {
      // Draw normal page
      _drawPage(canvas, size);
      return;
    }

    // Create curl path
    final curlPath = _createCurlPath(size);
    final shadowPath = _createShadowPath(size);

    // Draw page shadow
    final shadowPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.save();
    canvas.translate(4, 4);
    canvas.drawPath(shadowPath, shadowPaint);
    canvas.restore();

    // Clip and draw the main page
    canvas.save();
    canvas.clipPath(curlPath);
    _drawPage(canvas, size);
    canvas.restore();

    // Draw the curled corner
    _drawCurledCorner(canvas, size);

    // Add curl shadow on the page
    final curlShadowPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.1)
          ..style = PaintingStyle.fill;

    final gradientRect = Rect.fromPoints(
      Offset(size.width - curlRadius, size.height - curlRadius),
      Offset(size.width, size.height),
    );

    curlShadowPaint.shader = RadialGradient(
      center: Alignment.bottomRight,
      radius: 0.8,
      colors: [Colors.black.withOpacity(0.15), Colors.transparent],
    ).createShader(gradientRect);

    canvas.save();
    canvas.clipPath(curlPath);
    canvas.drawRect(gradientRect, curlShadowPaint);
    canvas.restore();
  }

  Path _createCurlPath(Size size) {
    final path = Path();

    if (curlRadius <= 0) {
      path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
      return path;
    }

    // Start from top-left
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);

    // Right edge to curl start
    final curlStartY = size.height - curlRadius;
    path.lineTo(size.width, curlStartY);

    // Create smooth curve for curl
    final controlPoint1 = Offset(
      size.width - curlRadius * 0.3,
      size.height - curlRadius * 0.7,
    );
    final controlPoint2 = Offset(
      size.width - curlRadius * 0.7,
      size.height - curlRadius * 0.3,
    );
    final endPoint = Offset(size.width - curlRadius, size.height);

    path.cubicTo(
      controlPoint1.dx,
      controlPoint1.dy,
      controlPoint2.dx,
      controlPoint2.dy,
      endPoint.dx,
      endPoint.dy,
    );

    // Complete the path
    path.lineTo(0, size.height);
    path.lineTo(0, 0);
    path.close();

    return path;
  }

  Path _createShadowPath(Size size) {
    final path = Path();
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    return path;
  }

  void _drawPage(Canvas canvas, Size size) {
    // Draw white background
    final pagePaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), pagePaint);
  }

  void _drawCurledCorner(Canvas canvas, Size size) {
    if (curlRadius <= 0) return;

    final cornerPath = Path();

    // Create the curled corner shape
    final centerX = size.width - curlRadius * 0.5;
    final centerY = size.height - curlRadius * 0.5;

    cornerPath.moveTo(size.width - curlRadius, size.height);
    cornerPath.quadraticBezierTo(
      centerX,
      size.height - curlRadius * 0.2,
      size.width - curlRadius * 0.2,
      centerY,
    );
    cornerPath.quadraticBezierTo(
      size.width - curlRadius * 0.7,
      size.height - curlRadius * 0.7,
      size.width - curlRadius,
      size.height,
    );
    cornerPath.close();

    // Draw curled corner with gradient
    final cornerPaint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey[100]!, Colors.grey[300]!],
          ).createShader(cornerPath.getBounds());

    canvas.drawPath(cornerPath, cornerPaint);

    // Add highlight to curled edge
    final highlightPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    canvas.drawPath(cornerPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant PageCurlPainter oldDelegate) {
    return oldDelegate.curlPosition != curlPosition ||
        oldDelegate.curlRadius != curlRadius ||
        oldDelegate.animationProgress != animationProgress;
  }
}

// Example usage
class PDFReaderExample extends StatefulWidget {
  @override
  _PDFReaderExampleState createState() => _PDFReaderExampleState();
}

class _PDFReaderExampleState extends State<PDFReaderExample> {
  int currentPageIndex = 0;

  final List<PageData> pages = [
    PageData("Page 1", "Introduction", Colors.blue[50]!),
    PageData("Page 2", "Getting Started", Colors.green[50]!),
    PageData("Page 3", "Advanced Topics", Colors.orange[50]!),
    PageData("Page 4", "Best Practices", Colors.purple[50]!),
    PageData("Page 5", "Conclusion", Colors.red[50]!),
  ];

  Widget _buildPage(PageData pageData) {
    return Container(
      decoration: BoxDecoration(
        color: pageData.backgroundColor,
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pageData.title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            pageData.subtitle,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 40),
          // Simulate paragraph content
          ...List.generate(
            12,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  if (index % 3 == 2)
                    const SizedBox(width: 100), // Shorter lines occasionally
                ],
              ),
            ),
          ),
          const Spacer(),
          // Page indicator
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${currentPageIndex + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    if (currentPageIndex < pages.length - 1) {
      setState(() {
        currentPageIndex++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'PDF Reader - Page ${currentPageIndex + 1}/${pages.length}',
        ),
        backgroundColor: Colors.indigo[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: PageCurlWidget(
          currentPage: _buildPage(pages[currentPageIndex]),
          nextPage:
              currentPageIndex < pages.length - 1
                  ? _buildPage(pages[currentPageIndex + 1])
                  : Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.book, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'End of Document',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          onPageTurn: _nextPage,
          sensitivity: 0.25,
        ),
      ),
    );
  }
}

class PageData {
  final String title;
  final String subtitle;
  final Color backgroundColor;

  PageData(this.title, this.subtitle, this.backgroundColor);
}

void main(List<String> args) {
  runApp(
    MaterialApp(
      home: PDFReaderExample(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    ),
  );
}
