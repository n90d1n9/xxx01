offset: const Offset(0, 40),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 16),
          ],
        ),
      ),
      itemBuilder: (context) => items.map((item) => PopupMenuItem(child: item)).toList(),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TOOLBAR
// ============================================================================

class StudioToolbar extends ConsumerWidget {
  const StudioToolbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 56,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: ListView(
        children: [
          const SizedBox(height: 8),
          _buildTool(context, ref, Icons.near_me, StudioTool.select, 'Select (V)'),
          _buildTool(context, ref, Icons.create, StudioTool.pen, 'Pen (P)'),
          const Divider(height: 16),
          _buildTool(context, ref, Icons.rectangle, StudioTool.rectangle, 'Rectangle (R)'),
          _buildTool(context, ref, Icons.circle_outlined, StudioTool.ellipse, 'Ellipse (E)'),
          _buildTool(context, ref, Icons.change_history, StudioTool.polygon, 'Polygon'),
          _buildTool(context, ref, Icons.star_outline, StudioTool.star, 'Star'),
          _buildTool(context, ref, Icons.horizontal_rule, StudioTool.line, 'Line'),
          _buildTool(context, ref, Icons.arrow_forward, StudioTool.arrow, 'Arrow'),
          _buildTool(context, ref, Icons.text_fields, StudioTool.text, 'Text (T)'),
          const Divider(height: 16),
          _buildTool(context, ref, Icons.gradient, StudioTool.gradient, 'Gradient (G)'),
          _buildTool(context, ref, Icons.bubble_chart, StudioTool.particle, 'Particle'),
          _buildTool(context, ref, Icons.accessibility, StudioTool.bone, 'Bone/IK'),
          _buildTool(context, ref, Icons.colorize, StudioTool.eyedropper, 'Eyedropper (I)'),
          const Divider(height: 16),
          _buildTool(context, ref, Icons.pan_tool, StudioTool.hand, 'Hand (H)'),
          _buildTool(context, ref, Icons.zoom_in, StudioTool.zoom, 'Zoom (Z)'),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTool(
    BuildContext context,
    WidgetRef ref,
    IconData icon,
    StudioTool tool,
    String tooltip,
  ) {
    final isSelected = ref.watch(studioStateProvider).currentTool == tool;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => ref.read(studioStateProvider.notifier).setTool(tool),
        child: Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                : null,
            borderRadius: BorderRadius.circular(6),
            border: isSelected
                ? Border.all(color: Theme.of(context).colorScheme.primary)
                : null,
          ),
          child: Icon(
            icon,
            size: 20,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.white70,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// LAYERS PANEL
// ============================================================================

class StudioLayersPanel extends ConsumerWidget {
  const StudioLayersPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studioState = ref.watch(studioStateProvider);

    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Text(
                  'Layers',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: () {
                    final newLayer = Layer(
                      id: 'layer_${DateTime.now().millisecondsSinceEpoch}',
                      name: 'Layer ${studioState.layers.length + 1}',
                      type: LayerType.shape,
                      data: ShapeData(
                        position: const Offset(400, 300),
                        shapeType: ShapeType.rectangle,
                        size: const Size(100, 100),
                        fillColor: Colors.primaries[studioState.layers.length % Colors.primaries.length],
                      ),
                    );
                    ref.read(studioStateProvider.notifier).addLayer(newLayer);
                  },
                  tooltip: 'Add Layer',
                ),
                IconButton(
                  icon: const Icon(Icons.folder, size: 18),
                  onPressed: () {
                    ref.read(studioStateProvider.notifier).groupLayers();
                  },
                  tooltip: 'Group Layers',
                ),
              ],
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              itemCount: studioState.layers.length,
              onReorder: (oldIndex, newIndex) {},
              itemBuilder: (context, index) {
                final layer = studioState.layers[index];
                final isSelected = studioState.selectedLayers.contains(layer);

                return ListTile(
                  key: ValueKey(layer.id),
                  selected: isSelected,
                  selectedTileColor: Colors.blue.withOpacity(0.2),
                  dense: true,
                  leading: Icon(_getLayerIcon(layer.type), size: 16),
                  title: Text(layer.name, style: const TextStyle(fontSize: 12)),
                  subtitle: Text(
                    '${(layer.opacity * 100).toInt()}%',
                    style: const TextStyle(fontSize: 10),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          layer.visible ? Icons.visibility : Icons.visibility_off,
                          size: 14,
                        ),
                        onPressed: () {
                          ref.read(studioStateProvider.notifier).updateLayer(
                                layer.copyWith(visible: !layer.visible),
                              );
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          layer.locked ? Icons.lock : Icons.lock_open,
                          size: 14,
                        ),
                        onPressed: () {
                          ref.read(studioStateProvider.notifier).updateLayer(
                                layer.copyWith(locked: !layer.locked),
                              );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 14),
                        onPressed: () {
                          ref.read(studioStateProvider.notifier).deleteLayer(layer.id);
                        },
                      ),
                    ],
                  ),
                  onTap: () => ref.read(studioStateProvider.notifier).selectLayer(layer),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getLayerIcon(LayerType type) {
    switch (type) {
      case LayerType.shape: return Icons.rectangle;
      case LayerType.path: return Icons.polyline;
      case LayerType.text: return Icons.text_fields;
      case LayerType.group: return Icons.folder;
      case LayerType.particle: return Icons.bubble_chart;
      case LayerType.image: return Icons.image;
    }
  }
}

// ============================================================================
// CANVAS
// ============================================================================

class StudioCanvas extends ConsumerStatefulWidget {
  const StudioCanvas({Key? key}) : super(key: key);

  @override
  ConsumerState<StudioCanvas> createState() => _StudioCanvasState();
}

class _StudioCanvasState extends ConsumerState<StudioCanvas> {
  Offset? _dragStart;
  Offset? _currentDragPosition;

  @override
  Widget build(BuildContext context) {
    final studioState = ref.watch(studioStateProvider);
    final canvasState = ref.watch(canvasProvider);
    final timelineState = ref.watch(timelineProvider);
    final particleState = ref.watch(particleSystemProvider);
    final physicsState = ref.watch(physicsProvider);

    return Container(
      color: const Color(0xFF2D2D30),
      child: GestureDetector(
        onPanStart: _handlePanStart,
        onPanUpdate: _handlePanUpdate,
        onPanEnd: _handlePanEnd,
        onTapDown: _handleTapDown,
        child: CustomPaint(
          painter: CanvasPainter(
            layers: studioState.layers,
            selectedLayers: studioState.selectedLayers,
            showGrid: studioState.showGrid,
            showRulers: studioState.showRulers,
            showGuides: studioState.showGuides,
            gridSize: studioState.gridSize,
            guides: studioState.guides,
            pan: canvasState.pan,
            zoom: canvasState.zoom,
            artboardSize: canvasState.artboardSize,
            canvasColor: studioState.canvasColor,
            currentTime: timelineState.currentTime,
            currentPath: studioState.currentPath,
            particles: particleState.particles,
            physicsBodies: physicsState.bodies,
            showBoundingBox: studioState.showBoundingBox,
            showAnchors: studioState.showAnchors,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }

  void _handlePanStart(DragStartDetails details) {
    _dragStart = details.localPosition;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _currentDragPosition = details.localPosition;
    });

    final tool = ref.read(studioStateProvider).currentTool;
    if (tool == StudioTool.hand) {
      final delta = details.delta;
      final currentPan = ref.read(canvasProvider).pan;
      ref.read(canvasProvider.notifier).setPan(currentPan + delta);
    } else if (tool == StudioTool.select) {
      final selectedLayers = ref.read(studioStateProvider).selectedLayers;
      if (selectedLayers.isNotEmpty && _dragStart != null) {
        final canvasState = ref.read(canvasProvider);
        final delta = (details.localPosition - _dragStart!) / canvasState.zoom;
        
        for (final layer in selectedLayers) {
          if (layer.locked) continue;
          
          if (layer.data is ShapeData) {
            final shapeData = layer.data as ShapeData;
            final newData = shapeData.copyWith(
              position: shapeData.position + delta,
            );
            ref.read(studioStateProvider.notifier).updateLayer(
                  layer.copyWith(data: newData),
                );
          } else if (layer.data is PathData) {
            final pathData = layer.data as PathData;
            final newData = pathData.copyWith(
              position: pathData.position + delta,
            );
            ref.read(studioStateProvider.notifier).updateLayer(
                  layer.copyWith(data: newData),
                );
          } else if (layer.data is TextData) {
            final textData = layer.data as TextData;
            final newData = textData.copyWith(
              position: textData.position + delta,
            );
            ref.read(studioStateProvider.notifier).updateLayer(
                  layer.copyWith(data: newData),
                );
          }
        }
        
        _dragStart = details.localPosition;
      }
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    _dragStart = null;
    _currentDragPosition = null;
  }

  void _handleTapDown(TapDownDetails details) {
    final canvasState = ref.read(canvasProvider);
    final studioState = ref.read(studioStateProvider);
    
    final screenCenter = Offset(context.size!.width / 2, context.size!.height / 2);
    final canvasPos = (details.localPosition - screenCenter - canvasState.pan) / canvasState.zoom +
                      Offset(canvasState.artboardSize.width / 2, canvasState.artboardSize.height / 2);

    // Check if clicked on a layer
    for (final layer in studioState.layers.reversed) {
      if (!layer.visible || layer.locked) continue;
      
      if (layer.data is ShapeData) {
        final shapeData = layer.data as ShapeData;
        final rect = Rect.fromCenter(
          center: shapeData.position,
          width: shapeData.size.width,
          height: shapeData.size.height,
        );
        
        if (rect.contains(canvasPos)) {
          ref.read(studioStateProvider.notifier).selectLayer(layer);
          return;
        }
      }
    }
    
    // If no layer was clicked, handle tool-specific actions
    final tool = studioState.currentTool;
    if (tool == StudioTool.rectangle) {
      _createShape(canvasPos, ShapeType.rectangle);
    } else if (tool == StudioTool.ellipse) {
      _createShape(canvasPos, ShapeType.ellipse);
    } else if (tool == StudioTool.polygon) {
      _createShape(canvasPos, ShapeType.polygon);
    } else if (tool == StudioTool.star) {
      _createShape(canvasPos, ShapeType.star);
    } else if (tool == StudioTool.text) {
      _createText(canvasPos);
    } else if (tool == StudioTool.particle) {
      ref.read(particleSystemProvider.notifier).setEmitterPosition(canvasPos);
      ref.read(particleSystemProvider.notifier).toggleActive();
    }
  }

  void _createShape(Offset position, ShapeType shapeType) {
    final studioState = ref.read(studioStateProvider);
    final newLayer = Layer(
      id: 'layer_${DateTime.now().millisecondsSinceEpoch}',
      name: '${shapeType.name} ${studioState.layers.length + 1}',
      type: LayerType.shape,
      data: ShapeData(
        position: position,
        shapeType: shapeType,
        size: const Size(100, 100),
        fillColor: studioState.currentFillColor,
        strokeColor: studioState.currentStrokeColor,
        strokeWidth: studioState.strokeWidth,
        sides: 5,
      ),
    );
    ref.read(studioStateProvider.notifier).addLayer(newLayer);
    ref.read(studioStateProvider.notifier).selectLayer(newLayer);
  }

  void _createText(Offset position) {
    final studioState = ref.read(studioStateProvider);
    final newLayer = Layer(
      id: 'layer_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Text ${studioState.layers.length + 1}',
      type: LayerType.text,
      data: TextData(
        position: position,
        text: 'Double click to edit',
        fontFamily: studioState.fontFamily,
        fontSize: studioState.fontSize,
        color: studioState.currentFillColor,
      ),
    );
    ref.read(studioStateProvider.notifier).addLayer(newLayer);
    ref.read(studioStateProvider.notifier).selectLayer(newLayer);
  }
}

// ============================================================================
// CANVAS PAINTER - Enhanced with all designer features
// ============================================================================

class CanvasPainter extends CustomPainter {
  final List<Layer> layers;
  final List<Layer> selectedLayers;
  final bool showGrid;
  final bool showRulers;
  final bool showGuides;
  final double gridSize;
  final List<Guide> guides;
  final Offset pan;
  final double zoom;
  final Size artboardSize;
  final Color canvasColor;
  final double currentTime;
  final BezierPathData? currentPath;
  final List<Particle> particles;
  final List<PhysicsBody> physicsBodies;
  final bool showBoundingBox;
  final bool showAnchors;

  CanvasPainter({
    required this.layers,
    required this.selectedLayers,
    required this.showGrid,
    required this.showRulers,
    required this.showGuides,
    required this.gridSize,
    required this.guides,
    required this.pan,
    required this.zoom,
    required this.artboardSize,
    required this.canvasColor,
    required this.currentTime,
    this.currentPath,
    required this.particles,
    required this.physicsBodies,
    required this.showBoundingBox,
    required this.showAnchors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    // Draw rulers if enabled
    if (showRulers) {
      _drawRulers(canvas, size);
    }

    canvas.translate(size.width / 2 + pan.dx, size.height / 2 + pan.dy);
    canvas.scale(zoom);
    canvas.translate(-artboardSize.width / 2, -artboardSize.height / 2);

    // Draw artboard background
    final artboardRect = Rect.fromLTWH(0, 0, artboardSize.width, artboardSize.height);
    canvas.drawRect(
      artboardRect,
      Paint()..color = canvasColor,
    );

    // Draw grid
    if (showGrid) {
      _drawGrid(canvas, artboardRect);
    }

    // Draw guides
    if (showGuides) {
      for (final guide in guides) {
        _drawGuide(canvas, guide, artboardRect);
      }
    }

    // Draw layers with animation
    for (final layer in layers) {
      if (!layer.visible) continue;
      _drawAnimatedLayer(canvas, layer);
    }

    // Draw current bezier path
    if (currentPath != null) {
      _drawBezierPath(canvas, currentPath!);
    }

    // Draw particles
    for (final particle in particles) {
      _drawParticle(canvas, particle);
    }

    // Draw physics bodies
    for (final body in physicsBodies) {
      _drawPhysicsBody(canvas, body);
    }

    // Draw selection
    if (showBoundingBox) {
      for (final layer in selectedLayers) {
        _drawSelection(canvas, layer);
      }
    }

    canvas.restore();
  }

  void _drawRulers(Canvas canvas, Size size) {
    final rulerPaint = Paint()..color = const Color(0xFF2D2D30);
    final rulerSize = 20.0;

    // Horizontal ruler
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, rulerSize),
      rulerPaint,
    );

    // Vertical ruler
    canvas.drawRect(
      Rect.fromLTWH(0, 0, rulerSize, size.height),
      rulerPaint,
    );

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    
    // Draw ruler markings
    for (var i = 0; i < size.width; i += 50) {
      canvas.drawLine(
        Offset(i.toDouble(), rulerSize),
        Offset(i.toDouble(), rulerSize - 5),
        Paint()..color = Colors.white54..strokeWidth = 1,
      );
      
      textPainter.text = TextSpan(
        text: i.toString(),
        style: const TextStyle(color: Colors.white54, fontSize: 8),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(i.toDouble() + 2, 2));
    }

    for (var i = 0; i < size.height; i += 50) {
      canvas.drawLine(
        Offset(rulerSize, i.toDouble()),
        Offset(rulerSize - 5, i.toDouble()),
        Paint()..color = Colors.white54..strokeWidth = 1,
      );
      
      textPainter.text = TextSpan(
        text: i.toString(),
        style: const TextStyle(color: Colors.white54, fontSize: 8),
      );
      textPainter.layout();
      canvas.save();
      canvas.translate(2, i.toDouble() + 2);
      canvas.rotate(-math.pi / 2);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  void _drawGrid(Canvas canvas, Rect bounds) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    for (double x = 0; x <= bounds.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, bounds.height),
        paint,
      );
    }

    for (double y = 0; y <= bounds.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(bounds.width, y),
        paint,
      );
    }
  }

  void _drawGuide(Canvas canvas, Guide guide, Rect bounds) {
    final paint = Paint()
      ..color = Colors.cyan.withOpacity(0.7)
      ..strokeWidth = 1;

    if (guide.type == GuideType.horizontal) {
      canvas.drawLine(
        Offset(0, guide.position),
        Offset(bounds.width, guide.position),
        paint,
      );
    } else {
      canvas.drawLine(
        Offset(guide.position, 0),
        Offset(guide.position, bounds.height),
        paint,
      );
    }
  }

  void _drawAnimatedLayer(Canvas canvas, Layer layer) {
    canvas.save();

    final animatedOpacity = layer.getPropertyAtTime('opacity', currentTime) as double? ?? layer.opacity;
    final animatedPosition = layer.getPropertyAtTime('position', currentTime) as Offset? ?? layer.data.position;
    final animatedRotation = layer.getPropertyAtTime('rotation', currentTime) as double? ?? layer.data.rotation;
    final animatedScale = layer.getPropertyAtTime('scale', currentTime) as Offset? ?? Offset(layer.data.scaleX, layer.data.scaleY);

    canvas.translate(animatedPosition.dx, animatedPosition.dy);
    canvas.rotate(animatedRotation * math.pi / 180);
    canvas.scale(animatedScale.dx, animatedScale.dy);

    if (layer.type == LayerType.shape) {
      _drawShape(canvas, layer, animatedOpacity);
    } else if (layer.type == LayerType.path) {
      _drawPath(canvas, layer, animatedOpacity);
    } else if (layer.type == LayerType.text) {
      _drawText(canvas, layer, animatedOpacity);
    }

    canvas.restore();
  }

  void _drawShape(Canvas canvas, Layer layer, double opacity) {
    final shapeData = layer.data as ShapeData;
    
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: shapeData.size.width,
      height: shapeData.size.height,
    );

    Paint fillPaint;
    if (shapeData.gradient != null) {
      fillPaint = Paint()
        ..shader = shapeData.gradient!.toGradient(rect).createShader(rect)
        ..style = PaintingStyle.fill;
    } else {
      fillPaint = Paint()
        ..color = shapeData.fillColor.withOpacity(opacity)
        ..style = PaintingStyle.fill;
    }

    if (shapeData.shapeType == ShapeType.rectangle) {
      if (shapeData.cornerRadius > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(shapeData.cornerRadius)),
          fillPaint,
        );
      } else {
        canvas.drawRect(rect, fillPaint);
      }
    } else if (shapeData.shapeType == ShapeType.ellipse) {
      canvas.drawOval(rect, fillPaint);
    } else if (shapeData.shapeType == ShapeType.polygon) {
      final path = _createPolygonPath(rect, shapeData.sides);
      canvas.drawPath(path, fillPaint);
    } else if (shapeData.shapeType == ShapeType.star) {
      final path = _createStarPath(rect, shapeData.sides);
      canvas.drawPath(path, fillPaint);
    }

