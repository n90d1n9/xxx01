import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/layout_element.dart';
import 'history_provider.dart';

final selectedElementIdProvider = StateProvider<String?>((ref) => null);

final layoutElementsProvider =
    StateNotifierProvider<LayoutElementsNotifier, List<LayoutElement>>((ref) {
      return LayoutElementsNotifier(ref);
    });

class LayoutElementsNotifier extends StateNotifier<List<LayoutElement>> {
  Ref ref;
  LayoutElementsNotifier(this.ref)
    : super([
        LayoutElement(
          type: 'container',
          properties: {
            'width': double.infinity,
            'height': 500.0,
            'color': Colors.grey[200]!.value,
            'padding': 16.0,
          },
        ),
      ]);

  /* void addElement(LayoutElement element, {String? parentId}) {
    if (parentId == null) {
      state = [...state, element];
      return;
    }

    state = _updateElements(state, parentId, (parent) {
      return parent.copyWith(children: [...parent.children, element]);
    });
  } */

  void recordForUndo(List<LayoutElement> elements) {
    ref
        .read(historyProvider.notifier)
        .recordState(elements.map((e) => e.copyWith()).toList());
  }

  void undo() {
    final previousState = ref.read(historyProvider.notifier).undo(state);
    if (previousState != null) {
      state = previousState;
    }
  }

  void redo() {
    final nextState = ref.read(historyProvider.notifier).redo(state);
    if (nextState != null) {
      state = nextState;
    }
  }

  // Enhanced version of addElement method
  void addElement(LayoutElement element, {String? parentId}) {
    // Record current state for undo
    recordForUndo(state);

    if (parentId == null) {
      state = [...state, element];
      return;
    }

    state = _updateElements(state, parentId, (parent) {
      return parent.copyWith(children: [...parent.children, element]);
    });
  }

  // Enhanced version of updateElement method
  void updateElement(String id, LayoutElement updated) {
    // Record current state for undo
    recordForUndo(state);
    state = _updateElementById(state, id, updated);
  }

  // Enhanced version of deleteElement method
  void deleteElement(String id) {
    // Record current state for undo
    recordForUndo(state);
    state = _removeElementById(state, id);
  }

  // Add this code for export functionality
  String exportToHTML() {
    StringBuffer html = StringBuffer();
    html.writeln('<!DOCTYPE html>');
    html.writeln('<html lang="en">');
    html.writeln('<head>');
    html.writeln('  <meta charset="UTF-8">');
    html.writeln(
      '  <meta name="viewport" content="width=device-width, initial-scale=1.0">',
    );
    html.writeln('  <title>Exported Website</title>');
    html.writeln('  <style>');
    html.writeln(
      '    body { margin: 0; padding: 0; font-family: sans-serif; }',
    );
    html.writeln('  </style>');
    html.writeln('</head>');
    html.writeln('<body>');

    for (var element in state) {
      html.writeln(_renderElementToHTML(element));
    }

    html.writeln('</body>');
    html.writeln('</html>');

    return html.toString();
  }

  String _renderElementToHTML(LayoutElement element) {
    StringBuffer html = StringBuffer();

    switch (element.type) {
      case 'container':
        final width = element.properties['width'] == double.infinity
            ? '100%'
            : '${element.properties['width']}px';
        final height = '${element.properties['height']}px';
        final color =
            '#${Color(element.properties['color']).value.toRadixString(16).substring(2)}';
        final padding = '${element.properties['padding']}px';

        html.write(
          '<div style="width: $width; height: $height; background-color: $color; padding: $padding;">',
        );
        for (var child in element.children) {
          html.write(_renderElementToHTML(child));
        }
        html.write('</div>');
        break;

      case 'text':
        final text = element.properties['text'];
        final fontSize = '${element.properties['fontSize']}px';
        final color =
            '#${Color(element.properties['color']).value.toRadixString(16).substring(2)}';

        html.write('<p style="font-size: $fontSize; color: $color;">$text</p>');
        break;

      case 'image':
        final url = element.properties['url'];
        final width = '${element.properties['width']}px';
        final height = '${element.properties['height']}px';

        html.write(
          '<img src="$url" width="$width" height="$height" style="object-fit: cover;" />',
        );
        break;

      case 'button':
        final text = element.properties['text'];
        final bgColor =
            '#${Color(element.properties['color']).value.toRadixString(16).substring(2)}';
        final textColor =
            '#${Color(element.properties['textColor']).value.toRadixString(16).substring(2)}';

        html.write(
          '<button style="background-color: $bgColor; color: $textColor; border: none; padding: 8px 16px; border-radius: 4px;">$text</button>',
        );
        break;

      default:
        html.write('<div>Unknown element type</div>');
    }

    return html.toString();
  }

  /*   void updateElement(String id, LayoutElement updated) {
    state = _updateElementById(state, id, updated);
  } */

  /*   void deleteElement(String id) {
    state = _removeElementById(state, id);
  } */

  List<LayoutElement> _updateElements(
    List<LayoutElement> elements,
    String targetId,
    LayoutElement Function(LayoutElement) updater,
  ) {
    return elements.map((element) {
      if (element.id == targetId) {
        return updater(element);
      }
      if (element.children.isNotEmpty) {
        return element.copyWith(
          children: _updateElements(element.children, targetId, updater),
        );
      }
      return element;
    }).toList();
  }

  List<LayoutElement> _updateElementById(
    List<LayoutElement> elements,
    String targetId,
    LayoutElement updated,
  ) {
    return elements.map((element) {
      if (element.id == targetId) {
        return updated;
      }
      if (element.children.isNotEmpty) {
        return element.copyWith(
          children: _updateElementById(element.children, targetId, updated),
        );
      }
      return element;
    }).toList();
  }

  List<LayoutElement> _removeElementById(
    List<LayoutElement> elements,
    String targetId,
  ) {
    return elements.where((element) => element.id != targetId).map((element) {
      if (element.children.isNotEmpty) {
        return element.copyWith(
          children: _removeElementById(element.children, targetId),
        );
      }
      return element;
    }).toList();
  }
}
