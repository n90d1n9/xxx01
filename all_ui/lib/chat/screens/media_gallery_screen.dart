import 'package:flutter/material.dart';

class MediaGalleryScreen extends StatelessWidget {
  final String roomId;

  const MediaGalleryScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Media Gallery')),
      body: Center(child: Text('Media Gallery Screen')),
    );
  }
}