    // Draw stroke
    if (shapeData.strokeColor != null && shapeData.strokeWidth > 0) {
      final strokePaint = Paint()
        ..color = shapeData.strokeColor!.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = shapeData.strokeWidth;

      if (shapeData.shapeType == ShapeType.rectangle) {
        if (shapeData.cornerRadius > 0) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, Radius.circular(shapeData.cornerRadius)),
            strokePaint,
          );
        } else {
          canvas.drawRect(rect, strokePaint);
        }
      } else if (shapeData.shapeType == ShapeType.ellipse) {
        canvas.drawOval(rect, strokePaint);
      } else if (shapeData.shapeType == ShapeType.polygon) {
        final path = _createPolygonPath(rect, shapeData.sides);
        canvas.drawPath(path, strokePaint);
      } else if (shapeData.shapeType == ShapeType.star) {
        final path = _createStarPath(rect, shapeData.sides);
        canvas.drawPath(path, strokePaint);
      }
    }
  }

  Path _createPolygonPath(Rect rect, int sides) {
    final path = Path();
    final center = rect.center;
    final radius = math.min(rect.width, rect.height) / 2;
    
    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * math.pi / sides) - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.close();
    return path;
  }

  Path _createStarPath(Rect rect, int points) {
    final path = Path();
    final center = rect.center;
    final outerRadius = math.min(rect.width, rect.height) / 2;
    final innerRadius = outerRadius * 0.5;
    
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi / points) - math.pi / 2;
      final radius = i.isEven ? outerRadius : innerRadius;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.close();
    return path;
  }

  void _drawPath(Canvas canvas, Layer layer, double opacity) {
    final pathData = layer.data as PathData;
    final path = pathData.toPath();

    final fillPaint = Paint()
      ..color = pathData.fillColor.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, fillPaint);

    if (pathData.strokeColor != null && pathData.strokeWidth > 0) {
      final strokePaint = Paint()
        ..color = pathData.strokeColor!.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = pathData.strokeWidth;

      canvas.drawPath(path, strokePaint);
    }
  }

  void _drawText(Canvas canvas, Layer layer, double opacity) {
    final textData = layer.data as TextData;
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: textData.text,
        style: TextStyle(
          color: textData.color.withOpacity(opacity),
          fontSize: textData.fontSize,
          fontFamily: textData.fontFamily,
          fontWeight: textData.fontWeight,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: textData.textAlign,
    );
    
    textPainter.layout();
    textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.  void addKeyframe(String layerId, String property, double time, dynamic value) {
    _saveUndoState();
    final layer = state.layers.firstWhere((l) => l.id == layerId);
    final newKeyframes = [...layer.keyframes, Keyframe(time: time, property: property, value: value)];
    updateLayer(layer.copyWith(keyframes: newKeyframes));
  }

  void addGradient(GradientDefinition gradient) {
    final newGradients = Map<String, GradientDefinition>.from(state.gradients);
    newGradients[gradient.id] = gradient;
    state = state.copyWith(gradients: newGradients);
  }

  void _saveUndoState() {
    final action = UndoAction(type: 'state', data: state);
    final newUndoStack = [...state.undoStack, action];
    if (newUndoStack.length > 50) newUndoStack.removeAt(0);
    state = state.copyWith(undoStack: newUndoStack, redoStack: []);
  }

  void undo() {
    if (state.undoStack.isEmpty) return;
    final action = state.undoStack.last;
    final newRedoStack = [...state.redoStack, UndoAction(type: 'state', data: state)];
    final newUndoStack = List<UndoAction>.from(state.undoStack)..removeLast();
    state = (action.data as StudioState).copyWith(
      undoStack: newUndoStack,
      redoStack: newRedoStack,
    );
  }

  void redo() {
    if (state.redoStack.isEmpty) return;
    final action = state.redoStack.last;
    final newUndoStack = [...state.undoStack, UndoAction(type: 'state', data: state)];
    final newRedoStack = List<UndoAction>.from(state.redoStack)..removeLast();
    state = (action.data as StudioState).copyWith(
      undoStack: newUndoStack,
      redoStack: newRedoStack,
    );
  }

  Map<String, dynamic> exportToJson() {
    return {
      'version': '1.0.0',
      'duration': 3.0,
      'artboardSize': {'width': 800, 'height': 600},
      'layers': state.layers.map((l) => {
        'id': l.id,
        'name': l.name,
        'type': l.type.toString(),
        'visible': l.visible,
        'opacity': l.opacity,
        'blendMode': l.blendMode.toString(),
        'keyframes': l.keyframes.map((k) => {
          'time': k.time,
          'property': k.property,
          'value': k.value.toString(),
        }).toList(),
      }).toList(),
    };
  }

  String exportToSvg() {
    final buffer = StringBuffer();
    buffer.writeln('<svg width="800" height="600" xmlns="http://www.w3.org/2000/svg">');
    
    for (final layer in state.layers) {
      if (!layer.visible) continue;
      
      if (layer.type == LayerType.shape) {
        final shapeData = layer.data as ShapeData;
        final transform = 'translate(${shapeData.position.dx},${shapeData.position.dy}) rotate(${shapeData.rotation})';
        
        if (shapeData.shapeType == ShapeType.rectangle) {
          buffer.writeln('  <rect x="${-shapeData.size.width/2}" y="${-shapeData.size.height/2}" '
              'width="${shapeData.size.width}" height="${shapeData.size.height}" '
              'fill="${_colorToHex(shapeData.fillColor)}" '
              'stroke="${shapeData.strokeColor != null ? _colorToHex(shapeData.strokeColor!) : 'none'}" '
              'stroke-width="${shapeData.strokeWidth}" '
              'rx="${shapeData.cornerRadius}" '
              'opacity="${layer.opacity}" '
              'transform="$transform" />');
        } else if (shapeData.shapeType == ShapeType.ellipse) {
          buffer.writeln('  <ellipse cx="${shapeData.position.dx}" cy="${shapeData.position.dy}" '
              'rx="${shapeData.size.width/2}" ry="${shapeData.size.height/2}" '
              'fill="${_colorToHex(shapeData.fillColor)}" '
              'stroke="${shapeData.strokeColor != null ? _colorToHex(shapeData.strokeColor!) : 'none'}" '
              'stroke-width="${shapeData.strokeWidth}" '
              'opacity="${layer.opacity}" />');
        }
      }
    }
    
    buffer.writeln('</svg>');
    return buffer.toString();
  }

  String _colorToHex(Color color) {
    return '#${color.red.toRadixString(16).padLeft(2, '0')}'
           '${color.green.toRadixString(16).padLeft(2, '0')}'
           '${color.blue.toRadixString(16).padLeft(2, '0')}';
  }
}

