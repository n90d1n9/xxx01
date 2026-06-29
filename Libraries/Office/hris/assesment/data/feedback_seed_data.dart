import '../../employee/models/employee.dart';
import '../models/feedback_category.dart';

List<Employee> buildFeedbackEmployees() {
  return [
    Employee(
      id: 1,
      name: 'Alex Johnson',
      position: 'Product Manager',
      department: 'Product',
      imageUrl: 'https://i.pravatar.cc/150?img=1',
    ),
    Employee(
      id: 2,
      name: 'Taylor Smith',
      position: 'UX Designer',
      department: 'Design',
      imageUrl: 'https://i.pravatar.cc/150?img=2',
    ),
    Employee(
      id: 3,
      name: 'Jordan Lee',
      position: 'Frontend Developer',
      department: 'Engineering',
      imageUrl: 'https://i.pravatar.cc/150?img=3',
    ),
  ];
}

List<FeedbackCategory> buildFeedbackCategories() {
  return [
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
}
