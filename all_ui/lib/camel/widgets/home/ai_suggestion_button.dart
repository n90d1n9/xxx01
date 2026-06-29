import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../states/ai_suggestion_provider.dart';

class AISuggestionsButton extends ConsumerWidget {
  final VoidCallback onPressed;

  const AISuggestionsButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(aiSuggestionsProvider);

    return IconButton(
      icon: Icon(
        Icons.lightbulb,
        color: suggestions.isNotEmpty ? Colors.amber : null,
      ),
      onPressed: onPressed,
      tooltip: 'AI Suggestions',
    );
  }
}
