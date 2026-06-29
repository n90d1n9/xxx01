
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import '../utils/merge_image.dart';

class MergeImage extends StatelessWidget {
  const MergeImage({super.key});

  @override
  Widget build(BuildContext context) {
    return /* MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Merge Images')),
        body:  */Center(
          child: FutureBuilder<img.Image>(
            future: mergeImages('assets/images/default.png', 'assets/images/gugle.png'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                img.Image mergedImage = snapshot.data!;
                return Image.memory(Uint8List.fromList(img.encodePng(mergedImage)));
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
      /*   ),
      ), */
    );
  }
}