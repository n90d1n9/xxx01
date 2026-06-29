import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import 'package:flutter_riverpod/legacy.dart';

// State management with Riverpod
final nodeStateProvider = StateNotifierProvider<NodeStateNotifier, NodeState>((
  ref,
) {
  return NodeStateNotifier();
});

class NodeState {
  final bool isDragging;
  final Offset position;
  final List<String> selectedFeatures;

  NodeState({
    this.isDragging = false,
    this.position = Offset.zero,
    this.selectedFeatures = const [],
  });

  NodeState copyWith({
    bool? isDragging,
    Offset? position,
    List<String>? selectedFeatures,
  }) {
    return NodeState(
      isDragging: isDragging ?? this.isDragging,
      position: position ?? this.position,
      selectedFeatures: selectedFeatures ?? this.selectedFeatures,
    );
  }
}

class NodeStateNotifier extends StateNotifier<NodeState> {
  NodeStateNotifier() : super(NodeState());

  void setDragging(bool dragging) {
    state = state.copyWith(isDragging: dragging);
  }

  void setPosition(Offset position) {
    state = state.copyWith(position: position);
  }

  void toggleFeature(String feature) {
    final features = List<String>.from(state.selectedFeatures);
    if (features.contains(feature)) {
      features.remove(feature);
    } else {
      features.add(feature);
    }
    state = state.copyWith(selectedFeatures: features);
  }
}

// Main Node Card Widget
class NodeCard extends ConsumerWidget {
  final String label;
  final List<String> features;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Function(Offset)? onDragUpdate;
  final Function(String)? onInputPortConnected;

  const NodeCard({
    super.key,
    required this.label,
    this.features = const [],
    this.onTap,
    this.onLongPress,
    this.onDragUpdate,
    this.onInputPortConnected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Draggable(
        feedback: Transform.scale(
          scale: 1.05,
          child: Opacity(opacity: 0.8, child: _buildCardContent(context, ref)),
        ),
        childWhenDragging: Opacity(
          opacity: 0.5,
          child: _buildCardContent(context, ref),
        ),
        onDragUpdate: (details) {
          onDragUpdate?.call(details.globalPosition);
        },
        onDragStarted: () {
          ref.read(nodeStateProvider.notifier).setDragging(true);
        },
        onDragEnd: (details) {
          ref.read(nodeStateProvider.notifier).setDragging(false);
        },
        child: _buildCardContent(context, ref),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, WidgetRef ref) {
    return Container(
      width: 266,
      height: 116,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF979797), width: 1),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Label
          Positioned(
            top: 38,
            left: 0,
            right: 0,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
          ),
          // Feature Ports
          Positioned(bottom: 8, left: 56, child: _buildFeaturePorts(ref)),
          // Input Port (Left side)
          const Positioned(left: -8, top: 51, child: InputPort()),
          // Output Port (Right side)
          const Positioned(right: -8, top: 51, child: OutputPort()),
        ],
      ),
    );
  }

  Widget _buildFeaturePorts(WidgetRef ref) {
    final state = ref.watch(nodeStateProvider);

    return Row(
      children: [
        _FeaturePort(
          label: 'Model',
          isSelected: state.selectedFeatures.contains('Model'),
          onTap:
              () => ref.read(nodeStateProvider.notifier).toggleFeature('Model'),
        ),
        const SizedBox(width: 69),
        _FeaturePort(
          label: 'Memory',
          isSelected: state.selectedFeatures.contains('Memory'),
          onTap:
              () =>
                  ref.read(nodeStateProvider.notifier).toggleFeature('Memory'),
        ),
        const SizedBox(width: 84),
        _FeaturePort(
          label: 'Tool',
          isSelected: state.selectedFeatures.contains('Tool'),
          onTap:
              () => ref.read(nodeStateProvider.notifier).toggleFeature('Tool'),
        ),
      ],
    );
  }
}

// Input Port Widget
class InputPort extends StatelessWidget {
  const InputPort({super.key});

  @override
  Widget build(BuildContext context) {
    return DragTarget<ConnectionData>(
      onAccept: (data) {
        // Handle connection from output port
        print('Connection accepted from ${data.sourceId}');
      },
      builder: (context, candidateData, rejectedData) {
        return Transform.rotate(
          angle: math.pi / 4,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: const Color(0xFFD8D8D8),
              border: Border.all(color: const Color(0xFF979797), width: 1),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      },
    );
  }
}

// Output Port Widget
class OutputPort extends StatelessWidget {
  const OutputPort({super.key});

  @override
  Widget build(BuildContext context) {
    return Draggable<ConnectionData>(
      data: const ConnectionData(sourceId: 'output_port'),
      feedback: Transform.rotate(
        angle: math.pi / 2,
        child: Container(
          width: 16,
          height: 16,
          decoration: const BoxDecoration(color: Color(0xFFD8D8D8)),
          child: CustomPaint(painter: _OutputPortPainter()),
        ),
      ),
      child: Transform.rotate(
        angle: math.pi / 2,
        child: Container(
          width: 16,
          height: 16,
          decoration: const BoxDecoration(color: Color(0xFFD8D8D8)),
          child: CustomPaint(painter: _OutputPortPainter()),
        ),
      ),
    );
  }
}

class _OutputPortPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF979797)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    final path =
        Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(size.width, size.height)
          ..lineTo(0, size.height)
          ..close();

    canvas.drawPath(path, paint);

    final fillPaint =
        Paint()
          ..color = const Color(0xFFD8D8D8)
          ..style = PaintingStyle.fill;

    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Feature Port Widget
class _FeaturePort extends ConsumerWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FeaturePort({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? const Color(0xFFA0A0A0)
                      : const Color(0xFFD8D8D8),
              border: Border.all(color: const Color(0xFF979797), width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}

// Data model for connections
class ConnectionData {
  final String sourceId;

  const ConnectionData({required this.sourceId});
}

// Usage example
class NodeCardExample extends ConsumerWidget {
  const NodeCardExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: NodeCard(
          label: 'Agent',
          features: ['Model', 'Memory', 'Tool'],
          onLongPress: () {
            _showContextMenu(context, ref);
          },
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Node'),
              onTap: () {
                Navigator.pop(context);
                // Handle edit action
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Node'),
              onTap: () {
                Navigator.pop(context);
                // Handle delete action
              },
            ),
            ListTile(
              leading: const Icon(Icons.content_copy),
              title: const Text('Duplicate'),
              onTap: () {
                Navigator.pop(context);
                // Handle duplicate action
              },
            ),
          ],
        );
      },
    );
  }
}

// Data models