class TimelineNotifier extends StateNotifier<TimelineState> {
  TimelineNotifier() : super(const TimelineState());

  void play() => state = state.copyWith(isPlaying: true);
  void pause() => state = state.copyWith(isPlaying: false);
  void stop() => state = state.copyWith(isPlaying: false, currentTime: 0);
  void seek(double time) => state = state.copyWith(currentTime: time.clamp(0, state.duration));
  void setDuration(double duration) => state = state.copyWith(duration: duration);
  void toggleLoop() => state = state.copyWith(loop: !state.loop);

  void updateTime(double dt) {
    if (!state.isPlaying) return;
    
    var newTime = state.currentTime + dt;
    if (newTime >= state.duration) {
      if (state.loop) {
        newTime = 0;
      } else {
        newTime = state.duration;
        state = state.copyWith(isPlaying: false);
      }
    }
    state = state.copyWith(currentTime: newTime);
  }
}

class CanvasNotifier extends StateNotifier<CanvasState> {
  CanvasNotifier() : super(const CanvasState());

  void setPan(Offset pan) => state = state.copyWith(pan: pan);
  void setZoom(double zoom) => state = state.copyWith(zoom: zoom.clamp(0.1, 10));
  void resetView() => state = state.copyWith(pan: Offset.zero, zoom: 1.0);
  void zoomIn() => setZoom(state.zoom * 1.2);
  void zoomOut() => setZoom(state.zoom / 1.2);
  void fitToScreen() => state = state.copyWith(zoom: 1.0, pan: Offset.zero);
  void updateCamera(CameraSettings camera) => state = state.copyWith(camera: camera);
}

class ParticleSystemNotifier extends StateNotifier<ParticleSystemState> {
  ParticleSystemNotifier() : super(const ParticleSystemState());

  void toggleActive() => state = state.copyWith(active: !state.active);
  void setEmissionRate(double rate) => state = state.copyWith(emissionRate: rate);
  void setParticleSize(double size) => state = state.copyWith(particleSize: size);
  void setParticleColor(Color color) => state = state.copyWith(particleColor: color);
  void setLifeSpan(double lifeSpan) => state = state.copyWith(lifeSpan: lifeSpan);
  void setSpeed(double speed) => state = state.copyWith(speed: speed);
  void setSpread(double spread) => state = state.copyWith(spread: spread);
  void setEmitterPosition(Offset position) => state = state.copyWith(emitterPosition: position);

  void update(double dt) {
    if (!state.active) return;

    final newParticles = List<Particle>.from(state.particles);
    
    final shouldEmit = math.Random().nextDouble() < (state.emissionRate * dt / 60);
    if (shouldEmit) {
      final random = math.Random();
      final angle = random.nextDouble() * state.spread - state.spread / 2;
      final velocity = Offset(
        math.cos(angle) * state.speed,
        math.sin(angle) * state.speed,
      );
      
      newParticles.add(Particle(
        position: state.emitterPosition,
        velocity: velocity,
        color: state.particleColor,
        size: state.particleSize,
        maxLife: state.lifeSpan,
      ));
    }

    newParticles.removeWhere((p) => p.isDead);
    for (var particle in newParticles) {
      particle.update(dt);
    }

    state = state.copyWith(particles: newParticles);
  }
}

class PhysicsNotifier extends StateNotifier<PhysicsState> {
  PhysicsNotifier() : super(const PhysicsState());

  void toggleActive() => state = state.copyWith(active: !state.active);
  void setGravity(double gravity) => state = state.copyWith(gravity: gravity);
  void addBody(PhysicsBody body) => state = state.copyWith(bodies: [...state.bodies, body]);

