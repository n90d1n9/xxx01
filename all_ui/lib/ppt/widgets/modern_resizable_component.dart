import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/component.dart';
import '../models/enums.dart';
import '../models/presentation_component.dart';
import '../states/component_provider.dart';
import '../states/history_provider.dart';
import '../states/presentation_provider.dart';
import 'animated_gradient_container.dart';
import 'simple_chart_widget.dart';
import 'triangle_painter.dart';

class ModernResizableComponent extends ConsumerStatefulWidget {
  final PresentationComponent component;

  const ModernResizableComponent({super.key, required this.component});

  @override
  ConsumerState<ModernResizableComponent> createState() =>
      _ModernResizableComponentState();
}

class _ModernResizableComponentState
    extends ConsumerState<ModernResizableComponent> {
  Offset? dragStart;
  Size? resizeStart;
  Offset? positionStart;
  ResizeHandle? activeHandle;
  double? rotationStart;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _textController.text = widget.component.richText?.text ?? '';
  }

  @override
  void didUpdateWidget(ModernResizableComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.component.richText?.text != widget.component.richText?.text) {
      _textController.text = widget.component.richText?.text ?? '';
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSelected =
        ref.watch(selectedComponentProvider) == widget.component.id;
    final snapToGrid = ref.watch(snapToGridProvider);

    Widget content = _buildComponentContent();

    // Apply visual effects
    if (widget.component.visualEffect != null) {
      content = _applyVisualEffect(content);
    }

    return Positioned(
      left: widget.component.position.dx,
      top: widget.component.position.dy,
      child: Transform.rotate(
        angle: widget.component.rotation * math.pi / 180,
        child: GestureDetector(
          onTap: () {
            ref.read(selectedComponentProvider.notifier).state =
                widget.component.id;
          },
          onDoubleTap: () {
            if (widget.component.type == ComponentType.richText) {
              ref
                  .read(presentationProvider.notifier)
                  .updateComponent(
                    widget.component.id,
                    widget.component.copyWith(isEditing: true),
                  );
              _focusNode.requestFocus();
            }
          },
          onPanStart: (details) {
            if (!isSelected) return;
            dragStart = details.localPosition;
            positionStart = widget.component.position;
          },
          onPanUpdate: (details) {
            if (!isSelected || dragStart == null || positionStart == null)
              return;
            var delta = details.localPosition - dragStart!;
            var newPosition = positionStart! + delta;

            if (snapToGrid) {
              newPosition = Offset(
                (newPosition.dx / 20).round() * 20.0,
                (newPosition.dy / 20).round() * 20.0,
              );
            }

            ref
                .read(presentationProvider.notifier)
                .updateComponent(
                  widget.component.id,
                  widget.component.copyWith(position: newPosition),
                );
          },
          onPanEnd: (_) {
            ref
                .read(historyProvider.notifier)
                .addState(ref.read(presentationProvider));
          },
          child: Opacity(
            opacity: widget.component.opacity,
            child: Container(
              width: widget.component.size.width,
              height: widget.component.size.height,
              decoration: BoxDecoration(
                border:
                    isSelected
                        ? Border.all(color: const Color(0xFF6366F1), width: 2)
                        : widget.component.border != null
                        ? Border.fromBorderSide(widget.component.border!)
                        : null,
                borderRadius: BorderRadius.circular(8),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ]
                        : widget.component.hasGlow
                        ? [
                          BoxShadow(
                            color: (widget.component.glowColor ?? Colors.blue)
                                .withOpacity(0.6),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ]
                        : null,
              ),
              child: Stack(
                children: [
                  content,
                  if (isSelected) ..._buildResizeHandles(),
                  if (isSelected) _buildRotateHandle(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRotateHandle() {
    return Positioned(
      top: -40,
      left: widget.component.size.width / 2 - 15,
      child: GestureDetector(
        onPanStart: (details) {
          rotationStart = widget.component.rotation;
        },
        onPanUpdate: (details) {
          if (rotationStart == null) return;

          final center = Offset(
            widget.component.size.width / 2,
            widget.component.size.height / 2 + 40,
          );

          final angle = math.atan2(
            details.localPosition.dy - center.dy,
            details.localPosition.dx - center.dx,
          );

          final rotation = (angle * 180 / math.pi) + 90;

          ref
              .read(presentationProvider.notifier)
              .updateComponent(
                widget.component.id,
                widget.component.copyWith(rotation: rotation),
              );
        },
        onPanEnd: (_) {
          rotationStart = null;
          ref
              .read(historyProvider.notifier)
              .addState(ref.read(presentationProvider));
        },
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
            ],
          ),
          child: const Icon(Icons.refresh, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  List<Widget> _buildResizeHandles() {
    return [
      _buildHandle(ResizeHandle.topLeft, Alignment.topLeft),
      _buildHandle(ResizeHandle.topRight, Alignment.topRight),
      _buildHandle(ResizeHandle.bottomLeft, Alignment.bottomLeft),
      _buildHandle(ResizeHandle.bottomRight, Alignment.bottomRight),
      _buildHandle(ResizeHandle.top, Alignment.topCenter),
      _buildHandle(ResizeHandle.bottom, Alignment.bottomCenter),
      _buildHandle(ResizeHandle.left, Alignment.centerLeft),
      _buildHandle(ResizeHandle.right, Alignment.centerRight),
    ];
  }

  Widget _buildHandle(ResizeHandle handle, Alignment alignment) {
    return Align(
      alignment: alignment,
      child: GestureDetector(
        onPanStart: (details) {
          activeHandle = handle;
          resizeStart = widget.component.size;
          positionStart = widget.component.position;
        },
        onPanUpdate: (details) {
          if (activeHandle == null ||
              resizeStart == null ||
              positionStart == null)
            return;

          double newWidth = resizeStart!.width;
          double newHeight = resizeStart!.height;
          double newX = positionStart!.dx;
          double newY = positionStart!.dy;

          switch (activeHandle!) {
            case ResizeHandle.topLeft:
              newWidth = math.max(50, resizeStart!.width - details.delta.dx);
              newHeight = math.max(50, resizeStart!.height - details.delta.dy);
              newX = positionStart!.dx + (resizeStart!.width - newWidth);
              newY = positionStart!.dy + (resizeStart!.height - newHeight);
              break;
            case ResizeHandle.topRight:
              newWidth = math.max(50, resizeStart!.width + details.delta.dx);
              newHeight = math.max(50, resizeStart!.height - details.delta.dy);
              newY = positionStart!.dy + (resizeStart!.height - newHeight);
              break;
            case ResizeHandle.bottomLeft:
              newWidth = math.max(50, resizeStart!.width - details.delta.dx);
              newHeight = math.max(50, resizeStart!.height + details.delta.dy);
              newX = positionStart!.dx + (resizeStart!.width - newWidth);
              break;
            case ResizeHandle.bottomRight:
              newWidth = math.max(50, resizeStart!.width + details.delta.dx);
              newHeight = math.max(50, resizeStart!.height + details.delta.dy);
              break;
            case ResizeHandle.top:
              newHeight = math.max(50, resizeStart!.height - details.delta.dy);
              newY = positionStart!.dy + (resizeStart!.height - newHeight);
              break;
            case ResizeHandle.bottom:
              newHeight = math.max(50, resizeStart!.height + details.delta.dy);
              break;
            case ResizeHandle.left:
              newWidth = math.max(50, resizeStart!.width - details.delta.dx);
              newX = positionStart!.dx + (resizeStart!.width - newWidth);
              break;
            case ResizeHandle.right:
              newWidth = math.max(50, resizeStart!.width + details.delta.dx);
              break;
            default:
              break;
          }

          ref
              .read(presentationProvider.notifier)
              .updateComponent(
                widget.component.id,
                widget.component.copyWith(
                  size: Size(newWidth, newHeight),
                  position: Offset(newX, newY),
                ),
              );
        },
        onPanEnd: (_) {
          activeHandle = null;
          resizeStart = null;
          positionStart = null;
          ref
              .read(historyProvider.notifier)
              .addState(ref.read(presentationProvider));
        },
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.5),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _applyVisualEffect(Widget child) {
    switch (widget.component.visualEffect) {
      case VisualEffect.glassmorphism:
        return ClipRRect(
          borderRadius: BorderRadius.circular(
            widget.component.glassStyle?.borderRadius ?? 16,
          ),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(
              sigmaX: widget.component.glassStyle?.blur ?? 10,
              sigmaY: widget.component.glassStyle?.blur ?? 10,
            ),
            child: Container(
              decoration: BoxDecoration(
                color:
                    widget.component.glassStyle?.tintColor.withOpacity(
                      widget.component.glassStyle?.opacity ?? 0.2,
                    ) ??
                    Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(
                  widget.component.glassStyle?.borderRadius ?? 16,
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: child,
            ),
          ),
        );
      case VisualEffect.neumorphism:
        final neumo = widget.component.neumoStyle;
        return Container(
          decoration: BoxDecoration(
            color: neumo?.baseColor ?? Colors.grey[300],
            borderRadius: BorderRadius.circular(neumo?.borderRadius ?? 16),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.7),
                offset: Offset(-(neumo?.depth ?? 10), -(neumo?.depth ?? 10)),
                blurRadius: (neumo?.depth ?? 10) * 2,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: Offset(neumo?.depth ?? 10, neumo?.depth ?? 10),
                blurRadius: (neumo?.depth ?? 10) * 2,
              ),
            ],
          ),
          child: child,
        );
      case VisualEffect.gradient:
        if (widget.component.gradientAnim != null) {
          return AnimatedGradientContainer(
            gradient: widget.component.gradientAnim!,
            child: child,
          );
        }
        return child;
      default:
        return child;
    }
  }

  Widget _buildComponentContent() {
    switch (widget.component.type) {
      case ComponentType.richText:
        if (widget.component.isEditing) {
          return TextField(
            controller: _textController,
            focusNode: _focusNode,
            style: widget.component.richText?.style,
            textAlign: widget.component.richText?.alignment ?? TextAlign.left,
            maxLines: null,
            expands: true,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12),
            ),
            onChanged: (value) {
              final updatedRichText = widget.component.richText?.copyWith(
                text: value,
              );
              ref
                  .read(presentationProvider.notifier)
                  .updateComponent(
                    widget.component.id,
                    widget.component.copyWith(richText: updatedRichText),
                  );
            },
            onSubmitted: (_) {
              ref
                  .read(presentationProvider.notifier)
                  .updateComponent(
                    widget.component.id,
                    widget.component.copyWith(isEditing: false),
                  );
              ref
                  .read(historyProvider.notifier)
                  .addState(ref.read(presentationProvider));
            },
          );
        } else {
          return Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: widget.component.backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.component.richText?.text ?? '',
              style: widget.component.richText?.style,
              textAlign: widget.component.richText?.alignment ?? TextAlign.left,
            ),
          );
        }
      case ComponentType.image:
        return widget.component.imageData != null
            ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                widget.component.imageData!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 48,
                      color: Colors.white30,
                    ),
                  );
                },
              ),
            )
            : const Center(
              child: Icon(Icons.image, size: 48, color: Colors.white30),
            );
      case ComponentType.shape:
        return Container(
          decoration: BoxDecoration(
            color: widget.component.backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      case ComponentType.circle:
        return Container(
          decoration: BoxDecoration(
            color: widget.component.backgroundColor,
            shape: BoxShape.circle,
          ),
        );
      case ComponentType.triangle:
        return CustomPaint(
          painter: TrianglePainter(
            widget.component.backgroundColor ?? Colors.blue,
          ),
        );
      case ComponentType.chart:
        return widget.component.chartData != null
            ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.component.backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SimpleChartWidget(data: widget.component.chartData!),
            )
            : const Center(
              child: Icon(Icons.auto_graph, size: 48, color: Colors.white30),
            );
      case ComponentType.video:
        return Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6366F1).withOpacity(0.8),
                        const Color(0xFF8B5CF6).withOpacity(0.8),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.component.videoUrl ?? 'Video',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        );
      case ComponentType.hotspot:
        return _buildInteractiveContent();
      default:
        return Container(
          decoration: BoxDecoration(
            color: widget.component.backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(Icons.widgets, size: 48, color: Colors.white30),
          ),
        );
    }
  }

  Widget _buildInteractiveContent() {
    final interactive = widget.component.interactive;
    if (interactive == null) return Container();

    switch (interactive.type) {
      case InteractiveType.hotspot:
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF6366F1).withOpacity(0.3),
                const Color(0xFF8B5CF6).withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF6366F1), width: 2),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.ads_click, size: 48, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  interactive.label ?? 'Click Here',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      case InteractiveType.poll:
      case InteractiveType.quiz:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF10B981).withOpacity(0.2),
                const Color(0xFF14B8A6).withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF10B981), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    interactive.type == InteractiveType.poll
                        ? Icons.poll
                        : Icons.quiz,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    interactive.label ??
                        (interactive.type == InteractiveType.poll
                            ? 'Poll'
                            : 'Quiz'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (interactive.options != null)
                ...interactive.options!.map(
                  (option) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      option,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        );
      case InteractiveType.countdown:
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFF59E0B).withOpacity(0.3),
                const Color(0xFFF97316).withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFF59E0B), width: 2),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer, size: 48, color: Colors.white),
                const SizedBox(height: 12),
                Text(
                  interactive.label ?? '60',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'seconds',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
        );
      default:
        return Container();
    }
  }
}
