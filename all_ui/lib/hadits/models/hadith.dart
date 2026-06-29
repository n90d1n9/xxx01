import 'multilingual_text.dart';

class Hadith {
  final String id;
  final String arabicText;
  final MultilingualText translation;
  final MultilingualText explanation;
  final List<String> sanad;
  final String grade;
  final String bookId;
  final MultilingualText chapter;
  final int number;
  final List<String> topics;
  final List<String> relatedHadiths;

  Hadith({
    required this.id,
    required this.arabicText,
    required this.translation,
    required this.explanation,
    required this.sanad,
    required this.grade,
    required this.bookId,
    required this.chapter,
    required this.number,
    required this.topics,
    required this.relatedHadiths,
  });
}
