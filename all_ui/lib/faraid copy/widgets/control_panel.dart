// components/control_panel.dart
import 'package:flutter/material.dart';

import '../models/family_tree_state.dart';
import 'minimap_painter.dart';

class ControlPanel extends StatelessWidget {
  final FamilyTreeState state;
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final VoidCallback? onToggleGrid;
  final VoidCallback? onAutoLayout;

  const ControlPanel({
    super.key,
    required this.state,
    this.onZoomIn,
    this.onZoomOut,
    this.onToggleGrid,
    this.onAutoLayout,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      right: 16,
      child: Column(
        children: [
          _buildMinimap(state),
          const SizedBox(height: 12),
          _buildZoomPanel(context, state),
        ],
      ),
    );
  }

  Widget _buildMinimap(FamilyTreeState state) {
    return Container(
      width: 150,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CustomPaint(
          painter: MinimapPainter(state.members, state.selectedMemberId),
        ),
      ),
    );
  }

  Widget _buildZoomPanel(BuildContext context, FamilyTreeState state) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Zoom: ${(state.scale * 100).toStringAsFixed(0)}%',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            '${state.members.length} Anggota',
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.zoom_in, size: 20),
                onPressed: onZoomIn,
                tooltip: 'Zoom In',
              ),
              IconButton(
                icon: const Icon(Icons.zoom_out, size: 20),
                onPressed: onZoomOut,
                tooltip: 'Zoom Out',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
