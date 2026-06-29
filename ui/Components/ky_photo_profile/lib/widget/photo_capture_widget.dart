import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:image/image.dart' as img;
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../model/photo_capture_guidelines.dart';
import '../model/photo_capture_state.dart';
import '../model/photo_capture_step.dart';
import '../model/profile_photo.dart';
import '../service/face_analysis_service.dart';

class ProfilePhotoCaptureWidget extends HookConsumerWidget {
  final PhotoCaptureGuidelines guidelines;
  final Function(ProfilePhoto)? onCaptureComplete;
  final bool showZoomControls;
  final bool showGuidelines;
  final bool autoEnhance;

  const ProfilePhotoCaptureWidget({
    Key? key,
    this.guidelines = const PhotoCaptureGuidelines.ktpGuidelines(),
    this.onCaptureComplete,
    this.showZoomControls = true,
    this.showGuidelines = true,
    this.autoEnhance = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraController = useState<CameraController?>(null);
    final isInitialized = useState(false);
    final currentZoom = useState(1.0);
    final minZoom = useState(1.0);
    final maxZoom = useState(5.0);
    final isFlashOn = useState(false);
    final captureState = useState<PhotoCaptureState?>(
      PhotoCaptureState(
        currentStep: PhotoCaptureStep.positioning,
        complianceStatus: PhotoComplianceStatus.nonCompliant,
      ),
    );
    final isAnalyzing = useState(false);
    final isCapturing = useState(false);

    final faceAnalysisService = useMemoized(() => FaceAnalysisService());

    // Initialize camera
    useEffect(() {
      _initializeCamera(
        cameraController,
        isInitialized,
        minZoom,
        maxZoom,
        currentZoom,
      );
      return () {
        cameraController.value?.dispose();
      };
    }, []);

    // Real-time analysis
    useEffect(() {
      if (cameraController.value != null &&
          isInitialized.value &&
          !isCapturing.value) {
        _startRealTimeAnalysis(
          cameraController.value!,
          faceAnalysisService,
          guidelines,
          captureState,
          isAnalyzing,
        );
      }
      return null;
    }, [cameraController.value, isInitialized.value, isCapturing.value]);

    return Container(
      child: Column(
        children: [
          // Camera Preview with Overlay
          if (cameraController.value != null && isInitialized.value)
            Stack(
              children: [
                Container(
                  height: 450,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getBorderColor(captureState.value),
                      width: 3,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CameraPreview(cameraController.value!),
                  ),
                ),

                // Face Guide Overlay
                if (showGuidelines) _buildFaceGuideOverlay(captureState.value),

                // Status Indicators
                _buildStatusIndicators(captureState.value),

                // Zoom Controls
                if (showZoomControls)
                  _buildZoomControls(
                    currentZoom.value,
                    minZoom.value,
                    maxZoom.value,
                    (value) =>
                        _setZoom(cameraController.value, value, currentZoom),
                  ),

                // Flash Toggle
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: Icon(
                      isFlashOn.value ? Icons.flash_on : Icons.flash_off,
                      color: isFlashOn.value ? Colors.yellow : Colors.white,
                    ),
                    onPressed: () =>
                        _toggleFlash(cameraController.value, isFlashOn),
                  ),
                ),

                // Capture Button
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: _buildCaptureButton(
                    captureState.value,
                    isCapturing,
                    () => _capturePhoto(
                      context,
                      cameraController.value,
                      faceAnalysisService,
                      guidelines,
                      captureState,
                      isCapturing,
                      onCaptureComplete,
                    ),
                  ),
                ),
              ],
            )
          else
            Container(
              height: 450,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),

          const SizedBox(height: 16),

          // Guidelines and Instructions
          _buildInstructions(captureState.value),

          const SizedBox(height: 16),

          // Issue List
          if (captureState.value?.issues.isConnected ?? false)
            _buildIssueList(captureState.value!.issues),
        ],
      ),
    );
  }

  Widget _buildFaceGuideOverlay(PhotoCaptureState? state) {
    return CustomPaint(
      size: Size.infinite,
      painter: FaceGuidePainter(state: state, guidelines: guidelines),
    );
  }

  Widget _buildStatusIndicators(PhotoCaptureState? state) {
    if (state == null) return const SizedBox();

    return Positioned(
      top: 16,
      left: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Face Size Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.straighten,
                  size: 16,
                  color: _getFaceSizeColor(state.faceSizeRatio),
                ),
                const SizedBox(width: 4),
                Text(
                  'Ukuran Wajah: ${(state.faceSizeRatio * 100).toInt()}%',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Head Tilt Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.screen_lock_rotation,
                  size: 16,
                  color: state.headTiltAngle < guidelines.maxHeadTilt
                      ? Colors.green
                      : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  'Kemiringan: ${state.headTiltAngle.toStringAsFixed(1)}°',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Brightness Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.brightness_6,
                  size: 16,
                  color: _getBrightnessColor(state.brightness),
                ),
                const SizedBox(width: 4),
                Text(
                  'Cahaya: ${state.brightness.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoomControls(
    double currentZoom,
    double minZoom,
    double maxZoom,
    Function(double) onZoomChanged,
  ) {
    return Positioned(
      bottom: 80,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            const Icon(Icons.zoom_out, color: Colors.white),
            Expanded(
              child: Slider(
                value: currentZoom,
                min: minZoom,
                max: maxZoom,
                divisions: 20,
                onChanged: onZoomChanged,
                activeColor: Colors.blue,
                inactiveColor: Colors.grey,
              ),
            ),
            const Icon(Icons.zoom_in, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              '${currentZoom.toStringAsFixed(1)}x',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptureButton(
    PhotoCaptureState? state,
    ValueNotifier<bool> isCapturing,
    VoidCallback onCapture,
  ) {
    return Center(
      child: GestureDetector(
        onTap: state?.isCompliant == true ? onCapture : null,
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: state?.isCompliant == true
                ? Colors.blue
                : Colors.grey.withOpacity(0.5),
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: isCapturing.value
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildInstructions(PhotoCaptureState? state) {
    if (state == null) return const SizedBox();

    String instruction;
    Color color;

    if (state.isCompliant) {
      instruction = 'Posisi sudah sempurna, tekan tombol untuk mengambil foto';
      color = Colors.green;
    } else if (state.hasIssues) {
      instruction = 'Perbaiki masalah berikut sebelum mengambil foto';
      color = Colors.orange;
    } else {
      instruction = 'Posisikan wajah di dalam panduan';
      color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(
            state.isCompliant ? Icons.check_circle : Icons.info,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(instruction, style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }

  Widget _buildIssueList(List<PhotoQualityIssue> issues) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Masalah yang perlu diperbaiki:',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
          ),
          const SizedBox(height: 8),
          ...issues.map(
            (issue) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Text(_getIssueMessage(issue)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getIssueMessage(PhotoQualityIssue issue) {
    switch (issue) {
      case PhotoQualityIssue.tooDark:
        return 'Cahaya terlalu redup';
      case PhotoQualityIssue.tooBright:
        return 'Cahaya terlalu terang';
      case PhotoQualityIssue.blurry:
        return 'Foto buram, jaga kamera tetap stabil';
      case PhotoQualityIssue.glassesGlare:
        return 'Silau pada kacamata';
      case PhotoQualityIssue.faceNotCentered:
        return 'Posisikan wajah di tengah';
      case PhotoQualityIssue.faceTooSmall:
        return 'Wajah terlalu kecil, mendekatlah';
      case PhotoQualityIssue.faceTooLarge:
        return 'Wajah terlalu besar, menjauhlah';
      case PhotoQualityIssue.eyesClosed:
        return 'Buka mata Anda';
      case PhotoQualityIssue.mouthOpen:
        return 'Tutup mulut Anda';
      case PhotoQualityIssue.headTilted:
        return 'Luruskan kepala';
      case PhotoQualityIssue.backgroundClutter:
        return 'Gunakan latar belakang polos';
    }
  }

  Color _getBorderColor(PhotoCaptureState? state) {
    if (state == null) return Colors.grey;
    if (state.isCompliant) return Colors.green;
    if (state.hasIssues) return Colors.orange;
    return Colors.yellow;
  }

  Color _getFaceSizeColor(double ratio) {
    if (ratio >= guidelines.minFaceSize && ratio <= guidelines.maxFaceSize) {
      return Colors.green;
    }
    return Colors.orange;
  }

  Color _getBrightnessColor(double brightness) {
    if (brightness >= 80 && brightness <= 200) return Colors.green;
    return Colors.orange;
  }

  Future<void> _initializeCamera(
    ValueNotifier<CameraController?> controller,
    ValueNotifier<bool> initialized,
    ValueNotifier<double> minZoom,
    ValueNotifier<double> maxZoom,
    ValueNotifier<double> currentZoom,
  ) async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await cameraController.initialize();

      // Get zoom range
      if (cameraController.value.isInitialized) {
        minZoom.value = await cameraController.getMinZoomLevel();
        maxZoom.value = await cameraController.getMaxZoomLevel();
        currentZoom.value = minZoom.value;
      }

      controller.value = cameraController;
      initialized.value = true;
    } catch (e) {
      print('Camera initialization error: $e');
    }
  }

  Future<void> _setZoom(
    CameraController? controller,
    double zoom,
    ValueNotifier<double> currentZoom,
  ) async {
    if (controller == null || !controller.value.isInitialized) return;

    try {
      await controller.setZoomLevel(zoom);
      currentZoom.value = zoom;
    } catch (e) {
      print('Zoom error: $e');
    }
  }

  void _toggleFlash(
    CameraController? controller,
    ValueNotifier<bool> isFlashOn,
  ) {
    if (controller == null || !controller.value.isInitialized) return;

    final newState = !isFlashOn.value;
    controller.setFlashMode(newState ? FlashMode.torch : FlashMode.off);
    isFlashOn.value = newState;
  }

  void _startRealTimeAnalysis(
    CameraController controller,
    FaceAnalysisService service,
    PhotoCaptureGuidelines guidelines,
    ValueNotifier<PhotoCaptureState?> state,
    ValueNotifier<bool> isAnalyzing,
  ) {
    const analysisInterval = Duration(milliseconds: 500);

    Timer.periodic(analysisInterval, (timer) async {
      if (!controller.value.isInitialized || isAnalyzing.value) return;

      isAnalyzing.value = true;

      try {
        final image = await controller.takePicture();
        final analysis = await service.analyzeFace(
          File(image.path),
          guidelines: guidelines,
        );
        state.value = analysis;
      } catch (e) {
        print('Analysis error: $e');
      } finally {
        isAnalyzing.value = false;
      }
    });
  }

  Future<void> _capturePhoto(
    BuildContext context,
    CameraController? controller,
    FaceAnalysisService service,
    PhotoCaptureGuidelines guidelines,
    ValueNotifier<PhotoCaptureState?> state,
    ValueNotifier<bool> isCapturing,
    Function(ProfilePhoto)? onComplete,
  ) async {
    if (controller == null || !controller.value.isInitialized) return;

    isCapturing.value = true;

    try {
      // Capture image
      final image = await controller.takePicture();
      final imageFile = File(image.path);

      // Show processing dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Auto-enhance if enabled
      File finalImage = imageFile;
      if (autoEnhance) {
        finalImage = await _enhanceImage(imageFile);
      }

      // Crop to face
      final croppedImage = await service.cropToFace(finalImage);

      // Analyze final image
      final analysis = await service.analyzeFace(
        croppedImage,
        guidelines: guidelines,
      );

      Navigator.pop(context); // Close dialog

      if (analysis.isCompliant) {
        // Create profile photo
        final profilePhoto = ProfilePhoto.fromFile(
          croppedImage,
          faceRect: await service.findFaceRect(croppedImage),
          confidence: 1.0,
        );

        state.value = analysis.copyWith(
          currentStep: PhotoCaptureStep.complete,
          finalPhoto: profilePhoto,
        );

        onComplete?.call(profilePhoto);

        _showSuccessDialog(context, profilePhoto);
      } else {
        _showErrorDialog(context, analysis.issues);
      }
    } catch (e) {
      Navigator.pop(context);
      _showErrorDialog(context, []);
    } finally {
      isCapturing.value = false;
    }
  }

  Future<File> _enhanceImage(File image) async {
    // Compress and enhance image
    final result = await FlutterImageCompress.compressAndGetFile(
      image.path,
      image.path.replaceAll('.jpg', '_enhanced.jpg'),
      quality: 90,
      minWidth: 600,
      minHeight: 800,
    );

    if (result != null) {
      // Apply additional enhancements (brightness, contrast, etc.)
      final img.Image? original = img.decodeImage(await result.readAsBytes());
      if (original != null) {
        // Adjust brightness and contrast
        final enhanced = img.adjustColor(
          original,
          brightness: 10,
          contrast: 1.1,
        );

        await result.writeAsBytes(img.encodeJpg(enhanced));
      }
      return result;
    }

    return image;
  }

  void _showSuccessDialog(BuildContext context, ProfilePhoto photo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.check_circle, color: Colors.green, size: 64),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Foto Berhasil!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(photo.path),
                height: 150,
                width: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Foto profil sesuai dengan standar yang ditentukan',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, List<PhotoQualityIssue> issues) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.error, color: Colors.red, size: 64),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Foto Tidak Sesuai',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Masalah yang ditemukan:'),
            const SizedBox(height: 8),
            ...issues.map(
              (issue) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '• ${_getIssueMessage(issue)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}

class FaceGuidePainter extends CustomPainter {
  final PhotoCaptureState? state;
  final PhotoCaptureGuidelines guidelines;

  FaceGuidePainter({required this.state, required this.guidelines});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Draw face oval guide
    final faceWidth = size.width * 0.5;
    final faceHeight = size.height * 0.6;

    final faceRect = Rect.fromCenter(
      center: center,
      width: faceWidth,
      height: faceHeight,
    );

    // Draw semi-transparent overlay outside face area
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    _drawOverlay(canvas, size, faceRect, overlayPaint);

    // Draw face outline
    final borderPaint = Paint()
      ..color = _getGuideColor()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawOval(faceRect, borderPaint);

    // Draw optimal face size indicator
    final optimalWidth = size.width * guidelines.optimalFaceSize * 1.2;
    final optimalHeight = size.height * guidelines.optimalFaceSize * 1.6;

    final optimalRect = Rect.fromCenter(
      center: center,
      width: optimalWidth,
      height: optimalHeight,
    );

    final optimalPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawOval(optimalRect, optimalPaint);

    // Draw alignment guides
    _drawAlignmentGuides(canvas, size, center);

    // Draw face landmarks if available
    if (state?.faceSizeRatio != null) {
      _drawFaceSizeIndicator(canvas, size, state!.faceSizeRatio);
    }
  }

  void _drawOverlay(Canvas canvas, Size size, Rect faceRect, Paint paint) {
    // Draw overlay excluding face area
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, faceRect.top), paint);
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        faceRect.bottom,
        size.width,
        size.height - faceRect.bottom,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, faceRect.top, faceRect.left, faceRect.height),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        faceRect.right,
        faceRect.top,
        size.width - faceRect.right,
        faceRect.height,
      ),
      paint,
    );
  }

  void _drawAlignmentGuides(Canvas canvas, Size size, Offset center) {
    final guidePaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 1;

    // Horizontal line
    canvas.drawLine(
      Offset(0, center.dy),
      Offset(size.width, center.dy),
      guidePaint,
    );

    // Vertical line
    canvas.drawLine(
      Offset(center.dx, 0),
      Offset(center.dx, size.height),
      guidePaint,
    );

    // Eye level guides
    final eyeLevel = center.dy - size.height * 0.1;
    canvas.drawLine(
      Offset(center.dx - 50, eyeLevel),
      Offset(center.dx + 50, eyeLevel),
      guidePaint..color = Colors.white.withOpacity(0.3),
    );

    // Chin guide
    final chinLevel = center.dy + size.height * 0.2;
    canvas.drawLine(
      Offset(center.dx - 30, chinLevel),
      Offset(center.dx + 30, chinLevel),
      guidePaint,
    );
  }

  void _drawFaceSizeIndicator(Canvas canvas, Size size, double ratio) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = 40.0;

    // Draw background
    final bgPaint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(60, size.height - 60), radius, bgPaint);

    // Draw size arc
    final arcPaint = Paint()
      ..color = _getFaceSizeColor(ratio)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final progress =
        (ratio - guidelines.minFaceSize) /
        (guidelines.maxFaceSize - guidelines.minFaceSize);

    canvas.drawArc(
      Rect.fromCircle(center: Offset(60, size.height - 60), radius: radius - 5),
      -pi / 2,
      2 * pi * progress.clamp(0.0, 1.0),
      false,
      arcPaint,
    );

    // Draw text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${(ratio * 100).toInt()}%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        60 - textPainter.width / 2,
        size.height - 60 - textPainter.height / 2,
      ),
    );
  }

  Color _getGuideColor() {
    if (state == null) return Colors.white;
    if (state!.isCompliant) return Colors.green;
    if (state!.hasIssues) return Colors.orange;
    return Colors.yellow;
  }

  Color _getFaceSizeColor(double ratio) {
    if (ratio >= guidelines.minFaceSize && ratio <= guidelines.maxFaceSize) {
      return Colors.green;
    }
    return Colors.orange;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
