class MermaidValidator {
  static bool validate(String content) {
    // Basic syntax validation
    if (content.isEmpty) return false;

    final validKeywords = [
      'graph',
      'flowchart',
      'sequenceDiagram',
      'classDiagram',
      'stateDiagram',
      'erDiagram',
      'gantt',
      'pie',
    ];

    final lines = content.trim().split('\n');
    if (lines.isEmpty) return false;

    final firstLine = lines[0].trim().toLowerCase();
    return validKeywords.any((keyword) => firstLine.startsWith(keyword.toLowerCase()));
  }
}
