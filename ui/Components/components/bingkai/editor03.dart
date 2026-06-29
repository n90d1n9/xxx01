import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_editor/image_editor.dart';
import 'package:image_picker/image_picker.dart' as ip;
//import 'package:flutter_image_editor/flutter_image_editor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_cropper/image_cropper.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;
  final ip.ImagePicker _picker = ip.ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ip.ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _cropImage() async {
    if (_image == null) return;

    final croppedImage = await ImageEditor.editImage(
      image: _image!.readAsBytesSync(),
      imageEditorOption: ImageEditorOption()
        ..addOption(CropOption(x: 0, y: 0, width: 200, height: 200)),
    );

    final tempDir = await getTemporaryDirectory();
    final croppedFile = await File('${tempDir.path}/cropped_image.jpg')
        .writeAsBytes(croppedImage);

    setState(() {
      _image = croppedFile;
    });
  }

  Future<void> _rotateImage() async {
    if (_image == null) return;

    final rotatedImage = await ImageEditor.editImage(
      image: _image!.readAsBytesSync(),
      imageEditorOption: ImageEditorOption()..addOption(RotateOption(90)),
    );

    final tempDir = await getTemporaryDirectory();
    final rotatedFile = await File('${tempDir.path}/rotated_image.jpg')
        .writeAsBytes(rotatedImage);

    setState(() {
      _image = rotatedFile;
    });
  }

  Future<void> _flipImage() async {
    if (_image == null) return;

    final flippedImage = await ImageEditor.editImage(
      image: _image!.readAsBytesSync(),
      imageEditorOption: ImageEditorOption()
        ..addOption(FlipOption(horizontal: true)),
    );

    final tempDir = await getTemporaryDirectory();
    final flippedFile = await File('${tempDir.path}/flipped_image.jpg')
        .writeAsBytes(flippedImage);

    setState(() {
      _image = flippedFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Image Editor'),
      ),
      body: Center(
        child:
            _image == null ? Text('No image selected.') : Image.file(_image!),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _pickImage,
            tooltip: 'Pick Image',
            child: Icon(Icons.add_a_photo),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _cropImage,
            tooltip: 'Crop Image',
            child: Icon(Icons.crop),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _rotateImage,
            tooltip: 'Rotate Image',
            child: Icon(Icons.rotate_right),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _flipImage,
            tooltip: 'Flip Image',
            child: Icon(Icons.flip),
          ),
        ],
      ),
    );
  }
}