  void update(double dt) {
    if (!state.active) return;

    final newBodies = List<PhysicsBody>.from(state.bodies);
    
    for (var body in newBodies) {
      body.applyForce(Offset(0, state.gravity * body.mass));
      body.update(dt);

      if (body.position.dy + body.radius > state.bounds.bottom) {
        body.position = Offset(body.position.dx, state.bounds.bottom - body.radius);
        body.velocity = Offset(body.velocity.dx, -body.velocity.dy * body.restitution);
      }

      if (body.position.dx - body.radius < state.bounds.left || 
          body.position.dx + body.radius > state.bounds.right) {
        body.velocity = Offset(-body.velocity.dx * body.restitution, body.velocity.dy);
      }

      if (body.position.dy - body.radius < state.bounds.top) {
        body.position = Offset(body.position.dx, state.bounds.top + body.radius);
        body.velocity = Offset(body.velocity.dx, -body.velocity.dy * body.restitution);
      }
    }

    state = state.copyWith(bodies: newBodies);
  }
}

class GradientEditorNotifier extends StateNotifier<GradientEditorState> {
  GradientEditorNotifier() : super(const GradientEditorState());

  void open(GradientDefinition gradient) {
    state = state.copyWith(isOpen: true, currentGradient: gradient);
  }

  void close() {
    state = state.copyWith(isOpen: false, currentGradient: null, selectedStopIndex: null);
  }

  void selectStop(int index) {
    state = state.copyWith(selectedStopIndex: index);
  }

  void addStop(double offset, Color color) {
    if (state.currentGradient == null) return;
    
    final newStops = [...state.currentGradient!.stops, GradientStop(offset: offset, color: color)];
    newStops.sort((a, b) => a.offset.compareTo(b.offset));
    
    state = state.copyWith(
      currentGradient: state.currentGradient!.copyWith(stops: newStops),
    );
  }

  void updateStop(int index, {double? offset, Color? color}) {
    if (state.currentGradient == null) return;
    
    final newStops = List<GradientStop>.from(state.currentGradient!.stops);
    newStops[index] = newStops[index].copyWith(offset: offset, color: color);
    
    state = state.copyWith(
      currentGradient: state.currentGradient!.copyWith(stops: newStops),
    );
  }

  void removeStop(int index) {
    if (state.currentGradient == null || state.currentGradient!.stops.length <= 2) return;
    
    final newStops = List<GradientStop>.from(state.currentGradient!.stops);
    newStops.removeAt(index);
    
    state = state.copyWith(
      currentGradient: state.currentGradient!.copyWith(stops: newStops),
    );
  }

  void setGradientType(GradientType type) {
    if (state.currentGradient == null) return;
    state = state.copyWith(
      currentGradient: state.currentGradient!.copyWith(type: type),
    );
  }
}

class PathEditorNotifier extends StateNotifier<PathEditorState> {
  PathEditorNotifier() : super(const PathEditorState());

  void activate() => state = state.copyWith(isActive: true);
  void deactivate() => state = state.copyWith(isActive: false, points: [], selectedPointIndex: null);

  void addPoint(PathPoint point) {
    state = state.copyWith(points: [...state.points, point]);
  }

  void updatePoint(int index, PathPoint point) {
    final newPoints = List<PathPoint>.from(state.points);
    newPoints[index] = point;
    state = state.copyWith(points: newPoints);
  }

  void selectPoint(int? index) {
    state = state.copyWith(selectedPointIndex: index);
  }

  void removePoint(int index) {
    if (state.points.length <= 2) return;
    final newPoints = List<PathPoint>.from(state.points);
    newPoints.removeAt(index);
    state = state.copyWith(points: newPoints);
  }
}

class ColorPickerNotifier extends StateNotifier<ColorPickerState> {
  ColorPickerNotifier() : super(const ColorPickerState());

  void open(Color color, String target) {
    state = state.copyWith(isOpen: true, selectedColor: color, target: target);
  }

  void close() {
    state = state.copyWith(isOpen: false);
  }

  void setColor(Color color) {
    state = state.copyWith(selectedColor: color);
  }
}

// ============================================================================
// MAIN UI - HOME PAGE
// ============================================================================

class StudioHomePage extends ConsumerStatefulWidget {
  const StudioHomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<StudioHomePage> createState() => _StudioHomePageState();
}

