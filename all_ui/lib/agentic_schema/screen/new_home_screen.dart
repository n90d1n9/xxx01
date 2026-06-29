import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/workflow/workflow_provider.dart';
import '../widget/cloud/cloud_workflow_browser.dart';
import '../widget/export_import_dialog.dart';
import '../widget/keyboard_shortcut.dart';
import '../widget/settings_dialog.dart';
import 'complete_visual_editor.dart';
import 'template_gallery_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.psychology),
            const SizedBox(width: 8),
            const Text('AI Agent Builder'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud),
            tooltip: 'Cloud Workflows',
            onPressed: () => _showCloudBrowser(),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(),
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Welcome section
              Text(
                'Welcome to AI Agent Builder',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Create intelligent AI agents with visual workflows',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Action cards
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ActionCard(
                    icon: Icons.add_circle,
                    title: 'New Workflow',
                    description: 'Start from scratch',
                    color: Colors.blue,
                    onTap: () => _createNewWorkflow(),
                  ),
                  const SizedBox(width: 24),
                  _ActionCard(
                    icon: Icons.cloud_download,
                    title: 'Open from Cloud',
                    description: 'Access your workflows',
                    color: Colors.green,
                    onTap: () => _showCloudBrowser(),
                  ),
                  const SizedBox(width: 24),
                  _ActionCard(
                    icon: Icons.folder_open,
                    title: 'Import',
                    description: 'Load from file',
                    color: Colors.orange,
                    onTap: () => _importWorkflow(),
                  ),
                  const SizedBox(width: 24),
                  _ActionCard(
                    icon: Icons.library_books,
                    title: 'Templates',
                    description: 'Use pre-built patterns',
                    color: Colors.purple,
                    onTap: () => _showTemplates(),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // Recent workflows
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Recent Workflows',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              _RecentWorkflowsList(),
            ],
          ),
        ),
      ),
    );
  }

  void _createNewWorkflow() {
    showDialog(
      context: context,
      builder: (context) => _NewWorkflowDialog(),
    ).then((name) {
      if (name != null) {
        ref.read(workflowProvider.notifier).createNewWorkflow(name);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                const KeyboardShortcuts(child: CompleteVisualEditor()),
          ),
        );
      }
    });
  }

  void _showCloudBrowser() {
    showDialog(
      context: context,
      builder: (context) => const CloudWorkflowsBrowser(),
    );
  }

  void _importWorkflow() {
    showDialog(
      context: context,
      builder: (context) => const ExportImportDialog(),
    );
  }

  void _showTemplates() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const TemplatesGalleryScreen()));
  }

  void _showSettings() {
    showDialog(context: context, builder: (context) => const SettingsDialog());
  }
}

// ============================================================================
// ACTION CARD
// ============================================================================

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                description,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// RECENT WORKFLOWS LIST
// ============================================================================

class _RecentWorkflowsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In production, load from local storage or cloud
    final recentWorkflows = <Map<String, dynamic>>[];

    if (recentWorkflows.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 8),
              Text(
                'No recent workflows',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recentWorkflows.length,
        itemBuilder: (context, index) {
          final workflow = recentWorkflows[index];
          return Container(
            width: 250,
            margin: const EdgeInsets.only(right: 16),
            child: Card(
              child: InkWell(
                onTap: () {
                  // Load workflow
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.account_tree, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              workflow['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        'Modified: ${workflow['modified']}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// NEW WORKFLOW DIALOG
// ============================================================================

class _NewWorkflowDialog extends StatefulWidget {
  @override
  State<_NewWorkflowDialog> createState() => _NewWorkflowDialogState();
}

class _NewWorkflowDialogState extends State<_NewWorkflowDialog> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Workflow'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Workflow Name',
              border: OutlineInputBorder(),
              hintText: 'Enter workflow name',
            ),
            autofocus: true,
            onSubmitted: (_) => _create(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _create, child: const Text('Create')),
      ],
    );
  }

  void _create() {
    if (_nameController.text.trim().isEmpty) return;
    Navigator.of(context).pop(_nameController.text.trim());
  }
}
