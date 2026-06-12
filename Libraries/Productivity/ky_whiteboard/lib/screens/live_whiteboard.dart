import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/provider.dart';
import '../models/whiteboard_painter.dart';
import '../models/_tool_chip.dart';
import '../models/_mobile_tool_button.dart';
import '../models/drawing_tool.dart';
import '../models/whiteboard_state.dart';
import '../models/whiteboard_notifier.dart';

class LiveWhiteboard extends ConsumerStatefulWidget {
  const LiveWhiteboard({super.key});
  @override
  ConsumerState<LiveWhiteboard> createState() => _LiveWhiteboardState();
}

class _LiveWhiteboardState extends ConsumerState<LiveWhiteboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      ref.read(whiteboardProvider.notifier).addUser(user);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(whiteboardProvider);
    final notifier = ref.read(whiteboardProvider.notifier);
    final currentUser = ref.watch(currentUserProvider);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Live Whiteboard',
          style: TextStyle(fontSize: isMobile ? 16 : 18),
        ),
        actions: [
          if (!isMobile) ...[
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () => _showExportOptions(context),
              tooltip: 'Export',
            ),
          ],
          IconButton(
            icon: Icon(
              state.isPalmRejectionEnabled
                  ? Icons.back_hand
                  : Icons.back_hand_outlined,
            ),
            onPressed: notifier.togglePalmRejection,
            tooltip: 'Palm Rejection',
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: notifier.toggleTouchIndicators,
                child: Row(
                  children: [
                    Icon(
                      state.showTouchIndicators
                          ? Icons.touch_app
                          : Icons.touch_app_outlined,
                    ),
                    const SizedBox(width: 8),
                    const Text('Touch Indicators'),
                  ],
                ),
              ),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
                onTap: () => _showSettings(context),
              ),
            ],
          ),
        ],
      ),
      body: GestureDetector(
        onScaleStart: notifier.handlePinchStart,
        onScaleUpdate: notifier.handlePinchUpdate,
        onScaleEnd: notifier.handlePinchEnd,
        child: Column(
          children: [
            if (!isMobile) _buildToolbar(state, notifier),
            Expanded(
              child: Stack(
                children: [
                  Listener(
                    onPointerDown: (event) => _handlePointerDown(
                      event,
                      notifier,
                      currentUser.id,
                      state,
                    ),
                    onPointerMove: (event) => _handlePointerMove(
                      event,
                      notifier,
                      currentUser.id,
                      state,
                    ),
                    onPointerUp: (event) => _handlePointerUp(event, notifier),
                    child: CustomPaint(
                      painter: WhiteboardPainter(
                        paths: state.paths,
                        activeUsers: state.activeUsers,
                        zoom: state.zoom,
                        panOffset: state.panOffset,
                        selectedPathIds: state.selectedPathIds,
                        isGridVisible: state.isGridVisible,
                        images: state.images,
                        selectedImageId: state.selectedImageId,
                        backgroundImage: state.backgroundImage,
                        laserPoints: state.laserPoints,
                        showTouchIndicators: state.showTouchIndicators,
                      ),
                      child: Container(),
                    ),
                  ),
                  if (isMobile)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: _buildMobileToolbar(state, notifier),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isMobile ? _buildMobileFAB(state, notifier) : null,
    );
  }

  void _handlePointerDown(
    PointerDownEvent event,
    WhiteboardNotifier notifier,
    String userId,
    WhiteboardState state,
  ) {
    final transformedPoint = _transformPointToWorldCoordinates(
      event.localPosition,
      state.zoom,
      state.panOffset,
    );

    final pressure = event.kind == PointerDeviceKind.mouse
        ? 0.5
        : event.pressure;
    notifier.startDrawing(transformedPoint, userId, pressure: pressure);
  }

  void _handlePointerMove(
    PointerMoveEvent event,
    WhiteboardNotifier notifier,
    String userId,
    WhiteboardState state,
  ) {
    final transformedPoint = _transformPointToWorldCoordinates(
      event.localPosition,
      state.zoom,
      state.panOffset,
    );

    final pressure = event.kind == PointerDeviceKind.mouse
        ? 0.5
        : event.pressure;
    notifier.updateDrawing(transformedPoint, userId, pressure: pressure);
  }

  void _handlePointerUp(PointerUpEvent event, WhiteboardNotifier notifier) {
    notifier.endDrawing();
  }

  Offset _transformPointToWorldCoordinates(
    Offset localPoint,
    double zoom,
    Offset panOffset,
  ) {
    return (localPoint - panOffset) / zoom;
  }

  // In your toolbar
  Widget _buildToolbar(WhiteboardState state, WhiteboardNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ToolChip(
              icon: Icons.edit,
              label: 'Pen',
              isSelected: state.currentTool == DrawingTool.pen,
              onTap: () => notifier.setTool(DrawingTool.pen),
            ),
            ToolChip(
              icon: Icons.highlight,
              label: 'Highlighter',
              isSelected: state.currentTool == DrawingTool.highlighter,
              onTap: () => notifier.setTool(DrawingTool.highlighter),
            ),
            ToolChip(
              icon: Icons.cleaning_services,
              label: 'Eraser',
              isSelected: state.currentTool == DrawingTool.eraser,
              onTap: () => notifier.setTool(DrawingTool.eraser),
            ),
            ToolChip(
              icon: Icons.near_me,
              label: 'Laser',
              isSelected: state.currentTool == DrawingTool.laser,
              onTap: () => notifier.setTool(DrawingTool.laser),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileToolbar(
    WhiteboardState state,
    WhiteboardNotifier notifier,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          MobileToolButton(
            icon: Icons.edit,
            isSelected: state.currentTool == DrawingTool.pen,
            onTap: () => notifier.setTool(DrawingTool.pen),
          ),
          MobileToolButton(
            icon: Icons.highlight,
            isSelected: state.currentTool == DrawingTool.highlighter,
            onTap: () => notifier.setTool(DrawingTool.highlighter),
          ),
          MobileToolButton(
            icon: Icons.cleaning_services,
            isSelected: state.currentTool == DrawingTool.eraser,
            onTap: () => notifier.setTool(DrawingTool.eraser),
          ),
          MobileToolButton(
            icon: Icons.near_me,
            isSelected: state.currentTool == DrawingTool.laser,
            onTap: () => notifier.setTool(DrawingTool.laser),
          ),
          MobileToolButton(
            icon: Icons.undo,
            isSelected: false,
            onTap: notifier.undo,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileFAB(WhiteboardState state, WhiteboardNotifier notifier) {
    return FloatingActionButton(
      onPressed: () => _showMobileMenu(context, state, notifier),
      child: const Icon(Icons.menu),
    );
  }

  void _showMobileMenu(
    BuildContext context,
    WhiteboardState state,
    WhiteboardNotifier notifier,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('Colors'),
              onTap: () {
                Navigator.pop(context);
                _showColorPicker(context, notifier);
              },
            ),
            ListTile(
              leading: const Icon(Icons.line_weight),
              title: const Text('Stroke Width'),
              onTap: () {
                Navigator.pop(context);
                _showStrokeWidthPicker(context, state, notifier);
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Export'),
              onTap: () {
                Navigator.pop(context);
                _showExportOptions(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                'Clear All',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                notifier.clearBoard();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context, WhiteboardNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Color'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              [
                    Colors.black,
                    const Color(0xFF3B82F6),
                    const Color(0xFF10B981),
                    const Color(0xFFF59E0B),
                    const Color(0xFFEF4444),
                    const Color(0xFF8B5CF6),
                  ]
                  .map(
                    (color) => GestureDetector(
                      onTap: () {
                        notifier.setColor(color);
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey, width: 2),
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }

  void _showStrokeWidthPicker(
    BuildContext context,
    WhiteboardState state,
    WhiteboardNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stroke Width'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Slider(
              value: state.strokeWidth,
              min: 1,
              max: 20,
              divisions: 19,
              label: state.strokeWidth.round().toString(),
              onChanged: notifier.setStrokeWidth,
            ),
            Text('${state.strokeWidth.round()} px'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showExportOptions(BuildContext context) {}
  void _showSettings(BuildContext context) {
    final state = ref.read(whiteboardProvider);
    final notifier = ref.read(whiteboardProvider.notifier);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Palm Rejection'),
              value: state.isPalmRejectionEnabled,
              onChanged: (_) => notifier.togglePalmRejection(),
            ),
            SwitchListTile(
              title: const Text('Touch Indicators'),
              value: state.showTouchIndicators,
              onChanged: (_) => notifier.toggleTouchIndicators(),
            ),
            ListTile(
              title: const Text('Touch Sensitivity'),
              subtitle: Slider(
                value: state.touchSensitivity,
                min: 0.5,
                max: 2.0,
                divisions: 15,
                label: state.touchSensitivity.toStringAsFixed(1),
                onChanged: notifier.setTouchSensitivity,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
