import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget {
  //CameraScreen(this.cameras);

  @override
  CameraScreenState createState() {
    return new CameraScreenState();
  }
}

class CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  List<CameraDescription>? cameras;
  @override
  void initState() {
    super.initState();
    camera();
    controller = new CameraController(cameras![0], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return new Container();
    }
    return new AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: new CameraPreview(controller),
    );
  }

  camera() async {
    print('${Platform.isAndroid}----- ${Platform.isIOS}');
    if (Platform.isAndroid || Platform.isIOS) {
      print('ini ios');
      cameras = await availableCameras();
    }
  }
}
