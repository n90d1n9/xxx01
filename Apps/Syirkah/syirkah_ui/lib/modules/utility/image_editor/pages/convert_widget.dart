/* import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;


class ConvertWidget extends StatefulWidget {
  const ConvertWidget({super.key});

  @override
  ConvertWidgetState createState() => ConvertWidgetState();
}

class ConvertWidgetState extends State<ConvertWidget> {
  final GlobalKey _globalKey = GlobalKey();

  Future<void> _capturePng() async {
    try {
      // Ensure the widget is rendered
      await Future.delayed(const Duration(milliseconds: 20));

      RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Get the directory to save the image
      //final directory = (await getApplicationDocumentsDirectory()).path;
      final directory = await FilePicker.platform.getDirectoryPath();
      File imgFile = File('$directory/screenshot.png');
      imgFile.writeAsBytesSync(pngBytes);

      print("Image saved to $directory/screenshot.png");
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return /* Scaffold(
      appBar: AppBar(
        title: const Text('Capture Widget to PNG'),
      ),
      body: */ Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RepaintBoundary(
              key: _globalKey,
              child: Container(
                width: 200,
                height: 200,
                color: Colors.blue,
                child: const Center(
                  child: Text(
                    'Hello, Flutter!',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _capturePng,
              child: const Text('Capture as PNG'),
            ),
          ],
        ),
     // ),
    );
  }
} */