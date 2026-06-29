import 'package:flutter/material.dart';

class ToolsMenu extends StatelessWidget {
  final VoidCallback onExpressionBuilder;
  final VoidCallback onDataMapper;
  final VoidCallback onCreateSnapshot;
  final VoidCallback onViewSnapshots;
  final VoidCallback onTestingFramework;
  final VoidCallback onGenerateDocs;
  final VoidCallback onCompareRoutes;
  final VoidCallback onShowStats;
  final VoidCallback onShowPlugins;

  const ToolsMenu({
    super.key,
    required this.onExpressionBuilder,
    required this.onDataMapper,
    required this.onCreateSnapshot,
    required this.onViewSnapshots,
    required this.onTestingFramework,
    required this.onGenerateDocs,
    required this.onCompareRoutes,
    required this.onShowStats,
    required this.onShowPlugins,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.build),
      tooltip: 'Tools',
      onSelected: (value) {
        switch (value) {
          case 'expression':
            onExpressionBuilder();
            break;
          case 'mapper':
            onDataMapper();
            break;
          case 'snapshot':
            onCreateSnapshot();
            break;
          case 'snapshots':
            onViewSnapshots();
            break;
          case 'test':
            onTestingFramework();
            break;
          case 'docs':
            onGenerateDocs();
            break;
          case 'compare':
            onCompareRoutes();
            break;
          case 'stats':
            onShowStats();
            break;
          case 'plugins':
            onShowPlugins();
            break;
        }
      },
      itemBuilder: (context) => _buildMenuItems(),
    );
  }

  List<PopupMenuItem<String>> _buildMenuItems() {
    return [
      const PopupMenuItem(
        value: 'expression',
        child: Row(
          children: [
            Icon(Icons.functions),
            SizedBox(width: 8),
            Text('Expression Builder'),
          ],
        ),
      ),
      const PopupMenuItem(
        value: 'mapper',
        child: Row(
          children: [
            Icon(Icons.compare_arrows),
            SizedBox(width: 8),
            Text('Data Mapper'),
          ],
        ),
      ),
      // const PopupMenuDivider(),
      const PopupMenuItem(
        value: 'snapshot',
        child: Row(
          children: [
            Icon(Icons.camera_alt),
            SizedBox(width: 8),
            Text('Create Snapshot'),
          ],
        ),
      ),
      // ... other menu items
    ];
  }
}