class _StudioHomePageState extends ConsumerState<StudioHomePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_onTick);
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTick() {
    final dt = 1 / 60;
    ref.read(timelineProvider.notifier).updateTime(dt);
    ref.read(particleSystemProvider.notifier).update(dt);
    ref.read(physicsProvider.notifier).update(dt);
  }

  @override
  Widget build(BuildContext context) {
    final studioState = ref.watch(studioStateProvider);

    return Scaffold(
      body: Column(
        children: [
          const StudioTopBar(),
          if (studioState.currentMode == StudioMode.design) const DesignerToolbar(),
          Expanded(
            child: Row(
              children: [
                const StudioToolbar(),
                const StudioLayersPanel(),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(child: Stack(
                        children: [
                          const StudioCanvas(),
                          if (studioState.currentMode == StudioMode.design)
                            const Positioned(
                              top: 16,
                              right: 16,
                              child: CanvasControls(),
                            ),
                        ],
                      )),
                      const StudioTimeline(),
                    ],
                  ),
                ),
                const StudioPropertiesPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DESIGNER TOOLBAR (Context Actions)
// ============================================================================

class DesignerToolbar extends ConsumerWidget {
  const DesignerToolbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studioState = ref.watch(studioStateProvider);
    final hasSelection = studioState.selectedLayers.isNotEmpty;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          
          // Fill color
          _buildColorButton(
            context,
            'Fill',
            studioState.currentFillColor,
            () {
              ref.read(colorPickerProvider.notifier).open(
                studioState.currentFillColor,
                'fill',
              );
            },
          ),

          const SizedBox(width: 8),

          // Stroke color
          _buildColorButton(
            context,
            'Stroke',
            studioState.currentStrokeColor,
            () {
              ref.read(colorPickerProvider.notifier).open(
                studioState.currentStrokeColor,
                'stroke',
              );
            },
          ),

          const SizedBox(width: 16),
          Container(width: 1, height: 24, color: Colors.white.withOpacity(0.1)),
          const SizedBox(width: 16),

          // Stroke width
          const Text('Stroke:', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            height: 32,
            child: TextField(
              controller: TextEditingController(text: studioState.strokeWidth.toString()),
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                final width = double.tryParse(value) ?? 2;
                ref.read(studioStateProvider.notifier).setStrokeWidth(width);
              },
            ),
          ),

          const SizedBox(width: 16),
          Container(width: 1, height: 24, color: Colors.white.withOpacity(0.1)),
          const SizedBox(width: 16),

          // Align tools
          if (hasSelection) ...[
            IconButton(
              icon: const Icon(Icons.align_horizontal_left, size: 20),
              onPressed: () => ref.read(studioStateProvider.notifier).alignLayers(AlignType.left),
              tooltip: 'Align Left',
            ),
            IconButton(
              icon: const Icon(Icons.align_horizontal_center, size: 20),
              onPressed: () => ref.read(studioStateProvider.notifier).alignLayers(AlignType.centerH),
              tooltip: 'Align Center H',
            ),
            IconButton(
              icon: const Icon(Icons.align_horizontal_right, size: 20),
              onPressed: () => ref.read(studioStateProvider.notifier).alignLayers(AlignType.right),
              tooltip: 'Align Right',
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.align_vertical_top, size: 20),
              onPressed: () => ref.read(studioStateProvider.notifier).alignLayers(AlignType.top),
              tooltip: 'Align Top',
            ),
            IconButton(
              icon: const Icon(Icons.align_vertical_center, size: 20),
              onPressed: () => ref.read(studioStateProvider.notifier).alignLayers(AlignType.centerV),
              tooltip: 'Align Center V',
            ),
            IconButton(
              icon: const Icon(Icons.align_vertical_bottom, size: 20),
              onPressed: () => ref.read(studioStateProvider.notifier).alignLayers(AlignType.bottom),
              tooltip: 'Align Bottom',
            ),

            const SizedBox(width: 16),
            Container(width: 1, height: 24, color: Colors.white.withOpacity(0.1)),
            const SizedBox(width: 16),

            // Distribute tools
            if (studioState.selectedLayers.length >= 3) ...[
              IconButton(
                icon: const Icon(Icons.align_horizontal_center, size: 20),
                onPressed: () => ref.read(studioStateProvider.notifier).distributeLayers(DistributeType.horizontal),
                tooltip: 'Distribute Horizontal',
              ),
              IconButton(
                icon: const Icon(Icons.align_vertical_center, size: 20),
                onPressed: () => ref.read(studioStateProvider.notifier).distributeLayers(DistributeType.vertical),
                tooltip: 'Distribute Vertical',
              ),
            ],
          ],

          const Spacer(),

          // Boolean operations (for future implementation)
          if (hasSelection && studioState.selectedLayers.length >= 2) ...[
            IconButton(
              icon: const Icon(Icons.add_box_outlined, size: 20),
              onPressed: () {},
              tooltip: 'Union',
            ),
            IconButton(
              icon: const Icon(Icons.indeterminate_check_box_outlined, size: 20),
              onPressed: () {},
              tooltip: 'Subtract',
            ),
            IconButton(
              icon: const Icon(Icons.crop_square, size: 20),
              onPressed: () {},
              tooltip: 'Intersect',
            ),
            IconButton(
              icon: const Icon(Icons.flip, size: 20),
              onPressed: () {},
              tooltip: 'Exclude',
            ),
            const SizedBox(width: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildColorButton(BuildContext context, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white30),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: Colors.white30),
              ),
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// CANVAS CONTROLS (Zoom, Grid, etc.)
// ============================================================================

class CanvasControls extends ConsumerWidget {
  const CanvasControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studioState = ref.watch(studioStateProvider);
    final canvasState = ref.watch(canvasProvider);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.zoom_in, size: 20),
            onPressed: () => ref.read(canvasProvider.notifier).zoomIn(),
            tooltip: 'Zoom In',
          ),
          Text(
            '${(canvasState.zoom * 100).toInt()}%',
            style: const TextStyle(fontSize: 11),
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out, size: 20),
            onPressed: () => ref.read(canvasProvider.notifier).zoomOut(),
            tooltip: 'Zoom Out',
          ),
          const Divider(height: 8),
          IconButton(
            icon: Icon(
              studioState.showGrid ? Icons.grid_on : Icons.grid_off,
              size: 20,
            ),
            onPressed: () => ref.read(studioStateProvider.notifier).toggleGrid(),
            tooltip: 'Toggle Grid',
          ),
          IconButton(
            icon: Icon(
              studioState.showRulers ? Icons.straighten : Icons.straighten_outlined,
              size: 20,
            ),
            onPressed: () => ref.read(studioStateProvider.notifier).toggleRulers(),
            tooltip: 'Toggle Rulers',
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TOP BAR
// ============================================================================

class StudioTopBar extends ConsumerWidget {
  const StudioTopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studioState = ref.watch(studioStateProvider);

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.animation, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'Animation Studio Pro',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          Container(width: 1, height: 24, color: Colors.white.withOpacity(0.1)),
          const SizedBox(width: 8),

          _buildMenuButton(context, ref, 'File', [
            _buildMenuItem(Icons.add, 'New Project', () {}),
            _buildMenuItem(Icons.folder_open, 'Open', () {}),
            _buildMenuItem(Icons.save, 'Save', () {}),
            _buildMenuItem(Icons.download, 'Export JSON', () {
              final json = ref.read(studioStateProvider.notifier).exportToJson();
              debugPrint('JSON: ${jsonEncode(json)}');
            }),
            _buildMenuItem(Icons.code, 'Export SVG', () {
              final svg = ref.read(studioStateProvider.notifier).exportToSvg();
              debugPrint('SVG:\n$svg');
            }),
          ]),

          _buildMenuButton(context, ref, 'Edit', [
            _buildMenuItem(Icons.undo, 'Undo (Ctrl+Z)', () {
              ref.read(studioStateProvider.notifier).undo();
            }),
            _buildMenuItem(Icons.redo, 'Redo (Ctrl+Shift+Z)', () {
              ref.read(studioStateProvider.notifier).redo();
            }),
            _buildMenuItem(Icons.content_copy, 'Copy (Ctrl+C)', () {
              ref.read(studioStateProvider.notifier).copySelectedLayers();
            }),
            _buildMenuItem(Icons.content_paste, 'Paste (Ctrl+V)', () {
              ref.read(studioStateProvider.notifier).pasteLayer();
            }),
            _buildMenuItem(Icons.file_copy, 'Duplicate (Ctrl+D)', () {
              ref.read(studioStateProvider.notifier).duplicateSelectedLayers();
            }),
          ]),

          _buildMenuButton(context, ref, 'View', [
            _buildMenuItem(
              Icons.grid_on,
              'Toggle Grid',
              () => ref.read(studioStateProvider.notifier).toggleGrid(),
            ),
            _buildMenuItem(
              Icons.straighten,
              'Toggle Rulers',
              () => ref.read(studioStateProvider.notifier).toggleRulers(),
            ),
            _buildMenuItem(Icons.zoom_in, 'Zoom In', () {
              ref.read(canvasProvider.notifier).zoomIn();
            }),
            _buildMenuItem(Icons.zoom_out, 'Zoom Out', () {
              ref.read(canvasProvider.notifier).zoomOut();
            }),
            _buildMenuItem(Icons.fit_screen, 'Fit to Screen', () {
              ref.read(canvasProvider.notifier).fitToScreen();
            }),
          ]),

          const Spacer(),

          SegmentedButton<StudioMode>(
            segments: const [
              ButtonSegment(
                value: StudioMode.design,
                icon: Icon(Icons.design_services, size: 16),
                label: Text('Design', style: TextStyle(fontSize: 12)),
              ),
              ButtonSegment(
                value: StudioMode.animate,
                icon: Icon(Icons.animation, size: 16),
                label: Text('Animate', style: TextStyle(fontSize: 12)),
              ),
              ButtonSegment(
                value: StudioMode.preview,
                icon: Icon(Icons.play_circle, size: 16),
                label: Text('Preview', style: TextStyle(fontSize: 12)),
              ),
              ButtonSegment(
                value: StudioMode.export,
                icon: Icon(Icons.download, size: 16),
                label: Text('Export', style: TextStyle(fontSize: 12)),
              ),
            ],
            selected: {studioState.currentMode},
            onSelectionChanged: (Set<StudioMode> selection) {
              ref.read(studioStateProvider.notifier).setMode(selection.first);
            },
          ),

          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    WidgetRef ref,
    String label,
    List<Widget> items,
  ) {
    return PopupMenuButton(
      offset: const Offset(0, 40),class GradientEditorState {
  final bool isOpen;
  final GradientDefinition? currentGradient;
  final int? selectedStopIndex;

  const GradientEditorState({
    this.isOpen = false,
    this.currentGradient,
    this.selectedStopIndex,
  });

  GradientEditorState copyWith({
    bool? isOpen,
    GradientDefinition? currentGradient,
    int? selectedStopIndex,
  }) {
    return GradientEditorState(
      isOpen: isOpen ?? this.isOpen,
      currentGradient: currentGradient ?? this.currentGradient,
      selectedStopIndex: selectedStopIndex ?? this.selectedStopIndex,
    );
  }
}

class PathEditorState {
  final bool isActive;
  final List<PathPoint> points;
  final int? selectedPointIndex;
  final PathPoint? draggedPoint;

  const PathEditorState({
    this.isActive = false,
    this.points = const [],
    this.selectedPointIndex,
    this.draggedPoint,
  });

  PathEditorState copyWith({
    bool? isActive,
    List<PathPoint>? points,
    int? selectedPointIndex,
    PathPoint? draggedPoint,
  }) {
    return PathEditorState(
      isActive: isActive ?? this.isActive,
      points: points ?? this.points,
      selectedPointIndex: selectedPointIndex ?? this.selectedPointIndex,
      draggedPoint: draggedPoint ?? this.draggedPoint,
    );
  }
}

class ColorPickerState {
  final bool isOpen;
  final Color selectedColor;
  final String target; // 'fill' or 'stroke'

  const ColorPickerState({
    this.isOpen = false,
    this.selectedColor = Colors.blue,
    this.target = 'fill',
  });

  ColorPickerState copyWith({
    bool? isOpen,
    Color? selectedColor,
    String? target,
  }) {
    return ColorPickerState(
      isOpen: isOpen ?? this.isOpen,
      selectedColor: selectedColor ?? this.selectedColor,
      target: target ?? this.target,
    );
  }
}

class Layer {
  final String id;
  final String name;
  final LayerType type;
  final bool visible;
  final bool locked;
  final double opacity;
  final List<Keyframe> keyframes;
  final LayerData data;
  final Transform3D? transform3D;
  final BlendMode blendMode;
  final List<LayerEffect> effects;

  Layer({
    required this.id,
    required this.name,
    required this.type,
    this.visible = true,
    this.locked = false,
    this.opacity = 1.0,
    this.keyframes = const [],
    required this.data,
    this.transform3D,
    this.blendMode = BlendMode.srcOver,
    this.effects = const [],
  });

  Layer copyWith({
    String? name,
    bool? visible,
    bool? locked,
    double? opacity,
    List<Keyframe>? keyframes,
    LayerData? data,
    Transform3D? transform3D,
    BlendMode? blendMode,
    List<LayerEffect>? effects,
  }) {
    return Layer(
      id: id,
      name: name ?? this.name,
      type: type,
      visible: visible ?? this.visible,
      locked: locked ?? this.locked,
      opacity: opacity ?? this.opacity,
      keyframes: keyframes ?? this.keyframes,
      data: data ?? this.data,
      transform3D: transform3D ?? this.transform3D,
      blendMode: blendMode ?? this.blendMode,
      effects: effects ?? this.effects,
    );
  }

  dynamic getPropertyAtTime(String property, double time) {
    final propertyKeyframes = keyframes.where((k) => k.property == property).toList();
    if (propertyKeyframes.isEmpty) return _getDefaultPropertyValue(property);
    if (propertyKeyframes.length == 1) return propertyKeyframes.first.value;

    Keyframe? before, after;
    for (var i = 0; i < propertyKeyframes.length - 1; i++) {
      if (time >= propertyKeyframes[i].time && time <= propertyKeyframes[i + 1].time) {
        before = propertyKeyframes[i];
        after = propertyKeyframes[i + 1];
        break;
      }
    }

    if (before == null || after == null) return propertyKeyframes.last.value;

    final t = (time - before.time) / (after.time - before.time);
    return _interpolateValue(before.value, after.value, t, before.curve);
  }

  dynamic _getDefaultPropertyValue(String property) {
    switch (property) {
      case 'opacity': return opacity;
      case 'position': return data.position;
      case 'rotation': return data.rotation;
      case 'scale': return Offset(data.scaleX, data.scaleY);
      default: return null;
    }
  }

  dynamic _interpolateValue(dynamic a, dynamic b, double t, Curve curve) {
    final curvedT = curve.transform(t);
    if (a is num && b is num) {
      return a + (b - a) * curvedT;
    } else if (a is Offset && b is Offset) {
      return Offset.lerp(a, b, curvedT);
    } else if (a is Color && b is Color) {
      return Color.lerp(a, b, curvedT);
    }
    return t < 0.5 ? a : b;
  }
}

enum LayerType {
  shape,
  path,
  text,
  group,
  particle,
  image,
}

enum LayerEffect {
  dropShadow,
  innerShadow,
  blur,
  glow,
}

abstract class LayerData {
  Offset get position;
  double get rotation;
  double get scaleX;
  double get scaleY;
}

class ShapeData implements LayerData {
  @override
  final Offset position;
  @override
  final double rotation;
  @override
  final double scaleX;
  @override
  final double scaleY;
  final ShapeType shapeType;
  final Size size;
  final Color fillColor;
  final Color? strokeColor;
  final double strokeWidth;
  final double cornerRadius;
  final GradientDefinition? gradient;
  final int sides; // For polygon/star

  ShapeData({
    required this.position,
    this.rotation = 0,
    this.scaleX = 1,
    this.scaleY = 1,
    required this.shapeType,
    required this.size,
    required this.fillColor,
    this.strokeColor,
    this.strokeWidth = 0,
    this.cornerRadius = 0,
    this.gradient,
    this.sides = 5,
  });

  ShapeData copyWith({
    Offset? position,
    double? rotation,
    double? scaleX,
    double? scaleY,
    Size? size,
    Color? fillColor,
    Color? strokeColor,
    double? strokeWidth,
    double? cornerRadius,
    GradientDefinition? gradient,
    int? sides,
  }) {
    return ShapeData(
      position: position ?? this.position,
      rotation: rotation ?? this.rotation,
      scaleX: scaleX ?? this.scaleX,
      scaleY: scaleY ?? this.scaleY,
      shapeType: shapeType,
      size: size ?? this.size,
      fillColor: fillColor ?? this.fillColor,
      strokeColor: strokeColor ?? this.strokeColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      gradient: gradient ?? this.gradient,
      sides: sides ?? this.sides,
    );
  }
}

enum ShapeType {
  rectangle,
  ellipse,
  polygon,
  star,
  line,
  arrow,
}

class PathData implements LayerData {
  @override
  final Offset position;
  @override
  final double rotation;
  @override
  final double scaleX;
  @override
  final double scaleY;
  final List<PathPoint> points;
  final Color fillColor;
  final Color? strokeColor;
  final double strokeWidth;
  final bool closed;

  PathData({
    required this.position,
    this.rotation = 0,
    this.scaleX = 1,
    this.scaleY = 1,
    required this.points,
    required this.fillColor,
    this.strokeColor,
    this.strokeWidth = 2,
    this.closed = false,
  });

  PathData copyWith({
    Offset? position,
    double? rotation,
    double? scaleX,
    double? scaleY,
    List<PathPoint>? points,
    Color? fillColor,
    Color? strokeColor,
    double? strokeWidth,
    bool? closed,
  }) {
    return PathData(
      position: position ?? this.position,
      rotation: rotation ?? this.rotation,
      scaleX: scaleX ?? this.scaleX,
      scaleY: scaleY ?? this.scaleY,
      points: points ?? this.points,
      fillColor: fillColor ?? this.fillColor,
      strokeColor: strokeColor ?? this.strokeColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      closed: closed ?? this.closed,
    );
  }

  Path toPath() {
    if (points.isEmpty) return Path();
    final path = Path();
    path.moveTo(points[0].position.dx, points[0].position.dy);

    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final current = points[i];

      if (prev.handleOut != null && current.handleIn != null) {
        final cp1 = prev.position + prev.handleOut!;
        final cp2 = current.position + current.handleIn!;
        path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, current.position.dx, current.position.dy);
      } else {
        path.lineTo(current.position.dx, current.position.dy);
      }
    }

    if (closed) path.close();
    return path;
  }
}

class TextData implements LayerData {
  @override
  final Offset position;
  @override
  final double rotation;
  @override
  final double scaleX;
  @override
  final double scaleY;
  final String text;
  final String fontFamily;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final TextAlign textAlign;

  TextData({
    required this.position,
    this.rotation = 0,
    this.scaleX = 1,
    this.scaleY = 1,
    required this.text,
    this.fontFamily = 'Roboto',
    this.fontSize = 24,
    this.fontWeight = FontWeight.normal,
    required this.color,
    this.textAlign = TextAlign.left,
  });

  TextData copyWith({
    Offset? position,
    double? rotation,
    double? scaleX,
    double? scaleY,
    String? text,
    String? fontFamily,
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    TextAlign? textAlign,
  }) {
    return TextData(
      position: position ?? this.position,
      rotation: rotation ?? this.rotation,
      scaleX: scaleX ?? this.scaleX,
      scaleY: scaleY ?? this.scaleY,
      text: text ?? this.text,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      color: color ?? this.color,
      textAlign: textAlign ?? this.textAlign,
    );
  }
}

class PathPoint {
  final Offset position;
  final Offset? handleIn;
  final Offset? handleOut;
  final PointType type;

  PathPoint({
    required this.position,
    this.handleIn,
    this.handleOut,
    this.type = PointType.smooth,
  });

  PathPoint copyWith({
    Offset? position,
    Offset? handleIn,
    Offset? handleOut,
    PointType? type,
  }) {
    return PathPoint(
      position: position ?? this.position,
      handleIn: handleIn ?? this.handleIn,
      handleOut: handleOut ?? this.handleOut,
      type: type ?? this.type,
    );
  }
}

enum PointType {
  corner,
  smooth,
  symmetric,
}

class BezierPathData {
  final List<PathPoint> points;
  final bool closed;

  BezierPathData({
    required this.points,
    this.closed = false,
  });

  Path toPath() {
    if (points.isEmpty) return Path();
    final path = Path();
    path.moveTo(points[0].position.dx, points[0].position.dy);

    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final current = points[i];

      if (prev.handleOut != null && current.handleIn != null) {
        final cp1 = prev.position + prev.handleOut!;
        final cp2 = current.position + current.handleIn!;
        path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, current.position.dx, current.position.dy);
      } else {
        path.lineTo(current.position.dx, current.position.dy);
      }
    }

    if (closed) path.close();
    return path;
  }
}

