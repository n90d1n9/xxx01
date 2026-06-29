import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'models/content_type_schema.dart';

import 'content_type_schema.dart';
import 'content_entries_page.dart';

class _ContentTypeCard extends ConsumerWidget {
  final ContentTypeSchema contentType;
  const _ContentTypeCard({required this.contentType});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _navigateToEntries(context),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                _getColorForIcon(contentType.icon).withOpacity(0.05),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getColorForIcon(contentType.icon),
                            _getColorForIcon(contentType.icon).withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: _getColorForIcon(
                              contentType.icon,
                            ).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getIconData(contentType.icon),
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton(
                      icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                      itemBuilder:
                          (context) => <PopupMenuItem>[
                            PopupMenuItem(
                              child: const Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 12),
                                  Text('Edit Schema'),
                                ],
                              ),
                              onTap:
                                  () => Future.delayed(
                                    Duration.zero,
                                    () => _editSchema(context, ref),
                                  ),
                            ),
                            PopupMenuItem(
                              child: const Row(
                                children: [
                                  Icon(Icons.code, size: 20),
                                  SizedBox(width: 12),
                                  Text('View SQL'),
                                ],
                              ),
                              onTap:
                                  () => Future.delayed(
                                    Duration.zero,
                                    () => _showSQL(context, ref),
                                  ),
                            ),
                            PopupMenuItem(
                              child: const Row(
                                children: [
                                  Icon(Icons.download, size: 20),
                                  SizedBox(width: 12),
                                  Text('Export JSON'),
                                ],
                              ),
                              onTap:
                                  () => Future.delayed(
                                    Duration.zero,
                                    () => _exportJSON(context, ref),
                                  ),
                            ),
                            const PopupMenuDivider(),
                            PopupMenuItem(
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                              onTap:
                                  () => Future.delayed(
                                    Duration.zero,
                                    () => _confirmDelete(context, ref),
                                  ),
                            ),
                          ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  contentType.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  contentType.description ?? 'No description',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.layers, size: 16, color: Colors.grey.shade700),
                      const SizedBox(width: 6),
                      Text(
                        '${contentType.fields.length} fields',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'v${contentType.version}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('•', style: TextStyle(color: Colors.grey.shade400)),
                    const SizedBox(width: 8),
                    Text(
                      contentType.tableName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getColorForIcon(String iconName) {
    switch (iconName) {
      case 'article':
        return const Color(0xFF6366F1);
      case 'image':
        return const Color(0xFFEC4899);
      case 'video':
        return const Color(0xFFF59E0B);
      case 'person':
        return const Color(0xFF10B981);
      case 'category':
        return const Color(0xFF8B5CF6);
      case 'settings':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'article':
        return Icons.article;
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.video_library;
      case 'person':
        return Icons.person;
      case 'category':
        return Icons.category;
      case 'settings':
        return Icons.settings;
      default:
        return Icons.folder;
    }
  }

  void _navigateToEntries(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ContentEntriesPage(contentType: contentType),
      ),
    );
  }

  void _editSchema(BuildContext context, WidgetRef ref) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ContentTypeBuilderPage(
              contentType: contentType,
              onSave: (updated) {
                ref.read(contentTypesProvider.notifier).update(updated);
              },
            ),
        fullscreenDialog: true,
      ),
    );
  }

  void _showSQL(BuildContext context, WidgetRef ref) {
    final sql = ref
        .read(cmsRepositoryProvider)
        .exportSchemaAsSQL(contentType.id);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('SQL Schema'),
            content: Container(
              width: 600,
              constraints: const BoxConstraints(maxHeight: 500),
              child: SingleChildScrollView(
                child: SelectableText(
                  sql,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: sql));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('SQL copied to clipboard')),
                  );
                },
                child: const Text('Copy'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _exportJSON(BuildContext context, WidgetRef ref) {
    final json = ref
        .read(cmsRepositoryProvider)
        .exportSchemaAsJSON(contentType.id);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('JSON Schema'),
            content: Container(
              width: 600,
              constraints: const BoxConstraints(maxHeight: 500),
              child: SingleChildScrollView(
                child: SelectableText(
                  json,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: json));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('JSON copied to clipboard')),
                  );
                },
                child: const Text('Copy'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Schema'),
            content: Text(
              'Are you sure you want to delete "${contentType.name}"?\n\nThis will also delete all entries and cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  ref
                      .read(contentTypesProvider.notifier)
                      .delete(contentType.id);
                  Navigator.pop(context);
                },
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
