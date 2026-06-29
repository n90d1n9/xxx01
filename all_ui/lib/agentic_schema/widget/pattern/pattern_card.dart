import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../schema/integration/integration_pattern_template.dart';
import '../../state/pattern_library_provider.dart';
import 'patterns_detail_dialog.dart';

class PatternCard extends ConsumerWidget {
  final IntegrationPatternTemplate pattern;

  const PatternCard({Key? key, required this.pattern}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Draggable<IntegrationPatternTemplate>(
      data: pattern,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _hexToColor(pattern.color!).withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(pattern.icon!, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      pattern.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      pattern.description!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: 2,
        child: InkWell(
          onTap: () {
            ref.read(patternLibraryProvider.notifier).selectPattern(pattern);
            _showPatternDetails(context, pattern);
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _hexToColor(pattern.color!).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      pattern.icon!,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pattern.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pattern.description!,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Chip(
                        label: Text(
                          pattern.category.toUpperCase(),
                          style: const TextStyle(fontSize: 10),
                        ),
                        backgroundColor: _hexToColor(
                          pattern.color!,
                        ).withOpacity(0.2),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.drag_indicator, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPatternDetails(
    BuildContext context,
    IntegrationPatternTemplate pattern,
  ) {
    showDialog(
      context: context,
      builder: (context) => PatternDetailsDialog(pattern: pattern),
    );
  }

  Color _hexToColor(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }
}
