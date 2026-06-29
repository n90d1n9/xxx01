import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/auth_states/auth_notifier.dart';
import '../../../features/auth_states/auth_state.dart';
import '../../../state/wayang_providers.dart';
import '../../preview_dialog.dart';

class Header extends ConsumerWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final wayangState = ref.watch(wayangProvider);
    return Positioned(
      right: 20,
      top: 20,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        height: 60,
        width: 800,
        // color: Theme.of(context).primaryColor,
        child: Row(
          children: [
            _buildFileMenu(context),
            _buildEditMenu(context),
            _buildViewMenu(context),
            _buildHelpMenu(context),
            ElevatedButton.icon(
              icon: const Icon(Icons.visibility),
              label: const Text('Preview'),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => PreviewDialog(),
                );
              },
            ),
            Spacer(),
            _buildAccountMenu(ref, authState),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountMenu(WidgetRef ref, AuthenticationState authState) {
    return PopupMenuButton(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                authState.user!.imageUrl ??
                    'https://ui-avatars.com/api/?rounded=true',
              ),
              radius: 16,
            ),
            const SizedBox(width: 8),
            Text(authState.username ?? 'Guest'),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          child: const Text('Profile'),
          onTap: () => context.go('/profile'),
        ),
        PopupMenuItem(
          child: Text(authState.isAuthenticated ? 'Sign Out' : 'Sign In'),
          onTap: () {
            if (authState.isAuthenticated) {
              ref.read(authProvider.notifier).signOut();
            } else {
              // Show sign in dialog
            }
          },
        ),
      ],
    );
  }

  Widget _buildFileMenu(BuildContext context) {
    return PopupMenuButton(
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text('File'),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(child: Text('New File')),
        const PopupMenuItem(child: Text('Open File')),
        const PopupMenuItem(child: Text('New Window')),
        const PopupMenuItem(child: Text('Export')),
        const PopupMenuItem(child: Text('Import')),
        const PopupMenuItem(child: Text('Open Folder')),
        const PopupMenuItem(child: Text('Save')),
        const PopupMenuItem(child: Text('Save All')),
        const PopupMenuItem(child: Text('Rename')),
        const PopupMenuItem(child: Text('Close')),
        const PopupMenuItem(child: Text('Close Window')),
        PopupMenuItem(
          child: const Text('Settings'),
          onTap: () => context.go('/settings'),
        ),
      ],
    );
  }

  Widget _buildEditMenu(BuildContext context) {
    return PopupMenuButton(
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text('Edit'),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(child: Text('Undo')),
        const PopupMenuItem(child: Text('Redo')),
        const PopupMenuItem(child: Text('Copy')),
        const PopupMenuItem(child: Text('Paste')),
        const PopupMenuItem(child: Text('Find')),
        const PopupMenuItem(child: Text('Replace')),
      ],
    );
  }

  Widget _buildViewMenu(BuildContext context) {
    return PopupMenuButton(
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text('View'),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(child: Text('Zoom In')),
        const PopupMenuItem(child: Text('Zoom Out')),
        const PopupMenuItem(child: Text('Fit Screen')),
      ],
    );
  }

  Widget _buildHelpMenu(BuildContext context) {
    return PopupMenuButton(
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text('Help'),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(child: Text('About')),
        const PopupMenuItem(child: Text('Update')),
        const PopupMenuItem(child: Text('Privacy Statement')),
        const PopupMenuItem(child: Text('View License')),
        const PopupMenuItem(child: Text('Tips and Tricks')),
        const PopupMenuItem(child: Text('Tutorial')),
        const PopupMenuItem(child: Text('Help')),
      ],
    );
  }
}
