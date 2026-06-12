import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'models/content_type_schema.dart';

import 'content_type_schema.dart';
import '_content_type_card.dart';

class CMSHomePage extends ConsumerWidget {
  const CMSHomePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentTypesAsync = ref.watch(contentTypesProvider);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.dashboard_customize,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enterprise CMS',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Schema Builder',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(contentTypesProvider.notifier).refresh(),
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
            tooltip: 'Settings',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: contentTypesAsync.when(
        data: (contentTypes) => contentTypes.isEmpty
            ? _buildEmptyState(context, ref)
            : _buildContentTypesGrid(context, ref, contentTypes),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => _buildErrorState(context, ref, err),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showContentTypeDialog(context, ref),
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('New Schema'),
        elevation: 4,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(48),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade100, Colors.purple.shade100],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.schema,
                size: 80,
                color: Colors.indigo.shade700,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No Content Schemas Yet',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first content schema to define your data structure. Schemas are automatically converted to database tables.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _showContentTypeDialog(context, ref),
              icon: const Icon(Icons.add_circle),
              label: const Text('Create First Schema'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text('Error: $error', style: TextStyle(color: Colors.red.shade700)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => ref.read(contentTypesProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContentTypesGrid(
    BuildContext context,
    WidgetRef ref,
    List<ContentTypeSchema> contentTypes,
  ) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Content Schemas',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${contentTypes.length} schema${contentTypes.length != 1 ? 's' : ''} defined',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 380,
              childAspectRatio: 1.3,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  _ContentTypeCard(contentType: contentTypes[index]),
              childCount: contentTypes.length,
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }

  void _showContentTypeDialog(BuildContext context, WidgetRef ref) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ContentTypeBuilderPage(
          onSave: (contentType) {
            ref.read(contentTypesProvider.notifier).create(contentType);
          },
        ),
        fullscreenDialog: true,
      ),
    );
  }
}
