import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GeneratedFilesDialog extends StatefulWidget {
  final Map<String, String> files;
  const GeneratedFilesDialog({super.key, required this.files});
  @override
  State<GeneratedFilesDialog> createState() => _GeneratedFilesDialogState();
}

class _GeneratedFilesDialogState extends State<GeneratedFilesDialog> {
  String? _selectedFile;
  String _selectedContent = '';
  @override
  void initState() {
    super.initState();
    if (widget.files.isNotEmpty) {
      _selectedFile = widget.files.keys.first;
      _selectedContent = widget.files.values.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 1000,
        height: 700,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade700,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Code Generated Successfully!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.files.length} files generated',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _downloadAll,
                    icon: const Icon(Icons.download),
                    label: const Text('Download All'),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 300,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border(
                        right: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: ListView.builder(
                      itemCount: widget.files.length,
                      itemBuilder: (context, index) {
                        final fileName = widget.files.keys.elementAt(index);
                        final isSelected = fileName == _selectedFile;
                        return ListTile(
                          selected: isSelected,
                          leading: Icon(
                            _getFileIcon(fileName),
                            color:
                                isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                          ),
                          title: Text(
                            fileName.split('/').last,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : null,
                            ),
                          ),
                          subtitle: Text(
                            fileName
                                .split('/')
                                .sublist(0, fileName.split('/').length - 1)
                                .join('/'),
                            style: const TextStyle(fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            setState(() {
                              _selectedFile = fileName;
                              _selectedContent = widget.files[fileName]!;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.insert_drive_file,
                                size: 20,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _selectedFile ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 20),
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: _selectedContent),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Copied to clipboard'),
                                    ),
                                  );
                                },
                                tooltip: 'Copy to clipboard',
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: Colors.grey.shade900,
                            padding: const EdgeInsets.all(16),
                            child: SingleChildScrollView(
                              child: SelectableText(
                                _selectedContent,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 13,
                                  color: Colors.greenAccent,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    if (fileName.endsWith('.java')) return Icons.code;
    if (fileName.endsWith('.xml')) return Icons.description;
    if (fileName.endsWith('.properties')) return Icons.settings;
    if (fileName.endsWith('.sql')) return Icons.storage;
    if (fileName.endsWith('.json')) return Icons.data_object;
    if (fileName.endsWith('.md')) return Icons.article;
    if (fileName.endsWith('.yml')) return Icons.settings_applications;
    return Icons.insert_drive_file;
  }

  void _downloadAll() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '💡 Copy individual files or use the generated code in your IDE',
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
