
import 'package:image_picker/image_picker.dart';

import 'package:oktoast/oktoast.dart';

import 'crop_editor_helper.dart';

bool _cropping = false;
Future<void> cropImage(bool useNative, editorKey) async {
  if (_cropping) {
    return;
  }
  String msg = '';
  try {
    _cropping = true;

    //await showBusyingDialog();
    late EditImageInfo imageInfo;

    /// native library
    if (useNative) {
      imageInfo =
          await cropImageDataWithNativeLibrary(state: editorKey.currentState!);
    } else {
      ///delay due to cropImageDataWithDartLibrary is time consuming on main thread
      ///it will block showBusyingDialog
      ///if you don't want to block ui, use compute/isolate,but it costs more time.
      //await Future.delayed(Duration(milliseconds: 200));

      ///if you don't want to block ui, use compute/isolate,but it costs more time.
      imageInfo =
          await cropImageDataWithDartLibrary(state: editorKey.currentState!);
    }

    /* final String? filePath = await ImageSaver.save(
        'extended_image_cropped_image.${imageInfo.imageType == ImageType.jpg ? 'jpg' : 'gif'}',
        imageInfo.data!);
    // var filePath = await ImagePickerSaver.saveFile(fileData: fileData);

    msg = 'save image : $filePath'; */
  } catch (e, stack) {
    msg = 'save failed: $e\n $stack';
    // print(msg);
  }

  //Navigator.of(context).pop();
  showToast(msg);
  _cropping = false;
}

Future<XFile?> pickImage() async {
  return await ImagePicker().pickImage(source: ImageSource.gallery);
}

Future<List<XFile>> pickImages() async {
  return await ImagePicker().pickMultiImage();
}
/* Future<XFile?> pickImage() async {
    final pickedFile =
        ;
    _memoryImage = 

    return await ImagePicker().pickImage(source: ImageSource.gallery);
  } */
/* 
class ImageSaver {
  const ImageSaver._();

  static Future<String?> save(String name, Uint8List fileData) async {
    // final String title = '${DateTime.now().millisecondsSinceEpoch}_$name';
    String? filePath = await FilePicker.platform.getDirectoryPath();
    final String path = filePath!;

    var file =
        await File('$path/$name').writeAsBytes(fileData.buffer.asInt8List());
    return file.path;
  }
} */
