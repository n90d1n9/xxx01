import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageService {
  final _picker = ImagePicker();

  Future<String?> captureImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null) return null;

    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedImage = File('${directory.path}/$fileName');
    await savedImage.writeAsBytes(await image.readAsBytes());

    return savedImage.path;
  }
}