class Keyframe {
  final double time;
  final String property;
  final dynamic value;
  final Curve curve;

  Keyframe({
    required this.time,
    required this.property,
    required this.value,
    this.curve = Curves.linear,
  });
}

class Transform3D {
  final double rotateX;
  final double rotateY;
  final double rotateZ;
  final double translateZ;

  const Transform3D({
    this.rotateX = 0,
    this.rotateY = 0,
    this.rotateZ = 0,
    this.translateZ = 0,
  });

  Transform3D copyWith({
    double? rotateX,
    double? rotateY,
    double? rotateZ,
    double? translateZ,
  }) {
    return Transform3D(
      rotateX: rotateX ?? this.rotateX,
      rotateY: rotateY ?? this.rotateY,
      rotateZ: rotateZ ?? this.rotateZ,
      translateZ: translateZ ?? this.translateZ,
    );
  }
}

class GradientDefinition {
  final String id;
  final GradientType type;
  final List<GradientStop> stops;
  final Offset start;
  final Offset end;

  GradientDefinition({
    required this.id,
    required this.type,
    required this.stops,
    this.start = Offset.zero,
    this.end = const Offset(1, 1),
  });

  GradientDefinition copyWith({
    List<GradientStop>? stops,
    GradientType? type,
    Offset? start,
    Offset? end,
  }) {
    return GradientDefinition(
      id: id,
      type: type ?? this.type,
      stops: stops ?? this.stops,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }

  Gradient toGradient(Rect bounds) {
    final colors = stops.map((s) => s.color).toList();
    final offsets = stops.map((s) => s.offset).toList();

    switch (type) {
      case GradientType.linear:
        return LinearGradient(
          begin: Alignment(start.dx * 2 - 1, start.dy * 2 - 1),
          end: Alignment(end.dx * 2 - 1, end.dy * 2 - 1),
          colors: colors,
          stops: offsets,
        );
      case GradientType.radial:
        return RadialGradient(colors: colors, stops: offsets);
      case GradientType.sweep:
        return SweepGradient(colors: colors, stops: offsets);
    }
  }
}

enum GradientType { linear, radial, sweep }

class GradientStop {
  final double offset;
  final Color color;

  GradientStop({required this.offset, required this.color});

  GradientStop copyWith({double? offset, Color? color}) {
    return GradientStop(
      offset: offset ?? this.offset,
      color: color ?? this.color,
    );
  }
}

class Guide {
  final GuideType type;
  final double position;

  Guide({required this.type, required this.position});
}

enum GuideType { horizontal, vertical }

class Particle {
  Offset position;
  Offset velocity;
  final Color color;
  final double size;
  double life;
  final double maxLife;

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.maxLife,
  }) : life = maxLife;

  bool get isDead => life <= 0;

  void update(double dt) {
    position += velocity * dt;
    velocity += const Offset(0, 200) * dt;
    life -= dt;
  }
}

class PhysicsBody {
  Offset position;
  Offset velocity;
  final double mass;
  final double restitution;
  final double radius;
  Offset acceleration;

  PhysicsBody({
    required this.position,
    this.velocity = Offset.zero,
    this.mass = 1.0,
    this.restitution = 0.8,
    this.radius = 20,
    this.acceleration = Offset.zero,
  });

  void update(double dt) {
    velocity += acceleration * dt;
    position += velocity * dt;
    acceleration = Offset.zero;
  }

  void applyForce(Offset force) {
    acceleration += force / mass;
  }
}

class BoneData {
  final String id;
  final String name;
  Offset position;
  double rotation;
  final double length;
  BoneData? parent;

  BoneData({
    required this.id,
    required this.name,
    required this.position,
    this.rotation = 0,
    required this.length,
    this.parent,
  });

  Offset get endPosition {
    return position + Offset(
      math.cos(rotation * math.pi / 180) * length,
      math.sin(rotation * math.pi / 180) * length,
    );
  }
}

class UndoAction {
  final String type;
  final dynamic data;

  UndoAction({required this.type, required this.data});
}

// ============================================================================
// STATE NOTIFIERS
// ============================================================================

