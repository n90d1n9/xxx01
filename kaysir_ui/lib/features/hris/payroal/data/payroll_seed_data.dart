import '../../employee/models/employee.dart';

List<Employee> buildPayrollEmployees() {
  return [
    Employee(
      id: 1,
      name: 'Alex Johnson',
      position: 'Senior Developer',
      department: 'Engineering',
      salary: 8500,
      imageUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
    ),
    Employee(
      id: 2,
      name: 'Sarah Williams',
      position: 'UI/UX Designer',
      department: 'Design',
      salary: 7200,
      imageUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
    ),
    Employee(
      id: 3,
      name: 'Michael Chen',
      position: 'Project Manager',
      department: 'Operations',
      salary: 9800,
      imageUrl: 'https://randomuser.me/api/portraits/men/59.jpg',
    ),
  ];
}

Map<int, bool> buildPayrollPaymentStatus(List<Employee> employees) {
  return {for (final employee in employees) employee.id: false};
}
