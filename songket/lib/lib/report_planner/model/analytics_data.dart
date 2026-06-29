import 'daily_stats.dart';

class AnalyticsData {
  final int totalEvents;
  final int completedEvents;
  final int upcomingEvents;
  final int overdueEvents;
  final double completionRate;
  final Map<String, int> categoryDistribution;
  final Map<String, int> priorityDistribution;
  final Map<String, double> timeByCategory;
  final List<DailyStats> weeklyStats;
  final List<DailyStats> monthlyStats;
  final int totalHoursScheduled;
  final String mostProductiveDay;
  final String mostActiveCategory;

  AnalyticsData({
    required this.totalEvents,
    required this.completedEvents,
    required this.upcomingEvents,
    required this.overdueEvents,
    required this.completionRate,
    required this.categoryDistribution,
    required this.priorityDistribution,
    required this.timeByCategory,
    required this.weeklyStats,
    required this.monthlyStats,
    required this.totalHoursScheduled,
    required this.mostProductiveDay,
    required this.mostActiveCategory,
  });
}
