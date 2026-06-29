// Multilingual text model
class MultilingualText {
  final String id;
  final String en;
  final String ar;

  MultilingualText({required this.id, required this.en, required this.ar});

  String get(String locale) {
    switch (locale) {
      case 'id':
        return id;
      case 'en':
        return en;
      case 'ar':
        return ar;
      default:
        return id;
    }
  }
}
