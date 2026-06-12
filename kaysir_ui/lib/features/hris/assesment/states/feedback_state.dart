import '../../employee/models/employee.dart';
import '../models/feedback_category.dart';

class FeedbackState {
  final Employee? selectedEmployee;
  final List<Employee> employees;
  final List<FeedbackCategory> categories;
  final Map<String, double> ratings;
  final String comments;
  final bool isSubmitting;
  final bool isSubmitted;

  FeedbackState({
    this.selectedEmployee,
    this.employees = const [],
    this.categories = const [],
    this.ratings = const {},
    this.comments = '',
    this.isSubmitting = false,
    this.isSubmitted = false,
  });

  FeedbackState copyWith({
    Employee? selectedEmployee,
    List<Employee>? employees,
    List<FeedbackCategory>? categories,
    Map<String, double>? ratings,
    String? comments,
    bool? isSubmitting,
    bool? isSubmitted,
  }) {
    return FeedbackState(
      selectedEmployee: selectedEmployee ?? this.selectedEmployee,
      employees: employees ?? this.employees,
      categories: categories ?? this.categories,
      ratings: ratings ?? this.ratings,
      comments: comments ?? this.comments,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }

  int get ratedCount {
    return categories.where((category) {
      return (ratings[category.id] ?? 0) > 0;
    }).length;
  }

  double get averageRating {
    if (ratedCount == 0) return 0;
    final total = categories.fold<double>(
      0,
      (sum, category) => sum + (ratings[category.id] ?? 0),
    );
    return total / ratedCount;
  }

  bool get hasCompleteRatings {
    return categories.isNotEmpty && ratedCount == categories.length;
  }

  bool get hasComments => comments.trim().isNotEmpty;

  bool get canSubmit {
    return selectedEmployee != null &&
        hasCompleteRatings &&
        hasComments &&
        !isSubmitting;
  }
}

class FeedbackSummary {
  final int employeeCount;
  final int categoryCount;
  final int ratedCount;
  final double averageRating;
  final bool hasCompleteRatings;

  const FeedbackSummary({
    required this.employeeCount,
    required this.categoryCount,
    required this.ratedCount,
    required this.averageRating,
    required this.hasCompleteRatings,
  });

  factory FeedbackSummary.fromState(FeedbackState state) {
    return FeedbackSummary(
      employeeCount: state.employees.length,
      categoryCount: state.categories.length,
      ratedCount: state.ratedCount,
      averageRating: state.averageRating,
      hasCompleteRatings: state.hasCompleteRatings,
    );
  }
}

class FeedbackReadinessSummary {
  final bool hasSelectedEmployee;
  final bool hasComments;
  final int ratedCount;
  final int missingCategoryCount;
  final double completionRate;
  final bool canSubmit;

  const FeedbackReadinessSummary({
    required this.hasSelectedEmployee,
    required this.hasComments,
    required this.ratedCount,
    required this.missingCategoryCount,
    required this.completionRate,
    required this.canSubmit,
  });

  factory FeedbackReadinessSummary.fromState(FeedbackState state) {
    final missingCategoryCount = state.categories.length - state.ratedCount;

    return FeedbackReadinessSummary(
      hasSelectedEmployee: state.selectedEmployee != null,
      hasComments: state.hasComments,
      ratedCount: state.ratedCount,
      missingCategoryCount: missingCategoryCount < 0 ? 0 : missingCategoryCount,
      completionRate:
          state.categories.isEmpty
              ? 0
              : state.ratedCount / state.categories.length,
      canSubmit: state.canSubmit,
    );
  }
}
