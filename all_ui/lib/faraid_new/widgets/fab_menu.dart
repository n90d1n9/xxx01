import 'package:flutter/material.dart';

class FABMenu extends StatelessWidget {
  final bool hasDeceased;
  final VoidCallback onAddChild;
  final VoidCallback onAddSpouse;
  final VoidCallback onAddMember;

  const FABMenu({
    super.key,
    required this.hasDeceased,
    required this.onAddChild,
    required this.onAddSpouse,
    required this.onAddMember,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasDeceased) ...[
            _buildSmallButton(
              icon: Icons.child_care,
              tooltip: 'Tambah Anak',
              onPressed: onAddChild,
              heroTag: 'add_child',
              context: context,
            ),
            const SizedBox(width: 8),
            _buildSmallButton(
              icon: Icons.favorite,
              tooltip: 'Tambah Pasangan',
              onPressed: onAddSpouse,
              heroTag: 'add_spouse',
              context: context,
            ),
            const SizedBox(width: 8),
          ],
          _buildMainButton(
            icon: Icons.add,
            tooltip: 'Tambah Anggota Keluarga',
            onPressed: onAddMember,
            heroTag: 'add_member',
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildSmallButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    required String heroTag,
    required BuildContext context,
  }) {
    return FloatingActionButton.small(
      heroTag: heroTag,
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      child: Icon(icon),
    );
  }

  Widget _buildMainButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    required String heroTag,
    required BuildContext context,
  }) {
    return FloatingActionButton(
      heroTag: heroTag,
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      child: Icon(icon),
    );
  }
}
