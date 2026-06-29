import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_picker/image_picker.dart';

enum QrCodeShape { rectangle, circle, roundedRectangle }

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

class AdvancedQrCodeGenerator extends StatefulWidget {
  final String data;
  final double size;
  final QrCodeShape shape;
  final Color foregroundColor;
  final Color backgroundColor;
  final double? logoSize;
  final BorderRadius borderRadius;

  const AdvancedQrCodeGenerator({
    Key? key,
    required this.data,
    this.size = 200,
    this.shape = QrCodeShape.rectangle,
    this.foregroundColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.logoSize,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  }) : super(key: key);

  @override
  _AdvancedQrCodeGeneratorState createState() =>
      _AdvancedQrCodeGeneratorState();
}

class _AdvancedQrCodeGeneratorState extends State<AdvancedQrCodeGenerator> {
  File? _logoFile;

  Future<void> _pickLogoFromDevice() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,
      maxHeight: 300,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _logoFile = File(pickedFile.path);
      });
    }
  }

  void _removeCurrentLogo() {
    setState(() {
      _logoFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipPath(
            clipper: _QrCodeClipper(widget.shape, widget.borderRadius),
            child: Container(
              color: widget.backgroundColor,
              width: widget.size,
              height: widget.size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // QR Code
                  QrImageView(
                    data: widget.data,
                    version: QrVersions.auto,
                    size: widget.size,
                    eyeStyle: QrEyeStyle(
                      eyeShape: QrEyeShape.circle,
                      color: widget.foregroundColor,
                    ),
                    embeddedImage:
                        _logoFile != null ? FileImage(_logoFile!) : null,
                    backgroundColor: widget.backgroundColor,
                  ),

                  // Optional Logo
                  if (_logoFile != null)
                    Container(
                      width: widget.logoSize ?? widget.size * 0.2,
                      height: widget.logoSize ?? widget.size * 0.2,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape:
                            widget.shape == QrCodeShape.circle
                                ? BoxShape.circle
                                : BoxShape.rectangle,
                        borderRadius:
                            widget.shape == QrCodeShape.roundedRectangle
                                ? widget.borderRadius
                                : null,
                        /*                       image: DecorationImage(
                        image: FileImage(_logoFile!),
                        fit: BoxFit.cover,
                      ), */
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _pickLogoFromDevice,
                icon: Icon(Icons.image),
                label: Text('Pick Logo'),
              ),
              SizedBox(width: 16),
              if (_logoFile != null)
                ElevatedButton.icon(
                  onPressed: _removeCurrentLogo,
                  icon: Icon(Icons.clear),
                  label: Text('Remove Logo'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

void main(List<String> args) {
  runApp(MaterialApp(home: QrCodeExampleScreen()));
}

/// Example Usage in a Widget
class QrCodeExampleScreen extends StatelessWidget {
  const QrCodeExampleScreen({super.key});

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
              //logo: AssetImage('assets/icons/caliphart-logo.png'),
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
