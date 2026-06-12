import 'dropoff_point.dart';

class FormAnalytics {
  final int totalSubmissions;
  final int successfulSubmissions;
  final int failedSubmissions;
  final double averageCompletionTime;
  final Map<String, int> fieldErrors;
  final Map<String, double> fieldCompletionRate;
  final List<DropOffPoint> dropOffPoints;

  const FormAnalytics({
    required this.totalSubmissions,
    required this.successfulSubmissions,
    required this.failedSubmissions,
    required this.averageCompletionTime,
    required this.fieldErrors,
    required this.fieldCompletionRate,
    required this.dropOffPoints,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalSubmissions': totalSubmissions,
      'successfulSubmissions': successfulSubmissions,
      'failedSubmissions': failedSubmissions,
      'averageCompletionTime': averageCompletionTime,
      'fieldErrors': fieldErrors,
      'fieldCompletionRate': fieldCompletionRate,
      'dropOffPoints': dropOffPoints.map((d) => d.toJson()).toList(),
    };
  }
}
