class Surah {
  final int id; // Unique identifier for the surah
  final int
  number; // Surah number in the Quran, min=1, max=114, required, unique
  final String name; // Surah name in Arabic, min=2, max=50, required
  final String transliteration; // Transliterated name, min=2, max=50, required
  final String? translation; // English translation of the name, min=2, max=100
  final int totalVerses; // Total number of verses, min=1, required
  final String type; // Meccan or Medinan, min=5, max=10, required

  Surah({
    required this.id,
    required this.number,
    required this.name,
    required this.transliteration,
    this.translation,
    required this.totalVerses,
    required this.type,
  });

  Surah copyWith({
    int? id,
    int? number,
    String? name,
    String? transliteration,
    String? translation,
    int? totalVerses,
    String? type,
  }) {
    return Surah(
      id: id ?? this.id,
      number: number ?? this.number,
      name: name ?? this.name,
      transliteration: transliteration ?? this.transliteration,
      translation: translation ?? this.translation,
      totalVerses: totalVerses ?? this.totalVerses,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'name': name,
      'transliteration': transliteration,
      'translation': translation,
      'totalVerses': totalVerses,
      'type': type,
    };
  }

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      id: json['id'],
      number: json['number'],
      name: json['name'],
      transliteration: json['transliteration'],
      translation: json['translation'],
      totalVerses: json['totalVerses'],
      type: json['type'],
    );
  }

  @override
  String toString() {
    return 'Surah(id: $id, number: $number, name: $name, transliteration: $transliteration, translation: $translation, totalVerses: $totalVerses, type: $type)';
  }
}
