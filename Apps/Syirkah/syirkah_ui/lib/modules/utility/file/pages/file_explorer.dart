import 'dart:io';

//import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FileExplorer extends StatefulWidget {
  const FileExplorer({super.key});

  @override
  State<FileExplorer> createState() => _FileExplorerState();
}

class _FileExplorerState extends State<FileExplorer> {
  String? _currentDirectory;
  List<FileSystemEntity> _files = [];

  @override
  void initState() {
    super.initState();
    _currentDirectory = Directory.current.path;
    _loadDirectory();
  }

  Future<void> _loadDirectory() async {
    try {
      final directory = Directory(_currentDirectory!);
      final files = await directory.list().toList();
      setState(() {
        _files = files;
      });
    } catch (e) {
      print('Error loading directory: $e');
    }
  }

  void _openFile(FileSystemEntity file) {
    if (file is File) {
      // Open the file using a suitable method.
      // For example, you could use `launch()` to open the file using the system's default application.
      launchUrl(Uri(path:file.path));
    }
  }

  void _navigateDirectory(String path) {
    setState(() {
      _currentDirectory = path;
      _loadDirectory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Explorer'),
        leading: IconButton(
          onPressed: () {
            // Navigate back to the previous directory.
            _navigateDirectory(Directory(_currentDirectory!).parent.path);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView.builder(
        itemCount: _files.length,
        itemBuilder: (context, index) {
          final file = _files[index];
          final isDirectory = file is Directory;

          return ListTile(
            leading: isDirectory
                ? const Icon(Icons.folder)
                : const Icon(Icons.file_copy),
            title: Text(file.path.split('/').last),
            onTap: () {
              if (isDirectory) {
                _navigateDirectory(file.path);
              } else {
                _openFile(file);
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Use FilePicker to select a file or directory.
          /* String? selectedPath = await FilePicker.platform.getDirectoryPath();
          if (selectedPath != null) {
            _navigateDirectory(selectedPath);
          } */
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}