class StudioStateNotifier extends StateNotifier<StudioState> {
  StudioStateNotifier() : super(const StudioState()) {
    _initializeDemo();
  }

  void _initializeDemo() {
    final demoLayers = [
      Layer(
        id: 'layer_1',
        name: 'Rectangle',
        type: LayerType.shape,
        data: ShapeData(
          position: const Offset(200, 150),
          shapeType: ShapeType.rectangle,
          size: const Size(150, 100),
          fillColor: Colors.blue,
          strokeColor: Colors.white,
          strokeWidth: 2,
          cornerRadius: 10,
        ),
        keyframes: [
          Keyframe(time: 0, property: 'position', value: const Offset(200, 150)),
          Keyframe(time: 2, property: 'position', value: const Offset(500, 150), curve: Curves.easeInOut),
        ],
      ),
      Layer(
        id: 'layer_2',
        name: 'Circle',
        type: LayerType.shape,
        data: ShapeData(
          position: const Offset(450, 200),
          shapeType: ShapeType.ellipse,
          size: const Size(120, 120),
          fillColor: Colors.purple,
          strokeColor: Colors.white,
          strokeWidth: 2,
        ),
        keyframes: [
          Keyframe(time: 0, property: 'scale', value: const Offset(1, 1)),
          Keyframe(time: 1.5, property: 'scale', value: const Offset(1.5, 1.5), curve: Curves.elasticOut),
        ],
      ),
    ];

    state = state.copyWith(layers: demoLayers);
  }

  void addLayer(Layer layer) {
    _saveUndoState();
    state = state.copyWith(layers: [...state.layers, layer]);
  }

  void updateLayer(Layer layer) {
    _saveUndoState();
    final index = state.layers.indexWhere((l) => l.id == layer.id);
    if (index != -1) {
      final newLayers = List<Layer>.from(state.layers);
      newLayers[index] = layer;
      state = state.copyWith(layers: newLayers);
    }
  }

  void deleteLayer(String id) {
    _saveUndoState();
    state = state.copyWith(
      layers: state.layers.where((l) => l.id != id).toList(),
      selectedLayers: state.selectedLayers.where((l) => l.id != id).toList(),
    );
  }

  void selectLayer(Layer? layer, {bool multi = false}) {
    if (layer == null) {
      state = state.copyWith(selectedLayers: []);
      return;
    }

    if (multi) {
      if (state.selectedLayers.contains(layer)) {
        state = state.copyWith(
          selectedLayers: state.selectedLayers.where((l) => l != layer).toList(),
        );
      } else {
        state = state.copyWith(selectedLayers: [...state.selectedLayers, layer]);
      }
    } else {
      state = state.copyWith(selectedLayers: [layer]);
    }
  }

  void setTool(StudioTool tool) {
    state = state.copyWith(currentTool: tool);
  }

  void setMode(StudioMode mode) {
    state = state.copyWith(currentMode: mode);
  }

  void toggleGrid() {
    state = state.copyWith(showGrid: !state.showGrid);
  }

  void toggleSnapToGrid() {
    state = state.copyWith(snapToGrid: !state.snapToGrid);
  }

  void toggleRulers() {
    state = state.copyWith(showRulers: !state.showRulers);
  }

  void toggleGuides() {
    state = state.copyWith(showGuides: !state.showGuides);
  }

  void addGuide(Guide guide) {
    state = state.copyWith(guides: [...state.guides, guide]);
  }

  void setCurrentFillColor(Color color) {
    state = state.copyWith(currentFillColor: color);
  }

  void setCurrentStrokeColor(Color color) {
    state = state.copyWith(currentStrokeColor: color);
  }

  void setStrokeWidth(double width) {
    state = state.copyWith(strokeWidth: width);
  }

  void alignLayers(AlignType type) {
    if (state.selectedLayers.isEmpty) return;
    _saveUndoState();

    final bounds = _getSelectionBounds();
    if (bounds == null) return;

    final newLayers = List<Layer>.from(state.layers);
    
    for (final layer in state.selectedLayers) {
      final index = newLayers.indexWhere((l) => l.id == layer.id);
      if (index == -1) continue;

      final data = layer.data;
      Offset newPosition;

      switch (type) {
        case AlignType.left:
          newPosition = Offset(bounds.left, data.position.dy);
          break;
        case AlignType.centerH:
          newPosition = Offset(bounds.center.dx, data.position.dy);
          break;
        case AlignType.right:
          newPosition = Offset(bounds.right, data.position.dy);
          break;
        case AlignType.top:
          newPosition = Offset(data.position.dx, bounds.top);
          break;
        case AlignType.centerV:
          newPosition = Offset(data.position.dx, bounds.center.dy);
          break;
        case AlignType.bottom:
          newPosition = Offset(data.position.dx, bounds.bottom);
          break;
      }

      if (data is ShapeData) {
        newLayers[index] = layer.copyWith(data: data.copyWith(position: newPosition));
      } else if (data is PathData) {
        newLayers[index] = layer.copyWith(data: data.copyWith(position: newPosition));
      } else if (data is TextData) {
        newLayers[index] = layer.copyWith(data: data.copyWith(position: newPosition));
      }
    }

    state = state.copyWith(layers: newLayers);
  }

  Rect? _getSelectionBounds() {
    if (state.selectedLayers.isEmpty) return null;
    
    double left = double.infinity;
    double top = double.infinity;
    double right = double.negativeInfinity;
    double bottom = double.negativeInfinity;

    for (final layer in state.selectedLayers) {
      final pos = layer.data.position;
      if (layer.data is ShapeData) {
        final size = (layer.data as ShapeData).size;
        left = math.min(left, pos.dx - size.width / 2);
        top = math.min(top, pos.dy - size.height / 2);
        right = math.max(right, pos.dx + size.width / 2);
        bottom = math.max(bottom, pos.dy + size.height / 2);
      }
    }

    return Rect.fromLTRB(left, top, right, bottom);
  }

  void distributeLayers(DistributeType type) {
    if (state.selectedLayers.length < 3) return;
    _saveUndoState();

    final sorted = List<Layer>.from(state.selectedLayers);
    if (type == DistributeType.horizontal) {
      sorted.sort((a, b) => a.data.position.dx.compareTo(b.data.position.dx));
    } else {
      sorted.sort((a, b) => a.data.position.dy.compareTo(b.data.position.dy));
    }

    final first = sorted.first.data.position;
    final last = sorted.last.data.position;
    final totalDistance = type == DistributeType.horizontal
        ? last.dx - first.dx
        : last.dy - first.dy;
    final spacing = totalDistance / (sorted.length - 1);

    final newLayers = List<Layer>.from(state.layers);

    for (var i = 1; i < sorted.length - 1; i++) {
      final layer = sorted[i];
      final index = newLayers.indexWhere((l) => l.id == layer.id);
      if (index == -1) continue;

      final data = layer.data;
      final newPosition = type == DistributeType.horizontal
          ? Offset(first.dx + spacing * i, data.position.dy)
          : Offset(data.position.dx, first.dy + spacing * i);

      if (data is ShapeData) {
        newLayers[index] = layer.copyWith(data: data.copyWith(position: newPosition));
      } else if (data is PathData) {
        newLayers[index] = layer.copyWith(data: data.copyWith(position: newPosition));
      } else if (data is TextData) {
        newLayers[index] = layer.copyWith(data: data.copyWith(position: newPosition));
      }
    }

    state = state.copyWith(layers: newLayers);
  }

  void groupLayers() {
    if (state.selectedLayers.length < 2) return;
    _saveUndoState();
    // Group implementation would go here
  }

  void ungroupLayers() {
    // Ungroup implementation would go here
  }

  void duplicateSelectedLayers() {
    if (state.selectedLayers.isEmpty) return;
    _saveUndoState();

    final newLayers = <Layer>[];
    for (final layer in state.selectedLayers) {
      final newId = 'layer_${DateTime.now().millisecondsSinceEpoch}_${newLayers.length}';
      var newData = layer.data;
      
      if (newData is ShapeData) {
        newData = newData.copyWith(position: newData.position + const Offset(20, 20));
      } else if (newData is PathData) {
        newData = newData.copyWith(position: newData.position + const Offset(20, 20));
      } else if (newData is TextData) {
        newData = newData.copyWith(position: newData.position + const Offset(20, 20));
      }

      newLayers.add(Layer(
        id: newId,
        name: '${layer.name} Copy',
        type: layer.type,
        visible: layer.visible,
        locked: false,
        opacity: layer.opacity,
        data: newData,
      ));
    }

    state = state.copyWith(layers: [...state.layers, ...newLayers]);
  }

  void copySelectedLayers() {
    if (state.selectedLayers.isEmpty) return;
    state = state.copyWith(clipboard: state.selectedLayers.first);
  }

  void pasteLayer() {
    if (state.clipboard == null) return;
    _saveUndoState();

    final layer = state.clipboard!;
    final newId = 'layer_${DateTime.now().millisecondsSinceEpoch}';
    var newData = layer.data;
    
    if (newData is ShapeData) {
      newData = newData.copyWith(position: newData.position + const Offset(20, 20));
    } else if (newData is PathData) {
      newData = newData.copyWith(position: newData.position + const Offset(20, 20));
    } else if (newData is TextData) {
      newData = newData.copyWith(position: newData.position + const Offset(20, 20));
    }

    final newLayer = Layer(
      id: newId,
      name: '${layer.name} Copy',
      type: layer.type,
      visible: layer.visible,
      locked: false,
      opacity: layer.opacity,
      data: newData,
    );

    state = state.copyWith(layers: [...state.layers, newLayer]);
  }

