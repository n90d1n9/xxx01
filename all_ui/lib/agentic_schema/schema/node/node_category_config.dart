class NodeCategoryConfig {
  final String name;
  final String? icon;
  final String? color;
  final List<String>? nodes;

  NodeCategoryConfig({required this.name, this.icon, this.color, this.nodes});

  factory NodeCategoryConfig.fromJson(Map<String, dynamic> json) {
    return NodeCategoryConfig(
      name: json['name'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      nodes: json['nodes'] != null
          ? List<String>.from(json['nodes'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (nodes != null) 'nodes': nodes,
    };
  }

  NodeCategoryConfig copyWith({
    String? name,
    String? icon,
    String? color,
    List<String>? nodes,
  }) {
    return NodeCategoryConfig(
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      nodes: nodes ?? this.nodes,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is NodeCategoryConfig &&
            runtimeType == other.runtimeType &&
            name == other.name &&
            icon == other.icon &&
            color == other.color &&
            _listEquals(nodes, other.nodes);
  }

  @override
  int get hashCode => Object.hash(name, icon, color, nodes);

  bool _listEquals(List<String>? list1, List<String>? list2) {
    if (list1 == null && list2 == null) return true;
    if (list1 == null || list2 == null) return false;
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }
}
