import '../models/scrum_activity.dart';
import 'scrum_activity_repository.dart';

class InMemoryScrumActivityRepository implements ScrumActivityRepository {
  InMemoryScrumActivityRepository({
    Iterable<ScrumActivity> initialActivities = const [],
  }) : _activities = List<ScrumActivity>.of(initialActivities);

  final List<ScrumActivity> _activities;

  @override
  Future<List<ScrumActivity>> loadActivities() async {
    return List<ScrumActivity>.unmodifiable(_activities);
  }

  @override
  Future<void> replaceActivities(List<ScrumActivity> activities) async {
    _activities
      ..clear()
      ..addAll(activities);
  }

  @override
  Future<void> addActivity(ScrumActivity activity) async {
    _activities.insert(0, activity);
  }

  @override
  Future<void> clearActivities() async {
    _activities.clear();
  }
}
