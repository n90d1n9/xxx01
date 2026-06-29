import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/provider.dart';

class StatusBar extends ConsumerWidget {
  const StatusBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(designerProvider);

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: state.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          _buildItem(Icons.design_services, 'Layout: ${state.layoutMode.name}'),
          const VerticalDivider(),

          _buildItem(Icons.layers, '${state.components.length} components'),
          const VerticalDivider(),
          _buildItem(Icons.zoom_in, '${(state.canvasZoom * 100).toInt()}%'),
          const Spacer(),
          if (state.hasUnsavedChanges)
            _buildItem(Icons.circle, 'Unsaved changes', color: Colors.orange),
          const SizedBox(width: 8),
          Text(
            'v2.0.0',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color ?? Colors.grey),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 11, color: color ?? Colors.grey)),
      ],
    );
  }
}
