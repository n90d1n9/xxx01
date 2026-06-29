import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:syirkah/modules/image_editor/pages/bingkai_edit_page.dart';

import '../utils/helper.dart';
//import 'package:cached_network_image/cached_network_image.dart';

class BingkaiPage extends StatefulWidget {
  const BingkaiPage({super.key});

  @override
  BingkaiPageState createState() => BingkaiPageState();
}

class BingkaiPageState extends State<BingkaiPage> {
  @override
  void initState() {
    super.initState();
    imageFiles.add(
        BingkaiImage(name: 'classic', image: File('assets/images/frame2.png'), path: 'assets/images/frame2.png'));
    print(img(File('assets/images/frame2.png')));
  }

/* 
final path = xFile.path;
final bytes = await File(path).readAsBytes();
final img.Image image = img.decodeImage(bytes);
 */
  List<XFile> newFiles = [];
  List<BingkaiImage> localFiles = [];
  List<BingkaiImage> imageFiles = [];

  Future<void> _pickImage() async {
    /* final List<XFile> */ newFiles = await pickImages();
    //if (pickedFiles != null) {
    setState(() {
      //newFiles.addAll(newFiles);
      imageFiles.addAll(newFiles.map((i) => BingkaiImage(image: File(i.path), path: i.path)));

    });
    //}
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan[100],
        shadowColor: Colors.black12,
        title: const Text('Koleksi Bingkai'),
        actions: [
          
        ],
      ),
      body: /* imageFiles == null || imageFiles!.isEmpty
          ? const Center(child: Text('No images selected.'))
          : */
          GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: imageFiles.length,
        itemBuilder: (BuildContext context, int index) {
  
          return GestureDetector(
              onTap: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => BingkaiEditPage(
                          frameImage: img(imageFiles[index].image), path:imageFiles[index].path,
                          bytes: imageFiles[index].image),
                    ),
                  ),
              child: img(imageFiles[index].image));
        },
      ),
      floatingActionButton: IconButton(
        iconSize: 35,
        icon: const Icon(Icons.add_a_photo),
        onPressed: _pickImage,
      ),
    );
  }

  img(File file)=>Image.file(
      file,
      //File(file.path),
      fit: BoxFit.cover,
    );
  
}

enum ImageLocation { local, cloud }

class BingkaiImage {
  BingkaiImage({this.description, this.location, required this.image, this.name,required this.path});
  final String? name;
  final String? description;
  final ImageLocation? location;
  final File image;
  final String path;
}
