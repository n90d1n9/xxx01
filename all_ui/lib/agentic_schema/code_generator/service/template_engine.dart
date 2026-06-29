import 'dart:io';
import 'package:path/path.dart' as path;

class TemplateEngine {
  final Map<String, String> _templateCache = {};
  final String _templateDirectory;
  final Map<String, Function> _helpers = {};
  final Map<String, String> _partials = {};

  TemplateEngine({String templateDirectory = 'templates'})
    : _templateDirectory = templateDirectory {
    _registerDefaultHelpers();
  }

  // Register custom helper functions
  void registerHelper(String name, Function helper) {
    _helpers[name] = helper;
  }

  // Register partial templates
  void registerPartial(String name, String content) {
    _partials[name] = content;
  }

  String render(String templateName, Map<String, dynamic> context) {
    final template = _loadTemplate(templateName);
    return _renderTemplate(template, context);
  }

  String renderString(String template, Map<String, dynamic> context) {
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

    // Handle comments {{! comment }}
    result = result.replaceAll(RegExp(r'{{!.*?}}', dotAll: true), '');

    // Handle partials {{> partial_name}}
    result = result.replaceAllMapped(RegExp(r'{{>\s*([^}]+)\s*}}'), (match) {
      final partialName = match.group(1)!.trim();
      if (_partials.containsKey(partialName)) {
        return _renderTemplate(_partials[partialName]!, context);
      }
      try {
        return _renderTemplate(_loadTemplate(partialName), context);
      } catch (e) {
        return '<!-- Partial not found: $partialName -->';
      }
    });

    // Handle helpers {{helper_name param1 param2}}
    result = result.replaceAllMapped(
      RegExp(r'{{#(\w+)\s+([^}]+)}}(.+?){{/\1}}', dotAll: true),
      (match) {
        final helperName = match.group(1)!;
        final params = match.group(2)!.trim();
        final content = match.group(3)!;

        if (_helpers.containsKey(helperName)) {
          return _callHelper(helperName, params, content, context);
        }

        // Fallback to section rendering
        return _renderSection(helperName, content, context);
      },
    );

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

    // Handle unescaped variables {{{variable}}}
    result = result.replaceAllMapped(RegExp(r'{{{\s*([^}]+)\s*}}}'), (match) {
      final key = match.group(1)!.trim();
      return _getValue(context, key)?.toString() ?? '';
    });

    // Handle escaped variables {{variable}}
    result = result.replaceAllMapped(RegExp(r'{{\s*([^}]+)\s*}}'), (match) {
      final key = match.group(1)!.trim();

      // Check for helper functions (inline)
      if (key.contains(' ')) {
        final parts = key.split(' ');
        final helperName = parts[0];
        if (_helpers.containsKey(helperName)) {
          return _callInlineHelper(helperName, parts.sublist(1), context);
        }
      }

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
            newContext['.'] = item;
            newContext['@index'] = value.toList().indexOf(item);
            newContext['@first'] = value.toList().indexOf(item) == 0;
            newContext['@last'] =
                value.toList().indexOf(item) == value.length - 1;

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

  String _callHelper(
    String name,
    String params,
    String content,
    Map<String, dynamic> context,
  ) {
    if (!_helpers.containsKey(name)) return content;

    final helper = _helpers[name]!;
    final paramList = params.split(' ').map((p) => p.trim()).toList();

    try {
      return helper(paramList, content, context) as String;
    } catch (e) {
      return '<!-- Helper error: $name - $e -->';
    }
  }

  String _callInlineHelper(
    String name,
    List<String> params,
    Map<String, dynamic> context,
  ) {
    if (!_helpers.containsKey(name)) return '';

    final helper = _helpers[name]!;

    try {
      return helper(params, null, context) as String;
    } catch (e) {
      return '<!-- Helper error: $name - $e -->';
    }
  }

  dynamic _getValue(Map<String, dynamic> context, String key) {
    if (key == '.') return context;
    if (key.startsWith('@')) return context[key]; // Special variables

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

  void _registerDefaultHelpers() {
    // if helper: {{#if condition}}...{{/if}}
    registerHelper('if', (params, content, context) {
      if (params.isEmpty) return '';
      final condition = _getValue(context, params[0]);
      return _isTruthy(condition) ? _renderContent(content, context) : '';
    });

    // unless helper: {{#unless condition}}...{{/unless}}
    registerHelper('unless', (params, content, context) {
      if (params.isEmpty) return '';
      final condition = _getValue(context, params[0]);
      return !_isTruthy(condition) ? _renderContent(content, context) : '';
    });

    // each helper: {{#each items}}...{{/each}}
    registerHelper('each', (params, content, context) {
      if (params.isEmpty) return '';
      final items = _getValue(context, params[0]);
      if (items is! Iterable) return '';

      return items
          .map((item) {
            final newContext = Map<String, dynamic>.from(context);
            newContext['.'] = item;
            if (item is Map<String, dynamic>) {
              newContext.addAll(item);
            }
            return _renderContent(content, newContext);
          })
          .join('');
    });

    // with helper: {{#with object}}...{{/with}}
    registerHelper('with', (params, content, context) {
      if (params.isEmpty) return '';
      final obj = _getValue(context, params[0]);
      if (obj is! Map<String, dynamic>) return '';

      final newContext = Map<String, dynamic>.from(context);
      newContext.addAll(obj);
      return _renderContent(content, newContext);
    });

    // uppercase helper: {{uppercase name}}
    registerHelper('uppercase', (params, content, context) {
      if (params.isEmpty) return '';
      final value = _getValue(context, params[0]);
      return value?.toString().toUpperCase() ?? '';
    });

    // lowercase helper: {{lowercase name}}
    registerHelper('lowercase', (params, content, context) {
      if (params.isEmpty) return '';
      final value = _getValue(context, params[0]);
      return value?.toString().toLowerCase() ?? '';
    });

    // camelCase helper: {{camelCase name}}
    registerHelper('camelCase', (params, content, context) {
      if (params.isEmpty) return '';
      final value = _getValue(context, params[0])?.toString() ?? '';
      return _toCamelCase(value);
    });

    // pascalCase helper: {{pascalCase name}}
    registerHelper('pascalCase', (params, content, context) {
      if (params.isEmpty) return '';
      final value = _getValue(context, params[0])?.toString() ?? '';
      return _toPascalCase(value);
    });

    // snakeCase helper: {{snakeCase name}}
    registerHelper('snakeCase', (params, content, context) {
      if (params.isEmpty) return '';
      final value = _getValue(context, params[0])?.toString() ?? '';
      return _toSnakeCase(value);
    });

    // kebabCase helper: {{kebabCase name}}
    registerHelper('kebabCase', (params, content, context) {
      if (params.isEmpty) return '';
      final value = _getValue(context, params[0])?.toString() ?? '';
      return _toKebabCase(value);
    });

    // join helper: {{join items ","}}
    registerHelper('join', (params, content, context) {
      if (params.length < 2) return '';
      final items = _getValue(context, params[0]);
      final separator = params[1].replaceAll('"', '').replaceAll("'", '');
      if (items is! Iterable) return '';
      return items.map((e) => e.toString()).join(separator);
    });

    // eq helper: {{#eq value1 value2}}...{{/eq}}
    registerHelper('eq', (params, content, context) {
      if (params.length < 2) return '';
      final val1 = _getValue(context, params[0]);
      final val2 = _getValue(context, params[1]);
      return val1 == val2 ? _renderContent(content, context) : '';
    });

    // ne helper: {{#ne value1 value2}}...{{/ne}}
    registerHelper('ne', (params, content, context) {
      if (params.length < 2) return '';
      final val1 = _getValue(context, params[0]);
      final val2 = _getValue(context, params[1]);
      return val1 != val2 ? _renderContent(content, context) : '';
    });
  }

  // Case conversion utilities
  String _toCamelCase(String text) {
    return text
        .split(RegExp(r'[_\-\s]+'))
        .asMap()
        .map(
          (i, word) => MapEntry(
            i,
            i == 0 ? word.toLowerCase() : _capitalize(word.toLowerCase()),
          ),
        )
        .values
        .join('');
  }

  String _toPascalCase(String text) {
    return text
        .split(RegExp(r'[_\-\s]+'))
        .map((word) => _capitalize(word.toLowerCase()))
        .join('');
  }

  String _toSnakeCase(String text) {
    return text
        .replaceAllMapped(
          RegExp(r'([a-z0-9])([A-Z])'),
          (match) => '${match.group(1)}_${match.group(2)}',
        )
        .replaceAll(RegExp(r'[\-\s]+'), '_')
        .toLowerCase();
  }

  String _toKebabCase(String text) {
    return text
        .replaceAllMapped(
          RegExp(r'([a-z0-9])([A-Z])'),
          (match) => '${match.group(1)}-${match.group(2)}',
        )
        .replaceAll(RegExp(r'[_\s]+'), '-')
        .toLowerCase();
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  void clearCache() {
    _templateCache.clear();
  }
}
