class TemplateRenderer {
  static String render(String template, Map<String, dynamic> context) {
    String result = template;
    final simpleVarRegex = RegExp(r'\{\{([^#/\}]+)\}\}');
    result = result.replaceAllMapped(simpleVarRegex, (match) {
      final key = match.group(1)!.trim();
      final value = _getValue(context, key);
      return value?.toString() ?? '';
    });
    final sectionRegex = RegExp(r'\{\{#(\w+)\}\}([\s\S]*?)\{\{/\1\}\}');
    result = result.replaceAllMapped(sectionRegex, (match) {
      final key = match.group(1)!;
      final content = match.group(2)!;
      final value = context[key];
      if (value is List) {
        return value
            .map((item) {
              final itemContext =
                  item is Map<String, dynamic> ? item : {key: item};
              return render(content, {...context, ...itemContext});
            })
            .join('');
      } else if (value is bool && value) {
        return render(content, context);
      } else if (value != null && value != false) {
        return render(content, context);
      }
      return '';
    });
    final invertedRegex = RegExp(r'\{\{\^(\w+)\}\}([\s\S]*?)\{\{/\1\}\}');
    result = result.replaceAllMapped(invertedRegex, (match) {
      final key = match.group(1)!;
      final content = match.group(2)!;
      final value = context[key];
      if (value == null || value == false || (value is List && value.isEmpty)) {
        return render(content, context);
      }
      return '';
    });
    return result;
  }

  static dynamic _getValue(Map<String, dynamic> context, String key) {
    if (context.containsKey(key)) {
      return context[key];
    }
    if (key.contains('.')) {
      final parts = key.split('.');
      dynamic value = context;
      for (final part in parts) {
        if (value is Map && value.containsKey(part)) {
          value = value[part];
        } else {
          return null;
        }
      }
      return value;
    }
    return null;
  }
}
