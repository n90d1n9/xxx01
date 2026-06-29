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
  final VoidCallback? onToggleMahram; // Add this
  final bool showMahram; // Add this

  const ControlPanel({
    super.key,
    required this.state,
    this.onZoomIn,
    this.onZoomOut,
    this.onToggleGrid,
    this.onAutoLayout,
    this.onToggleMahram, // Add this
    this.showMahram = false, // Add this
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      // ← Remove Positioned, just return Column
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMinimap(state),
        const SizedBox(height: 12),
        _buildZoomPanel(context, state),
        const SizedBox(height: 8),
        // Add Mahram toggle button if needed
        if (onToggleMahram != null) ...[
          _buildMahramToggle(context),
          const SizedBox(height: 8),
        ],
      ],
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
              if (onToggleGrid != null)
                IconButton(
                  icon: Icon(
                    state.showGrid ? Icons.grid_on : Icons.grid_off,
                    size: 20,
                  ),
                  onPressed: onToggleGrid,
                  tooltip: 'Toggle Grid',
                ),
              if (onAutoLayout != null)
                IconButton(
                  icon: const Icon(Icons.account_tree, size: 20),
                  onPressed: onAutoLayout,
                  tooltip: 'Auto Layout',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMahramToggle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.family_restroom,
            size: 16,
            color: showMahram ? Colors.purple : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            'Mahram',
            style: TextStyle(
              fontSize: 12,
              color: showMahram ? Colors.purple : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: showMahram,
            onChanged: (_) => onToggleMahram?.call(),
            activeColor: Colors.purple,
          ),
        ],
      ),
    );
  }
}
