import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_quality_gate_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_quality_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_quality_gate_provider.dart';

void main() {
  test('employee directory quality gate blocks critical roster issues', () {
    final container = ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
        employeeDirectoryMembersProvider.overrideWith(
          (ref) => EmployeeDirectoryNotifier([
            _member(
              id: '1',
              name: 'Sarah Johnson',
              email: 'shared@example.com',
            ),
            _member(
              id: '2',
              name: 'Maya Santoso',
              email: 'shared@example.com',
              manager: '',
            ),
            _member(id: '3', name: 'Rafi Pratama'),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);

    final gate = container.read(employeeDirectoryQualityGateProvider);

    expect(gate.status, EmployeeDirectoryQualityGateStatus.blocked);
    expect(gate.blockerCount, 2);
    expect(gate.reviewCount, 1);
    expect(gate.advisoryCount, 0);
    expect(gate.completionPercent, 50);
    expect(gate.nextActionLabel, 'Fix duplicate email for Maya Santoso');
    expect(gate.summaryLabel, '2 payroll blockers must clear before cutoff');

    final identity = gate.checks.firstWhere(
      (check) => check.id == 'identityContact',
    );
    expect(identity.isPassed, isFalse);
    expect(identity.severity, EmployeeDirectoryQualitySeverity.critical);
    expect(identity.affectedProfileCount, 2);
  });

  test(
    'employee directory quality gate enters review for noncritical issues',
    () {
      final container = ProviderContainer(
        overrides: [
          employeeDirectoryAsOfDateProvider.overrideWithValue(
            DateTime(2026, 5, 30),
          ),
          employeeDirectoryMembersProvider.overrideWith(
            (ref) => EmployeeDirectoryNotifier([
              _member(
                id: '1',
                name: 'Sarah Johnson',
                email: 'sarah@example.com',
                manager: '',
              ),
              _member(id: '2', name: 'Maya Santoso', email: 'maya@example.com'),
            ]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final gate = container.read(employeeDirectoryQualityGateProvider);

      expect(gate.status, EmployeeDirectoryQualityGateStatus.review);
      expect(gate.blockerCount, 0);
      expect(gate.reviewCount, 1);
      expect(gate.summaryLabel, '1 review item before cutoff');
      expect(gate.nextActionLabel, 'Fix missing manager for Sarah Johnson');
    },
  );

  test('employee directory quality gate is ready for clean roster', () {
    final container = ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
        employeeDirectoryMembersProvider.overrideWith(
          (ref) => EmployeeDirectoryNotifier([
            _member(id: '1', name: 'Sarah Johnson'),
            _member(id: '2', name: 'Maya Santoso', email: 'maya@example.com'),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);

    final gate = container.read(employeeDirectoryQualityGateProvider);

    expect(gate.status, EmployeeDirectoryQualityGateStatus.ready);
    expect(gate.isReady, isTrue);
    expect(gate.completionPercent, 100);
    expect(gate.nextActionLabel, 'Keep roster gate ready');
    expect(gate.summaryLabel, 'Roster gate is ready for payroll and reporting');
  });
}

EmployeeDirectoryMember _member({
  required String id,
  required String name,
  String email = 'person@example.com',
  String phone = '+62 812 0000 0000',
  String manager = 'Emma Rodriguez',
}) {
  return EmployeeDirectoryMember(
    id: id,
    name: name,
    position: 'HR Analyst',
    department: 'People Operations',
    avatarUrl: 'https://example.com/avatar.png',
    email: email,
    phone: phone,
    joiningDate: DateTime(2024, 1, 1),
    performance: 4.4,
    location: 'Jakarta',
    manager: manager,
    status: EmployeeDirectoryStatus.active,
  );
}
