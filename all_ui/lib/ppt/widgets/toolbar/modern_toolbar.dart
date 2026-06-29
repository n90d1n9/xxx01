import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../models/chart_data.dart';
import '../../models/component.dart';
import '../../models/enums.dart';
import '../../models/interactive_element.dart';
import '../../models/presentation_component.dart';
import '../../states/component_provider.dart';
import '../../states/history_provider.dart';
import '../../states/presentation_provider.dart';

class ModernToolbar extends ConsumerWidget {
  const ModernToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTool = ref.watch(currentToolProvider);
    final showRuler = ref.watch(rulerVisibilityProvider);
    final showGrid = ref.watch(showGridProvider);

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _ModernToolButton(
            icon: Icons.near_me,
            label: 'Select',
            isSelected: currentTool == ToolMode.select,
            gradient: const LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            ),
            onPressed:
                () =>
                    ref.read(currentToolProvider.notifier).state =
                        ToolMode.select,
          ),
          _ModernToolButton(
            icon: Icons.text_fields,
            label: 'Text',
            isSelected: currentTool == ToolMode.text,
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
            onPressed:
                () =>
                    ref.read(currentToolProvider.notifier).state =
                        ToolMode.text,
          ),
          _ModernToolButton(
            icon: Icons.image,
            label: 'Image',
            isSelected: currentTool == ToolMode.image,
            gradient: const LinearGradient(
              colors: [Color(0xFFEC4899), Color(0xFFF43F5E)],
            ),
            onPressed: () => _addImage(ref, context),
          ),
          _ModernToolButton(
            icon: Icons.auto_graph,
            label: 'Chart',
            isSelected: currentTool == ToolMode.chart,
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
            ),
            onPressed: () => _showChartDialog(context, ref),
          ),
          _ModernToolButton(
            icon: Icons.videocam,
            label: 'Video',
            isSelected: currentTool == ToolMode.video,
            gradient: const LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
            ),
            onPressed: () => _addVideo(ref, context),
          ),
          _ModernToolButton(
            icon: Icons.interests,
            label: 'Interactive',
            isSelected: currentTool == ToolMode.interactive,
            gradient: const LinearGradient(
              colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
            ),
            onPressed: () => _showInteractiveDialog(context, ref),
          ),
          PopupMenuButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.abc, color: Colors.white, size: 20),
            ),
            tooltip: 'Shapes',
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.crop_square),
                        SizedBox(width: 8),
                        Text('Rectangle'),
                      ],
                    ),
                    onTap: () => _addShape(ref, ComponentType.shape),
                  ),
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.circle_outlined),
                        SizedBox(width: 8),
                        Text('Circle'),
                      ],
                    ),
                    onTap: () => _addShape(ref, ComponentType.circle),
                  ),
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.change_history),
                        SizedBox(width: 8),
                        Text('Triangle'),
                      ],
                    ),
                    onTap: () => _addShape(ref, ComponentType.triangle),
                  ),
                ],
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              showRuler ? Icons.straighten : Icons.straighten_outlined,
              color: showRuler ? const Color(0xFF6366F1) : Colors.white54,
            ),
            tooltip: 'Toggle Ruler',
            onPressed: () {
              ref.read(rulerVisibilityProvider.notifier).state = !showRuler;
            },
          ),
          IconButton(
            icon: Icon(
              showGrid ? Icons.grid_on : Icons.grid_off,
              color: showGrid ? const Color(0xFF6366F1) : Colors.white54,
            ),
            tooltip: 'Toggle Grid',
            onPressed: () {
              ref.read(showGridProvider.notifier).state = !showGrid;
            },
          ),
          const VerticalDivider(),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white54),
            tooltip: 'Delete (Del)',
            onPressed: () {
              final selected = ref.read(selectedComponentProvider);
              if (selected != null) {
                ref
                    .read(presentationProvider.notifier)
                    .deleteComponent(selected);
                ref.read(selectedComponentProvider.notifier).state = null;
                ref
                    .read(historyProvider.notifier)
                    .addState(ref.read(presentationProvider));
              }
            },
          ),
        ],
      ),
    );
  }

  void _addShape(WidgetRef ref, ComponentType type) {
    final presentation = ref.read(presentationProvider);
    final component = PresentationComponent(
      id: const Uuid().v4(),
      type: type,
      position: const Offset(300, 300),
      size: const Size(200, 200),
      backgroundColor: presentation.theme.primaryColor,
    );
    ref.read(presentationProvider.notifier).addComponent(component);
    ref.read(selectedComponentProvider.notifier).state = component.id;
    ref.read(historyProvider.notifier).addState(ref.read(presentationProvider));
  }

  Future<void> _addImage(WidgetRef ref, BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final component = PresentationComponent(
          id: const Uuid().v4(),
          type: ComponentType.image,
          position: const Offset(300, 300),
          size: const Size(400, 300),
          imageData: result.files.single.bytes,
        );
        ref.read(presentationProvider.notifier).addComponent(component);
        ref.read(selectedComponentProvider.notifier).state = component.id;
        ref
            .read(historyProvider.notifier)
            .addState(ref.read(presentationProvider));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding image: $e')));
    }
  }

  void _addVideo(WidgetRef ref, BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: const Text(
              'Add Video',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Video URL (YouTube, Vimeo)',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF6366F1)),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onSubmitted: (url) {
                    if (url.isNotEmpty) {
                      final component = PresentationComponent(
                        id: const Uuid().v4(),
                        type: ComponentType.video,
                        position: const Offset(300, 300),
                        size: const Size(640, 360),
                        videoUrl: url,
                        backgroundColor: Colors.black,
                      );
                      ref
                          .read(presentationProvider.notifier)
                          .addComponent(component);
                      ref.read(selectedComponentProvider.notifier).state =
                          component.id;
                      ref
                          .read(historyProvider.notifier)
                          .addState(ref.read(presentationProvider));
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showChartDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: const Text(
              'Insert Chart',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ChartTypeTile(
                  icon: Icons.show_chart,
                  label: 'Line Chart',
                  type: ChartType.line,
                  onTap: () {
                    _addChart(ref, ChartType.line);
                    Navigator.pop(context);
                  },
                ),
                _ChartTypeTile(
                  icon: Icons.bar_chart,
                  label: 'Bar Chart',
                  type: ChartType.bar,
                  onTap: () {
                    _addChart(ref, ChartType.bar);
                    Navigator.pop(context);
                  },
                ),
                _ChartTypeTile(
                  icon: Icons.pie_chart,
                  label: 'Pie Chart',
                  type: ChartType.pie,
                  onTap: () {
                    _addChart(ref, ChartType.pie);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _addChart(WidgetRef ref, ChartType type) {
    final presentation = ref.read(presentationProvider);
    final chartData = ChartData(
      type: type,
      values: [30, 50, 70, 40, 60],
      labels: ['Q1', 'Q2', 'Q3', 'Q4', 'Q5'],
      colors: presentation.theme.colorPalette,
    );

    final component = PresentationComponent(
      id: const Uuid().v4(),
      type: ComponentType.chart,
      position: const Offset(300, 300),
      size: const Size(500, 350),
      chartData: chartData,
      backgroundColor: Colors.white.withOpacity(0.05),
    );
    ref.read(presentationProvider.notifier).addComponent(component);
    ref.read(selectedComponentProvider.notifier).state = component.id;
    ref.read(historyProvider.notifier).addState(ref.read(presentationProvider));
  }

  void _showInteractiveDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: const Text(
              'Interactive Elements',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.ads_click, color: Colors.white70),
                  title: const Text(
                    'Hotspot',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    _addInteractive(ref, InteractiveType.hotspot);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.poll, color: Colors.white70),
                  title: const Text(
                    'Poll',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    _addInteractive(ref, InteractiveType.poll);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.quiz, color: Colors.white70),
                  title: const Text(
                    'Quiz',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    _addInteractive(ref, InteractiveType.quiz);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.timer, color: Colors.white70),
                  title: const Text(
                    'Countdown',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    _addInteractive(ref, InteractiveType.countdown);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _addInteractive(WidgetRef ref, InteractiveType type) {
    final presentation = ref.read(presentationProvider);
    final interactive = InteractiveElement(
      id: const Uuid().v4(),
      type: type,
      label: type == InteractiveType.countdown ? '60' : 'Interactive Element',
      options:
          type == InteractiveType.poll || type == InteractiveType.quiz
              ? ['Option 1', 'Option 2', 'Option 3']
              : null,
      duration: type == InteractiveType.countdown ? 60 : null,
    );

    final component = PresentationComponent(
      id: const Uuid().v4(),
      type: ComponentType.hotspot,
      position: const Offset(300, 300),
      size: const Size(300, 200),
      interactive: interactive,
      backgroundColor: presentation.theme.primaryColor.withOpacity(0.2),
    );
    ref.read(presentationProvider.notifier).addComponent(component);
    ref.read(selectedComponentProvider.notifier).state = component.id;
    ref.read(historyProvider.notifier).addState(ref.read(presentationProvider));
  }
}

class _ModernToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Gradient gradient;
  final VoidCallback onPressed;

  const _ModernToolButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.gradient,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: isSelected ? gradient : null,
              borderRadius: BorderRadius.circular(12),
              border:
                  isSelected
                      ? null
                      : Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected ? Colors.white : Colors.white54,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartTypeTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final ChartType type;
  final VoidCallback onTap;

  const _ChartTypeTile({
    required this.icon,
    required this.label,
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.white54,
      ),
      onTap: onTap,
    );
  }
}
