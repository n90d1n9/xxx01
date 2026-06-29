class SkillItem {
  final String id;
  final String name;
  final int level;

  SkillItem({required this.id, required this.name, required this.level});

  SkillItem copyWith({String? name, int? level}) {
    return SkillItem(
      id: id,
      name: name ?? this.name,
      level: level ?? this.level,
    );
  }
}
