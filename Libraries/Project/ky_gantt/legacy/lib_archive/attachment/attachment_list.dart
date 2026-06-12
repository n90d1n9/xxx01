
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'attachment.dart';
import '../task/task.dart';

class AttachmentList extends StatelessWidget {
  final List<TaskAttachment> attachments;
  final Function(TaskAttachment) onAdd;
  final Function(TaskAttachment) onRemove;

  const AttachmentList({
    super.key,
    required this.attachments,
    required this.onAdd,
    required this.onRemove,
  });

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final file = result.files.first;
      final attachment = TaskAttachment(
        name: file.name,
        size: file.size,
        path: file.path ?? '',
      );
      onAdd(attachment);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Attachments', style: Theme.of(context).textTheme.titleMedium),
        ListView.builder(
          shrinkWrap: true,
          itemCount: attachments.length + 1,
          itemBuilder: (context, index) {
            if (index == attachments.length) {
              return TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Attachment'),
                onPressed: _pickFile,
              );
            }
            
            final attachment = attachments[index];
            return ListTile(
              leading: const Icon(Icons.attachment),
              title: Text(attachment.name!),
              subtitle: Text('${(attachment.size! / 1024).round()} KB'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => onRemove(attachment),
              ),
            );
          },
        ),
      ],
    );
  }
}