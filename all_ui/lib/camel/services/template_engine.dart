import 'dart:io';
import 'package:path/path.dart' as path;

import '../models/node.dart';

class TemplateEngine {
  final Map<String, String> _templateCache = {};
  final String _templateDirectory;

  TemplateEngine({String templateDirectory = 'templates'})
    : _templateDirectory = templateDirectory;

  String render(String templateName, Map<String, dynamic> context) {
    final template = _loadTemplate(templateName);
    return _renderTemplate(template, context);
  }

  String _loadTemplate(String templateName) {
    if (_templateCache.containsKey(templateName)) {
      return _templateCache[templateName]!;
    }

    final templatePath = path.join(
      _templateDirectory,
      '$templateName.mustache',
    );
    final file = File(templatePath);

    if (!file.existsSync()) {
      throw Exception('Template not found: $templatePath');
    }

    final content = file.readAsStringSync();
    _templateCache[templateName] = content;
    return content;
  }

  String _renderTemplate(String template, Map<String, dynamic> context) {
    var result = template;

    // Handle partials {{> partial_name}}
    result = result.replaceAllMapped(RegExp(r'{{>\s*([^}]+)\s*}}'), (match) {
      final partialName = match.group(1)!.trim();
      return _loadTemplate(partialName);
    });

    // Handle sections with logic (# and /)
    result = result.replaceAllMapped(
      RegExp(r'{{#(.+?)}}(.+?){{/\1}}', dotAll: true),
      (match) {
        final key = match.group(1)!.trim();
        final content = match.group(2)!;
        return _renderSection(key, content, context);
      },
    );

    // Handle inverted sections (^ and /)
    result = result.replaceAllMapped(
      RegExp(r'{{\^(.+?)}}(.+?){{/\1}}', dotAll: true),
      (match) {
        final key = match.group(1)!.trim();
        final content = match.group(2)!;
        final value = _getValue(context, key);
        return !_isTruthy(value) ? _renderContent(content, context) : '';
      },
    );

    // Handle variables
    result = result.replaceAllMapped(RegExp(r'{{{\s*([^}]+)\s*}}}'), (match) {
      // Triple braces for unescaped HTML
      final key = match.group(1)!.trim();
      return _getValue(context, key)?.toString() ?? '';
    });

    result = result.replaceAllMapped(RegExp(r'{{\s*([^}]+)\s*}}'), (match) {
      // Double braces for escaped output
      final key = match.group(1)!.trim();
      final value = _getValue(context, key)?.toString() ?? '';
      return _escapeHtml(value);
    });

    return result;
  }

  String _renderSection(
    String key,
    String content,
    Map<String, dynamic> context,
  ) {
    final value = _getValue(context, key);

    if (!_isTruthy(value)) {
      return '';
    }

    if (value is Iterable) {
      return value
          .map((item) {
            final newContext = Map<String, dynamic>.from(context);
            newContext['.'] = item; // Current context
            if (item is Map<String, dynamic>) {
              newContext.addAll(item);
            }
            return _renderContent(content, newContext);
          })
          .join('');
    }

    if (value is Map<String, dynamic>) {
      final newContext = Map<String, dynamic>.from(context);
      newContext.addAll(value);
      return _renderContent(content, newContext);
    }

    if (value is bool && value) {
      return _renderContent(content, context);
    }

    return _renderContent(content, context);
  }

  String _renderContent(String content, Map<String, dynamic> context) {
    return _renderTemplate(content, context);
  }

  dynamic _getValue(Map<String, dynamic> context, String key) {
    if (key == '.') return context;

    var current = context;
    final parts = key.split('.');

    for (int i = 0; i < parts.length - 1; i++) {
      final part = parts[i];
      if (current[part] is Map<String, dynamic>) {
        current = current[part];
      } else {
        return null;
      }
    }

    return current[parts.last];
  }

  bool _isTruthy(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is Iterable) return value.isNotEmpty;
    if (value is Map) return value.isNotEmpty;
    if (value is String) return value.isNotEmpty;
    if (value is num) return value != 0;
    return true;
  }

  String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');
  }

  void clearCache() {
    _templateCache.clear();
  }
}
