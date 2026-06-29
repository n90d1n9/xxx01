
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;

Future<img.Image> mergeImages(String imagePath1, String imagePath2) async {
  // Load the first image
  ByteData data1 = await rootBundle.load(imagePath1);
  List<int> bytes1 = data1.buffer.asUint8List(data1.offsetInBytes, data1.lengthInBytes);
  img.Image image1 = img.decodeImage(Uint8List.fromList(bytes1))!;

  // Load the second image
  ByteData data2 = await rootBundle.load(imagePath2);
  List<int> bytes2 = data2.buffer.asUint8List(data2.offsetInBytes, data2.lengthInBytes);
  img.Image image2 = img.decodeImage(Uint8List.fromList(bytes2))!;

  // Ensure both images are the same size
  img.Image resizedImage2 = img.copyResize(image2, width: image1.width, height: image1.height);

  // Merge the images
  img.Image mergedImage = img.Image(width:image1.width, height:image1.height);
  for (int y = 0; y < mergedImage.height; y++) {
    for (int x = 0; x < mergedImage.width; x++) {
      img.Pixel p1 = image1.getPixel( x, y);
      img.Pixel p2 = image1.getPixel( x, y);

      // Blend pixels together
      int blendedR = (p1.r + p2.r) ~/ 2;
      int blendedG = (p1.g + p2.g) ~/ 2;
      int blendedB = (p1.b + p2.b) ~/ 2;
      int blendedA = (p1.a + p2.a) ~/ 2;

      image1.setPixel( x, y, resizedImage2.getColor(blendedR, blendedG, blendedB, blendedA));
    }
  }

  return mergedImage;
}

Future<void> saveMergedImage(String outputPath, img.Image image) async {
  // Encode the image to PNG
  List<int> png = img.encodePng(image);
  File(outputPath).writeAsBytesSync(png);
}


