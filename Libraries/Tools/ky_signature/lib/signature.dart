import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:async';
import 'dart:math';

class TrendySignaturePad extends StatefulWidget {
  final Color strokeColor;
  final double strokeWidth;
  final Color backgroundColor;
  final BorderRadius borderRadius;
  final BoxShadow boxShadow;
  final Function(Uint8List)? onSigned;
  final double height;
  final double width;
  final String placeholder;
  final TextStyle placeholderStyle;

  const TrendySignaturePad({
    Key? key,
    this.strokeColor = const Color(0xFF0A84FF),
    this.strokeWidth = 3.0,
    this.backgroundColor = Colors.white,
    this.borderRadius = const BorderRadius.all(Radius.circular(16.0)),
    this.boxShadow = const BoxShadow(
      color: Color(0x20000000),
      blurRadius: 12,
      spreadRadius: 1,
      offset: Offset(0, 4),
    ),
    this.onSigned,
    this.height = 200,
    this.width = double.infinity,
    this.placeholder = 'Sign here',
    this.placeholderStyle = const TextStyle(
      color: Color(0xFFBBBBBB),
      fontSize: 18,
      fontWeight: FontWeight.w500,
    ),
  }) : super(key: key);

  @override
  _TrendySignaturePadState createState() => _TrendySignaturePadState();
}

class _TrendySignaturePadState extends State<TrendySignaturePad> with SingleTickerProviderStateMixin {
  List<SignaturePoint> points = [];
  bool isSigning = false;
  bool isEmpty = true;
  late AnimationController _animationController;
  late Animation<double> _cursorAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _cursorAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final point = renderBox.globalToLocal(details.globalPosition);
    setState(() {
      points = [SignaturePoint(point, ui.PointMode.points, widget.strokeColor)];
      isSigning = true;
      isEmpty = false;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!isSigning) return;
    
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final point = renderBox.globalToLocal(details.globalPosition);
    
    setState(() {
      points.add(SignaturePoint(point, ui.PointMode.lines, widget.strokeColor));
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      isSigning = false;
    });
    
    // Only export if there's a valid signature
    if (!isEmpty && widget.onSigned != null) {
      _exportSignature();
    }
  }

  Future<void> _exportSignature() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromPoints(
        const Offset(0.0, 0.0),
        Offset(widget.width, widget.height),
      ),
    );

    // Draw white background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, widget.width, widget.height),
      Paint()..color = Colors.white,
    );

    // Draw the signature
    final paint = Paint()
      ..color = widget.strokeColor
      ..strokeWidth = widget.strokeWidth
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i].point, points[i + 1].point, paint);
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(widget.width.toInt(), widget.height.toInt());
    final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
    
    if (pngBytes != null && widget.onSigned != null) {
      widget.onSigned!(pngBytes.buffer.asUint8List());
    }
  }

  void _clearSignature() {
    setState(() {
      points.clear();
      isEmpty = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: widget.borderRadius,
            boxShadow: [widget.boxShadow],
          ),
          child: Stack(
            children: [
              // The actual signature pad
              GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: CustomPaint(
                  painter: SignaturePainter(
                    points: points,
                    strokeColor: widget.strokeColor,
                    strokeWidth: widget.strokeWidth,
                  ),
                  size: Size.infinite,
                ),
              ),
              
              // Placeholder text when empty
              if (isEmpty)
                Center(
                  child: FadeTransition(
                    opacity: _cursorAnimation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.edit,
                          color: Color(0xFFBBBBBB),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.placeholder,
                          style: widget.placeholderStyle,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Clear button
            TextButton.icon(
              onPressed: isEmpty ? null : _clearSignature,
              icon: const Icon(Icons.refresh),
              label: const Text('Clear'),
              style: TextButton.styleFrom(
                foregroundColor: isEmpty ? Colors.grey : Colors.red,
              ),
            ),
            
            // Save/done button
            ElevatedButton.icon(
              onPressed: isEmpty ? null : () => _exportSignature(),
              icon: const Icon(Icons.check),
              label: const Text('Done'),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.strokeColor,
                foregroundColor: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SignaturePoint {
  final Offset point;
  final ui.PointMode mode;
  final Color color;

  SignaturePoint(this.point, this.mode, this.color);
}

class SignaturePainter extends CustomPainter {
  final List<SignaturePoint> points;
  final Color strokeColor;
  final double strokeWidth;

  SignaturePainter({
    required this.points,
    required this.strokeColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i].mode == ui.PointMode.points) {
        canvas.drawPoints(ui.PointMode.points, [points[i].point], paint);
      } else {
        canvas.drawLine(points[i].point, points[i + 1].point, paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) {
    return oldDelegate.points != points;
  }
}

// Example implementation
class SignatureScreen extends StatefulWidget {
  const SignatureScreen({Key? key}) : super(key: key);

  @override
  _SignatureScreenState createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  Uint8List? _signatureImage;
  bool _showPreview = false;

  void _handleSignature(Uint8List data) {
    setState(() {
      _signatureImage = data;
      _showPreview = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Signature'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and description
            const Text(
              'Please sign below',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your signature confirms that you agree to the terms and conditions.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            
            // The signature widget
            TrendySignaturePad(
              height: 200,
              strokeColor: const Color(0xFF3772FF),
              strokeWidth: 3.0,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const BoxShadow(
                color: Color(0x15000000),
                blurRadius: 15,
                spreadRadius: 1,
                offset: Offset(0, 5),
              ),
              onSigned: _handleSignature,
              placeholder: 'Sign your name here',
            ),
            
            // Signature preview
            if (_showPreview && _signatureImage != null) ...[
              const SizedBox(height: 32),
              const Text(
                'Signature Preview:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Image.memory(_signatureImage!),
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Handle submission
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Signature submitted successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3772FF),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Submit Signature',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}