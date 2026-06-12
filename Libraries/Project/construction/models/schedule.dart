class Schedule {
  final String id;
  final String projectId;
  final String aktivitas;
  final DateTime mulai;
  final DateTime selesai;
  final int progress;
  final String? pic;

  Schedule({
    required this.id,
    required this.projectId,
    required this.aktivitas,
    required this.mulai,
    required this.selesai,
    required this.progress,
    this.pic,
  });

  Schedule copyWith({
    String? aktivitas,
    DateTime? mulai,
    DateTime? selesai,
    int? progress,
    String? pic,
  }) {
    return Schedule(
      id: id,
      projectId: projectId,
      aktivitas: aktivitas ?? this.aktivitas,
      mulai: mulai ?? this.mulai,
      selesai: selesai ?? this.selesai,
      progress: progress ?? this.progress,
      pic: pic ?? this.pic,
    );
  }
}