  void addKeyframe(String layerId, String property, double time, dynamicimport 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:convert';

// ============================================================================
// COMPLETE PROFESSIONAL SVG ANIMATION STUDIO
// Full Designer View with All Features
// ============================================================================

void main() {
  runApp(const ProviderScope(child: AnimationStudioApp()));
}

class AnimationStudioApp extends StatelessWidget {
  const AnimationStudioApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animation Studio Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        colorScheme: ColorScheme.dark(
          primary: Colors.blue[400]!,
          secondary: Colors.purple[400]!,
          surface: const Color(0xFF252526),
          background: const Color(0xFF1E1E1E),
        ),
      ),
      home: const StudioHomePage(),
    );
  }
}

// ============================================================================
// STATE MANAGEMENT
// ============================================================================

final studioStateProvider = StateNotifierProvider<StudioStateNotifier, StudioState>((ref) {
  return StudioStateNotifier();
});

final timelineProvider = StateNotifierProvider<TimelineNotifier, TimelineState>((ref) {
  return TimelineNotifier();
});

final canvasProvider = StateNotifierProvider<CanvasNotifier, CanvasState>((ref) {
  return CanvasNotifier();
});

final particleSystemProvider = StateNotifierProvider<ParticleSystemNotifier, ParticleSystemState>((ref) {
  return ParticleSystemNotifier();
});

final physicsProvider = StateNotifierProvider<PhysicsNotifier, PhysicsState>((ref) {
  return PhysicsNotifier();
});

final gradientEditorProvider = StateNotifierProvider<GradientEditorNotifier, GradientEditorState>((ref) {
  return GradientEditorNotifier();
});

final pathEditorProvider = StateNotifierProvider<PathEditorNotifier, PathEditorState>((ref) {
  return PathEditorNotifier();
});

final colorPickerProvider = StateNotifierProvider<ColorPickerNotifier, ColorPickerState>((ref) {
  return ColorPickerNotifier();
});

// ============================================================================
// DATA MODELS
// ============================================================================

enum StudioTool {
  select,
  pen,
  rectangle,
  ellipse,
  polygon,
  star,
  text,
  gradient,
  particle,
  bone,
  eyedropper,
  hand,
  zoom,
  line,
  arrow,
}

enum StudioMode {
  design,
  animate,
  preview,
  export,
}

enum AlignType {
  left,
  centerH,
  right,
  top,
  centerV,
  bottom,
}

enum DistributeType {
  horizontal,
  vertical,
}

class StudioState {
  final List<Layer> layers;
  final List<Layer> selectedLayers;
  final StudioTool currentTool;
  final StudioMode currentMode;
  final Map<String, GradientDefinition> gradients;
  final bool showGrid;
  final bool snapToGrid;
  final bool showRulers;
  final bool showGuides;
  final double gridSize;
  final Color canvasColor;
  final List<Guide> guides;
  final BezierPathData? currentPath;
  final List<BoneData> skeleton;
  final List<UndoAction> undoStack;
  final List<UndoAction> redoStack;
  final Layer? clipboard;
  final bool showBoundingBox;
  final bool showAnchors;
  final double strokeWidth;
  final Color currentFillColor;
  final Color currentStrokeColor;
  final String fontFamily;
  final double fontSize;

  const StudioState({
    this.layers = const [],
    this.selectedLayers = const [],
    this.currentTool = StudioTool.select,
    this.currentMode = StudioMode.design,
    this.gradients = const {},
    this.showGrid = true,
    this.snapToGrid = true,
    this.showRulers = true,
    this.showGuides = true,
    this.gridSize = 20,
    this.canvasColor = Colors.white,
    this.guides = const [],
    this.currentPath,
    this.skeleton = const [],
    this.undoStack = const [],
    this.redoStack = const [],
    this.clipboard,
    this.showBoundingBox = true,
    this.showAnchors = true,
    this.strokeWidth = 2,
    this.currentFillColor = Colors.blue,
    this.currentStrokeColor = Colors.black,
    this.fontFamily = 'Roboto',
    this.fontSize = 24,
  });

  StudioState copyWith({
    List<Layer>? layers,
    List<Layer>? selectedLayers,
    StudioTool? currentTool,
    StudioMode? currentMode,
    Map<String, GradientDefinition>? gradients,
    bool? showGrid,
    bool? snapToGrid,
    bool? showRulers,
    bool? showGuides,
    double? gridSize,
    Color? canvasColor,
    List<Guide>? guides,
    BezierPathData? currentPath,
    List<BoneData>? skeleton,
    List<UndoAction>? undoStack,
    List<UndoAction>? redoStack,
    Layer? clipboard,
    bool? showBoundingBox,
    bool? showAnchors,
    double? strokeWidth,
    Color? currentFillColor,
    Color? currentStrokeColor,
    String? fontFamily,
    double? fontSize,
  }) {
    return StudioState(
      layers: layers ?? this.layers,
      selectedLayers: selectedLayers ?? this.selectedLayers,
      currentTool: currentTool ?? this.currentTool,
      currentMode: currentMode ?? this.currentMode,
      gradients: gradients ?? this.gradients,
      showGrid: showGrid ?? this.showGrid,
      snapToGrid: snapToGrid ?? this.snapToGrid,
      showRulers: showRulers ?? this.showRulers,
      showGuides: showGuides ?? this.showGuides,
      gridSize: gridSize ?? this.gridSize,
      canvasColor: canvasColor ?? this.canvasColor,
      guides: guides ?? this.guides,
      currentPath: currentPath ?? this.currentPath,
      skeleton: skeleton ?? this.skeleton,
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
      clipboard: clipboard ?? this.clipboard,
      showBoundingBox: showBoundingBox ?? this.showBoundingBox,
      showAnchors: showAnchors ?? this.showAnchors,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      currentFillColor: currentFillColor ?? this.currentFillColor,
      currentStrokeColor: currentStrokeColor ?? this.currentStrokeColor,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
    );
  }

  Layer? get selectedLayer => selectedLayers.isEmpty ? null : selectedLayers.first;
}

class TimelineState {
  final double currentTime;
  final double duration;
  final bool isPlaying;
  final double fps;
  final bool loop;

  const TimelineState({
    this.currentTime = 0,
    this.duration = 3,
    this.isPlaying = false,
    this.fps = 60,
    this.loop = false,
  });

  TimelineState copyWith({
    double? currentTime,
    double? duration,
    bool? isPlaying,
    double? fps,
    bool? loop,
  }) {
    return TimelineState(
      currentTime: currentTime ?? this.currentTime,
      duration: duration ?? this.duration,
      isPlaying: isPlaying ?? this.isPlaying,
      fps: fps ?? this.fps,
      loop: loop ?? this.loop,
    );
  }
}

class CanvasState {
  final Offset pan;
  final double zoom;
  final Size artboardSize;
  final CameraSettings camera;

  const CanvasState({
    this.pan = Offset.zero,
    this.zoom = 1.0,
    this.artboardSize = const Size(800, 600),
    this.camera = const CameraSettings(),
  });

  CanvasState copyWith({
    Offset? pan,
    double? zoom,
    Size? artboardSize,
    CameraSettings? camera,
  }) {
    return CanvasState(
      pan: pan ?? this.pan,
      zoom: zoom ?? this.zoom,
      artboardSize: artboardSize ?? this.artboardSize,
      camera: camera ?? this.camera,
    );
  }
}

class CameraSettings {
  final double distance;
  final double pitch;
  final double yaw;
  final double fov;

  const CameraSettings({
    this.distance = 1000,
    this.pitch = 0,
    this.yaw = 0,
    this.fov = 60,
  });

  CameraSettings copyWith({
    double? distance,
    double? pitch,
    double? yaw,
    double? fov,
  }) {
    return CameraSettings(
      distance: distance ?? this.distance,
      pitch: pitch ?? this.pitch,
      yaw: yaw ?? this.yaw,
      fov: fov ?? this.fov,
    );
  }
}

class ParticleSystemState {
  final bool active;
  final double emissionRate;
  final double particleSize;
  final Color particleColor;
  final double lifeSpan;
  final double speed;
  final double spread;
  final Offset emitterPosition;
  final List<Particle> particles;

  const ParticleSystemState({
    this.active = false,
    this.emissionRate = 20,
    this.particleSize = 5,
    this.particleColor = Colors.yellow,
    this.lifeSpan = 2,
    this.speed = 100,
    this.spread = math.pi * 2,
    this.emitterPosition = const Offset(400, 300),
    this.particles = const [],
  });

  ParticleSystemState copyWith({
    bool? active,
    double? emissionRate,
    double? particleSize,
    Color? particleColor,
    double? lifeSpan,
    double? speed,
    double? spread,
    Offset? emitterPosition,
    List<Particle>? particles,
  }) {
    return ParticleSystemState(
      active: active ?? this.active,
      emissionRate: emissionRate ?? this.emissionRate,
      particleSize: particleSize ?? this.particleSize,
      particleColor: particleColor ?? this.particleColor,
      lifeSpan: lifeSpan ?? this.lifeSpan,
      speed: speed ?? this.speed,
      spread: spread ?? this.spread,
      emitterPosition: emitterPosition ?? this.emitterPosition,
      particles: particles ?? this.particles,
    );
  }
}

class PhysicsState {
  final bool active;
  final double gravity;
  final List<PhysicsBody> bodies;
  final Rect bounds;

  const PhysicsState({
    this.active = false,
    this.gravity = 980,
    this.bodies = const [],
    this.bounds = const Rect.fromLTWH(0, 0, 800, 600),
  });

  PhysicsState copyWith({
    bool? active,
    double? gravity,
    List<PhysicsBody>? bodies,
    Rect? bounds,
  }) {
    return PhysicsState(
      active: active ?? this.active,
      gravity: gravity ?? this.gravity,
      bodies: bodies ?? this.bodies,
      bounds: bounds ?? this.bounds,
    );
  }
}

class GradientEditorState {
  final bool isOpen;
  final GradientDefinition? currentGradient;
  final int