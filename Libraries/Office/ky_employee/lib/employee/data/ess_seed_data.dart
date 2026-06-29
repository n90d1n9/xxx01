import 'package:kaysir/utils/id_generator.dart';

import '../models/employee.dart';
import '../models/pay_stub.dart';
import '../models/request_time_off_draft.dart';
import '../models/time_off_request.dart';

Employee buildDefaultEmployee() {
  return Employee(
    id: SnowflakeIdGenerator(1).next(),
    employeeId: 'E123',
    name: 'John Doe',
    email: 'john.doe@example.com',
    department: 'Engineering',
    position: 'Senior Developer',
    imageUrl: 'https://i.pravatar.cc/300',
    hireDate: DateTime(2020, 5, 15),
  );
}

List<PayStub> buildInitialPayStubs() {
  return [
    PayStub(
      id: 'PS001',
      payPeriodStart: DateTime(2025, 2, 1),
      payPeriodEnd: DateTime(2025, 2, 15),
      payDate: DateTime(2025, 2, 20),
      grossAmount: 3500.00,
      netAmount: 2800.00,
    ),
    PayStub(
      id: 'PS002',
      payPeriodStart: DateTime(2025, 2, 16),
      payPeriodEnd: DateTime(2025, 2, 28),
      payDate: DateTime(2025, 3, 5),
      grossAmount: 3500.00,
      netAmount: 2800.00,
    ),
    PayStub(
      id: 'PS003',
      payPeriodStart: DateTime(2025, 3, 1),
      payPeriodEnd: DateTime(2025, 3, 15),
      payDate: DateTime(2025, 3, 20),
      grossAmount: 3500.00,
      netAmount: 2800.00,
    ),
  ];
}

List<TimeOffRequest> buildInitialTimeOffRequests() {
  return [
    TimeOffRequest(
      id: 'TOR001',
      startDate: DateTime(2025, 4, 10),
      endDate: DateTime(2025, 4, 15),
      reason: 'Vacation',
      status: 'Approved',
    ),
    TimeOffRequest(
      id: 'TOR002',
      startDate: DateTime(2025, 5, 22),
      endDate: DateTime(2025, 5, 22),
      reason: 'Personal',
      status: 'Pending',
    ),
  ];
}

List<TimeOffBalance> buildInitialTimeOffBalances() {
  return const [
    TimeOffBalance(type: 'Vacation', usedDays: 7, totalDays: 15),
    TimeOffBalance(type: 'Sick Leave', usedDays: 2, totalDays: 10),
    TimeOffBalance(type: 'Personal', usedDays: 1, totalDays: 5),
    TimeOffBalance(type: 'Bereavement', usedDays: 0, totalDays: 3),
    TimeOffBalance(type: 'Other', usedDays: 0, totalDays: 2),
  ];
}
