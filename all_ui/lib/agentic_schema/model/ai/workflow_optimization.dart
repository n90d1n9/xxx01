enum OptimizationType { parallelization, errorHandling, caching, performance }

class WorkflowOptimization {
  final OptimizationType type;
  final String title;
  final String description;
  final String impact;

  WorkflowOptimization({
    required this.type,
    required this.title,
    required this.description,
    required this.impact,
  });
}
