// Dummy data for testing
import 'models/employee.dart';
import 'models/shift.dart';

List<Employee> dummyEmployees = [
  Employee(
    id: 1,
    name: 'John Doe',
    position: 'Senior Developer',
    department: 'Engineering',
    email: 'john.doe@example.com',
    phone: '+1 (555) 123-4567',
    address: '123 Main St, New York, NY',
    dateOfBirth: '1985-05-15',
    employeeId: 'EMP001',
    hireDate: DateTime(2009),
    managerName: 'Jane Smith',
    isActive: true,
  ),
  Employee(
    id: 2,
    name: 'Jane Smith',
    position: 'Engineering Manager',
    department: 'Engineering',
    email: 'jane.smith@example.com',
    phone: '+1 (555) 234-5678',
    address: '456 Park Ave, New York, NY',
    dateOfBirth: '1982-08-20',
    employeeId: 'EMP002',
    hireDate: DateTime(2015),
    managerName: 'Michael Johnson',
    isActive: true,
  ),
  Employee(
    id: 3,
    name: 'Robert Brown',
    position: 'UI Designer',
    department: 'Design',
    email: 'robert.brown@example.com',
    phone: '+1 (555) 345-6789',
    address: '789 Broadway, New York, NY',
    dateOfBirth: '1990-02-10',
    employeeId: 'EMP003',
    hireDate: DateTime(2011),
    managerName: 'Jane Smith',
    isActive: true,
  ),
  Employee(
    id: 4,
    name: 'Emily Wilson',
    position: 'QA Engineer',
    department: 'Engineering',
    email: 'emily.wilson@example.com',
    phone: '+1 (555) 456-7890',
    address: '321 Queens Blvd, New York, NY',
    dateOfBirth: '1988-11-25',
    employeeId: 'EMP004',
    hireDate: DateTime(2019),
    managerName: 'Jane Smith',
    isActive: false,
  ),
  Employee(
    id: 5,
    name: 'Michael Johnson',
    position: 'CTO',
    department: 'Executive',
    email: 'michael.johnson@example.com',
    phone: '+1 (555) 567-8901',
    address: '567 5th Ave, New York, NY',
    dateOfBirth: '1975-07-30',
    employeeId: 'EMP005',
    hireDate: DateTime(2012),
    managerName: null,
    isActive: true,
  ),
  Employee(
    id: 6,
    name: 'Sarah Lee',
    position: 'HR Manager',
    department: 'HR',
    email: 'sarah.lee@example.com',
    phone: '+1 (555) 678-9012',
    address: '432 Madison Ave, New York, NY',
    dateOfBirth: '1983-04-18',
    employeeId: 'EMP006',
    hireDate: DateTime(2010),
    managerName: 'Michael Johnson',
    isActive: true,
  ),
];

List<Shift> dummyShifts = [
  Shift(
    id: 1,
    employeeId: 1,
    date: DateTime.now().add(Duration(days: 1)),
    startTime: DateTime.now().add(Duration(days: 1, hours: 9)),
    endTime: DateTime.now().add(Duration(days: 1, hours: 17)),
    location: 'Main Office',
    status: 'scheduled',
  ),
  Shift(
    id: 2,
    employeeId: 1,
    date: DateTime.now(),
    startTime: DateTime.now().copyWith(hour: 9, minute: 0),
    endTime: DateTime.now().copyWith(hour: 17, minute: 0),
    location: 'Main Office',
    status: 'in_progress',
  ),
  Shift(
    id: 3,
    employeeId: 1,
    date: DateTime.now().subtract(Duration(days: 1)),
    startTime: DateTime.now()
        .subtract(Duration(days: 1))
        .copyWith(hour: 9, minute: 0),
    endTime: DateTime.now()
        .subtract(Duration(days: 1))
        .copyWith(hour: 17, minute: 0),
    location: 'Main Office',
    status: 'completed',
  ),
  Shift(
    id: 4,
    employeeId: 1,
    date: DateTime.now().subtract(Duration(days: 2)),
    startTime: DateTime.now()
        .subtract(Duration(days: 2))
        .copyWith(hour: 9, minute: 0),
    endTime: DateTime.now()
        .subtract(Duration(days: 2))
        .copyWith(hour: 17, minute: 0),
    location: 'Branch Office',
    status: 'completed',
  ),
  Shift(
    id: 5,
    employeeId: 1,
    date: DateTime.now().subtract(Duration(days: 7)),
    startTime: DateTime.now()
        .subtract(Duration(days: 7))
        .copyWith(hour: 9, minute: 0),
    endTime: DateTime.now()
        .subtract(Duration(days: 7))
        .copyWith(hour: 17, minute: 0),
    location: 'Client Site',
    status: 'missed',
  ),
  Shift(
    id: 6,
    employeeId: 2,
    date: DateTime.now(),
    startTime: DateTime.now().copyWith(hour: 9, minute: 0),
    endTime: DateTime.now().copyWith(hour: 17, minute: 0),
    location: 'Main Office',
    status: 'in_progress',
  ),
];
