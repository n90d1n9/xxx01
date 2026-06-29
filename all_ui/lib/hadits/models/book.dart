import 'multilingual_text.dart';

class Book {
  final String id;
  final MultilingualText name;
  final MultilingualText author;
  final MultilingualText description;

  Book({
    required this.id,
    required this.name,
    required this.author,
    required this.description,
  });
}
