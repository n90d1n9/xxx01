enum CandidateDevelopmentCheckInStatus {
  onTrack('On track'),
  watch('Watch'),
  blocked('Blocked');

  final String label;

  const CandidateDevelopmentCheckInStatus(this.label);
}

class CandidateDevelopmentCheckIn {
  final String id;
  final String objectiveId;
  final String candidateName;
  final String role;
  final String department;
  final String objectiveTitle;
  final String ownerName;
  final String mentorName;
  final int confidenceLevel;
  final String progressNote;
  final String blockerNote;
  final DateTime nextReviewDate;
  final CandidateDevelopmentCheckInStatus status;
  final DateTime createdAt;

  const CandidateDevelopmentCheckIn({
    required this.id,
    required this.objectiveId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.objectiveTitle,
    required this.ownerName,
    required this.mentorName,
    required this.confidenceLevel,
    required this.progressNote,
    required this.blockerNote,
    required this.nextReviewDate,
    required this.status,
    required this.createdAt,
  });

  int daysUntilReview(DateTime asOfDate) {
    final start = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    final review = DateTime(
      nextReviewDate.year,
      nextReviewDate.month,
      nextReviewDate.day,
    );
    return review.difference(start).inDays;
  }

  bool isReviewDueSoon(DateTime asOfDate) {
    return daysUntilReview(asOfDate) <= 7;
  }
}
