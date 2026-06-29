import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/quran_provider.dart';

class StudyTab extends ConsumerWidget {
  const StudyTab({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final annotationsAsync = ref.watch(annotationsProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Study Tools', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StudyToolCard(
                icon: Icons.book,
                title: 'Tafsir Library',
                description: 'Explore verse commentaries',
                onTap: () {},
              ),
              _StudyToolCard(
                icon: Icons.lightbulb,
                title: 'Topics & Themes',
                description: 'Browse by subject',
                onTap: () {},
              ),
              _StudyToolCard(
                icon: Icons.compare,
                title: 'Translation Compare',
                description: 'Side-by-side view',
                onTap: () {},
              ),
              _StudyToolCard(
                icon: Icons.link,
                title: 'Cross References',
                description: 'Related verses',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('My Notes', style: Theme.of(context).textTheme.titleLarge),
              TextButton.icon(
                onPressed: () async {
                  final exported =
                      await ref.read(studyServiceProvider).exportAnnotations();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notes exported!')),
                    );
                  }
                },
                icon: const Icon(Icons.download),
                label: const Text('Export'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          annotationsAsync.when(
            data: (annotations) {
              if (annotations.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(Icons.note_add, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No notes yet'),
                        SizedBox(height: 8),
                        Text(
                          'Long press on any ayah to add notes',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Column(
                children:
                    annotations.map((annotation) {
                      return Card(
                        child: ListTile(
                          leading:
                              annotation.highlightColor != null
                                  ? Container(
                                    width: 4,
                                    color: annotation.highlightColor,
                                  )
                                  : const Icon(Icons.note),
                          title: Text(
                            '${annotation.surahNumber}:${annotation.ayahNumber}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            annotation.text,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder:
                                (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                            onSelected: (value) {
                              if (value == 'delete') {
                                ref
                                    .read(studyServiceProvider)
                                    .deleteAnnotation(annotation.id);
                                ref.invalidate(annotationsProvider);
                              }
                            },
                          ),
                        ),
                      );
                    }).toList(),
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (error, _) => Text('Error: $error'),
          ),
        ],
      ),
    );
  }
}

class _StudyToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  const _StudyToolCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(description, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
