import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:signature/signature.dart';
import 'dart:ui' as ui;

class ImageEditorPage extends StatefulWidget {
  const ImageEditorPage({super.key});

  @override
  ImageEditorPageState createState() => ImageEditorPageState();
}

class ImageEditorPageState extends State<ImageEditorPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  List<Widget> imageLayer = [];
  ui.Image? _overlayImage;
  Color _color = Colors.black;
  final SignatureController _controller =
      SignatureController(penStrokeWidth: 5, penColor: Colors.black);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Image Editor'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[barButton(), Stack(children: imageLayer)],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getImage,
        tooltip: 'Pick Image',
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  newImage() {
    const Text('No image selected.');
    _image ?? Image.file(io.File(_image!.path));
  }

  barButton() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.crop),
            onPressed: _cropImage,
          ),
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: () => _pickColor(context),
          ),
          IconButton(
            icon: const Icon(Icons.brush),
            onPressed: _drawOnImage,
          ),
          IconButton(
            icon: const Icon(Icons.text_fields),
            onPressed: _addTextToImage,
          ),
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: _overlayOtherImage,
          ),
        ],
      );

  Future<void> _getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = pickedFile;
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _cropImage() async {
    if (_image != null) {
      var croppedFile = await ImageCropper().cropImage(
        sourcePath: _image!.path,
      );

      if (croppedFile != null) {
        setState(() {
          _image = XFile(croppedFile.path);
        });
      }
    }
  }

  Future<void> _pickColor(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color!'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _color,
              onColorChanged: (Color color) {
                setState(() {
                  _color = color;
                });
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Got it'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _drawOnImage() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Draw on Image'),
          content: Signature(
            controller: _controller,
            height: 300,
            backgroundColor: Colors.white,
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addTextToImage() async {}

  Future<void> _overlayOtherImage() async {}
}
