import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../states/cms_repository_provider.dart';
import '../generated_files_dialog.dart';

class CodeGenerationDialog extends ConsumerWidget {
  const CodeGenerationDialog({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      child: Container(
        width: 800,
        height: 600,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.code, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Code Generation',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Generate production-ready code from schemas',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Backend Frameworks',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildGenerationOption(
                      context,
                      ref,
                      icon: Icons.coffee,
                      title: 'Quarkus (Java)',
                      description:
                          'Entities, REST API, OpenAPI, Docker Compose',
                      color: Colors.blue,
                      onTap: () => _generateQuarkus(context, ref),
                    ),
                    _buildGenerationOption(
                      context,
                      ref,
                      icon: Icons.code,
                      title: 'Node.js/TypeScript',
                      description: 'Express.js with Prisma ORM (Coming Soon)',
                      color: Colors.green,
                      enabled: false,
                    ),
                    _buildGenerationOption(
                      context,
                      ref,
                      icon: Icons.language,
                      title: 'Deno',
                      description: 'Fresh framework with Deno KV (Coming Soon)',
                      color: Colors.purple,
                      enabled: false,
                    ),
                    _buildGenerationOption(
                      context,
                      ref,
                      icon: Icons.php,
                      title: 'PHP Laravel',
                      description:
                          'Models, controllers, migrations (Coming Soon)',
                      color: Colors.red,
                      enabled: false,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Frontend Frameworks',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildGenerationOption(
                      context,
                      ref,
                      icon: Icons.flutter_dash,
                      title: 'Flutter',
                      description: 'Models and API clients (Coming Soon)',
                      color: Colors.blue,
                      enabled: false,
                    ),
                    _buildGenerationOption(
                      context,
                      ref,
                      icon: Icons.web,
                      title: 'React/Next.js',
                      description:
                          'TypeScript types and React hooks (Coming Soon)',
                      color: Colors.cyan,
                      enabled: false,
                    ),
                    _buildGenerationOption(
                      context,
                      ref,
                      icon: Icons.web_asset,
                      title: 'Vue.js',
                      description: 'Vue 3 composables and types (Coming Soon)',
                      color: Colors.green,
                      enabled: false,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerationOption(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: enabled ? null : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            enabled
                                ? Colors.grey.shade600
                                : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                enabled ? Icons.arrow_forward_ios : Icons.lock,
                size: 20,
                color: enabled ? Colors.grey : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _generateQuarkus(BuildContext context, WidgetRef ref) {
    final repository = ref.read(cmsRepositoryProvider);
    final files = repository.generateQuarkusProject();
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => GeneratedFilesDialog(files: files),
    );
  }
}
