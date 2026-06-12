class ClassMember {
  final String name;
  final String type;
  final bool isMethod;
  final String visibility; // +, -, #, ~
  final String parameters;

  ClassMember({
    required this.name,
    required this.type,
    this.isMethod = false,
    this.visibility = '+',
    this.parameters = '', // Made optional with default value
  });

  // Add copyWith method for immutability
  ClassMember copyWith({
    String? name,
    String? type,
    bool? isMethod,
    String? visibility,
    String? parameters,
  }) {
    return ClassMember(
      name: name ?? this.name,
      type: type ?? this.type,
      isMethod: isMethod ?? this.isMethod,
      visibility: visibility ?? this.visibility,
      parameters: parameters ?? this.parameters,
    );
  }

  @override
  String toString() {
    return 'ClassMember(name: $name, type: $type, isMethod: $isMethod, visibility: $visibility, parameters: $parameters)';
  }
}
