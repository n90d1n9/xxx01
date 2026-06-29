enum MemorizationStatus { learning, reviewing, mastered, struggling }

class MemorizationEntry {
  final int surahNumber;
  final int ayahNumber;
  final DateTime startDate;
  final DateTime? masteredDate;
  final int reviewCount;
  final int correctCount;
  final double strength;
  final DateTime nextReview;
  final MemorizationStatus status;
  final List<String> notes;

  MemorizationEntry({
    required this.surahNumber,
    required this.ayahNumber,
    required this.startDate,
    this.masteredDate,
    this.reviewCount = 0,
    this.correctCount = 0,
    this.strength = 0.0,
    required this.nextReview,
    this.status = MemorizationStatus.learning,
    this.notes = const [],
  });

  MemorizationEntry copyWith({
    int? reviewCount,
    int? correctCount,
    double? strength,
    DateTime? nextReview,
    MemorizationStatus? status,
    DateTime? masteredDate,
    List<String>? notes,
  }) {
    return MemorizationEntry(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      startDate: startDate,
      masteredDate: masteredDate ?? this.masteredDate,
      reviewCount: reviewCount ?? this.reviewCount,
      correctCount: correctCount ?? this.correctCount,
      strength: strength ?? this.strength,
      nextReview: nextReview ?? this.nextReview,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'surahNumber': surahNumber,
    'ayahNumber': ayahNumber,
    'startDate': startDate.toIso8601String(),
    'masteredDate': masteredDate?.toIso8601String(),
    'reviewCount': reviewCount,
    'correctCount': correctCount,
    'strength': strength,
    'nextReview': nextReview.toIso8601String(),
    'status': status.name,
    'notes': notes,
  };

  factory MemorizationEntry.fromJson(Map<String, dynamic> json) {
    return MemorizationEntry(
      surahNumber: json['surahNumber'],
      ayahNumber: json['ayahNumber'],
      startDate: DateTime.parse(json['startDate']),
      masteredDate:
          json['masteredDate'] != null
              ? DateTime.parse(json['masteredDate'])
              : null,
      reviewCount: json['reviewCount'] ?? 0,
      correctCount: json['correctCount'] ?? 0,
      strength: json['strength'] ?? 0.0,
      nextReview: DateTime.parse(json['nextReview']),
      status: MemorizationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MemorizationStatus.learning,
      ),
      notes: List<String>.from(json['notes'] ?? []),
    );
  }
}
