// Component Statistics
class ComponentStats {
  final Map<String, int> componentUsage;
  final Map<String, double> averageConfigComplexity;
  final List<String> mostUsedComponents;
  final List<String> unusedComponents;

  ComponentStats({
    required this.componentUsage,
    required this.averageConfigComplexity,
    required this.mostUsedComponents,
    required this.unusedComponents,
  });
}
