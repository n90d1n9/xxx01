import 'dart:io' if (dart.library.html) 'package:extended_image_library/src/_platform_web.dart';
//import 'package:extended_image_library/src/_platform_web.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import '../utils/helper.dart';

class BingkaiEditPage extends StatefulWidget {
  const BingkaiEditPage(
      {super.key, required this.frameImage, this.bytes, this.path});
  final Image frameImage;
  final File? bytes;
  final String? path;
  @override
  State<BingkaiEditPage> createState() => _BingkaiEditPageState();
}



class _BingkaiEditPageState extends State<BingkaiEditPage> {
  final GlobalKey<ExtendedImageEditorState> editorKey =
      GlobalKey<ExtendedImageEditorState>();
  final GlobalKey<PopupMenuButtonState<EditorCropLayerPainter>> popupMenuKey =
      GlobalKey<PopupMenuButtonState<EditorCropLayerPainter>>();

  File? contentImage;

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ExtendedImageGestureState> gestureKey =
        GlobalKey<ExtendedImageGestureState>();
    //.decodeImage(bytes)

    return Scaffold(
      appBar: AppBar(),
      body: 
      Stack(children: [
        contentImage != null
            ? ExtendedImage.file(
                contentImage!,
                fit: BoxFit.contain,
                mode: ExtendedImageMode.gesture,
                extendedImageGestureKey: gestureKey,
                initGestureConfigHandler: (ExtendedImageState state) {
                  return GestureConfig(
                    minScale: 0.9,
                    animationMinScale: 0.7,
                    maxScale: 4.0,
                    animationMaxScale: 4.5,
                    speed: 1.0,
                    inertialSpeed: 100.0,
                    initialScale: 1.0,
                    inPageView: false,
                    initialAlignment: InitialAlignment.center,
                    reverseMousePointerScrollDirection: true,
                    gestureDetailsIsChanged: (GestureDetails? details) {
                      //print(details?.totalScale);
                    },
                  );
                },
              )
            : const SizedBox(),
        // ),
        GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => print("green"),
                child: IgnorePointer(
                  child: widget.frameImage))
      ]),

/* 
          FutureBuilder(
              future: widget.bytes.readAsBytes(),
              initialData: const SizedBox(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                 // print(snapshot.data);
                 print(img.encodePng(snapshot.data));
                  return ExtendedImage.memory(
                    snapshot.data,
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
                  );
                }
                return const SizedBox();
              }),
          contentImage ?? const SizedBox(),
          widget.frameImage
        ],
      ), */
      /*  ExtendedImage.memory(
                    File(widget.path).readAsBytes(),
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
                  ), */
      floatingActionButton: IconButton(
        iconSize: 35,
        icon: const Icon(Icons.add_a_photo),
        onPressed: getContentImage,
      ),
      bottomNavigationBar: const BottomAppBar(
        child: Row(
          children: [],
        ),
      ),
    );
  }

  getContentImage() async {
    File f = File((await pickImage())!.path);
    setState(() {
      contentImage = f; //Image.file(f);
    });
  }

  // Widget frame()=> Image.file(widget.path);
}
