// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const ProviderScope(child: DocumentRepositoryApp()));
}

class DocumentRepositoryApp extends StatelessWidget {
  const DocumentRepositoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Document Repository',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      themeMode: ThemeMode.system,
      home: const DocumentRepositoryScreen(),
    );
  }
}

// Models
enum FileType { document, image, pdf, spreadsheet, other }

enum PermissionLevel { owner, editor, viewer, none }

class User {
  final String id;
  final String name;
  final String avatarUrl;

  User({required this.id, required this.name, required this.avatarUrl});
}

class FileVersion {
  final String id;
  final DateTime timestamp;
  final User author;
  final String notes;

  FileVersion({
    required this.id,
    required this.timestamp,
    required this.author,
    required this.notes,
  });
}

class RepositoryFile {
  final String id;
  final String name;
  final FileType type;
  final DateTime lastModified;
  final User owner;
  final List<FileVersion> versions;
  final List<User> collaborators;
  final Map<String, PermissionLevel> permissions;
  final int size; // in KB

  RepositoryFile({
    required this.id,
    required this.name,
    required this.type,
    required this.lastModified,
    required this.owner,
    required this.versions,
    required this.collaborators,
    required this.permissions,
    required this.size,
  });

  IconData get iconData {
    switch (type) {
      case FileType.document:
        return Icons.description;
      case FileType.image:
        return Icons.image;
      case FileType.pdf:
        return Icons.picture_as_pdf;
      case FileType.spreadsheet:
        return Icons.table_chart;
      case FileType.other:
        return Icons.insert_drive_file;
    }
  }
}

// Providers
final currentUserProvider = Provider<User>(
  (ref) => User(
    id: 'user-001',
    name: 'Alex Morgan',
    avatarUrl: 'https://i.pravatar.cc/150?img=65',
  ),
);

final searchQueryProvider = StateProvider<String>((ref) => '');

final filesRepositoryProvider =
    StateNotifierProvider<FilesRepository, List<RepositoryFile>>((ref) {
      return FilesRepository();
    });

