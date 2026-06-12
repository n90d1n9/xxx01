enum BuilderLayoutMechanism {
  freeform(
    key: 'freeform',
    label: 'Freeform',
    description: 'Manual placement with optional snap rules.',
  ),
  grid(
    key: 'grid',
    label: 'Grid',
    description: 'Snap position and size to a regular grid.',
  ),
  tabularColumns(
    key: 'tabular_columns',
    label: 'Tabular Columns',
    description: 'Snap components to fixed columns and row height.',
  ),
  autoGrid(
    key: 'auto_grid',
    label: 'Auto Grid',
    description: 'Arrange components in repeatable cards or tiles.',
  ),
  flexFlow(
    key: 'flex_flow',
    label: 'Flex Flow',
    description: 'Prepare components for row, column, and wrap layouts.',
  );

  const BuilderLayoutMechanism({
    required this.key,
    required this.label,
    required this.description,
  });

  final String key;
  final String label;
  final String description;

  static BuilderLayoutMechanism fromKey(String? key) {
    return BuilderLayoutMechanism.values.firstWhere(
      (mechanism) => mechanism.key == key || mechanism.name == key,
      orElse: () => BuilderLayoutMechanism.grid,
    );
  }
}
