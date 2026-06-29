import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:signature/signature.dart';
import 'dart:ui' as ui;

class ImageEditorPage extends StatefulWidget {
  @override
  _ImageEditorPageState createState() => _ImageEditorPageState();
}

class _ImageEditorPageState extends State<ImageEditorPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
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
      body: SingleChildScrollView(
          child: Center(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            Row(
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
            ),
            _image == null
                    ? const Text('No image selected.')
                    : Image.file(File(_image!.path)),
          ],
        ),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: _getImage,
        tooltip: 'Pick Image',
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  getImage() {
    print('--get image biasa--');
    /* final pickedFile =  _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = pickedFile;
      } else {
        print('No image selected.');
      }
    }); */
  }

  Future<void> _getImage() async {
    print('--get image--');
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
      print(' croped');
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: _image!.path,
      );
      print(croppedFile);
print(' croped lewat');
      if (croppedFile != null) {
        print(' croped tidak null');
        setState(() {
          _image = XFile(croppedFile.path);
        });
      }
    }
  }
  /* 
  _cropImage() async {
    // CroppedFile? croppedFile ;
    if (_image != null) {
      /* CroppedFile?  croppedFile = */ await ImageCropper().cropImage(
        sourcePath: _image!.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Cropper',
          ),
          WebUiSettings(
            context: context,
          ),
        ],
      );
    }
    // return croppedFile;
  } */

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
                // TODO: Save the drawn image
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addTextToImage() async {
    // TODO: Implement adding text to image
  }

  Future<void> _overlayOtherImage() async {
    // TODO: Implement overlaying another image
  }
}
