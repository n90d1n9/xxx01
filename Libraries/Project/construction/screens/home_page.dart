import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../states/project_provider.dart';
import '../widgets/add_project_dialog.dart';
import '../widgets/project_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistem Manajemen Proyek'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAbout(context),
          ),
        ],
      ),
      body: projects.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                return ProjectCard(project: projects[index]);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProjectDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Proyek Baru'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Belum ada proyek',
            style: TextStyle(fontSize: 20, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap tombol + untuk menambah proyek baru',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Sistem Manajemen Proyek',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.construction, size: 48),
      children: [
        const Text('Sistem manajemen proyek konstruksi Indonesia'),
        const Text('dengan fitur lengkap untuk perencanaan,'),
        const Text('penganggaran, BoQ, dan penjadwalan.'),
      ],
    );
  }

  void _showAddProjectDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddProjectDialog(ref: ref),
    );
  }
}
