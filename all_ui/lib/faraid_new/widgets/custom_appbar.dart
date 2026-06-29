// components/custom_app_bar.dart
import 'package:flutter/material.dart';

import '../models/family_tree_state.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final FamilyTreeState state;
  final VoidCallback onToggleGrid;
  final VoidCallback onAutoLayout;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final Function(String) onMenuAction;
  final VoidCallback? onExportImage;
  final VoidCallback? onShareData;
  final VoidCallback onToggleTheme;
  final bool isDarkMode;
  final VoidCallback onToggleMahram;
  final bool showMahram;
  const CustomAppBar({
    super.key,
    required this.state,
    required this.onToggleGrid,
    required this.onAutoLayout,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onMenuAction,
    this.onExportImage,
    this.onShareData,
    required this.onToggleTheme,
    required this.isDarkMode,
    required this.onToggleMahram,
    required this.showMahram,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Kalkulator Faraid'),
      elevation: 2,
      actions: [
        IconButton(
          icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
          tooltip: isDarkMode ? 'Light Mode' : 'Dark Mode',
          onPressed: onToggleTheme,
        ),

        IconButton(
          icon: Icon(state.showGrid ? Icons.grid_on : Icons.grid_off),
          tooltip: 'Toggle Grid',
          onPressed: onToggleGrid,
        ),
        IconButton(
          icon: const Icon(Icons.auto_fix_high),
          tooltip: 'Auto Layout',
          onPressed: onAutoLayout,
        ),
        IconButton(
          icon: const Icon(Icons.zoom_in),
          tooltip: 'Zoom In',
          onPressed: onZoomIn,
        ),
        IconButton(
          icon: const Icon(Icons.zoom_out),
          tooltip: 'Zoom Out',
          onPressed: onZoomOut,
        ),
        _buildMenuButton(context),
        IconButton(
          icon: Icon(
            showMahram ? Icons.family_restroom : Icons.family_restroom_outlined,
            color: showMahram ? Colors.purple : null,
          ),
          onPressed: onToggleMahram,
          tooltip: 'Tampilkan/Sembunyikan Hubungan Mahram',
        ),
      ],
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: onMenuAction,
      itemBuilder: (ctx) => _buildMenuItems(ctx),
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems(BuildContext context) {
    return [
      const PopupMenuItem(
        value: 'assets',
        child: ListTile(
          leading: Icon(Icons.inventory),
          title: Text('Assets & Debts'),
          contentPadding: EdgeInsets.zero,
        ),
      ),
      const PopupMenuItem(
        value: 'export_pdf',
        child: ListTile(
          leading: Icon(Icons.picture_as_pdf),
          title: Text('Export to PDF'),
          contentPadding: EdgeInsets.zero,
        ),
      ),
      const PopupMenuItem(
        value: 'export_image',
        child: ListTile(
          leading: Icon(Icons.image),
          title: Text('Export to Image'),
          contentPadding: EdgeInsets.zero,
        ),
      ),
      const PopupMenuItem(
        value: 'share',
        child: ListTile(
          leading: Icon(Icons.share),
          title: Text('Share'),
          contentPadding: EdgeInsets.zero,
        ),
      ),
      const PopupMenuDivider(),
      const PopupMenuItem(
        value: 'export',
        child: ListTile(
          leading: Icon(Icons.upload),
          title: Text('Export Data'),
          contentPadding: EdgeInsets.zero,
        ),
      ),
      const PopupMenuItem(
        value: 'import',
        child: ListTile(
          leading: Icon(Icons.download),
          title: Text('Import Data'),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    ];
  }
}
