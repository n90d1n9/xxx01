import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/provider.dart';

class ToolbarPanel extends ConsumerWidget {
  const ToolbarPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(designerProvider);
    final notifier = ref.read(designerProvider.notifier);

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: state.isDarkMode ? Colors.grey.shade900 : Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          _buildToolSection('Align', [
            _ToolBtn(Icons.align_horizontal_left, 'Left', notifier.alignLeft),
            _ToolBtn(
              Icons.align_horizontal_center,
              'Center',
              notifier.alignCenter,
            ),
            _ToolBtn(
              Icons.align_horizontal_right,
              'Right',
              notifier.alignRight,
            ),
            _ToolBtn(Icons.align_vertical_top, 'Top', notifier.alignTop),
            _ToolBtn(
              Icons.align_vertical_bottom,
              'Bottom',
              notifier.alignBottom,
            ),
          ]),
          const VerticalDivider(),
          _buildToolSection('Distribute', [
            _ToolBtn(
              Icons.horizontal_distribute,
              'H-Space',
              notifier.distributeHorizontally,
            ),
            _ToolBtn(
              Icons.vertical_distribute,
              'V-Space',
              notifier.distributeVertically,
            ),
          ]),
          const VerticalDivider(),
          _buildToolSection('Order', [
            _ToolBtn(Icons.flip_to_front, 'Front', notifier.bringToFront),
            _ToolBtn(Icons.flip_to_back, 'Back', notifier.sendToBack),
            _ToolBtn(Icons.arrow_upward, 'Up', notifier.bringForward),
            _ToolBtn(Icons.arrow_downward, 'Down', notifier.sendBackward),
          ]),
          const Spacer(),
          _buildZoomControl(ref),
        ],
      ),
    );
  }

  Widget _buildToolSection(String label, List<Widget> tools) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 4),
          Row(children: tools),
        ],
      ),
    );
  }

  Widget _buildZoomControl(WidgetRef ref) {
    final state = ref.watch(designerProvider);
    final notifier = ref.read(designerProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 16),
            onPressed: () => notifier.setZoom(state.canvasZoom - 0.1),
            padding: EdgeInsets.zero,
          ),
          Text(
            '${(state.canvasZoom * 100).toInt()}%',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 16),
            onPressed: () => notifier.setZoom(state.canvasZoom + 0.1),
            padding: EdgeInsets.zero,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 16),
            onPressed: () => notifier.setZoom(1.0),
            padding: EdgeInsets.zero,
            tooltip: 'Reset',
          ),
        ],
      ),
    );
  }
}

class _ToolBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _ToolBtn(this.icon, this.tooltip, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}
