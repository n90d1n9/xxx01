

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../task/task.dart';

class CommentSection extends StatefulWidget {
  final List<TaskComment> comments;
  final Function(String) onAddComment;

  const CommentSection({
    super.key,
    required this.comments,
    required this.onAddComment,
  });

  @override
  CommentSectionState createState() => CommentSectionState();
}

class CommentSectionState extends State<CommentSection> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Comments', style: Theme.of(context).textTheme.titleMedium),
        ListView.builder(
          shrinkWrap: true,
          itemCount: widget.comments.length,
          itemBuilder: (context, index) {
            final comment = widget.comments[index];
            return ListTile(
              leading: CircleAvatar(
                child: Text(comment.author![0]),
              ),
              title: Text(comment.author!),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(comment.content!),
                  Text(
                    DateFormat('MMM dd, yyyy HH:mm').format(comment.timestamp!),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Add a comment...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  if (_commentController.text.isNotEmpty) {
                    widget.onAddComment(_commentController.text);
                    _commentController.clear();
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
