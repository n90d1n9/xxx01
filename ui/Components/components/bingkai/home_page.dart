import 'dart:async';
import 'dart:convert';
// ignore: unnecessary_import
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart' as go;
import 'package:image_editor/image_editor.dart'
    show
        ClipOption,
        FlipOption,
        ImageEditor,
        ImageEditorOption,
        Option,
        OutputFormat,
        RotateOption;
import 'package:image_size_getter/image_size_getter.dart';
import 'package:syirkah/utils/routes.dart';

import 'resource.dart';
import 'widgets/clip_widget.dart';
import 'widgets/flip_widget.dart';
import 'widgets/rotate_widget.dart';
import 'widgets/scale_widget.dart';

/* import 'const/resource.dart';
import 'widget/clip_widget.dart';
import 'widget/flip_widget.dart';
import 'widget/rotate_widget.dart';
 */
/* class IndexPage extends StatefulWidget {
  @override
  IndexPageState createState() => IndexPageState();
} */

/* class IndexPageState extends State<IndexPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Index'),
      ),
      body: Examples(),
    );
  }
} */

class SimpleExamplePage extends StatefulWidget {
  const SimpleExamplePage({super.key});

  @override
  SimpleExamplePageState createState() => SimpleExamplePageState();
}

class SimpleExamplePageState extends State<SimpleExamplePage> {
  ImageProvider? provider = const AssetImage(R.ASSETS_ICON_PNG);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple usage'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings_backup_restore),
            onPressed: restore,
            tooltip: 'Restore image to default.',
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
            tooltip: 'Restore image to default.',
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          if (provider != null)
            AspectRatio(
              aspectRatio: 1,
              child: Image(
                image: provider!,
              ),
            ),
          Expanded(
            child: DraggableScrollableSheet(
                maxChildSize: .8,
                initialChildSize: .53,
                minChildSize: .53,
                builder: (context, scrollController) {
                  return Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                        color: Colors.white),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        children: <Widget>[
                          FlipWidget(
                            onTap: _flip,
                          ),
                          ClipWidget(
                            onTap: _clip,
                          ),
                          RotateWidget(
                            onTap: _rotate,
                          ),
                          ScaleWidget(
                            onTap: _scale,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }

  void setProvider(ImageProvider? provider) {
    setState(() {
    this.provider = provider;
    });
  }

  void restore() {
    setProvider(const AssetImage(R.ASSETS_ICON_PNG));
  }

  Future<Uint8List> getAssetImage() async {
    final ByteData byteData = await rootBundle.load(R.ASSETS_ICON_PNG);
    return byteData.buffer.asUint8List();
  }

  Future<void> _flip(FlipOption flipOption) async {
    handleOption(<Option>[flipOption]);
  }

  Future<void> _clip(ClipOption clipOpt) async {
    handleOption(<Option>[clipOpt]);
  }

  Future<void> _rotate(RotateOption rotateOpt) async {
    handleOption(<Option>[rotateOpt]);
  }

  void _scale(Option value) {
    handleOption(<Option>[value]);
  }

  Future<void> handleOption(List<Option> options) async {
    try{
    final ImageEditorOption option = ImageEditorOption();
    for (int i = 0; i < options.length; i++) {
      final Option o = options[i];
      option.addOption(o);
    }

    option.outputFormat = const OutputFormat.png();

    final Uint8List assetImage = await getAssetImage();

    final srcSize = ImageSizeGetter.getSize(MemoryInput(assetImage));

    print(const JsonEncoder.withIndent('  ').convert(option.toJson()));
    final Uint8List? result = await ImageEditor.editImage(
      image: assetImage,
      imageEditorOption: option,
    );

    if (result == null) {
      setProvider(null);
      return;
    }

    final resultSize = ImageSizeGetter.getSize(MemoryInput(result));

    print('srcSize: $srcSize, resultSize: $resultSize');

    final MemoryImage img = MemoryImage(result);
    
    setProvider(img);
  }catch(e){
    print(e);
  }
  }
}
