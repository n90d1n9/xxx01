class ChartStoryCategory {
  const ChartStoryCategory({
    required this.id,
    required this.label,
    required this.description,
  });

  final String id;
  final String label;
  final String description;

  Iterable<Object?> get searchValues sync* {
    yield id;
    yield label;
    yield description;
  }
}

const chartStoryCategoryDiscover = ChartStoryCategory(
  id: 'discover',
  label: 'Discover',
  description: 'Overview galleries and broad chart-family discovery stories.',
);

const chartStoryCategoryTooling = ChartStoryCategory(
  id: 'tooling',
  label: 'Tooling',
  description: 'Diagnostics, safety, export, performance, and authoring tools.',
);

const chartStoryCategoryCoreShapes = ChartStoryCategory(
  id: 'core-shapes',
  label: 'Core Shapes',
  description:
      'Core visual encodings organized by data shape and chart family.',
);

const chartStoryCategoryDomainSpecialized = ChartStoryCategory(
  id: 'domain-specialized',
  label: 'Domain & Specialized',
  description: 'Domain-specific and specialized analytical chart families.',
);

const chartStoryCategoryUncategorized = ChartStoryCategory(
  id: 'uncategorized',
  label: 'Uncategorized',
  description: 'Stories that have not been assigned to a navigation category.',
);

const chartStoryCategories = [
  chartStoryCategoryDiscover,
  chartStoryCategoryTooling,
  chartStoryCategoryCoreShapes,
  chartStoryCategoryDomainSpecialized,
];
