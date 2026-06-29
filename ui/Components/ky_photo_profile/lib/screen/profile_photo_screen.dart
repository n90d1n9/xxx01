import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../model/photo_capture_guidelines.dart';
import '../model/profile_photo.dart';
import '../widget/photo_capture_widget.dart';
import 'photo_review_screen.dart';

class ProfilePhotoScreen extends ConsumerStatefulWidget {
  final PhotoCaptureGuidelines guidelines;
  final Function(ProfilePhoto)? onPhotoVerified;

  const ProfilePhotoScreen({
    super.key,
    this.guidelines = const PhotoCaptureGuidelines.ktpGuidelines(),
    this.onPhotoVerified,
  });

  @override
  _ProfilePhotoScreenState createState() => _ProfilePhotoScreenState();
}

class _ProfilePhotoScreenState extends ConsumerState<ProfilePhotoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foto Profil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.camera_alt, size: 48, color: Colors.blue),
                  const SizedBox(height: 8),
                  const Text(
                    'Ambil Foto Profil',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pastikan foto sesuai dengan panduan untuk verifikasi',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Photo Capture Widget
            Expanded(
              child: ProfilePhotoCaptureWidget(
                guidelines: widget.guidelines,
                showZoomControls: true,
                showGuidelines: true,
                autoEnhance: true,
                onCaptureComplete: (photo) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PhotoReviewScreen(
                        photo: photo,
                        onConfirm: (confirmedPhoto) {
                          widget.onPhotoVerified?.call(confirmedPhoto);
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        onRetake: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            // Footer with guidelines summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Pastikan wajah terlihat jelas, tidak buram, dan pencahayaan cukup',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
