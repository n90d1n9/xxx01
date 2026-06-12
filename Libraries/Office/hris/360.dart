import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/legacy.dart';

// Models
class Employee {
  final String id;
  final String name;
  final String position;
  final String department;
  final String imageUrl;

  Employee({
    required this.id,
    required this.name,
    required this.position,
    required this.department,
    required this.imageUrl,
  });
}

class FeedbackCategory {
  final String id;
  final String title;
  final String description;

  FeedbackCategory({
    required this.id,
    required this.title,
    required this.description,
  });
}

// State for feedback
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
}

// Provider
final feedbackProvider = StateNotifierProvider<FeedbackNotifier, FeedbackState>(
  (ref) {
    return FeedbackNotifier();
  },
);

class FeedbackNotifier extends StateNotifier<FeedbackState> {
  FeedbackNotifier() : super(FeedbackState()) {
    _initData();
  }

  void _initData() {
    // Mock data
    final employees = [
      Employee(
        id: '1',
        name: 'Alex Johnson',
        position: 'Product Manager',
        department: 'Product',
        imageUrl: 'https://i.pravatar.cc/150?img=1',
      ),
      Employee(
        id: '2',
        name: 'Taylor Smith',
        position: 'UX Designer',
        department: 'Design',
        imageUrl: 'https://i.pravatar.cc/150?img=2',
      ),
      Employee(
        id: '3',
        name: 'Jordan Lee',
        position: 'Frontend Developer',
        department: 'Engineering',
        imageUrl: 'https://i.pravatar.cc/150?img=3',
      ),
    ];

    final categories = [
      FeedbackCategory(
        id: 'comm',
        title: 'Communication Skills',
        description: 'Ability to convey information clearly and effectively',
      ),
      FeedbackCategory(
        id: 'teamwork',
        title: 'Teamwork',
        description: 'Collaborates well with others to achieve common goals',
      ),
      FeedbackCategory(
        id: 'leadership',
        title: 'Leadership',
        description: 'Guides and influences others positively',
      ),
      FeedbackCategory(
        id: 'technical',
        title: 'Technical Competence',
        description: 'Knowledge and skills specific to their role',
      ),
      FeedbackCategory(
        id: 'innovation',
        title: 'Innovation',
        description: 'Contributes creative ideas and solutions',
      ),
    ];

    state = state.copyWith(employees: employees, categories: categories);
  }

  void selectEmployee(Employee employee) {
    state = state.copyWith(selectedEmployee: employee);
  }

  void updateRating(String categoryId, double rating) {
    final updatedRatings = {...state.ratings};
    updatedRatings[categoryId] = rating;
    state = state.copyWith(ratings: updatedRatings);
  }

  void updateComments(String comments) {
    state = state.copyWith(comments: comments);
  }

  Future<void> submitFeedback() async {
    if (state.selectedEmployee == null) return;

    state = state.copyWith(isSubmitting: true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    state = state.copyWith(isSubmitting: false, isSubmitted: true);

    // Reset after showing success
    await Future.delayed(const Duration(seconds: 2));
    state = FeedbackState(
      employees: state.employees,
      categories: state.categories,
    );
  }
}

// Main Screen
class FeedbackScreen extends ConsumerWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(feedbackProvider);
    final notifier = ref.read(feedbackProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          '360° Feedback',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.history), onPressed: () {}),
        ],
      ),
      body: state.isSubmitted
          ? _buildSuccessView(context)
          : state.selectedEmployee == null
          ? _buildEmployeeSelection(context, state, notifier)
          : _buildFeedbackForm(context, state, notifier),
    );
  }

  Widget _buildEmployeeSelection(
    BuildContext context,
    FeedbackState state,
    FeedbackNotifier notifier,
  ) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select an employee to provide feedback',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your feedback will help them grow professionally',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final employee = state.employees[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _EmployeeCard(
                  employee: employee,
                  onTap: () => notifier.selectEmployee(employee),
                ),
              );
            }, childCount: state.employees.length),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackForm(
    BuildContext context,
    FeedbackState state,
    FeedbackNotifier notifier,
  ) {
    final employee = state.selectedEmployee!;
    final categories = state.categories;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey,
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/150?img=1',
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  employee.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${employee.position} • ${employee.department}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Rate their performance',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final category = categories[index];
            return _RatingCard(
              category: category,
              rating: state.ratings[category.id] ?? 0,
              onRatingUpdate: (rating) =>
                  notifier.updateRating(category.id, rating),
            );
          }, childCount: categories.length),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Additional feedback',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  onChanged: notifier.updateComments,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Share your observations and suggestions...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.blue[300]!,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: state.isSubmitting
                        ? null
                        : notifier.submitFeedback,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: state.isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Submit Feedback',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
          const SizedBox(height: 24),
          Text(
            'Feedback Submitted',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Thank you for your valuable input',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  final Employee employee;
  final VoidCallback onTap;

  const _EmployeeCard({Key? key, required this.employee, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[200],
                backgroundImage: NetworkImage(employee.imageUrl),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${employee.position} • ${employee.department}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _RatingCard extends StatelessWidget {
  final FeedbackCategory category;
  final double rating;
  final Function(double) onRatingUpdate;

  const _RatingCard({
    Key? key,
    required this.category,
    required this.rating,
    required this.onRatingUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey[200]!),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                category.description,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RatingBar.builder(
                    initialRating: rating,
                    minRating: 0,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 28,
                    unratedColor: Colors.grey[300],
                    itemBuilder: (context, _) =>
                        Icon(Icons.star, color: Colors.amber[700]),
                    onRatingUpdate: onRatingUpdate,
                  ),
                  Text(
                    rating > 0 ? rating.toString() : 'Not rated',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: rating > 0 ? Colors.black87 : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Main app entry point
void main() {
  runApp(const ProviderScope(child: FeedbackApp()));
}

class FeedbackApp extends StatelessWidget {
  const FeedbackApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '360-Degree Feedback',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.grey[900],
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const FeedbackScreen(),
    );
  }
}
