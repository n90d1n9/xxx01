import 'multilingual_text.dart';

class Rawi {
  final String id;
  final MultilingualText name;
  final String birthYear;
  final String deathYear;
  final MultilingualText region;
  final MultilingualText biography;
  final List<String> teachers;
  final List<String> students;

  Rawi({
    required this.id,
    required this.name,
    required this.birthYear,
    required this.deathYear,
    required this.region,
    required this.biography,
    required this.teachers,
    required this.students,
  });
}
