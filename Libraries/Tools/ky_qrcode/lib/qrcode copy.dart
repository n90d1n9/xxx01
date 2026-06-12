// First, ensure you have these dependencies in your pubspec.yaml:
//
// dependencies:
//   flutter:
//     sdk: flutter
//   flutter_riverpod: ^2.3.6
//   qr_flutter: ^4.1.0
//   image_picker: ^1.0.4
//   path_provider: ^2.1.1
//   share_plus: ^7.1.0
//   google_fonts: ^6.1.0

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

// QR Code Style enum
enum QRCodeStyle { standard, rounded, dots, neon, gradient, embossed, minimal }

// QR Code State
class QRCodeState {
  final String data;
  final QRCodeStyle style;
  final Color primaryColor;
  final Color backgroundColor;
  final Color? secondaryColor;
  final File? logo;
  final double size;
  final double borderRadius;

  QRCodeState({
    required this.data,
    this.style = QRCodeStyle.standard,
    this.primaryColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.secondaryColor,
    this.logo,
    this.size = 250.0,
    this.borderRadius = 16.0,
  });

  QRCodeState copyWith({
    String? data,
    QRCodeStyle? style,
    Color? primaryColor,
    Color? backgroundColor,
    Color? secondaryColor,
    File? logo,
    double? size,
    double? borderRadius,
  }) {
    return QRCodeState(
      data: data ?? this.data,
      style: style ?? this.style,
      primaryColor: primaryColor ?? this.primaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      logo: logo ?? this.logo,
      size: size ?? this.size,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }
}

// QR Code Notifier
class QRCodeNotifier extends StateNotifier<QRCodeState> {
  QRCodeNotifier()
    : super(
        QRCodeState(data: 'https://flutter.dev', secondaryColor: Colors.blue),
      );

  void updateData(String data) {
    state = state.copyWith(data: data);
  }

  void updateStyle(QRCodeStyle style) {
    state = state.copyWith(style: style);
  }

  void updatePrimaryColor(Color color) {
    state = state.copyWith(primaryColor: color);
  }

  void updateBackgroundColor(Color color) {
    state = state.copyWith(backgroundColor: color);
  }

  void updateSecondaryColor(Color color) {
    state = state.copyWith(secondaryColor: color);
  }

  void updateSize(double size) {
    state = state.copyWith(size: size);
  }

  Future<void> pickLogo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      state = state.copyWith(logo: File(image.path));
    }
  }

  void removeLogo() {
    state = state.copyWith(logo: null);
  }
}

// Providers
final qrCodeProvider = StateNotifierProvider<QRCodeNotifier, QRCodeState>((
  ref,
) {
  return QRCodeNotifier();
});

class QRCodeGeneratorScreen extends ConsumerWidget {
  final GlobalKey _qrKey = GlobalKey();

  QRCodeGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qrState = ref.watch(qrCodeProvider);
    TextEditingController controller = TextEditingController();

