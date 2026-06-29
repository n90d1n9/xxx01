/* import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:extended_image/extended_image.dart';
//import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oktoast/oktoast.dart';
import 'package:go_router/go_router.dart';

import '../utils/crop_circle.dart';
import '../utils/helper.dart';
import '../widgets/common_widget.dart';

class ImageEditor extends StatefulWidget {
  const ImageEditor({super.key});

  @override
  ImageEditorState createState() => ImageEditorState();
}

class ImageEditorState extends State<ImageEditor> {
  final GlobalKey<ExtendedImageEditorState> editorKey =
      GlobalKey<ExtendedImageEditorState>();
  final GlobalKey<PopupMenuButtonState<EditorCropLayerPainter>> popupMenuKey =
      GlobalKey<PopupMenuButtonState<EditorCropLayerPainter>>();
  final List<AspectRatioItem> _aspectRatios = <AspectRatioItem>[
    AspectRatioItem(text: 'custom', value: CropAspectRatios.custom),
    AspectRatioItem(text: 'original', value: CropAspectRatios.original),
    AspectRatioItem(text: '1*1', value: CropAspectRatios.ratio1_1),
    AspectRatioItem(text: '4*3', value: CropAspectRatios.ratio4_3),
    AspectRatioItem(text: '3*4', value: CropAspectRatios.ratio3_4),
    AspectRatioItem(text: '16*9', value: CropAspectRatios.ratio16_9),
    AspectRatioItem(text: '9*16', value: CropAspectRatios.ratio9_16)
  ];
  AspectRatioItem? _aspectRatio;
  final GlobalKey _globalKey = GlobalKey();

  EditorCropLayerPainter? _cropLayerPainter;

  @override
  void initState() {
    _aspectRatio = _aspectRatios.first;
    _cropLayerPainter = const EditorCropLayerPainter();
    super.initState();
  }

  gotoMain() => () => context.go('/');

  @override
  Widget build(BuildContext context) {
    return OKToast(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('image editor demo'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: gotoMain,
          ),
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: _getImage,
          ),
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () {
              if (kIsWeb) {
                cropImage(false, editorKey);
              } else {
                cropImage(false, editorKey);
              }
            },
          ),
        ],
      ),
      body: Column(children: <Widget>[
        Expanded(
            child: RepaintBoundary(
          key: _globalKey,
          child: _memoryImage != null
              ? Stack(children: [
                  ExtendedImage.memory(
                    _memoryImage!,
                    fit: BoxFit.contain,
                    mode: ExtendedImageMode.editor,
                    enableLoadState: true,
                    extendedImageEditorKey: editorKey,
                    initEditorConfigHandler: (ExtendedImageState? state) {
                      return EditorConfig(
                        maxScale: 8.0,
                        cropRectPadding: const EdgeInsets.all(20.0),
                        hitTestSize: 20.0,
                        cropLayerPainter: _cropLayerPainter!,
                        initCropRectType: InitCropRectType.imageRect,
                        cropAspectRatio: _aspectRatio!.value,
                      );
                    },
                    cacheRawData: true,
                  ),
                  //Image.asset('assets/images/gugle.png')
                ])
              : const Center( child:  Text('Tidak ada Gambar'))
        )),
      ]),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: ButtonTheme(
          minWidth: 0.0,
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              FlatButtonWithIcon(
                icon: const Icon(Icons.crop),
                label: const Text(
                  'Crop',
                  style: TextStyle(fontSize: 10.0),
                ),
                textColor: Colors.white,
                onPressed: () {
                  showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return Column(
                          children: <Widget>[
                            const Expanded(
                              child: SizedBox(),
                            ),
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.all(20.0),
                                itemBuilder: (_, int index) {
                                  final AspectRatioItem item =
                                      _aspectRatios[index];
                                  return GestureDetector(
                                    child: AspectRatioWidget(
                                      aspectRatio: item.value,
                                      aspectRatioS: item.text,
                                      isSelected: item == _aspectRatio,
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      setState(() {
                                        _aspectRatio = item;
                                      });
                                    },
                                  );
                                },
                                itemCount: _aspectRatios.length,
                              ),
                            ),
                          ],
                        );
                      });
                },
              ),
              FlatButtonWithIcon(
                icon: const Icon(Icons.flip),
                label: const Text(
                  'Flip',
                  style: TextStyle(fontSize: 10.0),
                ),
                textColor: Colors.white,
                onPressed: () {
                  editorKey.currentState!.flip();
                },
              ),
              FlatButtonWithIcon(
                icon: const Icon(Icons.rotate_left),
                label: const Text(
                  'Rotate Left',
                  style: TextStyle(fontSize: 8.0),
                ),
                textColor: Colors.white,
                onPressed: () {
                  editorKey.currentState!.rotate(right: false);
                },
              ),
              FlatButtonWithIcon(
                icon: const Icon(Icons.rotate_right),
                label: const Text(
                  'Rotate Right',
                  style: TextStyle(fontSize: 8.0),
                ),
                textColor: Colors.white,
                onPressed: () {
                  editorKey.currentState!.rotate(right: true);
                },
              ),
              FlatButtonWithIcon(
                icon: const Icon(Icons.rounded_corner_sharp),
                label: PopupMenuButton<EditorCropLayerPainter>(
                  key: popupMenuKey,
                  enabled: false,
                  offset: const Offset(100, -300),
                  initialValue: _cropLayerPainter,
                  itemBuilder: (BuildContext context) {
                    return <PopupMenuEntry<EditorCropLayerPainter>>[
                      const PopupMenuItem<EditorCropLayerPainter>(
                        value: EditorCropLayerPainter(),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.rounded_corner_sharp,
                              color: Colors.blue,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text('Default'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem<EditorCropLayerPainter>(
                        value: CustomEditorCropLayerPainter(),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.circle,
                              color: Colors.blue,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text('Custom'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem<EditorCropLayerPainter>(
                        value: CircleEditorCropLayerPainter(),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              CupertinoIcons.circle,
                              color: Colors.blue,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text('Circle'),
                          ],
                        ),
                      ),
                    ];
                  },
                  onSelected: (EditorCropLayerPainter value) {
                    if (_cropLayerPainter != value) {
                      setState(() {
                        if (value is CircleEditorCropLayerPainter) {
                          _aspectRatio = _aspectRatios[2];
                        }
                        _cropLayerPainter = value;
                      });
                    }
                  },
                  child: const Text(
                    'Painter',
                    style: TextStyle(fontSize: 8.0),
                  ),
                ),
                textColor: Colors.white,
                onPressed: () {
                  popupMenuKey.currentState!.showButtonMenu();
                },
              ),
              FlatButtonWithIcon(
                icon: const Icon(Icons.restore),
                label: const Text(
                  'Reset',
                  style: TextStyle(fontSize: 10.0),
                ),
                textColor: Colors.white,
                onPressed: () {
                  editorKey.currentState!.reset();
                },
              ),
              ElevatedButton(
                onPressed: _capturePng,
                child: const Text('Capture as PNG'),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Future<void> _capturePng() async {
    try {
      // Ensure the widget is rendered
      await Future.delayed(const Duration(milliseconds: 20));

      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Get the directory to save the image
      //final directory = (await getApplicationDocumentsDirectory()).path;
     /*  final directory = await FilePicker.platform.getDirectoryPath();
      File imgFile = File('$directory/screenshot.png');
      imgFile.writeAsBytesSync(pngBytes);

      print("Image saved to $directory/screenshot.png"); */
    } catch (e) {
      print(e);
    }
  }

  Uint8List? _memoryImage;
  Future<void> _getImage() async {
     XFile? localimage = await pickImage();
    _memoryImage = await localimage!.readAsBytes();
    //when back to current page, may be editorKey.currentState is not ready.
    Future<void>.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        editorKey.currentState!.reset();
      });
    });
  }

  
}
 */