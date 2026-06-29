import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image/image.dart' as img;

/// Enum to define QR code shape
enum QrCodeShape { rectangle, circle, roundedRectangle }

/// Advanced QR Code Generator Widget
class AdvancedQrCodeGenerator extends StatelessWidget {
  /// The data to be encoded in the QR code
  final String data;

  /// Logo image to be overlaid on the QR code
  final ImageProvider? logo;

  /// Size of the QR code
  final double size;

  /// Shape of the QR code
  final QrCodeShape shape;

  /// Color of the QR code
  final Color foregroundColor;

  /// Background color of the QR code
  final Color backgroundColor;

  /// Logo size (defaults to 20% of QR code size)
  final double? logoSize;

  /// Border radius for rounded rectangle shape
  final BorderRadius borderRadius;

  const AdvancedQrCodeGenerator({
    Key? key,
    required this.data,
    this.logo,
    this.size = 200,
    this.shape = QrCodeShape.rectangle,
    this.foregroundColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.logoSize,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _QrCodeClipper(shape, borderRadius),
      child: Container(
        color: backgroundColor,
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // QR Code
            QrImageView(
              data: data,
              version: QrVersions.auto,
              size: size,
              foregroundColor: foregroundColor,
              backgroundColor: backgroundColor,
            ),

            // Optional Logo
            if (logo != null)
              Container(
                width: logoSize ?? size * 0.2,
                height: logoSize ?? size * 0.2,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape:
                      shape == QrCodeShape.circle
                          ? BoxShape.circle
                          : BoxShape.rectangle,
                  borderRadius:
                      shape == QrCodeShape.roundedRectangle
                          ? borderRadius
                          : null,
                  image: DecorationImage(image: logo!, fit: BoxFit.cover),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Custom clipper to create different QR code shapes
class _QrCodeClipper extends CustomClipper<Path> {
  final QrCodeShape shape;
  final BorderRadius borderRadius;

  _QrCodeClipper(this.shape, this.borderRadius);

  @override
  Path getClip(Size size) {
    switch (shape) {
      case QrCodeShape.circle:
        return Path()..addOval(
          Rect.fromCircle(
            center: Offset(size.width / 2, size.height / 2),
            radius: size.width / 2,
          ),
        );

      case QrCodeShape.roundedRectangle:
        return Path()..addRRect(
          borderRadius
              .resolve(TextDirection.ltr)
              .toRRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        );

      case QrCodeShape.rectangle:
      default:
        return Path()..addRect(Offset.zero & size);
    }
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Example Usage in a Widget
class QrCodeExampleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('QR Code Generator')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Rectangle QR Code with Black and White
            AdvancedQrCodeGenerator(
              data: 'https://www.example.com',
              size: 250,
              shape: QrCodeShape.rectangle,
              foregroundColor: Colors.indigo,
            ),
            SizedBox(height: 20),

            // Circular QR Code with Logo
            AdvancedQrCodeGenerator(
              data: 'https://www.example.com',
              logo: AssetImage('assets/icons/caliphart-logo.png'),
              size: 250,
              shape: QrCodeShape.circle,
              foregroundColor: Colors.green,
              backgroundColor: Colors.white70,
            ),
            SizedBox(height: 20),

            // Rounded Rectangle QR Code
            AdvancedQrCodeGenerator(
              data: 'https://www.example.com',
              size: 250,
              shape: QrCodeShape.roundedRectangle,
              foregroundColor: Colors.deepPurple,
              borderRadius: BorderRadius.circular(32),
            ),
          ],
        ),
      ),
    );
  }
}
