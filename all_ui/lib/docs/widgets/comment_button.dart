import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/docs_provider.dart';
import 'comment_panel.dart';

class CommentsButton extends ConsumerWidget {
  const CommentsButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docState = ref.watch(documentControllerProvider);

    return IconButton(
      icon: Badge(
        label: Text('${docState.comments.length}'),
        isLabelVisible: docState.comments.isNotEmpty,
        child: const Icon(Icons.comment_outlined, size: 20),
      ),
      tooltip: 'Comments',
      onPressed: () {
        _showCommentsPanel(context);
      },
    );
  }

  void _showCommentsPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const CommentsPanel(),
    );
  }
}