final filteredFilesProvider = Provider<List<RepositoryFile>>((ref) {
  final files = ref.watch(filesRepositoryProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();

  if (searchQuery.isEmpty) {
    return files;
  }

  return files
      .where(
        (file) =>
            file.name.toLowerCase().contains(searchQuery) ||
            file.owner.name.toLowerCase().contains(searchQuery),
      )
      .toList();
});

final selectedFileProvider = StateProvider<RepositoryFile?>((ref) => null);

// Repository
class FilesRepository extends StateNotifier<List<RepositoryFile>> {
  FilesRepository() : super(_generateInitialFiles());

  static List<RepositoryFile> _generateInitialFiles() {
    final user1 = User(
      id: 'user-001',
      name: 'Alex Morgan',
      avatarUrl: 'https://i.pravatar.cc/150?img=65',
    );
    final user2 = User(
      id: 'user-002',
      name: 'Jamie Smith',
      avatarUrl: 'https://i.pravatar.cc/150?img=33',
    );
    final user3 = User(
      id: 'user-003',
      name: 'Taylor Reid',
      avatarUrl: 'https://i.pravatar.cc/150?img=48',
    );

    return [
      RepositoryFile(
        id: 'file-001',
        name: 'Project Proposal.docx',
        type: FileType.document,
        lastModified: DateTime.now().subtract(const Duration(hours: 2)),
        owner: user1,
        versions: [
          FileVersion(
            id: 'v1',
            timestamp: DateTime.now().subtract(const Duration(days: 2)),
            author: user1,
            notes: 'Initial draft',
          ),
          FileVersion(
            id: 'v2',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            author: user1,
            notes: 'Updated project timeline',
          ),
        ],
        collaborators: [user1, user2],
        permissions: {
          'user-001': PermissionLevel.owner,
          'user-002': PermissionLevel.editor,
          'user-003': PermissionLevel.viewer,
        },
        size: 458,
      ),
      RepositoryFile(
        id: 'file-002',
        name: 'Financial Report Q1.xlsx',
        type: FileType.spreadsheet,
        lastModified: DateTime.now().subtract(const Duration(days: 1)),
        owner: user2,
        versions: [
          FileVersion(
            id: 'v1',
            timestamp: DateTime.now().subtract(const Duration(days: 5)),
            author: user2,
            notes: 'Initial spreadsheet',
          ),
          FileVersion(
            id: 'v2',
            timestamp: DateTime.now().subtract(const Duration(days: 3)),
            author: user3,
            notes: 'Added Q1 numbers',
          ),
          FileVersion(
            id: 'v3',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            author: user2,
            notes: 'Final review and corrections',
          ),
        ],
        collaborators: [user2, user3],
        permissions: {
          'user-001': PermissionLevel.viewer,
          'user-002': PermissionLevel.owner,
          'user-003': PermissionLevel.editor,
        },
        size: 1024,
      ),
      RepositoryFile(
        id: 'file-003',
        name: 'Product Mockup.png',
        type: FileType.image,
        lastModified: DateTime.now().subtract(const Duration(days: 3)),
        owner: user1,
        versions: [
          FileVersion(
            id: 'v1',
            timestamp: DateTime.now().subtract(const Duration(days: 3)),
            author: user1,
            notes: 'First design concept',
          ),
        ],
        collaborators: [user1],
        permissions: {
          'user-001': PermissionLevel.owner,
          'user-002': PermissionLevel.viewer,
          'user-003': PermissionLevel.none,
        },
        size: 3845,
      ),
      RepositoryFile(
        id: 'file-004',
        name: 'Contract Agreement.pdf',
        type: FileType.pdf,
        lastModified: DateTime.now().subtract(const Duration(days: 7)),
        owner: user3,
        versions: [
          FileVersion(
            id: 'v1',
            timestamp: DateTime.now().subtract(const Duration(days: 14)),
            author: user3,
            notes: 'Draft version',
          ),
          FileVersion(
            id: 'v2',
            timestamp: DateTime.now().subtract(const Duration(days: 7)),
            author: user3,
            notes: 'Final version with signatures',
          ),
        ],
        collaborators: [user1, user3],
        permissions: {
          'user-001': PermissionLevel.viewer,
          'user-002': PermissionLevel.none,
          'user-003': PermissionLevel.owner,
        },
        size: 2156,
      ),
    ];
  }

  void uploadFile(RepositoryFile file) {
    state = [...state, file];
  }

  void deleteFile(String fileId) {
    state = state.where((file) => file.id != fileId).toList();
  }

  void addVersion(String fileId, FileVersion version) {
    state = state.map((file) {
      if (file.id == fileId) {
        final updatedVersions = [...file.versions, version];
        return RepositoryFile(
          id: file.id,
          name: file.name,
          type: file.type,
          lastModified: version.timestamp,
          owner: file.owner,
          versions: updatedVersions,
          collaborators: file.collaborators,
          permissions: file.permissions,
          size: file.size,
        );
      }
      return file;
    }).toList();
  }

  void updatePermissions(String fileId, String userId, PermissionLevel level) {
    state = state.map((file) {
      if (file.id == fileId) {
        final updatedPermissions = Map<String, PermissionLevel>.from(
          file.permissions,
        );
        if (level == PermissionLevel.none) {
          updatedPermissions.remove(userId);
        } else {
          updatedPermissions[userId] = level;
        }

        // Update collaborators list if needed
        List<User> updatedCollaborators = List.from(file.collaborators);
        final user = findUserById(userId);
        if (user != null) {
          if (level != PermissionLevel.none &&
              !file.collaborators.any((u) => u.id == userId)) {
            updatedCollaborators.add(user);
          } else if (level == PermissionLevel.none) {
            updatedCollaborators.removeWhere((u) => u.id == userId);
          }
        }

        return RepositoryFile(
          id: file.id,
          name: file.name,
          type: file.type,
          lastModified: file.lastModified,
          owner: file.owner,
          versions: file.versions,
          collaborators: updatedCollaborators,
          permissions: updatedPermissions,
          size: file.size,
        );
      }
      return file;
    }).toList();
  }

  // Helper method to find users by ID (in a real app, this would use a user repository)
  User? findUserById(String userId) {
    if (userId == 'user-001') {
      return User(
        id: 'user-001',
        name: 'Alex Morgan',
        avatarUrl: 'https://i.pravatar.cc/150?img=65',
      );
    } else if (userId == 'user-002') {
      return User(
        id: 'user-002',
        name: 'Jamie Smith',
        avatarUrl: 'https://i.pravatar.cc/150?img=33',
      );
    } else if (userId == 'user-003') {
      return User(
        id: 'user-003',
        name: 'Taylor Reid',
        avatarUrl: 'https://i.pravatar.cc/150?img=48',
      );
    }
    return null;
  }
}

// Screens
class DocumentRepositoryScreen extends ConsumerStatefulWidget {
  const DocumentRepositoryScreen({super.key});

  @override
  ConsumerState<DocumentRepositoryScreen> createState() =>
      _DocumentRepositoryScreenState();
}

class _DocumentRepositoryScreenState
    extends ConsumerState<DocumentRepositoryScreen> {
  bool _isGridView = false;

  @override
  Widget build(BuildContext context) {
    final files = ref.watch(filteredFilesProvider);
    final selectedFile = ref.watch(selectedFileProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Repository'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _mockUploadFile,
            tooltip: 'Upload new file',
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            tooltip: _isGridView
                ? 'Switch to list view'
                : 'Switch to grid view',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Left sidebar with navigation
          NavigationRail(
            extended: false,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.folder),
                label: Text('My Files'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('Shared'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.star),
                label: Text('Starred'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.delete),
                label: Text('Trash'),
              ),
            ],
            selectedIndex: 0,
            onDestinationSelected: (index) {
              // Handle navigation
            },
          ),

          // Main content area
          Expanded(
            child: Row(
              children: [
                // Files list area
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      // Search bar
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SearchBar(
                          hintText: 'Search files...',
                          leading: const Icon(Icons.search),
                          onChanged: (value) {
                            ref.read(searchQueryProvider.notifier).state =
                                value;
                          },
                          trailing: [
                            IconButton(
                              icon: const Icon(Icons.filter_list),
                              onPressed: () {
                                // Show filter options
                              },
                            ),
                          ],
                        ),
                      ),

                      // Files list
                      Expanded(
                        child: files.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 64,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outline,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No files found',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Try adjusting your search or filters',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              )
                            : _isGridView
                            ? _buildGridView(files)
                            : _buildListView(files),
                      ),
                    ],
                  ),
                ),

                // Details panel for selected file
                if (selectedFile != null)
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Theme.of(context).colorScheme.surfaceVariant
                                  .withValues(alpha: 0.3)
                            : Theme.of(context).colorScheme.surfaceVariant
                                  .withValues(alpha: 0.5),
                        border: Border(
                          left: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                      ),
                      child: FileDetailsPanel(file: selectedFile),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<RepositoryFile> files) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: files.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final file = files[index];
        final selected = ref.watch(selectedFileProvider)?.id == file.id;

        return FileListTile(
          file: file,
          isSelected: selected,
          onTap: () {
            ref.read(selectedFileProvider.notifier).state = file;
          },
        );
      },
    );
  }

  Widget _buildGridView(List<RepositoryFile> files) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        final selected = ref.watch(selectedFileProvider)?.id == file.id;

        return FileGridTile(
          file: file,
          isSelected: selected,
          onTap: () {
            ref.read(selectedFileProvider.notifier).state = file;
          },
        );
      },
    );
  }

  void _mockUploadFile() async {
    // In a real app, this would use FilePicker to get a real file
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    final fileName = result.files.first.name;

    final fileType = fileName.endsWith('.pdf')
        ? FileType.pdf
        : fileName.endsWith('.docx') || fileName.endsWith('.doc')
        ? FileType.document
        : fileName.endsWith('.xlsx') || fileName.endsWith('.xls')
        ? FileType.spreadsheet
        : fileName.endsWith('.png') ||
              fileName.endsWith('.jpg') ||
              fileName.endsWith('.jpeg')
        ? FileType.image
        : FileType.other;

    final currentUser = ref.read(currentUserProvider);
    final newFile = RepositoryFile(
      id: 'file-${DateTime.now().millisecondsSinceEpoch}',
      name: fileName,
      type: fileType,
      lastModified: DateTime.now(),
      owner: currentUser,
      versions: [
        FileVersion(
          id: 'v1',
          timestamp: DateTime.now(),
          author: currentUser,
          notes: 'Initial upload',
        ),
      ],
      collaborators: [currentUser],
      permissions: {currentUser.id: PermissionLevel.owner},
      size: 1024, // Mock file size
    );

    ref.read(filesRepositoryProvider.notifier).uploadFile(newFile);
    ref.read(selectedFileProvider.notifier).state = newFile;

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Uploaded $fileName successfully'),
          behavior: SnackBarBehavior.floating,
          width: 300,
        ),
      );
    }
  }
}