    controller.text = qrState.data;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'QR Code Generator',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _captureAndSave(context),
            tooltip: 'Save QR Code',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // QR Code Preview
            RepaintBoundary(
              key: _qrKey,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: qrState.backgroundColor,
                  borderRadius: BorderRadius.circular(qrState.borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: _buildQRCodeWidget(qrState),
              ),
            ),
            const SizedBox(height: 30),
            // URL Input Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Enter URL or Text',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.link),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    ref.read(qrCodeProvider.notifier).updateData(value);
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            // Style Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'QR Code Style',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 60,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: QRCodeStyle.values.map((style) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: InkWell(
                            onTap: () {
                              ref
                                  .read(qrCodeProvider.notifier)
                                  .updateStyle(style);
                            },
                            child: Container(
                              width: 60,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: qrState.style == style
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey.shade300,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  style.name[0].toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: qrState.style == style
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: qrState.style == style
                                        ? Theme.of(context).primaryColor
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Color Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Primary Color',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 5),
                        _buildColorSelector(
                          context,
                          qrState.primaryColor,
                          (color) => ref
                              .read(qrCodeProvider.notifier)
                              .updatePrimaryColor(color),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Background Color',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 5),
                        _buildColorSelector(
                          context,
                          qrState.backgroundColor,
                          (color) => ref
                              .read(qrCodeProvider.notifier)
                              .updateBackgroundColor(color),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Secondary Color (for gradient and neon styles)
            if (qrState.style == QRCodeStyle.gradient ||
                qrState.style == QRCodeStyle.neon)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Secondary Color',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),
                    _buildColorSelector(
                      context,
                      qrState.secondaryColor ?? Colors.blue,
                      (color) => ref
                          .read(qrCodeProvider.notifier)
                          .updateSecondaryColor(color),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            // Logo Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref.read(qrCodeProvider.notifier).pickLogo();
                      },
                      icon: const Icon(Icons.image),
                      label: const Text('Add Logo'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  if (qrState.logo != null) ...[
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () {
                        ref.read(qrCodeProvider.notifier).removeLogo();
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Remove Logo',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Future<ui.Image?> _getImageFromFile(File? file) async {
    if (file == null) return null;

    final Uint8List bytes = await file.readAsBytes();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  Future<ui.Image> getImagePainter(state) {
    return FutureBuilder<ui.Image?>(
      future: _getImageFromFile(state.logo),
      builder: (context, snapshot) {
        return CustomPaint(
          size: Size(state.size, state.size),
          painter: QrPainter(
            data: state.data,
            version: QrVersions.auto,
            eyeStyle: QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: state.primaryColor,
            ),
            dataModuleStyle: QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: state.primaryColor,
            ),
            // Use the image from the snapshot
            embeddedImage: snapshot.data,
            embeddedImageStyle: snapshot.data != null
                ? QrEmbeddedImageStyle(
                    size: Size(state.size * 0.2, state.size * 0.2),
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildQRCodeWidget(QRCodeState state) {
    QrPainter painter;

    switch (state.style) {
      case QRCodeStyle.rounded:
        painter = getImagePainter(state); /* QrPainter(
          data: state.data,
          version: QrVersions.auto,
          eyeStyle: QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: state.primaryColor,
          ),
          dataModuleStyle: QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.circle,
            color: state.primaryColor,
          ),
          gapless: false,
          embeddedImage: getImagePainter(
            state,
          ), //state.logo != null ? FileImage(state.logo!) : null,
          embeddedImageStyle:
              state.logo != null
                  ? QrEmbeddedImageStyle(
                    size: Size(state.size * 0.2, state.size * 0.2),
                  )
                  : null,
        ); */
        break;
      case QRCodeStyle.dots:
        painter = getImagePainter(state); /* QrPainter(
          data: state.data,
          version: QrVersions.auto,
          eyeStyle: QrEyeStyle(
            eyeShape: QrEyeShape.circle,
            color: state.primaryColor,
          ),
          dataModuleStyle: QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.circle,
            color: state.primaryColor,
          ),
          gapless: true,
          embeddedImage: getImagePainter(
            state,
          ), //state.logo != null ? FileImage(state.logo!) : null,
          embeddedImageStyle:
              state.logo != null
                  ? QrEmbeddedImageStyle(
                    size: Size(state.size * 0.2, state.size * 0.2),
                  )
                  : null,
        ); */
        break;
      case QRCodeStyle.gradient:
        // For gradient style, we'll use CustomPaint later
        painter = getImagePainter(state); /* QrPainter(
          data: state.data,
          version: QrVersions.auto,
          eyeStyle: QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: state.primaryColor,
          ),
          dataModuleStyle: QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: state.primaryColor,
          ),
          embeddedImage: getImagePainter(
            state,
          ), //state.logo != null ? FileImage(state.logo!) : null,
          embeddedImageStyle:
              state.logo != null
                  ? QrEmbeddedImageStyle(
                    size: Size(state.size * 0.2, state.size * 0.2),
                  )
                  : null,
        ); */
        break;
      case QRCodeStyle.neon:
        return Container(
          width: state.size,
          height: state.size,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              QrImageView(
                data: state.data,
                version: QrVersions.auto,
                size: state.size * 0.9,
                backgroundColor: Colors.transparent,
                eyeStyle: QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: state.primaryColor.withValues(alpha: 0.8),
                ),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: state.primaryColor.withValues(alpha: 0.8),
                ),
              ),
              Container(
                width: state.size * 0.9,
                height: state.size * 0.9,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: state.primaryColor.withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: (state.secondaryColor ?? state.primaryColor)
                          .withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
              if (state.logo != null)
                Container(
                  width: state.size * 0.2,
                  height: state.size * 0.2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: FileImage(state.logo!),
                      fit: BoxFit.contain,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: state.primaryColor.withValues(alpha: 0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      case QRCodeStyle.embossed:
        return Container(
          width: state.size,
          height: state.size,
          decoration: BoxDecoration(
            color: state.backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: state.size * 0.9,
                height: state.size * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: state.primaryColor.withValues(alpha: 0.1),
                      blurRadius: 4,
                      spreadRadius: 2,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: state.data,
                  version: QrVersions.auto,
                  size: state.size * 0.9,
                  backgroundColor: Colors.transparent,
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: state.primaryColor,
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: state.primaryColor,
                  ),
                  embeddedImage: state.logo != null
                      ? FileImage(state.logo!)
                      : null,
                  embeddedImageStyle: state.logo != null
                      ? QrEmbeddedImageStyle(
                          size: Size(state.size * 0.2, state.size * 0.2),
                        )
                      : null,
                ),
              ),
            ],
          ),
        );
      case QRCodeStyle.minimal:
        return Container(
          width: state.size,
          height: state.size,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: state.backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: state.primaryColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: QrImageView(
            data: state.data,
            version: QrVersions.auto,
            size: state.size * 0.9,
            backgroundColor: Colors.transparent,
            eyeStyle: QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: state.primaryColor,
            ),
            dataModuleStyle: QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: state.primaryColor,
            ),
            embeddedImage: state.logo != null ? FileImage(state.logo!) : null,
            embeddedImageStyle: state.logo != null
                ? QrEmbeddedImageStyle(
                    size: Size(state.size * 0.2, state.size * 0.2),
                  )
                : null,
          ),
        );
      case QRCodeStyle.standard:
      default:
        painter = getImagePainter(state); /* QrPainter(
          data: state.data,
          version: QrVersions.auto,
          eyeStyle: QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: state.primaryColor,
          ),
          dataModuleStyle: QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: state.primaryColor,
          ),
          embeddedImage: getImagePainter(
            state,
          ), //state.logo != null ? FileImage(state.logo!) : null,
          embeddedImageStyle:
              state.logo != null
                  ? QrEmbeddedImageStyle(
                    size: Size(state.size * 0.2, state.size * 0.2),
                  )
                  : null,
        ); */
    }

    if (state.style == QRCodeStyle.gradient) {
      return ShaderMask(
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            colors: [state.primaryColor, state.secondaryColor ?? Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds);
        },
        child: CustomPaint(
          size: Size(state.size, state.size),
          painter: painter,
        ),
      );
    }

    return CustomPaint(size: Size(state.size, state.size), painter: painter);
  }

  Widget _buildColorSelector(
    BuildContext context,
    Color currentColor,
    Function(Color) onColorSelected,
  ) {
    final List<Color> presetColors = [
      Colors.black,
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
    ];

    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: currentColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(7),
                bottomLeft: Radius.circular(7),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: presetColors.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => onColorSelected(presetColors[index]),
                  child: Container(
                    width: 30,
                    height: 30,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: presetColors[index],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: currentColor == presetColors[index]
                            ? Colors.white
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _captureAndSave(BuildContext context) async {
    try {
      final RenderRepaintBoundary boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();

        // Save to temporary file
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/qr_code.png');
        await file.writeAsBytes(pngBytes);

        // Share file
        await Share.shareXFiles([
          XFile(file.path),
        ], text: 'Here is your QR code');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR Code shared successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving QR Code: $e')));
    }
  }
}

// Main app for usage example
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code Generator',

      home: QRCodeGeneratorScreen(),
    );
  }
}
