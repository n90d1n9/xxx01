// lib/widgets/share_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/file_item.dart';

enum SharePermission { viewer, commenter, editor }

class ShareDialog extends ConsumerStatefulWidget {
  final FileItem file;
  const ShareDialog({super.key, required this.file});

  @override
  ConsumerState<ShareDialog> createState() => _ShareDialogState();
}

class _ShareDialogState extends ConsumerState<ShareDialog> {
  final _emailController = TextEditingController();
  SharePermission _selectedPermission = SharePermission.viewer;
  final List<_ShareEntry> _pendingShares = [];
  bool _linkEnabled = false;
  SharePermission _linkPermission = SharePermission.viewer;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Share', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                        Text(widget.file.name,
                          style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Add people
              Text('Add people', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Enter email address...',
                        prefixIcon: const Icon(Icons.person_add_rounded, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _PermissionDropdown(
                    value: _selectedPermission,
                    onChanged: (p) => setState(() => _selectedPermission = p!),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _addPending,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('Add'),
                  ),
                ],
              ),

              // Pending shares
              if (_pendingShares.isNotEmpty) ...[
                const SizedBox(height: 12),
                ..._pendingShares.map((e) => _ShareRow(
                  email: e.email,
                  permission: e.permission,
                  onRemove: () => setState(() => _pendingShares.remove(e)),
                  onPermissionChange: (p) => setState(() => e.permission = p),
                )),
              ],

              // Existing shares
              if (widget.file.sharedWith.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Currently shared with',
                  style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...widget.file.sharedWith.map((email) => _ShareRow(
                  email: email,
                  permission: SharePermission.editor,
                  onRemove: null,
                  onPermissionChange: (_) {},
                )),
              ],

              // Link sharing
              const SizedBox(height: 16),
              Divider(color: colorScheme.outlineVariant.withOpacity(0.4)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.link_rounded, size: 20, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Share via link',
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                        Text(_linkEnabled ? 'Anyone with the link can access' : 'Link sharing is off',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  if (_linkEnabled)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _PermissionDropdown(
                        value: _linkPermission,
                        onChanged: (p) => setState(() => _linkPermission = p!),
                      ),
                    ),
                  Switch(
                    value: _linkEnabled,
                    onChanged: (v) => setState(() => _linkEnabled = v),
                  ),
                ],
              ),
              if (_linkEnabled) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('https://drive.example.com/share/abc123',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant),
                          overflow: TextOverflow.ellipsis),
                      ),
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Link copied to clipboard'),
                            behavior: SnackBarBehavior.floating,
                          ));
                        },
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(_pendingShares.isEmpty
                            ? 'Link settings updated'
                            : 'Shared with ${_pendingShares.length} ${_pendingShares.length == 1 ? 'person' : 'people'}'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ));
                    },
                    child: const Text('Done'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addPending() {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;
    setState(() {
      _pendingShares.add(_ShareEntry(email: email, permission: _selectedPermission));
      _emailController.clear();
    });
  }
}

class _ShareEntry {
  final String email;
  SharePermission permission;
  _ShareEntry({required this.email, required this.permission});
}

class _ShareRow extends StatelessWidget {
  final String email;
  final SharePermission permission;
  final VoidCallback? onRemove;
  final ValueChanged<SharePermission> onPermissionChange;
  const _ShareRow({required this.email, required this.permission,
    required this.onRemove, required this.onPermissionChange});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: colorScheme.primaryContainer,
            child: Text(email[0].toUpperCase(),
              style: TextStyle(fontSize: 12, color: colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(email, style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis),
          ),
          _PermissionDropdown(
            value: permission,
            onChanged: (p) => onPermissionChange(p!),
          ),
          if (onRemove != null)
            IconButton(
              onPressed: onRemove,
              icon: Icon(Icons.close_rounded, size: 16, color: colorScheme.onSurfaceVariant),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}

class _PermissionDropdown extends StatelessWidget {
  final SharePermission value;
  final ValueChanged<SharePermission?> onChanged;
  const _PermissionDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<SharePermission>(
        value: value,
        onChanged: onChanged,
        underline: const SizedBox(),
        isDense: true,
        style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
        items: const [
          DropdownMenuItem(value: SharePermission.viewer, child: Text('Viewer')),
          DropdownMenuItem(value: SharePermission.commenter, child: Text('Commenter')),
          DropdownMenuItem(value: SharePermission.editor, child: Text('Editor')),
        ],
      ),
    );
  }
}