class FileListTile extends StatelessWidget {
  final RepositoryFile file;
  final bool isSelected;
  final Function() onTap;

  const FileListTile({
    super.key,
    required this.file,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(file.iconData, color: theme.colorScheme.primary),
      ),
      title: Text(file.name, style: theme.textTheme.titleMedium),
      subtitle: Text(
        'Modified ${_formatDate(file.lastModified)} • ${_formatFileSize(file.size)}',
        style: theme.textTheme.bodySmall,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AvatarStack(users: file.collaborators),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show more options
            },
          ),
        ],
      ),
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primaryContainer.withValues(
        alpha: 0.2,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: onTap,
    );
  }
}

class FileGridTile extends StatelessWidget {
  final RepositoryFile file;
  final bool isSelected;
  final Function() onTap;

  const FileGridTile({
    super.key,
    required this.file,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
          : theme.colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.5,
                ),
                child: Center(
                  child: Icon(
                    file.iconData,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    style: theme.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(file.lastModified),
                        style: theme.textTheme.bodySmall,
                      ),
                      AvatarStack(users: file.collaborators, size: 18),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AvatarStack extends StatelessWidget {
  final List<User> users;
  final double size;
  final int maxDisplayed;

  const AvatarStack({
    super.key,
    required this.users,
    this.size = 24,
    this.maxDisplayed = 3,
  });

  @override
  Widget build(BuildContext context) {
    final displayUsers = users.take(maxDisplayed).toList();
    final remaining = users.length - displayUsers.length;

    return SizedBox(
      height: size,
      child: Stack(
        children: [
          for (int i = 0; i < displayUsers.length; i++)
            Positioned(
              left: i * (size * 0.6),
              child: _buildAvatar(displayUsers[i]),
            ),
          if (remaining > 0)
            Positioned(
              left: displayUsers.length * (size * 0.6),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    '+$remaining',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: size * 0.4,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(User user) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        image: DecorationImage(
          image: NetworkImage(user.avatarUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class FileDetailsPanel extends ConsumerWidget {
  final RepositoryFile file;

  const FileDetailsPanel({super.key, required this.file});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Header with close button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('File Details', style: theme.textTheme.titleLarge),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  ref.read(selectedFileProvider.notifier).state = null;
                },
              ),
            ],
          ),
        ),

        const Divider(),

        // File preview
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    file.iconData,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(file.name, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.visibility),
                    label: const Text('Preview'),
                    onPressed: () {
                      // Show file preview
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Preview functionality would open here',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

        // File info
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Information', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              _buildInfoRow(context, 'Type', _getFileTypeString(file.type)),
              _buildInfoRow(context, 'Size', _formatFileSize(file.size)),
              _buildInfoRow(context, 'Owner', file.owner.name),
              _buildInfoRow(
                context,
                'Modified',
                _formatDate(file.lastModified),
              ),
              _buildInfoRow(context, 'Versions', '${file.versions.length}'),
            ],
          ),
        ),

        // Version history
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Version History', style: theme.textTheme.titleMedium),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.upload),
                    label: const Text('Upload New Version'),
                    onPressed: () {
                      // Upload new version logic
                      _uploadNewVersion(context, ref);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: file.versions.length,
                  itemBuilder: (context, index) {
                    final version =
                        file.versions[file.versions.length -
                            1 -
                            index]; // Reverse order
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(version.author.avatarUrl),
                      ),
                      title: Text(
                        'Version ${file.versions.length - index}',
                        style: theme.textTheme.titleSmall,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${version.author.name} • ${_formatDate(version.timestamp)}',
                            style: theme.textTheme.bodySmall,
                          ),
                          Text(
                            version.notes,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () {
                          // Download version
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Permissions
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Permissions', style: theme.textTheme.titleMedium),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add User'),
                    onPressed: () {
                      // Add new user permission
                      _showAddUserDialog(context, ref);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: file.permissions.entries.length,
                itemBuilder: (context, index) {
                  final entry = file.permissions.entries.elementAt(index);
                  final userId = entry.key;
                  final permission = entry.value;

                  // Find user object by ID
                  User? user;
                  if (userId == file.owner.id) {
                    user = file.owner;
                  } else {
                    user = file.collaborators.firstWhere(
                      (u) => u.id == userId,
                      orElse: () => User(
                        id: userId,
                        name: 'Unknown User',
                        avatarUrl: 'https://i.pravatar.cc/150?img=0',
                      ),
                    );
                  }

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user.avatarUrl),
                    ),
                    title: Text(user.name, style: theme.textTheme.titleSmall),
                    subtitle: Text(
                      _getPermissionString(permission),
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: permission == PermissionLevel.owner
                        ? const Chip(
                            label: Text('Owner'),
                            backgroundColor: Colors.amber,
                          )
                        : DropdownButton<PermissionLevel>(
                            value: permission,
                            onChanged: (newValue) {
                              if (newValue != null) {
                                ref
                                    .read(filesRepositoryProvider.notifier)
                                    .updatePermissions(
                                      file.id,
                                      userId,
                                      newValue,
                                    );
                              }
                            },
                            items:
                                [
                                  PermissionLevel.editor,
                                  PermissionLevel.viewer,
                                  PermissionLevel.none,
                                ].map<DropdownMenuItem<PermissionLevel>>((
                                  level,
                                ) {
                                  return DropdownMenuItem<PermissionLevel>(
                                    value: level,
                                    child: Text(_getPermissionString(level)),
                                  );
                                }).toList(),
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _uploadNewVersion(BuildContext context, WidgetRef ref) async {
    final currentUser = ref.read(currentUserProvider);

    // In a real app, this would use FilePicker to get a real file
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    // Show dialog for version notes
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) {
          String notes = '';

          return AlertDialog(
            title: const Text('Add Version Notes'),
            content: TextField(
              decoration: const InputDecoration(
                hintText: 'Describe the changes in this version',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                notes = value;
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  // Add new version
                  final newVersion = FileVersion(
                    id: 'v${file.versions.length + 1}',
                    timestamp: DateTime.now(),
                    author: currentUser,
                    notes: notes.isEmpty ? 'Updated version' : notes,
                  );

                  ref
                      .read(filesRepositoryProvider.notifier)
                      .addVersion(file.id, newVersion);

                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('New version uploaded successfully'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('Upload'),
              ),
            ],
          );
        },
      );
    }
  }

  void _showAddUserDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        String email = '';
        PermissionLevel permissionLevel = PermissionLevel.viewer;

        return AlertDialog(
          title: const Text('Add User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Email or Username',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  email = value;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<PermissionLevel>(
                decoration: const InputDecoration(
                  labelText: 'Permission Level',
                  border: OutlineInputBorder(),
                ),
                value: permissionLevel,
                onChanged: (value) {
                  if (value != null) {
                    permissionLevel = value;
                  }
                },
                items: [PermissionLevel.editor, PermissionLevel.viewer]
                    .map<DropdownMenuItem<PermissionLevel>>((level) {
                      return DropdownMenuItem<PermissionLevel>(
                        value: level,
                        child: Text(_getPermissionString(level)),
                      );
                    })
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                // Mock adding a user - in a real app, we would validate the email and lookup the user
                final newUserId =
                    'user-${DateTime.now().millisecondsSinceEpoch}';

                // For demo purposes, we'll just add Taylor Reid as the new user
                ref
                    .read(filesRepositoryProvider.notifier)
                    .updatePermissions(file.id, 'user-003', permissionLevel);

                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'User added with ${_getPermissionString(permissionLevel)} permission',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

// Utility functions
String _formatDate(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inDays == 0) {
    if (diff.inHours == 0) {
      if (diff.inMinutes == 0) {
        return 'Just now';
      }
      return '${diff.inMinutes}m ago';
    }
    return '${diff.inHours}h ago';
  } else if (diff.inDays < 7) {
    return '${diff.inDays}d ago';
  } else {
    final formatter = DateFormat('MMM d, yyyy');
    return formatter.format(date);
  }
}

String _formatFileSize(int sizeInKB) {
  if (sizeInKB < 1024) {
    return '$sizeInKB KB';
  } else {
    final sizeInMB = (sizeInKB / 1024).toStringAsFixed(1);
    return '$sizeInMB MB';
  }
}

String _getFileTypeString(FileType type) {
  switch (type) {
    case FileType.document:
      return 'Document';
    case FileType.image:
      return 'Image';
    case FileType.pdf:
      return 'PDF';
    case FileType.spreadsheet:
      return 'Spreadsheet';
    case FileType.other:
      return 'File';
  }
}

String _getPermissionString(PermissionLevel level) {
  switch (level) {
    case PermissionLevel.owner:
      return 'Owner';
    case PermissionLevel.editor:
      return 'Can Edit';
    case PermissionLevel.viewer:
      return 'Can View';
    case PermissionLevel.none:
      return 'No Access';
  }
}
