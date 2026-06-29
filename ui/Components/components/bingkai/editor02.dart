import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;


class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey _globalKey = GlobalKey();

  Future<void> _captureAndSavePng() async {
    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      File file = await File('${tempDir.path}/image.png').create();
      await file.writeAsBytes(pngBytes);

      print('Image saved to ${file.path}');
    } catch (e) {
      print(e);
    }
  }

  Future<void> _captureAndSaveJpeg() async {
    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.rawRgba);
      Uint8List rawBytes = byteData!.buffer.asUint8List();
      
      final imageWidth = image.width;
      final imageHeight = image.height;
      //img.Image originalImage = img.Image.fromBytes(imageWidth, imageHeight, rawBytes,);
img.Image originalImage = img.Image.fromBytes( width: 100, height: 200, bytes: byteData.buffer);

      final jpegBytes = img.encodeJpg(originalImage);

      final tempDir = await getTemporaryDirectory();
      File file = await File('${tempDir.path}/image.jpg').create();
      await file.writeAsBytes(jpegBytes);

      print('Image saved to ${file.path}');
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Widget to Image'),
      ),
      body: Center(
        child: RepaintBoundary(
          key: _globalKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Hello, World!'),
              Image.network('https://via.placeholder.com/150'),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _captureAndSavePng,
            tooltip: 'Save as PNG',
            child: Icon(Icons.save_alt),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _captureAndSaveJpeg,
            tooltip: 'Save as JPEG',
            child: Icon(Icons.save_alt),
          ),
        ],
      ),
    );
  }
}