// lib/widgets/file_info_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/file_item.dart';
import '../providers/file_provider.dart';
import '../utils/file_utils.dart';
import 'tag_manager_sheet.dart';

class FileInfoPanel extends ConsumerWidget {
  const FileInfoPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final file = ref.watch(infoPanelFileProvider);
    final isOpen = ref.watch(isInfoPanelOpenProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: isOpen ? 300 : 0,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          left: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
        ),
      ),
      child: isOpen && file != null
          ? _PanelContent(file: file)
          : isOpen
              ? _NothingSelected()
              : const SizedBox.shrink(),
    );
  }
}

class _PanelContent extends ConsumerStatefulWidget {
  final FileItem file;
  const _PanelContent({required this.file});

  @override
  ConsumerState<_PanelContent> createState() => _PanelContentState();
}

class _PanelContentState extends ConsumerState<_PanelContent> {
  late TextEditingController _descController;
  bool _editingDesc = false;

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController(text: widget.file.description ?? '');
  }

  @override
  void didUpdateWidget(_PanelContent old) {
    super.didUpdateWidget(old);
    if (old.file.id != widget.file.id) {
      _descController.text = widget.file.description ?? '';
      _editingDesc = false;
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final file = widget.file;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fileColor = FileUtils.getFileColor(file.type);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.4))),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text('File info',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              ),
              IconButton(
                onPressed: () => ref.read(isInfoPanelOpenProvider.notifier).state = false,
                icon: const Icon(Icons.close_rounded, size: 18),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon / thumbnail
                Center(
                  child: Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: fileColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(FileUtils.getFileIcon(file.type), size: 40, color: fileColor),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(file.name,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center),
                ),
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: fileColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(FileUtils.getFileTypeName(file.type),
                      style: TextStyle(color: fileColor, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ),

                // Star / Share quick actions
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _QuickAction(
                      icon: file.isStarred ? Icons.star_rounded : Icons.star_outline_rounded,
                      label: file.isStarred ? 'Starred' : 'Star',
                      color: file.isStarred ? Colors.amber : colorScheme.onSurfaceVariant,
                      onTap: () => ref.read(filesNotifierProvider.notifier).toggleStar(file.id),
                    ),
                    const SizedBox(width: 12),
                    _QuickAction(
                      icon: Icons.share_rounded,
                      label: 'Share',
                      color: colorScheme.onSurfaceVariant,
                      onTap: () {},
                    ),
                    const SizedBox(width: 12),
                    _QuickAction(
                      icon: Icons.download_rounded,
                      label: 'Download',
                      color: colorScheme.onSurfaceVariant,
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                _Divider(),

                // Properties
                _SectionHeader('Properties'),
                _InfoRow('Size', file.displaySize),
                _InfoRow('Owner', file.owner == 'me' ? 'Me' : (file.owner ?? '--')),
                _InfoRow('Modified', FileUtils.formatFullDate(file.dateModified)),
                _InfoRow('Created', FileUtils.formatFullDate(file.dateCreated)),
                if (file.lastOpenedAt != null)
                  _InfoRow('Last opened', FileUtils.formatDate(file.lastOpenedAt!)),
                if (file.isFolder)
                  _InfoRow('Contains', '${file.itemCount} items'),

                if (file.isShared) ...[
                  _Divider(),
                  _SectionHeader('Shared with'),
                  ...file.sharedWith.map((email) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: colorScheme.primaryContainer,
                          child: Text(email[0].toUpperCase(),
                            style: TextStyle(fontSize: 11, color: colorScheme.primary,
                              fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(email,
                            style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  )),
                ],

                _Divider(),
                _SectionHeader('Description'),
                if (_editingDesc) ...[
                  TextField(
                    controller: _descController,
                    maxLines: 3,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Add a description...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.all(10),
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => setState(() => _editingDesc = false),
                        style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () {
                          ref.read(filesNotifierProvider.notifier)
                              .updateDescription(file.id, _descController.text);
                          setState(() => _editingDesc = false);
                        },
                        style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ] else
                  GestureDetector(
                    onTap: () => setState(() => _editingDesc = true),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.4)),
                      ),
                      child: Text(
                        file.description?.isNotEmpty == true
                            ? file.description!
                            : 'Add a description...',
                        style: TextStyle(
                          fontSize: 12,
                          color: file.description?.isNotEmpty == true
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),

                if (file.tags.isNotEmpty) ...[
                  _Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SectionHeader('Tags'),
                      TextButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                            builder: (_) => TagManagerSheet(file: file),
                          );
                        },
                        icon: const Icon(Icons.edit_rounded, size: 13),
                        label: const Text('Edit', style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: file.tags.map((tag) => Chip(
                      label: Text(tag, style: const TextStyle(fontSize: 11)),
                      deleteIcon: const Icon(Icons.close, size: 12),
                      onDeleted: () =>
                          ref.read(filesNotifierProvider.notifier).removeTag(file.id, tag),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    )).toList(),
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label,
    required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _NothingSelected extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline_rounded, size: 40, color: colorScheme.onSurfaceVariant.withOpacity(0.4)),
          const SizedBox(height: 12),
          Text('Select a file\nto see details',
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
            textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(title, style: TextStyle(
      fontWeight: FontWeight.w700, fontSize: 11,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      letterSpacing: 0.8)),
  );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(label, style: TextStyle(
              fontSize: 12, color: colorScheme.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.4)),
  );
}
