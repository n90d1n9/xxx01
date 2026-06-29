import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/design_component.dart';
import '../models/enums.dart';
import '../states/autosave_provider.dart';
import '../services/designer_service.dart';
import '../widgets/animation_panel.dart';
import '../widgets/cloud_sync_button.dart';
import '../widgets/component_palette.dart';
import '../widgets/component_tree_panel.dart';
import '../widgets/designer_appbar.dart';
import '../widgets/designer_canvas.dart';
import '../widgets/properties_panel.dart';

// Main Designer Screen
class DesignerScreen extends StatefulWidget {
  const DesignerScreen({super.key});

  @override
  State<DesignerScreen> createState() => _DesignerScreenState();
}

class _DesignerScreenState extends State<DesignerScreen>
    with TickerProviderStateMixin {
  List<DesignComponent> components = [];
  List<DesignComponent> selectedComponents = [];
  String selectedFramework = 'Flutter';
  final HistoryManager _history = HistoryManager();
  double _canvasZoom = 1.0;
  Offset _canvasOffset = Offset.zero;
  bool _showGrid = true;
  bool _snapToGrid = true;
  final double _gridSize = 20.0;
  int _idCounter = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isDarkMode = false;
  ResponsiveBreakpoint _currentBreakpoint = ResponsiveBreakpoint.desktop;
  bool _showComponentTree = false;
  bool _showAnimationPanel = false;

  // Clipboard
  List<DesignComponent> _clipboard = [];

  // Selection
  Offset? _selectionStart;
  Offset? _selectionEnd;

  // Groups
  final Map<String, List<String>> _groups = {};
  int _groupCounter = 0;

  @override
  void initState() {
    super.initState();
    _addInitialState();
  }

  void _addInitialState() {
    _history.addState(components);
  }

  String _generateId() => 'component_${_idCounter++}';
  String _generateGroupId() => 'group_${_groupCounter++}';

  DesignComponent? get selectedComponent =>
      selectedComponents.isNotEmpty ? selectedComponents.first : null;

  void _addComponent(ComponentType type) {
    final newComponent = DesignComponent(
      id: _generateId(),
      type: type,
      position: const Offset(100, 100),
      size: _getDefaultSize(type),
      properties: _getDefaultProperties(type),
      zIndex: components.length,
    );

    setState(() {
      components.add(newComponent);
      selectedComponents = [newComponent];
      _history.addState(components);
    });
  }

  Size _getDefaultSize(ComponentType type) {
    switch (type) {
      case ComponentType.container:
        return const Size(200, 150);
      case ComponentType.text:
        return const Size(150, 40);
      case ComponentType.button:
        return const Size(120, 45);
      case ComponentType.image:
        return const Size(200, 200);
      case ComponentType.input:
        return const Size(250, 50);
      case ComponentType.card:
        return const Size(300, 200);
      case ComponentType.appBar:
        return const Size(400, 56);
      case ComponentType.navigationBar:
        return const Size(400, 80);
      case ComponentType.listView:
        return const Size(300, 400);
      case ComponentType.gridView:
        return const Size(400, 400);
      case ComponentType.column:
      case ComponentType.row:
      case ComponentType.stack:
        return const Size(250, 200);
      case ComponentType.divider:
        return const Size(200, 2);
      case ComponentType.spacer:
        return const Size(50, 50);
      case ComponentType.checkbox:
      case ComponentType.radioButton:
        return const Size(40, 40);
      case ComponentType.slider:
        return const Size(200, 40);
      case ComponentType.icon:
        return const Size(50, 50);
      default:
        return const Size(200, 150);
    }
  }

  Map<String, dynamic> _getDefaultProperties(ComponentType type) {
    switch (type) {
      case ComponentType.container:
        return {
          'backgroundColor': Colors.blue.shade100.value,
          'borderRadius': 8.0,
          'borderWidth': 1.0,
          'borderColor': Colors.blue.value,
          'padding': 16.0,
          'margin': 0.0,
          'shadow': false,
          'shadowBlur': 10.0,
          'shadowColor': Colors.black26.value,
          'shadowOffsetX': 0.0,
          'shadowOffsetY': 2.0,
        };
      case ComponentType.text:
        return {
          'text': 'Text Component',
          'fontSize': 16.0,
          'color': Colors.black.value,
          'fontWeight': 'normal',
          'fontStyle': 'normal',
          'textAlign': 'left',
          'letterSpacing': 0.0,
          'lineHeight': 1.5,
          'decoration': 'none',
          'maxLines': 1,
          'overflow': 'visible',
        };
      case ComponentType.button:
        return {
          'text': 'Button',
          'backgroundColor': Colors.blue.value,
          'textColor': Colors.white.value,
          'borderRadius': 8.0,
          'elevation': 2.0,
          'padding': 16.0,
          'fontSize': 14.0,
          'fontWeight': 'normal',
          'borderWidth': 0.0,
          'borderColor': Colors.transparent.value,
          'hoverColor': Colors.blue.shade700.value,
        };
      case ComponentType.image:
        return {
          'url': 'https://via.placeholder.com/200',
          'fit': 'cover',
          'borderRadius': 0.0,
          'opacity': 1.0,
          'grayscale': false,
          'blur': 0.0,
        };
      case ComponentType.input:
        return {
          'placeholder': 'Enter text...',
          'borderColor': Colors.grey.value,
          'backgroundColor': Colors.white.value,
          'textColor': Colors.black.value,
          'borderRadius': 8.0,
          'borderWidth': 1.0,
          'padding': 12.0,
          'fontSize': 14.0,
          'labelText': '',
          'helperText': '',
          'prefixIcon': '',
          'suffixIcon': '',
        };
      case ComponentType.card:
        return {
          'backgroundColor': Colors.white.value,
          'borderRadius': 12.0,
          'elevation': 4.0,
          'padding': 16.0,
          'margin': 0.0,
        };
      case ComponentType.divider:
        return {
          'color': Colors.grey.value,
          'thickness': 1.0,
          'indent': 0.0,
          'endIndent': 0.0,
        };
      case ComponentType.checkbox:
        return {
          'checked': false,
          'activeColor': Colors.blue.value,
          'checkColor': Colors.white.value,
        };
      case ComponentType.radioButton:
        return {'selected': false, 'activeColor': Colors.blue.value};
      case ComponentType.slider:
        return {
          'value': 0.5,
          'min': 0.0,
          'max': 1.0,
          'divisions': 10,
          'activeColor': Colors.blue.value,
          'inactiveColor': Colors.grey.value,
        };
      case ComponentType.icon:
        return {'icon': 'star', 'color': Colors.blue.value, 'size': 24.0};
      case ComponentType.column:
        return {
          'backgroundColor': Colors.transparent.value,
          'spacing': 8.0,
          'mainAxisAlignment': 'start',
          'crossAxisAlignment': 'center',
          'padding': 16.0,
        };
      case ComponentType.row:
        return {
          'backgroundColor': Colors.transparent.value,
          'spacing': 8.0,
          'mainAxisAlignment': 'start',
          'crossAxisAlignment': 'center',
          'padding': 16.0,
        };
      default:
        return {};
    }
  }

  void _updateComponentProperty(String key, dynamic value) {
    if (selectedComponent != null) {
      setState(() {
        selectedComponent!.properties[key] = value;
        _history.addState(components);
      });
    }
  }

  void _deleteSelectedComponents() {
    if (selectedComponents.isNotEmpty) {
      setState(() {
        for (var component in selectedComponents) {
          components.remove(component);
        }
        selectedComponents.clear();
        _history.addState(components);
      });
    }
  }

  void _duplicateComponents() {
    if (selectedComponents.isNotEmpty) {
      final duplicates = <DesignComponent>[];
      for (var component in selectedComponents) {
        final duplicate = component.copyWith(
          id: _generateId(),
          position: Offset(
            component.position.dx + 20,
            component.position.dy + 20,
          ),
        );
        duplicates.add(duplicate);
      }
      setState(() {
        components.addAll(duplicates);
        selectedComponents = duplicates;
        _history.addState(components);
      });
    }
  }

  void _copyComponents() {
    if (selectedComponents.isNotEmpty) {
      _clipboard = selectedComponents.map((c) => c.copyWith()).toList();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${selectedComponents.length} component(s) copied'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _pasteComponents() {
    if (_clipboard.isNotEmpty) {
      final pasted = <DesignComponent>[];
      for (var component in _clipboard) {
        final paste = component.copyWith(
          id: _generateId(),
          position: Offset(
            component.position.dx + 20,
            component.position.dy + 20,
          ),
        );
        pasted.add(paste);
      }
      setState(() {
        components.addAll(pasted);
        selectedComponents = pasted;
        _history.addState(components);
      });
    }
  }

  void _groupSelected() {
    if (selectedComponents.length > 1) {
      final groupId = _generateGroupId();
      setState(() {
        for (var component in selectedComponents) {
          component.groupId = groupId;
        }
        _groups[groupId] = selectedComponents.map((c) => c.id).toList();
        _history.addState(components);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Components grouped'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _ungroupSelected() {
    if (selectedComponent?.groupId != null) {
      final groupId = selectedComponent!.groupId!;
      setState(() {
        for (var component in components) {
          if (component.groupId == groupId) {
            component.groupId = null;
          }
        }
        _groups.remove(groupId);
        _history.addState(components);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Components ungrouped'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _alignLeft() {
    if (selectedComponents.length > 1) {
      final leftMost = selectedComponents
          .map((c) => c.position.dx)
          .reduce(math.min);
      setState(() {
        for (var component in selectedComponents) {
          component.position = Offset(leftMost, component.position.dy);
        }
        _history.addState(components);
      });
    }
  }

  void _alignCenter() {
    if (selectedComponents.length > 1) {
      final avg =
          selectedComponents
              .map((c) => c.position.dx + c.size.width / 2)
              .reduce((a, b) => a + b) /
          selectedComponents.length;
      setState(() {
        for (var component in selectedComponents) {
          component.position = Offset(
            avg - component.size.width / 2,
            component.position.dy,
          );
        }
        _history.addState(components);
      });
    }
  }

  void _alignRight() {
    if (selectedComponents.length > 1) {
      final rightMost = selectedComponents
          .map((c) => c.position.dx + c.size.width)
          .reduce(math.max);
      setState(() {
        for (var component in selectedComponents) {
          component.position = Offset(
            rightMost - component.size.width,
            component.position.dy,
          );
        }
        _history.addState(components);
      });
    }
  }

  void _distributeHorizontally() {
    if (selectedComponents.length > 2) {
      final sorted = List<DesignComponent>.from(selectedComponents)
        ..sort((a, b) => a.position.dx.compareTo(b.position.dx));
      final leftMost = sorted.first.position.dx;
      final rightMost = sorted.last.position.dx + sorted.last.size.width;
      final totalWidth = sorted
          .map((c) => c.size.width)
          .reduce((a, b) => a + b);
      final spacing = (rightMost - leftMost - totalWidth) / (sorted.length - 1);

      setState(() {
        var currentX = leftMost;
        for (var component in sorted) {
          component.position = Offset(currentX, component.position.dy);
          currentX += component.size.width + spacing;
        }
        _history.addState(components);
      });
    }
  }

  void _undo() {
    final state = _history.undo();
    if (state != null) {
      setState(() {
        components = state;
        selectedComponents.clear();
      });
    }
  }

  void _redo() {
    final state = _history.redo();
    if (state != null) {
      setState(() {
        components = state;
        selectedComponents.clear();
      });
    }
  }

  void _bringToFront() {
    if (selectedComponent != null) {
      setState(() {
        final maxZ =
            components.isEmpty
                ? 0
                : components.map((c) => c.zIndex).reduce(math.max);
        selectedComponent!.zIndex = maxZ + 1;
        _history.addState(components);
      });
    }
  }

  void _sendToBack() {
    if (selectedComponent != null) {
      setState(() {
        final minZ =
            components.isEmpty
                ? 0
                : components.map((c) => c.zIndex).reduce(math.min);
        selectedComponent!.zIndex = minZ - 1;
        _history.addState(components);
      });
    }
  }

  Offset _snapToGridIfEnabled(Offset offset) {
    if (_snapToGrid) {
      return Offset(
        (offset.dx / _gridSize).round() * _gridSize,
        (offset.dy / _gridSize).round() * _gridSize,
      );
    }
    return offset;
  }

  void _saveProject() {
    final jsonData = {
      'components': components.map((c) => c.toJson()).toList(),
      'version': '2.0',
      'groups': _groups,
    };
    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
    Clipboard.setData(ClipboardData(text: jsonString));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Project saved to clipboard!')),
    );
  }

  void _loadProject(String jsonString) {
    try {
      final jsonData = jsonDecode(jsonString);
      final loadedComponents =
          (jsonData['components'] as List)
              .map((c) => DesignComponent.fromJson(c))
              .toList();
      setState(() {
        components = loadedComponents;
        selectedComponents.clear();
        if (jsonData['groups'] != null) {
          _groups.clear();
          _groups.addAll(
            Map<String, List<String>>.from(
              (jsonData['groups'] as Map).map(
                (k, v) => MapEntry(k, List<String>.from(v)),
              ),
            ),
          );
        }
        _history.clear();
        _history.addState(components);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project loaded successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading project: $e')));
    }
  }

  void _exportAsImage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export as image feature coming soon!')),
    );
  }

  void _setResponsiveLayout() {
    if (selectedComponent != null) {
      if (selectedComponent!.responsiveLayout == null) {
        selectedComponent!.responsiveLayout = ResponsiveLayout(
          positions: {
            ResponsiveBreakpoint.mobile: selectedComponent!.position,
            ResponsiveBreakpoint.tablet: selectedComponent!.position,
            ResponsiveBreakpoint.desktop: selectedComponent!.position,
          },
          sizes: {
            ResponsiveBreakpoint.mobile: selectedComponent!.size,
            ResponsiveBreakpoint.tablet: selectedComponent!.size,
            ResponsiveBreakpoint.desktop: selectedComponent!.size,
          },
          visibility: {
            ResponsiveBreakpoint.mobile: true,
            ResponsiveBreakpoint.tablet: true,
            ResponsiveBreakpoint.desktop: true,
          },
        );
      }
      setState(() {});
    }
  }

  // Code Generation
  String _generateCode() {
    switch (selectedFramework) {
      case 'Flutter':
        return _generateFlutterCode();
      case 'Flutter (Animated)':
        return _generateAnimatedFlutterCode();
      case 'React':
        return _generateReactCode();
      case 'React Native':
        return _generateReactNativeCode();
      case 'HTML/CSS':
        return _generateHTMLCode();
      case 'Vue.js':
        return _generateVueCode();
      case 'Tailwind CSS':
        return _generateTailwindCode();
      case 'Jinja2 Template':
        return _generateJinja2Template();
      case 'Mustache Template':
        return _generateMustacheTemplate();
      default:
        return '// Framework not implemented yet';
    }
  }

  String _generateJinja2Template() {
    final buffer = StringBuffer();
    buffer.writeln('{% extends "base.html" %}');
    buffer.writeln('');
    buffer.writeln('{% block title %}Generated Page{% endblock %}');
    buffer.writeln('');
    buffer.writeln('{% block styles %}');
    buffer.writeln('<style>');
    buffer.writeln(
      '  .container { position: relative; width: 100%; min-height: 100vh; }',
    );
    buffer.writeln('  .component { position: absolute; }');

    // Generate CSS animations
    buffer.writeln(
      '  @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }',
    );
    buffer.writeln(
      '  @keyframes slideIn { from { transform: translateX(-50px); } to { transform: translateX(0); } }',
    );
    buffer.writeln(
      '  @keyframes scaleIn { from { transform: scale(0); } to { transform: scale(1); } }',
    );
    buffer.writeln('</style>');
    buffer.writeln('{% endblock %}');
    buffer.writeln('');
    buffer.writeln('{% block content %}');
    buffer.writeln('<div class="container">');
    buffer.writeln('  {% for component in components %}');
    buffer.writeln('    {% if component.type == "text" %}');
    buffer.writeln(
      '      <div class="component" style="left: {{ component.position.x }}px; top: {{ component.position.y }}px; font-size: {{ component.fontSize }}px; color: {{ component.color }};">',
    );
    buffer.writeln('        {{ component.text }}');
    buffer.writeln('      </div>');
    buffer.writeln('    {% elif component.type == "button" %}');
    buffer.writeln(
      '      <button class="component" style="left: {{ component.position.x }}px; top: {{ component.position.y }}px; background-color: {{ component.backgroundColor }}; color: {{ component.textColor }}; border-radius: {{ component.borderRadius }}px; padding: {{ component.padding }}px;">',
    );
    buffer.writeln('        {{ component.text }}');
    buffer.writeln('      </button>');
    buffer.writeln('    {% elif component.type == "input" %}');
    buffer.writeln(
      '      <input type="text" class="component" placeholder="{{ component.placeholder }}" style="left: {{ component.position.x }}px; top: {{ component.position.y }}px; width: {{ component.width }}px; padding: {{ component.padding }}px; border-radius: {{ component.borderRadius }}px;">',
    );
    buffer.writeln('    {% elif component.type == "container" %}');
    buffer.writeln(
      '      <div class="component" style="left: {{ component.position.x }}px; top: {{ component.position.y }}px; width: {{ component.width }}px; height: {{ component.height }}px; background-color: {{ component.backgroundColor }}; border-radius: {{ component.borderRadius }}px; {% if component.shadow %}box-shadow: {{ component.shadowOffsetX }}px {{ component.shadowOffsetY }}px {{ component.shadowBlur }}px {{ component.shadowColor }};{% endif %}"></div>',
    );
    buffer.writeln('    {% elif component.type == "image" %}');
    buffer.writeln(
      '      <img src="{{ component.url }}" class="component" style="left: {{ component.position.x }}px; top: {{ component.position.y }}px; width: {{ component.width }}px; height: {{ component.height }}px; border-radius: {{ component.borderRadius }}px; object-fit: {{ component.fit }};">',
    );
    buffer.writeln('    {% endif %}');
    buffer.writeln('  {% endfor %}');
    buffer.writeln('</div>');
    buffer.writeln('{% endblock %}');
    buffer.writeln('');
    buffer.writeln('{% block scripts %}');
    buffer.writeln('<script>');
    buffer.writeln('  // Add your JavaScript here');
    buffer.writeln(
      '  document.addEventListener("DOMContentLoaded", function() {',
    );
    buffer.writeln(
      '    console.log("Page loaded with {{ components|length }} components");',
    );
    buffer.writeln('  });');
    buffer.writeln('</script>');
    buffer.writeln('{% endblock %}');
    buffer.writeln('');
    buffer.writeln('<!-- Python/Flask Context Data -->');
    buffer.writeln('<!-- In your Flask route, pass: -->');
    buffer.writeln('<!--');
    buffer.writeln('components = [');

    final sortedComponents = List<DesignComponent>.from(components)
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    for (var component in sortedComponents) {
      buffer.writeln('  {');
      buffer.writeln(
        '    "type": "${component.type.toString().split('.').last}",',
      );
      buffer.writeln(
        '    "position": {"x": ${component.position.dx.toStringAsFixed(0)}, "y": ${component.position.dy.toStringAsFixed(0)}},',
      );
      buffer.writeln(
        '    "width": ${component.size.width.toStringAsFixed(0)},',
      );
      buffer.writeln(
        '    "height": ${component.size.height.toStringAsFixed(0)},',
      );

      switch (component.type) {
        case ComponentType.text:
          buffer.writeln('    "text": "${component.properties['text']}",');
          buffer.writeln(
            '    "fontSize": ${component.properties['fontSize']},',
          );
          buffer.writeln(
            '    "color": "${_colorToHex(component.properties['color'])}",',
          );
          break;
        case ComponentType.button:
          buffer.writeln('    "text": "${component.properties['text']}",');
          buffer.writeln(
            '    "backgroundColor": "${_colorToHex(component.properties['backgroundColor'])}",',
          );
          buffer.writeln(
            '    "textColor": "${_colorToHex(component.properties['textColor'])}",',
          );
          buffer.writeln(
            '    "borderRadius": ${component.properties['borderRadius']},',
          );
          buffer.writeln('    "padding": ${component.properties['padding']},');
          break;
        case ComponentType.input:
          buffer.writeln(
            '    "placeholder": "${component.properties['placeholder']}",',
          );
          buffer.writeln(
            '    "borderRadius": ${component.properties['borderRadius']},',
          );
          buffer.writeln('    "padding": ${component.properties['padding']},');
          break;
        case ComponentType.container:
          buffer.writeln(
            '    "backgroundColor": "${_colorToHex(component.properties['backgroundColor'])}",',
          );
          buffer.writeln(
            '    "borderRadius": ${component.properties['borderRadius']},',
          );
          buffer.writeln('    "shadow": ${component.properties['shadow']},');
          if (component.properties['shadow'] == true) {
            buffer.writeln(
              '    "shadowOffsetX": ${component.properties['shadowOffsetX']},',
            );
            buffer.writeln(
              '    "shadowOffsetY": ${component.properties['shadowOffsetY']},',
            );
            buffer.writeln(
              '    "shadowBlur": ${component.properties['shadowBlur']},',
            );
            buffer.writeln(
              '    "shadowColor": "${_colorToHex(component.properties['shadowColor'])}",',
            );
          }
          break;
        case ComponentType.image:
          buffer.writeln('    "url": "${component.properties['url']}",');
          buffer.writeln(
            '    "borderRadius": ${component.properties['borderRadius']},',
          );
          buffer.writeln('    "fit": "${component.properties['fit']}",');
          break;
        default:
          break;
      }

      buffer.writeln('  },');
    }

    buffer.writeln(']');
    buffer.writeln(
      'return render_template("generated_page.html", components=components)',
    );
    buffer.writeln('-->');

    return buffer.toString();
  }

  String _generateMustacheTemplate() {
    final buffer = StringBuffer();
    buffer.writeln('<!DOCTYPE html>');
    buffer.writeln('<html lang="en">');
    buffer.writeln('<head>');
    buffer.writeln('  <meta charset="UTF-8">');
    buffer.writeln(
      '  <meta name="viewport" content="width=device-width, initial-scale=1.0">',
    );
    buffer.writeln('  <title>{{pageTitle}}</title>');
    buffer.writeln('  <style>');
    buffer.writeln('    * { margin: 0; padding: 0; box-sizing: border-box; }');
    buffer.writeln(
      '    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; }',
    );
    buffer.writeln(
      '    .container { position: relative; width: 100%; min-height: 100vh; }',
    );
    buffer.writeln('    .component { position: absolute; }');
    buffer.writeln('    .btn { cursor: pointer; border: none; }');
    buffer.writeln('    .btn:hover { opacity: 0.9; }');
    buffer.writeln('    .input-field { outline: none; }');
    buffer.writeln(
      '    @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }',
    );
    buffer.writeln(
      '    @keyframes slideInLeft { from { transform: translateX(-50px); opacity: 0; } to { transform: translateX(0); opacity: 1; } }',
    );
    buffer.writeln(
      '    @keyframes scaleIn { from { transform: scale(0); } to { transform: scale(1); } }',
    );
    buffer.writeln(
      '    .animate-fade { animation: fadeIn {{animationDuration}}s ease; }',
    );
    buffer.writeln(
      '    .animate-slide { animation: slideInLeft {{animationDuration}}s ease; }',
    );
    buffer.writeln(
      '    .animate-scale { animation: scaleIn {{animationDuration}}s ease; }',
    );
    buffer.writeln('  </style>');
    buffer.writeln('</head>');
    buffer.writeln('<body>');
    buffer.writeln('  <div class="container">');
    buffer.writeln('    {{#components}}');
    buffer.writeln('      {{#isText}}');
    buffer.writeln(
      '        <div class="component {{animationClass}}" style="left: {{position.x}}px; top: {{position.y}}px; font-size: {{fontSize}}px; color: {{color}}; font-weight: {{fontWeight}}; text-align: {{textAlign}};">',
    );
    buffer.writeln('          {{text}}');
    buffer.writeln('        </div>');
    buffer.writeln('      {{/isText}}');
    buffer.writeln('');
    buffer.writeln('      {{#isButton}}');
    buffer.writeln(
      '        <button class="component btn {{animationClass}}" onclick="{{onClick}}" style="left: {{position.x}}px; top: {{position.y}}px; width: {{width}}px; height: {{height}}px; background-color: {{backgroundColor}}; color: {{textColor}}; border-radius: {{borderRadius}}px; padding: {{padding}}px; font-size: {{fontSize}}px;">',
    );
    buffer.writeln('          {{text}}');
    buffer.writeln('        </button>');
    buffer.writeln('      {{/isButton}}');
    buffer.writeln('');
    buffer.writeln('      {{#isInput}}');
    buffer.writeln(
      '        <input type="text" class="component input-field {{animationClass}}" name="{{name}}" placeholder="{{placeholder}}" style="left: {{position.x}}px; top: {{position.y}}px; width: {{width}}px; height: {{height}}px; padding: {{padding}}px; border-radius: {{borderRadius}}px; border: {{borderWidth}}px solid {{borderColor}}; background-color: {{backgroundColor}}; font-size: {{fontSize}}px;">',
    );
    buffer.writeln('      {{/isInput}}');
    buffer.writeln('');
    buffer.writeln('      {{#isContainer}}');
    buffer.writeln(
      '        <div class="component {{animationClass}}" style="left: {{position.x}}px; top: {{position.y}}px; width: {{width}}px; height: {{height}}px; background-color: {{backgroundColor}}; border-radius: {{borderRadius}}px; border: {{borderWidth}}px solid {{borderColor}}; {{#hasShadow}}box-shadow: {{shadowOffsetX}}px {{shadowOffsetY}}px {{shadowBlur}}px {{shadowColor}};{{/hasShadow}}">',
    );
    buffer.writeln('          {{#children}}');
    buffer.writeln('            <div>{{.}}</div>');
    buffer.writeln('          {{/children}}');
    buffer.writeln('        </div>');
    buffer.writeln('      {{/isContainer}}');
    buffer.writeln('');
    buffer.writeln('      {{#isImage}}');
    buffer.writeln(
      '        <img src="{{url}}" alt="{{alt}}" class="component {{animationClass}}" style="left: {{position.x}}px; top: {{position.y}}px; width: {{width}}px; height: {{height}}px; border-radius: {{borderRadius}}px; object-fit: {{fit}}; opacity: {{opacity}};">',
    );
    buffer.writeln('      {{/isImage}}');
    buffer.writeln('');
    buffer.writeln('      {{#isCheckbox}}');
    buffer.writeln(
      '        <input type="checkbox" class="component" {{#checked}}checked{{/checked}} style="left: {{position.x}}px; top: {{position.y}}px; width: {{size}}px; height: {{size}}px;">',
    );
    buffer.writeln('      {{/isCheckbox}}');
    buffer.writeln('');
    buffer.writeln('      {{#isSlider}}');
    buffer.writeln(
      '        <input type="range" class="component" min="{{min}}" max="{{max}}" value="{{value}}" step="{{step}}" style="left: {{position.x}}px; top: {{position.y}}px; width: {{width}}px;">',
    );
    buffer.writeln('      {{/isSlider}}');
    buffer.writeln('');
    buffer.writeln('      {{#isIcon}}');
    buffer.writeln(
      '        <i class="{{iconClass}} component" style="left: {{position.x}}px; top: {{position.y}}px; font-size: {{size}}px; color: {{color}};"></i>',
    );
    buffer.writeln('      {{/isIcon}}');
    buffer.writeln('    {{/components}}');
    buffer.writeln('  </div>');
    buffer.writeln('');
    buffer.writeln('  <script>');
    buffer.writeln('    // Add your JavaScript here');
    buffer.writeln(
      '    console.log("Page loaded with {{componentCount}} components");',
    );
    buffer.writeln('    ');
    buffer.writeln('    // Example event handlers');
    buffer.writeln('    {{#hasInteractiveComponents}}');
    buffer.writeln(
      '    document.addEventListener("DOMContentLoaded", function() {',
    );
    buffer.writeln('      {{#buttons}}');
    buffer.writeln(
      '      document.querySelector(\'[data-id="{{id}}"]\')?.addEventListener("click", function() {',
    );
    buffer.writeln('        console.log("Button {{text}} clicked");');
    buffer.writeln('      });');
    buffer.writeln('      {{/buttons}}');
    buffer.writeln('    });');
    buffer.writeln('    {{/hasInteractiveComponents}}');
    buffer.writeln('  </script>');
    buffer.writeln('</body>');
    buffer.writeln('</html>');
    buffer.writeln('');
    buffer.writeln('<!-- JSON Data Structure for Mustache -->');
    buffer.writeln('<!--');
    buffer.writeln('{');
    buffer.writeln('  "pageTitle": "Generated Page",');
    buffer.writeln('  "animationDuration": 1,');
    buffer.writeln('  "componentCount": ${components.length},');
    buffer.writeln(
      '  "hasInteractiveComponents": ${components.any((c) => c.type == ComponentType.button)},',
    );
    buffer.writeln('  "components": [');

    final sortedComponents = List<DesignComponent>.from(components)
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    for (var i = 0; i < sortedComponents.length; i++) {
      final component = sortedComponents[i];
      buffer.writeln('    {');
      buffer.writeln('      "id": "${component.id}",');
      buffer.writeln(
        '      "position": {"x": ${component.position.dx.toStringAsFixed(0)}, "y": ${component.position.dy.toStringAsFixed(0)}},',
      );
      buffer.writeln(
        '      "width": ${component.size.width.toStringAsFixed(0)},',
      );
      buffer.writeln(
        '      "height": ${component.size.height.toStringAsFixed(0)},',
      );
      buffer.writeln(
        '      "animationClass": "${component.animation.type != AnimationType.none ? 'animate-${component.animation.type.toString().split('.').last}' : ''}",',
      );

      // Add type-specific boolean flags
      buffer.writeln(
        '      "isText": ${component.type == ComponentType.text},',
      );
      buffer.writeln(
        '      "isButton": ${component.type == ComponentType.button},',
      );
      buffer.writeln(
        '      "isInput": ${component.type == ComponentType.input},',
      );
      buffer.writeln(
        '      "isContainer": ${component.type == ComponentType.container},',
      );
      buffer.writeln(
        '      "isImage": ${component.type == ComponentType.image},',
      );
      buffer.writeln(
        '      "isCheckbox": ${component.type == ComponentType.checkbox},',
      );
      buffer.writeln(
        '      "isSlider": ${component.type == ComponentType.slider},',
      );
      buffer.writeln(
        '      "isIcon": ${component.type == ComponentType.icon},',
      );

      // Add component-specific properties
      switch (component.type) {
        case ComponentType.text:
          buffer.writeln('      "text": "${component.properties['text']}",');
          buffer.writeln(
            '      "fontSize": ${component.properties['fontSize']},',
          );
          buffer.writeln(
            '      "color": "${_colorToHex(component.properties['color'])}",',
          );
          buffer.writeln(
            '      "fontWeight": "${component.properties['fontWeight']}",',
          );
          buffer.writeln(
            '      "textAlign": "${component.properties['textAlign']}",',
          );
          break;
        case ComponentType.button:
          buffer.writeln('      "text": "${component.properties['text']}",');
          buffer.writeln(
            '      "backgroundColor": "${_colorToHex(component.properties['backgroundColor'])}",',
          );
          buffer.writeln(
            '      "textColor": "${_colorToHex(component.properties['textColor'])}",',
          );
          buffer.writeln(
            '      "borderRadius": ${component.properties['borderRadius']},',
          );
          buffer.writeln(
            '      "padding": ${component.properties['padding']},',
          );
          buffer.writeln(
            '      "fontSize": ${component.properties['fontSize']},',
          );
          buffer.writeln(
            '      "onClick": "handleButtonClick(\'${component.id}\')",',
          );
          break;
        case ComponentType.input:
          buffer.writeln('      "name": "${component.id}",');
          buffer.writeln(
            '      "placeholder": "${component.properties['placeholder']}",',
          );
          buffer.writeln(
            '      "backgroundColor": "${_colorToHex(component.properties['backgroundColor'])}",',
          );
          buffer.writeln(
            '      "borderColor": "${_colorToHex(component.properties['borderColor'])}",',
          );
          buffer.writeln(
            '      "borderRadius": ${component.properties['borderRadius']},',
          );
          buffer.writeln(
            '      "borderWidth": ${component.properties['borderWidth']},',
          );
          buffer.writeln(
            '      "padding": ${component.properties['padding']},',
          );
          buffer.writeln(
            '      "fontSize": ${component.properties['fontSize']},',
          );
          break;
        case ComponentType.container:
          buffer.writeln(
            '      "backgroundColor": "${_colorToHex(component.properties['backgroundColor'])}",',
          );
          buffer.writeln(
            '      "borderColor": "${_colorToHex(component.properties['borderColor'])}",',
          );
          buffer.writeln(
            '      "borderRadius": ${component.properties['borderRadius']},',
          );
          buffer.writeln(
            '      "borderWidth": ${component.properties['borderWidth']},',
          );
          buffer.writeln(
            '      "hasShadow": ${component.properties['shadow']},',
          );
          if (component.properties['shadow'] == true) {
            buffer.writeln(
              '      "shadowOffsetX": ${component.properties['shadowOffsetX']},',
            );
            buffer.writeln(
              '      "shadowOffsetY": ${component.properties['shadowOffsetY']},',
            );
            buffer.writeln(
              '      "shadowBlur": ${component.properties['shadowBlur']},',
            );
            buffer.writeln(
              '      "shadowColor": "${_colorToHex(component.properties['shadowColor'])}",',
            );
          }
          buffer.writeln('      "children": [],');
          break;
        case ComponentType.image:
          buffer.writeln('      "url": "${component.properties['url']}",');
          buffer.writeln('      "alt": "Component Image",');
          buffer.writeln(
            '      "borderRadius": ${component.properties['borderRadius']},',
          );
          buffer.writeln('      "fit": "${component.properties['fit']}",');
          buffer.writeln(
            '      "opacity": ${component.properties['opacity']},',
          );
          break;
        case ComponentType.checkbox:
          buffer.writeln(
            '      "checked": ${component.properties['checked']},',
          );
          buffer.writeln('      "size": 24,');
          break;
        case ComponentType.slider:
          buffer.writeln('      "min": ${component.properties['min']},');
          buffer.writeln('      "max": ${component.properties['max']},');
          buffer.writeln('      "value": ${component.properties['value']},');
          buffer.writeln('      "step": 0.1,');
          break;
        case ComponentType.icon:
          buffer.writeln(
            '      "iconClass": "fas fa-${component.properties['icon']}",',
          );
          buffer.writeln('      "size": ${component.properties['size']},');
          buffer.writeln(
            '      "color": "${_colorToHex(component.properties['color'])}",',
          );
          break;
        default:
          break;
      }

      buffer.write('    }${i < sortedComponents.length - 1 ? ',' : ''}');
      buffer.writeln();
    }

    buffer.writeln('  ],');
    buffer.writeln('  "buttons": [');

    final buttons =
        sortedComponents.where((c) => c.type == ComponentType.button).toList();
    for (var i = 0; i < buttons.length; i++) {
      buffer.writeln('    {');
      buffer.writeln('      "id": "${buttons[i].id}",');
      buffer.writeln('      "text": "${buttons[i].properties['text']}"');
      buffer.write('    }${i < buttons.length - 1 ? ',' : ''}');
      buffer.writeln();
    }

    buffer.writeln('  ]');
    buffer.writeln('}');
    buffer.writeln('-->');

    return buffer.toString();
  }

  String _generateFlutterCode() {
    final buffer = StringBuffer();
    buffer.writeln('import \'package:flutter/material.dart\';');
    buffer.writeln('');
    buffer.writeln('class GeneratedPage extends StatelessWidget {');
    buffer.writeln('  const GeneratedPage({Key? key}) : super(key: key);');
    buffer.writeln('');
    buffer.writeln('  @override');
    buffer.writeln('  Widget build(BuildContext context) {');
    buffer.writeln('    return Scaffold(');
    buffer.writeln('      body: Stack(');
    buffer.writeln('        children: [');

    final sortedComponents = List<DesignComponent>.from(components)
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    for (var component in sortedComponents) {
      buffer.write(_generateFlutterWidget(component, indent: 10));
    }

    buffer.writeln('        ],');
    buffer.writeln('      ),');
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln('}');

    return buffer.toString();
  }

  String _generateAnimatedFlutterCode() {
    final buffer = StringBuffer();
    buffer.writeln('import \'package:flutter/material.dart\';');
    buffer.writeln('');
    buffer.writeln('class GeneratedPage extends StatefulWidget {');
    buffer.writeln('  const GeneratedPage({Key? key}) : super(key: key);');
    buffer.writeln('  @override');
    buffer.writeln(
      '  State<GeneratedPage> createState() => _GeneratedPageState();',
    );
    buffer.writeln('}');
    buffer.writeln('');
    buffer.writeln(
      'class _GeneratedPageState extends State<GeneratedPage> with TickerProviderStateMixin {',
    );
    buffer.writeln('  late List<AnimationController> _controllers;');
    buffer.writeln('  late List<Animation> _animations;');
    buffer.writeln('');
    buffer.writeln('  @override');
    buffer.writeln('  void initState() {');
    buffer.writeln('    super.initState();');
    buffer.writeln(
      '    _controllers = List.generate(${components.length}, (i) => AnimationController(',
    );
    buffer.writeln('      vsync: this,');
    buffer.writeln('      duration: Duration(milliseconds: 1000),');
    buffer.writeln('    )..forward());');
    buffer.writeln(
      '    _animations = _controllers.map((c) => CurvedAnimation(parent: c, curve: Curves.easeInOut)).toList();',
    );
    buffer.writeln('  }');
    buffer.writeln('');
    buffer.writeln('  @override');
    buffer.writeln('  void dispose() {');
    buffer.writeln(
      '    for (var controller in _controllers) { controller.dispose(); }',
    );
    buffer.writeln('    super.dispose();');
    buffer.writeln('  }');
    buffer.writeln('');
    buffer.writeln('  @override');
    buffer.writeln('  Widget build(BuildContext context) {');
    buffer.writeln('    return Scaffold(');
    buffer.writeln('      body: Stack(');
    buffer.writeln('        children: [');

    final sortedComponents = List<DesignComponent>.from(components)
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    for (var i = 0; i < sortedComponents.length; i++) {
      final component = sortedComponents[i];
      buffer.write(_generateAnimatedFlutterWidget(component, i, indent: 10));
    }

    buffer.writeln('        ],');
    buffer.writeln('      ),');
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln('}');

    return buffer.toString();
  }

  String _generateFlutterWidget(DesignComponent component, {int indent = 0}) {
    final spacing = ' ' * indent;
    final buffer = StringBuffer();

    buffer.writeln('$spacing Positioned(');
    buffer.writeln(
      '$spacing   left: ${component.position.dx.toStringAsFixed(1)},',
    );
    buffer.writeln(
      '$spacing   top: ${component.position.dy.toStringAsFixed(1)},',
    );
    buffer.writeln('$spacing   child: SizedBox(');
    buffer.writeln(
      '$spacing     width: ${component.size.width.toStringAsFixed(1)},',
    );
    buffer.writeln(
      '$spacing     height: ${component.size.height.toStringAsFixed(1)},',
    );
    buffer.writeln(
      '$spacing     child: ${_generateFlutterComponentCode(component, spacing)}',
    );
    buffer.writeln('$spacing   ),');
    buffer.writeln('$spacing ),');

    return buffer.toString();
  }

  String _generateAnimatedFlutterWidget(
    DesignComponent component,
    int index, {
    int indent = 0,
  }) {
    final spacing = ' ' * indent;
    final buffer = StringBuffer();
    final animType = component.animation.type;

    buffer.writeln('$spacing AnimatedBuilder(');
    buffer.writeln('$spacing   animation: _animations[$index],');
    buffer.writeln('$spacing   builder: (context, child) {');

    if (animType == AnimationType.fadeIn) {
      buffer.writeln('$spacing     return Opacity(');
      buffer.writeln('$spacing       opacity: _animations[$index].value,');
      buffer.writeln('$spacing       child: child,');
      buffer.writeln('$spacing     );');
    } else if (animType == AnimationType.scaleIn) {
      buffer.writeln('$spacing     return Transform.scale(');
      buffer.writeln('$spacing       scale: _animations[$index].value,');
      buffer.writeln('$spacing       child: child,');
      buffer.writeln('$spacing     );');
    } else if (animType == AnimationType.slideInLeft) {
      buffer.writeln('$spacing     return Transform.translate(');
      buffer.writeln(
        '$spacing       offset: Offset(-50 * (1 - _animations[$index].value), 0),',
      );
      buffer.writeln('$spacing       child: child,');
      buffer.writeln('$spacing     );');
    } else {
      buffer.writeln('$spacing     return child!;');
    }

    buffer.writeln('$spacing   },');
    buffer.writeln('$spacing   child: Positioned(');
    buffer.writeln(
      '$spacing     left: ${component.position.dx.toStringAsFixed(1)},',
    );
    buffer.writeln(
      '$spacing     top: ${component.position.dy.toStringAsFixed(1)},',
    );
    buffer.writeln('$spacing     child: SizedBox(');
    buffer.writeln(
      '$spacing       width: ${component.size.width.toStringAsFixed(1)},',
    );
    buffer.writeln(
      '$spacing       height: ${component.size.height.toStringAsFixed(1)},',
    );
    buffer.writeln(
      '$spacing       child: ${_generateFlutterComponentCode(component, spacing)}',
    );
    buffer.writeln('$spacing     ),');
    buffer.writeln('$spacing   ),');
    buffer.writeln('$spacing ),');

    return buffer.toString();
  }

  String _generateFlutterComponentCode(
    DesignComponent component,
    String spacing,
  ) {
    switch (component.type) {
      case ComponentType.container:
        final shadow = component.properties['shadow'] == true;
        return '''Container(
$spacing       decoration: BoxDecoration(
$spacing         color: Color(${component.properties['backgroundColor']}),
$spacing         borderRadius: BorderRadius.circular(${component.properties['borderRadius']}),
$spacing         border: Border.all(color: Color(${component.properties['borderColor']}), width: ${component.properties['borderWidth']}),
${shadow ? '$spacing         boxShadow: [BoxShadow(color: Color(${component.properties['shadowColor']}), blurRadius: ${component.properties['shadowBlur']}, offset: Offset(${component.properties['shadowOffsetX']}, ${component.properties['shadowOffsetY']}))],\n' : ''}$spacing       ),
$spacing       padding: EdgeInsets.all(${component.properties['padding']}),
$spacing     )''';

      case ComponentType.text:
        return '''Text(
$spacing       '${component.properties['text']}',
$spacing       style: TextStyle(
$spacing         fontSize: ${component.properties['fontSize']},
$spacing         color: Color(${component.properties['color']}),
$spacing         fontWeight: FontWeight.${component.properties['fontWeight']},
$spacing         fontStyle: FontStyle.${component.properties['fontStyle']},
$spacing         letterSpacing: ${component.properties['letterSpacing']},
$spacing         height: ${component.properties['lineHeight']},
$spacing       ),
$spacing       textAlign: TextAlign.${component.properties['textAlign']},
$spacing       maxLines: ${component.properties['maxLines']},
$spacing       overflow: TextOverflow.${component.properties['overflow']},
$spacing     )''';

      case ComponentType.button:
        return '''ElevatedButton(
$spacing       style: ElevatedButton.styleFrom(
$spacing         backgroundColor: Color(${component.properties['backgroundColor']}),
$spacing         foregroundColor: Color(${component.properties['textColor']}),
$spacing         elevation: ${component.properties['elevation']},
$spacing         padding: EdgeInsets.all(${component.properties['padding']}),
$spacing         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(${component.properties['borderRadius']})),
$spacing       ),
$spacing       onPressed: () {},
$spacing       child: Text('${component.properties['text']}', style: TextStyle(fontSize: ${component.properties['fontSize']})),
$spacing     )''';

      case ComponentType.image:
        return '''ClipRRect(
$spacing       borderRadius: BorderRadius.circular(${component.properties['borderRadius']}),
$spacing       child: Opacity(
$spacing         opacity: ${component.properties['opacity']},
$spacing         child: Image.network('${component.properties['url']}', fit: BoxFit.${component.properties['fit']}),
$spacing       ),
$spacing     )''';

      case ComponentType.input:
        return '''TextField(
$spacing       decoration: InputDecoration(
$spacing         hintText: '${component.properties['placeholder']}',
$spacing         labelText: '${component.properties['labelText']}',
$spacing         filled: true,
$spacing         fillColor: Color(${component.properties['backgroundColor']}),
$spacing         border: OutlineInputBorder(borderRadius: BorderRadius.circular(${component.properties['borderRadius']})),
$spacing       ),
$spacing     )''';

      case ComponentType.checkbox:
        return '''Checkbox(
$spacing       value: ${component.properties['checked']},
$spacing       onChanged: (v) {},
$spacing       activeColor: Color(${component.properties['activeColor']}),
$spacing     )''';

      case ComponentType.slider:
        return '''Slider(
$spacing       value: ${component.properties['value']},
$spacing       onChanged: (v) {},
$spacing       min: ${component.properties['min']},
$spacing       max: ${component.properties['max']},
$spacing       divisions: ${component.properties['divisions']},
$spacing     )''';

      case ComponentType.icon:
        return '''Icon(
$spacing       Icons.${component.properties['icon']},
$spacing       color: Color(${component.properties['color']}),
$spacing       size: ${component.properties['size']},
$spacing     )''';

      default:
        return 'Container()';
    }
  }

  String _generateReactCode() {
    final buffer = StringBuffer();
    buffer.writeln('import React, { useState, useEffect } from \'react\';');
    buffer.writeln('');
    buffer.writeln('const GeneratedPage = () => {');
    buffer.writeln('  const [mounted, setMounted] = useState(false);');
    buffer.writeln('');
    buffer.writeln('  useEffect(() => {');
    buffer.writeln('    setMounted(true);');
    buffer.writeln('  }, []);');
    buffer.writeln('');
    buffer.writeln('  return (');
    buffer.writeln(
      '    <div style={{ position: \'relative\', width: \'100%\', minHeight: \'100vh\' }}>',
    );

    final sortedComponents = List<DesignComponent>.from(components)
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    for (var component in sortedComponents) {
      buffer.write(_generateReactComponent(component, indent: 6));
    }

    buffer.writeln('    </div>');
    buffer.writeln('  );');
    buffer.writeln('};');
    buffer.writeln('');
    buffer.writeln('export default GeneratedPage;');

    return buffer.toString();
  }

  String _generateReactComponent(DesignComponent component, {int indent = 0}) {
    final spacing = ' ' * indent;
    final buffer = StringBuffer();
    final animType = component.animation.type;

    final baseStyle = {
      'position': 'absolute',
      'left': '${component.position.dx.toStringAsFixed(0)}px',
      'top': '${component.position.dy.toStringAsFixed(0)}px',
      'width': '${component.size.width.toStringAsFixed(0)}px',
      'height': '${component.size.height.toStringAsFixed(0)}px',
      'zIndex': component.zIndex.toString(),
    };

    if (animType != AnimationType.none) {
      baseStyle['transition'] = 'all ${component.animation.duration}s ease';
      baseStyle['animation'] =
          '${animType.toString().split('.').last} ${component.animation.duration}s ${component.animation.delay}s ${component.animation.repeat ? 'infinite' : 'forwards'}';
    }

    switch (component.type) {
      case ComponentType.container:
        baseStyle['backgroundColor'] = _colorToHex(
          component.properties['backgroundColor'],
        );
        baseStyle['borderRadius'] = '${component.properties['borderRadius']}px';
        baseStyle['border'] =
            '${component.properties['borderWidth']}px solid ${_colorToHex(component.properties['borderColor'])}';
        if (component.properties['shadow'] == true) {
          baseStyle['boxShadow'] =
              '${component.properties['shadowOffsetX']}px ${component.properties['shadowOffsetY']}px ${component.properties['shadowBlur']}px ${_colorToHex(component.properties['shadowColor'])}';
        }
        buffer.writeln(
          '$spacing<div style={${_styleToReactString(baseStyle)}}></div>',
        );
        break;

      case ComponentType.text:
        baseStyle['fontSize'] = '${component.properties['fontSize']}px';
        baseStyle['color'] = _colorToHex(component.properties['color']);
        baseStyle['fontWeight'] = component.properties['fontWeight'];
        baseStyle['textAlign'] = component.properties['textAlign'];
        buffer.writeln(
          '$spacing<div style={${_styleToReactString(baseStyle)}}>${component.properties['text']}</div>',
        );
        break;

      case ComponentType.button:
        baseStyle['backgroundColor'] = _colorToHex(
          component.properties['backgroundColor'],
        );
        baseStyle['color'] = _colorToHex(component.properties['textColor']);
        baseStyle['borderRadius'] = '${component.properties['borderRadius']}px';
        baseStyle['border'] = 'none';
        baseStyle['padding'] = '${component.properties['padding']}px';
        baseStyle['cursor'] = 'pointer';
        buffer.writeln(
          '$spacing<button style={${_styleToReactString(baseStyle)}}>${component.properties['text']}</button>',
        );
        break;

      case ComponentType.input:
        baseStyle['padding'] = '${component.properties['padding']}px';
        baseStyle['borderRadius'] = '${component.properties['borderRadius']}px';
        baseStyle['border'] =
            '${component.properties['borderWidth']}px solid ${_colorToHex(component.properties['borderColor'])}';
        buffer.writeln(
          '$spacing<input type="text" placeholder="${component.properties['placeholder']}" style={${_styleToReactString(baseStyle)}} />',
        );
        break;

      case ComponentType.checkbox:
        buffer.writeln(
          '$spacing<input type="checkbox" style={${_styleToReactString(baseStyle)}} />',
        );
        break;

      case ComponentType.slider:
        buffer.writeln(
          '$spacing<input type="range" min="${component.properties['min']}" max="${component.properties['max']}" style={${_styleToReactString(baseStyle)}} />',
        );
        break;

      default:
        buffer.writeln(
          '$spacing<div style={${_styleToReactString(baseStyle)}}></div>',
        );
    }

    return buffer.toString();
  }

  String _generateTailwindCode() {
    final buffer = StringBuffer();
    buffer.writeln('<!-- Tailwind CSS Generated Code -->');
    buffer.writeln('<div class="relative w-full min-h-screen">');

    final sortedComponents = List<DesignComponent>.from(components)
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    for (var component in sortedComponents) {
      buffer.write(_generateTailwindComponent(component, indent: 2));
    }

    buffer.writeln('</div>');

    return buffer.toString();
  }

  String _generateTailwindComponent(
    DesignComponent component, {
    int indent = 0,
  }) {
    final spacing = ' ' * indent;
    final buffer = StringBuffer();
    final classes = <String>['absolute'];

    switch (component.type) {
      case ComponentType.container:
        classes.addAll(['rounded-lg', 'border', 'shadow-md', 'p-4']);
        buffer.writeln(
          '$spacing<div class="${classes.join(' ')}" style="left: ${component.position.dx}px; top: ${component.position.dy}px; width: ${component.size.width}px; height: ${component.size.height}px;"></div>',
        );
        break;

      case ComponentType.text:
        classes.addAll(['text-base', 'font-normal']);
        buffer.writeln(
          '$spacing<div class="${classes.join(' ')}" style="left: ${component.position.dx}px; top: ${component.position.dy}px;">${component.properties['text']}</div>',
        );
        break;

      case ComponentType.button:
        classes.addAll([
          'bg-blue-500',
          'text-white',
          'rounded-lg',
          'px-4',
          'py-2',
          'hover:bg-blue-600',
        ]);
        buffer.writeln(
          '$spacing<button class="${classes.join(' ')}" style="left: ${component.position.dx}px; top: ${component.position.dy}px;">${component.properties['text']}</button>',
        );
        break;

      default:
        buffer.writeln(
          '$spacing<div class="${classes.join(' ')}" style="left: ${component.position.dx}px; top: ${component.position.dy}px;"></div>',
        );
    }

    return buffer.toString();
  }

  String _generateReactNativeCode() {
    final buffer = StringBuffer();
    buffer.writeln('import React from \'react\';');
    buffer.writeln(
      'import { View, Text, TouchableOpacity, TextInput, Image, StyleSheet } from \'react-native\';',
    );
    buffer.writeln('');
    buffer.writeln('const GeneratedPage = () => {');
    buffer.writeln('  return (');
    buffer.writeln('    <View style={styles.container}>');

    for (var i = 0; i < components.length; i++) {
      buffer.write(_generateReactNativeComponent(components[i], i, indent: 6));
    }

    buffer.writeln('    </View>');
    buffer.writeln('  );');
    buffer.writeln('};');
    buffer.writeln('');
    buffer.writeln('const styles = StyleSheet.create({');
    buffer.writeln('  container: { flex: 1 },');

    for (var i = 0; i < components.length; i++) {
      final component = components[i];
      buffer.writeln('  component$i: {');
      buffer.writeln('    position: \'absolute\',');
      buffer.writeln('    left: ${component.position.dx.toStringAsFixed(0)},');
      buffer.writeln('    top: ${component.position.dy.toStringAsFixed(0)},');
      buffer.writeln('    width: ${component.size.width.toStringAsFixed(0)},');
      buffer.writeln(
        '    height: ${component.size.height.toStringAsFixed(0)},',
      );

      if (component.type == ComponentType.button) {
        buffer.writeln(
          '    backgroundColor: \'${_colorToHex(component.properties['backgroundColor'])}\',',
        );
        buffer.writeln(
          '    borderRadius: ${component.properties['borderRadius']},',
        );
        buffer.writeln('    justifyContent: \'center\',');
        buffer.writeln('    alignItems: \'center\',');
      }

      buffer.writeln('  },');
    }

    buffer.writeln('});');
    buffer.writeln('');
    buffer.writeln('export default GeneratedPage;');

    return buffer.toString();
  }

  String _generateReactNativeComponent(
    DesignComponent component,
    int index, {
    int indent = 0,
  }) {
    final spacing = ' ' * indent;
    final buffer = StringBuffer();

    switch (component.type) {
      case ComponentType.text:
        buffer.writeln(
          '$spacing<Text style={styles.component$index}>${component.properties['text']}</Text>',
        );
        break;
      case ComponentType.button:
        buffer.writeln(
          '$spacing<TouchableOpacity style={styles.component$index}>',
        );
        buffer.writeln(
          '$spacing  <Text style={{ color: \'${_colorToHex(component.properties['textColor'])}\' }}>${component.properties['text']}</Text>',
        );
        buffer.writeln('$spacing</TouchableOpacity>');
        break;
      case ComponentType.input:
        buffer.writeln(
          '$spacing<TextInput style={styles.component$index} placeholder="${component.properties['placeholder']}" />',
        );
        break;
      default:
        buffer.writeln('$spacing<View style={styles.component$index} />');
    }

    return buffer.toString();
  }

  String _generateHTMLCode() {
    final buffer = StringBuffer();
    buffer.writeln('<!DOCTYPE html>');
    buffer.writeln('<html lang="en">');
    buffer.writeln('<head>');
    buffer.writeln('  <meta charset="UTF-8">');
    buffer.writeln(
      '  <meta name="viewport" content="width=device-width, initial-scale=1.0">',
    );
    buffer.writeln('  <title>Generated Page</title>');
    buffer.writeln('  <style>');
    buffer.writeln('    * { margin: 0; padding: 0; box-sizing: border-box; }');
    buffer.writeln(
      '    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; }',
    );
    buffer.writeln(
      '    .container { position: relative; width: 100%; min-height: 100vh; }',
    );

    // Add animation keyframes
    buffer.writeln(
      '    @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }',
    );
    buffer.writeln(
      '    @keyframes slideInLeft { from { transform: translateX(-50px); opacity: 0; } to { transform: translateX(0); opacity: 1; } }',
    );
    buffer.writeln(
      '    @keyframes scaleIn { from { transform: scale(0); } to { transform: scale(1); } }',
    );

    buffer.writeln('  </style>');
    buffer.writeln('</head>');
    buffer.writeln('<body>');
    buffer.writeln('  <div class="container">');

    final sortedComponents = List<DesignComponent>.from(components)
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    for (var component in sortedComponents) {
      buffer.write(_generateHTMLElement(component, indent: 4));
    }

    buffer.writeln('  </div>');
    buffer.writeln('</body>');
    buffer.writeln('</html>');

    return buffer.toString();
  }

  String _generateHTMLElement(DesignComponent component, {int indent = 0}) {
    final spacing = ' ' * indent;
    final buffer = StringBuffer();

    var style =
        'position: absolute; left: ${component.position.dx.toStringAsFixed(0)}px; top: ${component.position.dy.toStringAsFixed(0)}px; width: ${component.size.width.toStringAsFixed(0)}px; height: ${component.size.height.toStringAsFixed(0)}px;';

    if (component.animation.type != AnimationType.none) {
      style +=
          ' animation: ${component.animation.type.toString().split('.').last} ${component.animation.duration}s ${component.animation.delay}s ${component.animation.repeat ? 'infinite' : 'forwards'};';
    }

    switch (component.type) {
      case ComponentType.container:
        style +=
            ' background-color: ${_colorToHex(component.properties['backgroundColor'])};';
        style += ' border-radius: ${component.properties['borderRadius']}px;';
        if (component.properties['shadow'] == true) {
          style +=
              ' box-shadow: ${component.properties['shadowOffsetX']}px ${component.properties['shadowOffsetY']}px ${component.properties['shadowBlur']}px ${_colorToHex(component.properties['shadowColor'])};';
        }
        buffer.writeln('$spacing<div style="$style"></div>');
        break;

      case ComponentType.text:
        style += ' font-size: ${component.properties['fontSize']}px;';
        style += ' color: ${_colorToHex(component.properties['color'])};';
        buffer.writeln(
          '$spacing<div style="$style">${component.properties['text']}</div>',
        );
        break;

      case ComponentType.button:
        style +=
            ' background-color: ${_colorToHex(component.properties['backgroundColor'])};';
        style += ' color: ${_colorToHex(component.properties['textColor'])};';
        style += ' border-radius: ${component.properties['borderRadius']}px;';
        style += ' border: none; cursor: pointer;';
        buffer.writeln(
          '$spacing<button style="$style">${component.properties['text']}</button>',
        );
        break;

      case ComponentType.input:
        style += ' padding: ${component.properties['padding']}px;';
        style += ' border-radius: ${component.properties['borderRadius']}px;';
        buffer.writeln(
          '$spacing<input type="text" placeholder="${component.properties['placeholder']}" style="$style" />',
        );
        break;

      default:
        buffer.writeln('$spacing<div style="$style"></div>');
    }

    return buffer.toString();
  }

  String _generateVueCode() {
    final buffer = StringBuffer();
    buffer.writeln('<template>');
    buffer.writeln('  <div class="container">');

    for (var component in components) {
      buffer.write(_generateVueComponent(component, indent: 4));
    }

    buffer.writeln('  </div>');
    buffer.writeln('</template>');
    buffer.writeln('');
    buffer.writeln('<script>');
    buffer.writeln('export default {');
    buffer.writeln('  name: \'GeneratedPage\',');
    buffer.writeln('};');
    buffer.writeln('</script>');
    buffer.writeln('');
    buffer.writeln('<style scoped>');
    buffer.writeln(
      '.container { position: relative; width: 100%; min-height: 100vh; }',
    );
    buffer.writeln('</style>');

    return buffer.toString();
  }

  String _generateVueComponent(DesignComponent component, {int indent = 0}) {
    final spacing = ' ' * indent;
    final buffer = StringBuffer();

    final styleAttrs = <String>[
      'position: absolute',
      'left: ${component.position.dx.toStringAsFixed(0)}px',
      'top: ${component.position.dy.toStringAsFixed(0)}px',
      'width: ${component.size.width.toStringAsFixed(0)}px',
      'height: ${component.size.height.toStringAsFixed(0)}px',
    ];

    switch (component.type) {
      case ComponentType.button:
        styleAttrs.add(
          'background-color: ${_colorToHex(component.properties['backgroundColor'])}',
        );
        buffer.writeln(
          '$spacing<button :style="{${styleAttrs.join(', ')}}">${component.properties['text']}</button>',
        );
        break;
      default:
        buffer.writeln(
          '$spacing<div :style="{${styleAttrs.join(', ')}}"></div>',
        );
    }

    return buffer.toString();
  }

  String _colorToHex(int colorValue) {
    return '#${colorValue.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  String _styleToReactString(Map<String, String> style) {
    final entries = style.entries
        .map((e) {
          final key = e.key.replaceAllMapped(
            RegExp(r'-([a-z])'),
            (match) => match.group(1)!.toUpperCase(),
          );
          return '$key: \'${e.value}\'';
        })
        .join(', ');
    return '{$entries}';
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.delete) {
            _deleteSelectedComponents();
          } else if (HardwareKeyboard.instance.isControlPressed) {
            if (event.logicalKey == LogicalKeyboardKey.keyZ) {
              _undo();
            } else if (event.logicalKey == LogicalKeyboardKey.keyY) {
              _redo();
            } else if (event.logicalKey == LogicalKeyboardKey.keyC) {
              _copyComponents();
            } else if (event.logicalKey == LogicalKeyboardKey.keyV) {
              _pasteComponents();
            } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
              _duplicateComponents();
            } else if (event.logicalKey == LogicalKeyboardKey.keyG) {
              _groupSelected();
            }
          }
        }
      },
      child: Scaffold(
        backgroundColor:
            _isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
        appBar: _buildAppBar(),
        body: Row(
          children: [
            _buildComponentPalette(),
            Expanded(flex: 3, child: _buildCanvas()),
            if (_showAnimationPanel)
              _buildAnimationPanel()
            else
              _buildPropertiesPanel(),
            if (_showComponentTree) _buildComponentTreePanel(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Advanced Website Designer Pro'),
      actions: [
        // Undo/Redo
        IconButton(
          icon: const Icon(Icons.undo),
          onPressed: _history.canUndo() ? _undo : null,
          tooltip: 'Undo (Ctrl+Z)',
        ),
        IconButton(
          icon: const Icon(Icons.redo),
          onPressed: _history.canRedo() ? _redo : null,
          tooltip: 'Redo (Ctrl+Y)',
        ),
        const VerticalDivider(),

        // Copy/Paste/Duplicate
        IconButton(
          icon: const Icon(Icons.content_copy),
          onPressed: selectedComponents.isNotEmpty ? _copyComponents : null,
          tooltip: 'Copy (Ctrl+C)',
        ),
        IconButton(
          icon: const Icon(Icons.content_paste),
          onPressed: _clipboard.isNotEmpty ? _pasteComponents : null,
          tooltip: 'Paste (Ctrl+V)',
        ),
        IconButton(
          icon: const Icon(Icons.control_point_duplicate),
          onPressed:
              selectedComponents.isNotEmpty ? _duplicateComponents : null,
          tooltip: 'Duplicate (Ctrl+D)',
        ),
        const VerticalDivider(),

        // Alignment
        PopupMenuButton(
          icon: const Icon(Icons.align_horizontal_left),
          tooltip: 'Alignment',
          itemBuilder:
              (context) => [
                const PopupMenuItem(value: 'left', child: Text('Align Left')),
                const PopupMenuItem(
                  value: 'center',
                  child: Text('Align Center'),
                ),
                const PopupMenuItem(value: 'right', child: Text('Align Right')),
                const PopupMenuItem(
                  value: 'distribute',
                  child: Text('Distribute Horizontally'),
                ),
              ],
          onSelected: (value) {
            if (value == 'left') _alignLeft();
            if (value == 'center') _alignCenter();
            if (value == 'right') _alignRight();
            if (value == 'distribute') _distributeHorizontally();
          },
        ),

        // Group/Ungroup
        IconButton(
          icon: const Icon(Icons.group_work),
          onPressed: selectedComponents.length > 1 ? _groupSelected : null,
          tooltip: 'Group (Ctrl+G)',
        ),
        IconButton(
          icon: const Icon(Icons.ungroup),
          onPressed:
              selectedComponent?.groupId != null ? _ungroupSelected : null,
          tooltip: 'Ungroup',
        ),
        const VerticalDivider(),

        // Z-Index
        IconButton(
          icon: const Icon(Icons.flip_to_front),
          onPressed: selectedComponent != null ? _bringToFront : null,
          tooltip: 'Bring to Front',
        ),
        IconButton(
          icon: const Icon(Icons.flip_to_back),
          onPressed: selectedComponent != null ? _sendToBack : null,
          tooltip: 'Send to Back',
        ),
        const VerticalDivider(),

        // View options
        IconButton(
          icon: Icon(_showGrid ? Icons.grid_on : Icons.grid_off),
          onPressed: () => setState(() => _showGrid = !_showGrid),
          tooltip: 'Toggle Grid',
        ),
        IconButton(
          icon: Icon(_snapToGrid ? Icons.sync_alt : Icons.sync_disabled),
          onPressed: () => setState(() => _snapToGrid = !_snapToGrid),
          tooltip: 'Snap to Grid',
        ),
        IconButton(
          icon: Icon(
            _showComponentTree
                ? Icons.account_tree
                : Icons.account_tree_outlined,
          ),
          onPressed:
              () => setState(() => _showComponentTree = !_showComponentTree),
          tooltip: 'Component Tree',
        ),
        IconButton(
          icon: Icon(
            _showAnimationPanel ? Icons.animation : Icons.animation_outlined,
          ),
          onPressed:
              () => setState(() => _showAnimationPanel = !_showAnimationPanel),
          tooltip: 'Animation Panel',
        ),
        const VerticalDivider(),

        // Responsive
        SegmentedButton<ResponsiveBreakpoint>(
          segments: const [
            ButtonSegment(
              value: ResponsiveBreakpoint.mobile,
              icon: Icon(Icons.phone_android, size: 16),
            ),
            ButtonSegment(
              value: ResponsiveBreakpoint.tablet,
              icon: Icon(Icons.tablet_mac, size: 16),
            ),
            ButtonSegment(
              value: ResponsiveBreakpoint.desktop,
              icon: Icon(Icons.desktop_windows, size: 16),
            ),
          ],
          selected: {_currentBreakpoint},
          onSelectionChanged: (Set<ResponsiveBreakpoint> selection) {
            setState(() => _currentBreakpoint = selection.first);
          },
        ),
        const VerticalDivider(),

        // Save/Load/Export
        PopupMenuButton(
          icon: const Icon(Icons.menu),
          tooltip: 'More Options',
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'save',
                  child: Row(
                    children: [
                      Icon(Icons.save),
                      SizedBox(width: 8),
                      Text('Save Project'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'load',
                  child: Row(
                    children: [
                      Icon(Icons.folder_open),
                      SizedBox(width: 8),
                      Text('Load Project'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'export_image',
                  child: Row(
                    children: [
                      Icon(Icons.image),
                      SizedBox(width: 8),
                      Text('Export as Image'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'code',
                  child: Row(
                    children: [
                      Icon(Icons.code),
                      SizedBox(width: 8),
                      Text('Generate Code'),
                    ],
                  ),
                ),
              ],
          onSelected: (value) {
            if (value == 'save') _saveProject();
            if (value == 'load') _showLoadDialog(context);
            if (value == 'export_image') _exportAsImage();
            if (value == 'code') _showCodeDialog(context);
          },
        ),

        // Delete
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed:
              selectedComponents.isNotEmpty ? _deleteSelectedComponents : null,
          tooltip: 'Delete (Delete)',
          color: Colors.red,
        ),
        const VerticalDivider(),

        // Theme
        IconButton(
          icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
          onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
          tooltip: 'Toggle Theme',
        ),
      ],
    );
  }

  Widget _buildComponentPalette() {
    return Container(
      width: 220,
      color: _isDarkMode ? Colors.grey.shade800 : Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Components',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: Icon(Icons.search, size: 20),
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onChanged:
                      (value) =>
                          setState(() => _searchQuery = value.toLowerCase()),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(child: ListView(children: _buildFilteredComponents())),
        ],
      ),
    );
  }

  List<Widget> _buildFilteredComponents() {
    final items = [
      {
        'type': ComponentType.container,
        'icon': Icons.crop_square,
        'label': 'Container',
        'category': 'Layout',
      },
      {
        'type': ComponentType.column,
        'icon': Icons.view_column,
        'label': 'Column',
        'category': 'Layout',
      },
      {
        'type': ComponentType.row,
        'icon': Icons.view_week,
        'label': 'Row',
        'category': 'Layout',
      },
      {
        'type': ComponentType.stack,
        'icon': Icons.layers,
        'label': 'Stack',
        'category': 'Layout',
      },
      {
        'type': ComponentType.text,
        'icon': Icons.text_fields,
        'label': 'Text',
        'category': 'Content',
      },
      {
        'type': ComponentType.image,
        'icon': Icons.image,
        'label': 'Image',
        'category': 'Content',
      },
      {
        'type': ComponentType.icon,
        'icon': Icons.star,
        'label': 'Icon',
        'category': 'Content',
      },
      {
        'type': ComponentType.button,
        'icon': Icons.smart_button,
        'label': 'Button',
        'category': 'Input',
      },
      {
        'type': ComponentType.input,
        'icon': Icons.input,
        'label': 'Input',
        'category': 'Input',
      },
      {
        'type': ComponentType.checkbox,
        'icon': Icons.check_box,
        'label': 'Checkbox',
        'category': 'Input',
      },
      {
        'type': ComponentType.radioButton,
        'icon': Icons.radio_button_checked,
        'label': 'Radio',
        'category': 'Input',
      },
      {
        'type': ComponentType.slider,
        'icon': Icons.tune,
        'label': 'Slider',
        'category': 'Input',
      },
      {
        'type': ComponentType.card,
        'icon': Icons.credit_card,
        'label': 'Card',
        'category': 'Surface',
      },
      {
        'type': ComponentType.divider,
        'icon': Icons.horizontal_rule,
        'label': 'Divider',
        'category': 'Surface',
      },
      {
        'type': ComponentType.appBar,
        'icon': Icons.space_bar,
        'label': 'App Bar',
        'category': 'Navigation',
      },
      {
        'type': ComponentType.navigationBar,
        'icon': Icons.navigation,
        'label': 'Nav Bar',
        'category': 'Navigation',
      },
    ];

    final filtered =
        items
            .where(
              (item) =>
                  (item['label'] as String).toLowerCase().contains(
                    _searchQuery,
                  ) ||
                  (item['category'] as String).toLowerCase().contains(
                    _searchQuery,
                  ),
            )
            .toList();

    final grouped = <String, List<Map<String, dynamic>>>{};
    for (var item in filtered) {
      final category = item['category'] as String;
      grouped.putIfAbsent(category, () => []).add(item);
    }

    final widgets = <Widget>[];
    grouped.forEach((category, items) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            category,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
      );
      widgets.addAll(
        items.map(
          (item) => _buildPaletteItem(
            item['type'] as ComponentType,
            item['icon'] as IconData,
            item['label'] as String,
          ),
        ),
      );
    });

    return widgets;
  }

  Widget _buildPaletteItem(ComponentType type, IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(label, style: const TextStyle(fontSize: 13)),
      onTap: () => _addComponent(type),
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildCanvas() {
    return Container(
      color: _isDarkMode ? Colors.grey.shade850 : Colors.white,
      margin: const EdgeInsets.all(16),
      child: ClipRect(
        child: Stack(
          children: [
            if (_showGrid)
              CustomPaint(
                size: Size.infinite,
                painter: GridPainter(gridSize: _gridSize, isDark: _isDarkMode),
              ),
            ...components.map((c) => _buildDraggableComponent(c)).toList(),
            if (_selectionStart != null && _selectionEnd != null)
              _buildSelectionBox(),
            Positioned(bottom: 16, right: 16, child: _buildZoomControls()),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionBox() {
    final start = _selectionStart!;
    final end = _selectionEnd!;
    final left = math.min(start.dx, end.dx);
    final top = math.min(start.dy, end.dy);
    final width = (start.dx - end.dx).abs();
    final height = (start.dy - end.dy).abs();

    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 2),
          color: Colors.blue.withOpacity(0.1),
        ),
      ),
    );
  }

  Widget _buildZoomControls() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed:
                  () => setState(
                    () => _canvasZoom = (_canvasZoom - 0.1).clamp(0.5, 2.0),
                  ),
              iconSize: 16,
              tooltip: 'Zoom Out',
            ),
            Text(
              '${(_canvasZoom * 100).toInt()}%',
              style: const TextStyle(fontSize: 12),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed:
                  () => setState(
                    () => _canvasZoom = (_canvasZoom + 0.1).clamp(0.5, 2.0),
                  ),
              iconSize: 16,
              tooltip: 'Zoom In',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => setState(() => _canvasZoom = 1.0),
              iconSize: 16,
              tooltip: 'Reset Zoom',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableComponent(DesignComponent component) {
    final isSelected = selectedComponents.any((c) => c.id == component.id);

    return Positioned(
      left: component.position.dx * _canvasZoom,
      top: component.position.dy * _canvasZoom,
      child: GestureDetector(
        onPanUpdate: (details) {
          if (!component.locked) {
            setState(() {
              var newPosition = Offset(
                component.position.dx + details.delta.dx / _canvasZoom,
                component.position.dy + details.delta.dy / _canvasZoom,
              );
              component.position = _snapToGridIfEnabled(newPosition);
            });
          }
        },
        onPanEnd: (_) => _history.addState(components),
        onTap: () {
          setState(() {
            if (HardwareKeyboard.instance.isShiftPressed) {
              if (isSelected) {
                selectedComponents.removeWhere((c) => c.id == component.id);
              } else {
                selectedComponents.add(component);
              }
            } else {
              selectedComponents = [component];
            }
          });
        },
        child: Transform.scale(
          scale: _canvasZoom,
          alignment: Alignment.topLeft,
          child: Stack(
            children: [
              Container(
                width: component.size.width,
                height: component.size.height,
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        isSelected
                            ? Colors.blue
                            : (component.locked
                                ? Colors.red
                                : Colors.transparent),
                    width: 2,
                  ),
                ),
                child: _buildComponentWidget(component),
              ),
              if (isSelected && !component.locked)
                ..._buildResizeHandles(component),
              if (component.locked)
                const Positioned(
                  top: 4,
                  right: 4,
                  child: Icon(Icons.lock, size: 16, color: Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildResizeHandles(DesignComponent component) {
    return [
      Positioned(
        right: -4,
        bottom: -4,
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              component.size = Size(
                (component.size.width + details.delta.dx / _canvasZoom).clamp(
                  20,
                  2000,
                ),
                (component.size.height + details.delta.dy / _canvasZoom).clamp(
                  20,
                  2000,
                ),
              );
            });
          },
          onPanEnd: (_) => _history.addState(components),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.blue,
              border: Border.all(color: Colors.white, width: 1),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildComponentWidget(DesignComponent component) {
    switch (component.type) {
      case ComponentType.container:
        return Container(
          decoration: BoxDecoration(
            color: Color(component.properties['backgroundColor']),
            borderRadius: BorderRadius.circular(
              component.properties['borderRadius'],
            ),
            border: Border.all(
              color: Color(component.properties['borderColor']),
              width: component.properties['borderWidth'],
            ),
            boxShadow:
                component.properties['shadow'] == true
                    ? [
                      BoxShadow(
                        color: Color(component.properties['shadowColor']),
                        blurRadius: component.properties['shadowBlur'],
                        offset: Offset(
                          component.properties['shadowOffsetX'],
                          component.properties['shadowOffsetY'],
                        ),
                      ),
                    ]
                    : null,
          ),
          padding: EdgeInsets.all(component.properties['padding']),
        );

      case ComponentType.text:
        return Text(
          component.properties['text'],
          style: TextStyle(
            fontSize: component.properties['fontSize'],
            color: Color(component.properties['color']),
            fontWeight:
                component.properties['fontWeight'] == 'bold'
                    ? FontWeight.bold
                    : FontWeight.normal,
            fontStyle:
                component.properties['fontStyle'] == 'italic'
                    ? FontStyle.italic
                    : FontStyle.normal,
          ),
        );

      case ComponentType.button:
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(component.properties['backgroundColor']),
            foregroundColor: Color(component.properties['textColor']),
          ),
          onPressed: () {},
          child: Text(component.properties['text']),
        );

      case ComponentType.checkbox:
        return Checkbox(
          value: component.properties['checked'],
          onChanged: (v) {},
          activeColor: Color(component.properties['activeColor']),
        );

      case ComponentType.slider:
        return Slider(
          value: component.properties['value'],
          onChanged: (v) {},
          min: component.properties['min'],
          max: component.properties['max'],
        );

      case ComponentType.icon:
        return Icon(
          Icons.star,
          color: Color(component.properties['color']),
          size: component.properties['size'],
        );

      default:
        return Container(
          color: Colors.grey.shade200,
          child: Center(child: Text(component.type.toString().split('.').last)),
        );
    }
  }

  Widget _buildPropertiesPanel() {
    return Container(
      width: 300,
      color: _isDarkMode ? Colors.grey.shade800 : Colors.white,
      child:
          selectedComponent == null
              ? const Center(child: Text('Select a component'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Properties',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    _buildBasicProperties(),
                    const Divider(),
                    _buildTypeSpecificProperties(),
                  ],
                ),
              ),
    );
  }

  Widget _buildBasicProperties() {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text('Locked'),
          value: selectedComponent!.locked,
          onChanged:
              (v) => setState(() {
                selectedComponent!.locked = v!;
                _history.addState(components);
              }),
        ),
      ],
    );
  }

  Widget _buildTypeSpecificProperties() {
    // Return type-specific property editors based on component type
    return const SizedBox();
  }

  Widget _buildAnimationPanel() {
    return Container(
      width: 300,
      color: _isDarkMode ? Colors.grey.shade800 : Colors.white,
      child:
          selectedComponent == null
              ? const Center(child: Text('Select a component'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Animation',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<AnimationType>(
                      value: selectedComponent!.animation.type,
                      decoration: const InputDecoration(
                        labelText: 'Animation Type',
                      ),
                      items:
                          AnimationType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type.toString().split('.').last),
                            );
                          }).toList(),
                      onChanged:
                          (value) => setState(() {
                            selectedComponent!.animation.type = value!;
                            _history.addState(components);
                          }),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Duration: ${selectedComponent!.animation.duration.toStringAsFixed(1)}s',
                    ),
                    Slider(
                      value: selectedComponent!.animation.duration,
                      min: 0.1,
                      max: 5.0,
                      onChanged:
                          (v) => setState(() {
                            selectedComponent!.animation.duration = v;
                            _history.addState(components);
                          }),
                    ),
                    Text(
                      'Delay: ${selectedComponent!.animation.delay.toStringAsFixed(1)}s',
                    ),
                    Slider(
                      value: selectedComponent!.animation.delay,
                      min: 0.0,
                      max: 3.0,
                      onChanged:
                          (v) => setState(() {
                            selectedComponent!.animation.delay = v;
                            _history.addState(components);
                          }),
                    ),
                    CheckboxListTile(
                      title: const Text('Repeat'),
                      value: selectedComponent!.animation.repeat,
                      onChanged:
                          (v) => setState(() {
                            selectedComponent!.animation.repeat = v!;
                            _history.addState(components);
                          }),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildComponentTreePanel() {
    return Container(
      width: 250,
      color: _isDarkMode ? Colors.grey.shade800 : Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Component Tree',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: components.length,
              itemBuilder: (context, index) {
                final component = components[index];
                return ListTile(
                  leading: Icon(_getComponentIcon(component.type), size: 20),
                  title: Text(
                    '${component.type.toString().split('.').last} #${component.id.split('_').last}',
                  ),
                  selected: selectedComponents.any((c) => c.id == component.id),
                  onTap: () => setState(() => selectedComponents = [component]),
                  trailing:
                      component.locked
                          ? const Icon(Icons.lock, size: 16)
                          : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getComponentIcon(ComponentType type) {
    switch (type) {
      case ComponentType.container:
        return Icons.crop_square;
      case ComponentType.text:
        return Icons.text_fields;
      case ComponentType.button:
        return Icons.smart_button;
      case ComponentType.checkbox:
        return Icons.check_box;
      default:
        return Icons.widgets;
    }
  }

  void _showCodeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Row(
                    children: [
                      const Text('Generate Code'),
                      const Spacer(),
                      DropdownButton<String>(
                        value: selectedFramework,
                        items:
                            [
                                  'Flutter',
                                  'Flutter (Animated)',
                                  'React',
                                  'React Native',
                                  'HTML/CSS',
                                  'Vue.js',
                                  'Tailwind CSS',
                                  'Jinja2 Template',
                                  'Mustache Template',
                                ]
                                .map(
                                  (f) => DropdownMenuItem(
                                    value: f,
                                    child: Text(f),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() => selectedFramework = value!);
                          setDialogState(() {});
                        },
                      ),
                    ],
                  ),
                  content: SizedBox(
                    width: 800,
                    height: 600,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.grey.shade100,
                          child: Row(
                            children: [
                              Chip(
                                label: Text(selectedFramework),
                                avatar: const Icon(Icons.code, size: 16),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                icon: const Icon(Icons.copy),
                                label: const Text('Copy'),
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: _generateCode()),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Code copied!'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade900,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: SingleChildScrollView(
                              child: SelectableText(
                                _generateCode(),
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showLoadDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Load Project'),
            content: SizedBox(
              width: 500,
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Paste JSON data',
                  border: OutlineInputBorder(),
                ),
                maxLines: 10,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  _loadProject(controller.text);
                  Navigator.pop(context);
                },
                child: const Text('Load'),
              ),
            ],
          ),
    );
  }
}
