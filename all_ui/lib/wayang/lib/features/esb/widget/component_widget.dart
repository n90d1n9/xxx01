import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/component_type.dart';
import '../model/integration_component.dart';
import '../states/current_route_notifier.dart';

class ComponentWidget extends StatefulWidget {
  final IntegrationComponent component;
  final bool isSelected;
  final Function(Offset) onPositionChanged;
  final Function(bool) onTap;
  final VoidCallback onConnectStart;
  final Function(String) onConnectEnd;
  final Function(Offset) onConnectDrag;

  const ComponentWidget({
    super.key,
    required this.component,
    required this.isSelected,
    required this.onPositionChanged,
    required this.onTap,
    required this.onConnectStart,
    required this.onConnectEnd,
    required this.onConnectDrag,
  });

  @override
  State<ComponentWidget> createState() => _ComponentWidgetState();
}

class _ComponentWidgetState extends State<ComponentWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.component.position.dx,
      top: widget.component.position.dy,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: () {
            widget.onTap(HardwareKeyboard.instance.isControlPressed);
          },
          onPanUpdate: (details) {
            widget.onPositionChanged(widget.component.position + details.delta);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 180,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.component.enabled
                  ? _getColor(widget.component.type)
                  : Colors.grey,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.isSelected
                    ? Colors.blue
                    : _isHovered
                    ? Colors.blue.withValues(alpha: 0.5)
                    : Colors.transparent,
                width: widget.isSelected ? 3 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: widget.isSelected ? 0.3 : 0.15,
                  ),
                  blurRadius: widget.isSelected ? 12 : 6,
                  offset: Offset(0, widget.isSelected ? 4 : 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getIcon(widget.component.type),
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.component.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Consumer(
                      builder: (context, ref, _) {
                        return PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                            size: 18,
                          ),
                          onSelected: (value) =>
                              _handleMenuAction(context, ref, value),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'duplicate',
                              child: Row(
                                children: [
                                  Icon(Icons.copy, size: 18),
                                  SizedBox(width: 8),
                                  Text('Duplicate'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'toggle',
                              child: Row(
                                children: [
                                  Icon(
                                    widget.component.enabled
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.component.enabled
                                        ? 'Disable'
                                        : 'Enable',
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                if (widget.component.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.component.description!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 10,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Input connector
                    GestureDetector(
                      onTap: () => widget.onConnectEnd(widget.component.id),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_downward,
                          size: 14,
                          color: _getColor(widget.component.type),
                        ),
                      ),
                    ),
                    // Output connector
                    GestureDetector(
                      onPanStart: (_) {
                        widget.onConnectStart();
                      },
                      onPanUpdate: (details) {
                        widget.onConnectDrag(
                          widget.component.position +
                              Offset(90, 60) +
                              details.localPosition,
                        );
                      },
                      onPanEnd: (_) {
                        widget.onConnectEnd(widget.component.id);
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          size: 14,
                          color: _getColor(widget.component.type),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'duplicate':
        ref
            .read(currentRouteProvider.notifier)
            .duplicateComponent(widget.component.id);
        break;
      case 'toggle':
        ref
            .read(currentRouteProvider.notifier)
            .updateComponent(
              widget.component.copyWith(enabled: !widget.component.enabled),
            );
        break;
      case 'delete':
        ref
            .read(currentRouteProvider.notifier)
            .deleteComponent(widget.component.id);
        break;
    }
  }

  IconData _getIcon(ComponentType type) {
    switch (type) {
      case ComponentType.from:
        return Icons.input;
      case ComponentType.to:
        return Icons.output;
      case ComponentType.transform:
        return Icons.transform;
      case ComponentType.filter:
        return Icons.filter_alt;
      case ComponentType.choice:
        return Icons.call_split;
      case ComponentType.log:
        return Icons.article;
      case ComponentType.setHeader:
        return Icons.view_headline;
      case ComponentType.setBody:
        return Icons.data_object;
      case ComponentType.process:
        return Icons.settings;
      case ComponentType.split:
        return Icons.call_split;
      case ComponentType.aggregate:
        return Icons.merge;
      case ComponentType.enrich:
        return Icons.add_circle;
      case ComponentType.multicast:
        return Icons.broadcast_on_personal;
      case ComponentType.wiretap:
        return Icons.visibility;
      case ComponentType.loop:
        return Icons.loop;
      case ComponentType.delay:
        return Icons.schedule;
      case ComponentType.throttle:
        return Icons.speed;
      default:
        return Icons.widgets;
    }
  }

  Color _getColor(ComponentType type) {
    switch (type) {
      case ComponentType.from:
        return Colors.green[700]!;
      case ComponentType.to:
        return Colors.red[700]!;
      case ComponentType.transform:
      case ComponentType.setBody:
      case ComponentType.setHeader:
        return Colors.purple[700]!;
      case ComponentType.choice:
      case ComponentType.filter:
      case ComponentType.multicast:
      case ComponentType.split:
        return Colors.orange[700]!;
      case ComponentType.loop:
      case ComponentType.delay:
      case ComponentType.throttle:
        return Colors.indigo[700]!;
      case ComponentType.marshal:
      case ComponentType.unmarshal:
        return Colors.teal[700]!;
      case ComponentType.onException:
      case ComponentType.doTry:
      case ComponentType.doCatch:
        return Colors.red[900]!;
      default:
        return Colors.blue[700]!;
    }
  }
}
