import '../models/scrum_activity.dart';

abstract interface class ScrumActivityRepository {
  Future<List<ScrumActivity>> loadActivities();

  Future<void> replaceActivities(List<ScrumActivity> activities);

  Future<void> addActivity(ScrumActivity activity);

  Future<void> clearActivities();
}
