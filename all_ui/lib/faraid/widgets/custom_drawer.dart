// components/custom_drawer.dart
import 'package:flutter/material.dart';

import '../models/family_member.dart';
import '../models/family_tree_state.dart';
import '../models/relation_type.dart';

class CustomDrawer extends StatelessWidget {
  final FamilyTreeState state;
  final VoidCallback onShowAssets;
  final VoidCallback onShowAbout;

  const CustomDrawer({
    super.key,
    required this.state,
    required this.onShowAssets,
    required this.onShowAbout,
  });

  @override
  Widget build(BuildContext context) {
    final heirs = state.members.where((m) => m.faraidShare > 0).toList();
    final deceased =
        state.members
            .where((m) => m.relation == RelationType.deceased)
            .firstOrNull;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(deceased),
          _buildStats(heirs, state),
          const Divider(),
          _buildMenuItems(context),
        ],
      ),
    );
  }

  Widget _buildHeader(FamilyMember? deceased) {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal[700]!, Colors.teal[400]!],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Icon(Icons.account_tree, size: 48, color: Colors.white),
          const SizedBox(height: 12),
          const Text(
            'Keluarga',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (deceased != null)
            Text(
              'Harta dari ${deceased.name}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
        ],
      ),
    );
  }

  Widget _buildStats(List<FamilyMember> heirs, FamilyTreeState state) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.person_outline, color: Colors.teal),
          title: const Text('Total Anggota Keluarga'),
          trailing: Chip(
            label: Text('${state.members.length}'),
            backgroundColor: Colors.teal.withOpacity(0.1),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.people_outline, color: Colors.teal),
          title: const Text('Ahli Waris'),
          trailing: Chip(
            label: Text('${heirs.length}'),
            backgroundColor: Colors.green.withOpacity(0.1),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.account_balance_wallet, color: Colors.teal),
          title: const Text('Bersih Harta'),
          subtitle: Text('\$${state.estate.netEstate.toStringAsFixed(2)}'),
          onTap: onShowAssets,
        ),
      ],
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.inventory, color: Colors.teal),
          title: const Text('Aset Harta & Hutang'),
          onTap: onShowAssets,
        ),
        ListTile(
          leading: const Icon(Icons.info_outline, color: Colors.teal),
          title: const Text('Tentang Faraid'),
          onTap: onShowAbout,
        ),
      ],
    );
  }
}
