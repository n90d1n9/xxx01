import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../model/profile_photo.dart';
import '../widget/face_overlay_painter.dart';

class PhotoReviewScreen extends StatefulWidget {
  final ProfilePhoto photo;
  final Function(ProfilePhoto)? onConfirm;
  final Function()? onRetake;

  const PhotoReviewScreen({
    Key? key,
    required this.photo,
    this.onConfirm,
    this.onRetake,
  }) : super(key: key);

  @override
  _PhotoReviewScreenState createState() => _PhotoReviewScreenState();
}

class _PhotoReviewScreenState extends State<PhotoReviewScreen> {
  double _brightness = 0.0;
  double _contrast = 1.0;
  double _saturation = 1.0;
  bool _showAdjustments = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Foto'),
        actions: [
          IconButton(
            icon: Icon(_showAdjustments ? Icons.tune : Icons.tune_outlined),
            onPressed: () {
              setState(() {
                _showAdjustments = !_showAdjustments;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Photo Preview
          Expanded(
            child: Stack(
              children: [
                PhotoView(
                  imageProvider: FileImage(File(widget.photo.path)),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                  initialScale: PhotoViewComputedScale.contained,
                  backgroundDecoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                ),

                // Face Detection Overlay
                if (widget.photo.faceRect != null)
                  CustomPaint(
                    size: Size.infinite,
                    painter: FaceOverlayPainter(widget.photo.faceRect!),
                  ),

                // Adjustment Panel
                if (_showAdjustments)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildAdjustmentPanel(),
                  ),
              ],
            ),
          ),

          // Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.onRetake,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Ambil Ulang'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => widget.onConfirm?.call(widget.photo),
                    icon: const Icon(Icons.check),
                    label: const Text('Gunakan Foto'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustmentPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Penyesuaian Foto',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Brightness
          Row(
            children: [
              const Icon(Icons.brightness_6, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Kecerahan'),
                    Slider(
                      value: _brightness,
                      min: -0.5,
                      max: 0.5,
                      divisions: 20,
                      onChanged: (value) {
                        setState(() {
                          _brightness = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Contrast
          Row(
            children: [
              const Icon(Icons.contrast, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Kontras'),
                    Slider(
                      value: _contrast,
                      min: 0.5,
                      max: 2.0,
                      divisions: 30,
                      onChanged: (value) {
                        setState(() {
                          _contrast = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Saturation
          Row(
            children: [
              const Icon(Icons.color_lens, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Saturasi'),
                    Slider(
                      value: _saturation,
                      min: 0.0,
                      max: 2.0,
                      divisions: 40,
                      onChanged: (value) {
                        setState(() {
                          _saturation = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Reset Button
          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  _brightness = 0.0;
                  _contrast = 1.0;
                  _saturation = 1.0;
                });
              },
              child: const Text('Reset'),
            ),
          ),
        ],
      ),
    );
  }
}
