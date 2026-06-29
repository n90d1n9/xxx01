class ERRelationship {
  final String from;
  final String to;
  final String fromCardinality;
  final String toCardinality;
  final String label;

  ERRelationship({
    required this.from,
    required this.to,
    required this.fromCardinality,
    required this.toCardinality,
    this.label = '',
  });

  // Getter for backward compatibility with 'type'
  String get type => '$fromCardinality-$toCardinality';

  ERRelationship copyWith({
    String? from,
    String? to,
    String? fromCardinality,
    String? toCardinality,
    String? label,
  }) {
    return ERRelationship(
      from: from ?? this.from,
      to: to ?? this.to,
      fromCardinality: fromCardinality ?? this.fromCardinality,
      toCardinality: toCardinality ?? this.toCardinality,
      label: label ?? this.label,
    );
  }

  @override
  String toString() {
    return 'ERRelationship(from: $from, to: $to, fromCardinality: $fromCardinality, toCardinality: $toCardinality, label: $label)';
  }
}
