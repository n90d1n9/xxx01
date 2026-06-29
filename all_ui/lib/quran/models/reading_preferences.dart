import 'reading_mode.dart';

class ReadingPreferences {
  final double arabicFontSize;
  final double translationFontSize;
  final String reciter;
  final ReadingMode readingMode;

  ReadingPreferences({
    this.arabicFontSize = 24.0,
    this.translationFontSize = 16.0,
    this.reciter = 'ar.alafasy',
    this.readingMode = ReadingMode.continuous,
  });

  ReadingPreferences copyWith({
    double? arabicFontSize,
    double? translationFontSize,
    String? reciter,
    ReadingMode? readingMode,
  }) {
    return ReadingPreferences(
      arabicFontSize: arabicFontSize ?? this.arabicFontSize,
      translationFontSize: translationFontSize ?? this.translationFontSize,
      reciter: reciter ?? this.reciter,
      readingMode: readingMode ?? this.readingMode,
    );
  }

  Map<String, dynamic> toJson() => {
    'arabicFontSize': arabicFontSize,
    'translationFontSize': translationFontSize,
    'reciter': reciter,
    'readingMode': readingMode.name,
  };

  factory ReadingPreferences.fromJson(Map<String, dynamic> json) {
    return ReadingPreferences(
      arabicFontSize: json['arabicFontSize'] ?? 24.0,
      translationFontSize: json['translationFontSize'] ?? 16.0,
      reciter: json['reciter'] ?? 'ar.alafasy',
      readingMode: ReadingMode.values.firstWhere(
        (e) => e.name == json['readingMode'],
        orElse: () => ReadingMode.continuous,
      ),
    );
  }
}
