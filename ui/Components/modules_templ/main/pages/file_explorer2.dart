import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class FileExplorer2 extends StatefulWidget {
  @override
  _FileExplorer2State createState() => _FileExplorer2State();
}

class _FileExplorer2State extends State<FileExplorer2> {
  List<FileSystemEntity> _files = [];
  String _currentPath = '/';

  @override
  void initState() {
    super.initState();
    _loadFiles(_currentPath);
  }

  Future<void> _loadFiles(String path) async {
    try {
      final dir = Directory(path);
      final files = await dir.list().toList();
      setState(() {
        _files = files;
        _currentPath = path;
      });
    } catch (e) {
      print('Error loading files: $e');
    }
  }

  void _openFile(String filePath) async {
    // Replace with your logic to open the file based on its type
    print('Opening file: $filePath');
  }

  void _navigateToDirectory(String path) {
    setState(() {
      _currentPath = path;
    });
    _loadFiles(path);
  }

  void _createTempDir() async {
    var tempDir = await getTemporaryDirectory();
    var tempDirPath = tempDir.path;
    final myAppPath = '$tempDirPath/my_app';
    final res = await Directory(myAppPath).create(recursive: true);
    print('Path: ${res.path}');
  }

  void _deleteDir() async {
    Directory dir = await getTemporaryDirectory();
    Directory myDir = Directory(dir.path + "/my_app");
    myDir.deleteSync(recursive: true);
    myDir.create();
  }

  Widget _buildFileListItem(FileSystemEntity file) {
    if (file is File) {
      return ListTile(
        leading: Icon(Icons.file_copy),
        title: Text(path.basename(file.path)),
        onTap: () {
          _openFile(file.path);
        },
      );
    } else if (file is Directory) {
      return ListTile(
        leading: Icon(Icons.folder),
        title: Text(path.basename(file.path)),
        onTap: () {
          print('------open create-----');
          _createTempDir();
          _navigateToDirectory(file.path);
        },
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('File Explorer'),
      ),
      body: Row(
        children: [
          // Tree view for navigation
          Expanded(
            child: ListView.builder(
              itemCount: _files.length,
              itemBuilder: (context, index) {
                return _buildFileListItem(_files[index]);
              },
            ),
          ),
          // File/Folder List
          Expanded(
            child: ListView.builder(
              itemCount: _files.length,
              itemBuilder: (context, index) {
                final file = _files[index];
                return _buildFileListItem(file);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String? selectedPath = await FilePicker.platform.getDirectoryPath();
          if (selectedPath != null) {
            _navigateToDirectory(selectedPath);
          }
        },
        child: Icon(Icons.folder_open),
      ),
    );
  }
}
