import 'core_aliases.dart';

/// Tracks a shift task, owner, progress, and operational pressure.
class RestaurantShiftTask {
  const RestaurantShiftTask({
    required this.id,
    required this.title,
    required this.owner,
    required this.dueLabel,
    required this.progress,
    required this.status,
  });

  final String id;
  final String title;
  final String owner;
  final String dueLabel;
  final double progress;
  final RestaurantServiceStatus status;

  RestaurantShiftTask copyWith({
    String? title,
    String? owner,
    String? dueLabel,
    double? progress,
    RestaurantServiceStatus? status,
  }) {
    return RestaurantShiftTask(
      id: id,
      title: title ?? this.title,
      owner: owner ?? this.owner,
      dueLabel: dueLabel ?? this.dueLabel,
      progress: progress ?? this.progress,
      status: status ?? this.status,
    );
  }
}
