import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:syirkah/modules/utility/image_editor/pages/bingkai_edit_page.dart';

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
    imageFiles.add(BingkaiImage(
        name: 'classic', image: Image.asset('assets/images/frame2.png')));
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
      imageFiles.addAll(newFiles.map((i) => BingkaiImage(image: img(i.path))));
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
        actions: const [],
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
                      builder: (BuildContext context) =>
                          BingkaiEditPage(frameImage: imageFiles[index].image!),
                    ),
                  ),
              child: imageFiles[index].image);
        },
      ),
      bottomNavigationBar: bottomBar(),
      floatingActionButton: IconButton(
        iconSize: 35,
        icon: const Icon(Icons.add_a_photo),
        onPressed: _pickImage,
      ),
    );
  }

  bottomBar() => BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              label: 'home',
              icon: Icon(Icons.home),
              activeIcon: Icon(Icons.abc)),
          BottomNavigationBarItem(
              label: 'imah',
              icon: Icon(Icons.home),
              activeIcon: Icon(Icons.abc))
        ],
        onTap: (val) => context.go('/'),
      );

  img(file) {
    Image.file(
      File(file.path),
      fit: BoxFit.cover,
    );
  }
}

enum ImageLocation { local, cloud }

class BingkaiImage {
  BingkaiImage({this.description, this.location, this.image, this.name});
  final String? name;
  final String? description;
  final ImageLocation? location;
  final Image? image;
}
