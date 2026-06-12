import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_intake_draft.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_models.dart';

void main() {
  test('employee directory intake draft validates required fields', () {
    final draft = EmployeeDirectoryIntakeDraft.empty(
      joiningDate: DateTime(2026, 5, 30),
    );

    expect(draft.isReadyToCreate, isFalse);
    expect(draft.validationErrors, contains('Please enter a name'));
    expect(
      EmployeeDirectoryIntakeDraft.validateEmail('not-an-email'),
      'Please enter a valid email',
    );
    expect(
      EmployeeDirectoryIntakeDraft.validatePerformance('5.4'),
      'Please enter a rating from 0 to 5',
    );
    expect(
      EmployeeDirectoryIntakeDraft.validateJoiningDate(
        DateTime.now().add(const Duration(days: 1)),
      ),
      'Joining date cannot be in future',
    );
  });

  test('employee directory intake draft creates directory member', () {
    final draft = EmployeeDirectoryIntakeDraft.empty(
      joiningDate: DateTime(2026, 5, 30),
    ).copyWith(
      name: '  Aisha Putri  ',
      position: ' HR Operations Analyst ',
      department: ' People Operations ',
      email: ' aisha.putri@example.com ',
      phone: ' +62 812 0000 0000 ',
      performance: '4.4',
      location: ' Jakarta ',
      manager: ' Emma Rodriguez ',
      status: EmployeeDirectoryStatus.active,
    );

    final member = draft.toMember(
      id: '6',
      avatarUrl: 'https://randomuser.me/api/portraits/lego/2.jpg',
    );

    expect(draft.isReadyToCreate, isTrue);
    expect(draft.completionRatio, 1);
    expect(member.id, '6');
    expect(member.name, 'Aisha Putri');
    expect(member.position, 'HR Operations Analyst');
    expect(member.department, 'People Operations');
    expect(member.email, 'aisha.putri@example.com');
    expect(member.phone, '+62 812 0000 0000');
    expect(member.performance, 4.4);
    expect(member.location, 'Jakarta');
    expect(member.manager, 'Emma Rodriguez');
    expect(member.status, EmployeeDirectoryStatus.active);
  });

  test('employee directory intake draft initializes from member', () {
    final member = EmployeeDirectoryMember(
      id: '42',
      name: 'Sarah Johnson',
      position: 'UX Designer',
      department: 'Design',
      avatarUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
      email: 'sarah.johnson@company.com',
      phone: '+1 (555) 123-4567',
      joiningDate: DateTime(2022, 4, 15),
      performance: 4.7,
      location: 'Jakarta',
      manager: 'Emma Rodriguez',
      status: EmployeeDirectoryStatus.active,
    );

    final draft = EmployeeDirectoryIntakeDraft.fromMember(member);

    expect(draft.isReadyToCreate, isTrue);
    expect(draft.name, 'Sarah Johnson');
    expect(draft.position, 'UX Designer');
    expect(draft.department, 'Design');
    expect(draft.email, 'sarah.johnson@company.com');
    expect(draft.phone, '+1 (555) 123-4567');
    expect(draft.joiningDate, DateTime(2022, 4, 15));
    expect(draft.performance, '4.7');
    expect(draft.location, 'Jakarta');
    expect(draft.manager, 'Emma Rodriguez');
    expect(draft.status, EmployeeDirectoryStatus.active);
  });
}
