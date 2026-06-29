import 'dart:io';
import 'package:flutter/material.dart';

void main() {
  runApp(LargeFileFinderApp());
}

class LargeFileFinderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: LargeFileFinderScreen());
  }
}

class LargeFileFinderScreen extends StatefulWidget {
  @override
  _LargeFileFinderScreenState createState() => _LargeFileFinderScreenState();
}

class _LargeFileFinderScreenState extends State<LargeFileFinderScreen> {
  String directoryPath = '/Users/yourname/Documents';
  List<String> largeFiles = [];

  bool isLoading = false;

  Future<void> findLargeFiles() async {
    String findLarge =
        'find "$directoryPath" -type f -size +100M -exec ls -lh {} \\; | sort -k 5 -rh';
    String large = 'du -sh ~/Workspace/workkayys/* | sort -hr | head -n 20';
    String ls = 'ls ~/';
    String command = large;
    print('..processing...');
    setState(() {
      isLoading = true;
      largeFiles = [];
    });

    print(command);

    final result = await Process.run('bash', ['-c', command]);

    setState(() {
      isLoading = false;
      largeFiles =
          result.stdout
              .toString()
              .split('\n')
              .where((line) => line.trim().isNotEmpty)
              .toList();

      print(largeFiles);
    });
  }

  Future<void> deleteFile(String fileLine) async {
    final filePath = fileLine.split(RegExp(r'\s+')).last;
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
      setState(() {
        largeFiles.removeWhere((line) => line.contains(filePath));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Large File Finder')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Directory Path'),
              controller: TextEditingController(text: directoryPath),
              onChanged: (value) {
                setState(() {
                  directoryPath = value;

                  print(directoryPath);
                });
              },
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: findLargeFiles,
              child: Text('Find Large Files'),
            ),
            SizedBox(height: 10),
            isLoading
                ? CircularProgressIndicator()
                : Expanded(
                  child: ListView.builder(
                    itemCount: largeFiles.length,
                    itemBuilder: (context, index) {
                      final file = largeFiles[index];
                      return ListTile(
                        title: Text(file),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            deleteFile(file);
                          },
                        ),
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
