import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';


class ImageSaver {
  const ImageSaver._();

  static Future<String?> save(String name, Uint8List fileData) async {
   // final String title = '${DateTime.now().millisecondsSinceEpoch}_$name';

    String? filePath = await FilePicker.platform.getDirectoryPath();

 
    final String path = filePath!;

    var file = await File('$path/$name').writeAsBytes(
        fileData.buffer.asInt8List()); 
    return file.path;
  }
}
