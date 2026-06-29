class PaletteSection {
  final String name;
  final bool? expanded;
  final List<String>? items;

  PaletteSection({required this.name, this.expanded = true, this.items});

  factory PaletteSection.fromJson(Map<String, dynamic> json) {
    return PaletteSection(
      name: json['name'] as String,
      expanded: json['expanded'] as bool?,
      items: json['items'] != null
          ? List<String>.from(json['items'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (expanded != null) 'expanded': expanded,
      if (items != null) 'items': items,
    };
  }
}
