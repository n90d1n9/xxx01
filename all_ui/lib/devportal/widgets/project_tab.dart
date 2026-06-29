import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/enums.dart';
import '../states/provider.dart';
import 'status_badge.dart';

class ProjectsTab extends ConsumerWidget {
  final bool isDarkMode;

  const ProjectsTab({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Projects',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('New Project'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Filter Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color:
                        isDarkMode
                            ? const Color(0xFF1E1E2D)
                            : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search projects',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color:
                                  isDarkMode ? Colors.white30 : Colors.black38,
                            ),
                          ),
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color:
                      isDarkMode
                          ? const Color(0xFF1E1E2D)
                          : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: 'All Status',
                    items:
                        ['All Status', 'Active', 'Warning', 'Inactive'].map((
                          String value,
                        ) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                          );
                        }).toList(),
                    onChanged: (_) {},
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                    dropdownColor:
                        isDarkMode ? const Color(0xFF1E1E2D) : Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color:
                      isDarkMode
                          ? const Color(0xFF1E1E2D)
                          : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: 'Last Updated',
                    items:
                        [
                          'Last Updated',
                          'Name A-Z',
                          'Name Z-A',
                          'Oldest First',
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                          );
                        }).toList(),
                    onChanged: (_) {},
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                    dropdownColor:
                        isDarkMode ? const Color(0xFF1E1E2D) : Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Projects Grid
          Expanded(
            child: projects.when(
              data:
                  (projectList) => GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 3 / 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: projectList.length,
                    itemBuilder: (context, index) {
                      final project = projectList[index];
                      return Container(
                        decoration: BoxDecoration(
                          color:
                              isDarkMode
                                  ? const Color(0xFF2D2D42)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        project.name,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              isDarkMode
                                                  ? Colors.white
                                                  : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          StatusBadge(
                                            status: ProjectStatus.active,
                                            isDarkMode: isDarkMode,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Updated ${_timeAgo(project.lastUpdated!)}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  isDarkMode
                                                      ? Colors.white60
                                                      : Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  PopupMenuButton<String>(
                                    icon: Icon(
                                      Icons.more_vert,
                                      color:
                                          isDarkMode
                                              ? Colors.white60
                                              : Colors.black54,
                                    ),
                                    itemBuilder:
                                        (BuildContext context) =>
                                            <PopupMenuEntry<String>>[
                                              const PopupMenuItem<String>(
                                                value: 'edit',
                                                child: Text('Edit Project'),
                                              ),
                                              const PopupMenuItem<String>(
                                                value: 'settings',
                                                child: Text('Project Settings'),
                                              ),
                                              const PopupMenuItem<String>(
                                                value: 'duplicate',
                                                child: Text('Duplicate'),
                                              ),
                                              const PopupMenuItem<String>(
                                                value: 'delete',
                                                child: Text('Delete'),
                                              ),
                                            ],
                                    onSelected: (String value) {},
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Text(
                                'API Integrations:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      isDarkMode
                                          ? Colors.white60
                                          : Colors.black54,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children:
                                    project.apis!.map((api) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              isDarkMode
                                                  ? const Color(0xFF1E1E2D)
                                                  : const Color(0xFFF5F5F5),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          api,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                isDarkMode
                                                    ? Colors.white70
                                                    : Colors.black87,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color:
                                        isDarkMode
                                            ? Colors.white12
                                            : Colors.black12,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  OutlinedButton(
                                    onPressed: () {},
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color:
                                            isDarkMode
                                                ? Colors.white30
                                                : Colors.black26,
                                      ),
                                    ),
                                    child: const Text('View Docs'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Manage'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (_, __) =>
                      const Center(child: Text('Failed to load projects')),
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes} min ago';
    } else if (duration.inHours < 24) {
      return '${duration.inHours} hours ago';
    } else {
      return '${duration.inDays} days ago';
    }
  }
}
