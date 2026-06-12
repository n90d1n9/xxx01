// lib/models/option.dart
class Option {
  final String id;
  final String text;
  final bool selected;

  Option({required this.id, required this.text, this.selected = false});

  Option copyWith({String? id, String? text, bool? selected}) {
    return Option(
      id: id ?? this.id,
      text: text ?? this.text,
      selected: selected ?? this.selected,
    );
  }

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['id'],
      text: json['text'],
      selected: json['selected'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'text': text, 'selected': selected};
  }
}
