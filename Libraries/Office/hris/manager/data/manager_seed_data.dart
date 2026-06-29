import '../models/manager_models.dart';

const managerTeamMembers = [
  TeamMember(
    id: '1',
    name: 'Alex Morgan',
    role: 'UX Designer',
    team: 'Design',
    avatarUrl: 'https://i.pravatar.cc/150?img=1',
    status: TeamMemberStatus.available,
    capacityPercent: 72,
    performanceScore: 92,
  ),
  TeamMember(
    id: '2',
    name: 'Jamie Smith',
    role: 'Frontend Developer',
    team: 'Engineering',
    avatarUrl: 'https://i.pravatar.cc/150?img=2',
    status: TeamMemberStatus.busy,
    capacityPercent: 91,
    performanceScore: 88,
  ),
  TeamMember(
    id: '3',
    name: 'Taylor Wilson',
    role: 'Backend Developer',
    team: 'Engineering',
    avatarUrl: 'https://i.pravatar.cc/150?img=3',
    status: TeamMemberStatus.onLeave,
    capacityPercent: 0,
    performanceScore: 84,
  ),
  TeamMember(
    id: '4',
    name: 'Casey Johnson',
    role: 'QA Engineer',
    team: 'QA',
    avatarUrl: 'https://i.pravatar.cc/150?img=4',
    status: TeamMemberStatus.available,
    capacityPercent: 76,
    performanceScore: 90,
  ),
  TeamMember(
    id: '5',
    name: 'Morgan Lee',
    role: 'Product Manager',
    team: 'Product',
    avatarUrl: 'https://i.pravatar.cc/150?img=5',
    status: TeamMemberStatus.busy,
    capacityPercent: 87,
    performanceScore: 78,
  ),
];

List<PendingRequest> buildManagerPendingRequests(DateTime asOfDate) {
  return [
    PendingRequest(
      id: '101',
      employeeName: 'Jamie Smith',
      team: 'Engineering',
      requestType: 'Time Off',
      requestDate: asOfDate.subtract(
        const Duration(days: 2, hours: 2, minutes: 30),
      ),
      status: ManagerRequestStatus.pending,
      avatarUrl: 'https://i.pravatar.cc/150?img=2',
      priority: ManagerRequestPriority.urgent,
    ),
    PendingRequest(
      id: '102',
      employeeName: 'Taylor Wilson',
      team: 'Engineering',
      requestType: 'Equipment Request',
      requestDate: asOfDate.subtract(
        const Duration(days: 2, hours: 21, minutes: 45),
      ),
      status: ManagerRequestStatus.pending,
      avatarUrl: 'https://i.pravatar.cc/150?img=3',
      priority: ManagerRequestPriority.standard,
    ),
    PendingRequest(
      id: '103',
      employeeName: 'Casey Johnson',
      team: 'QA',
      requestType: 'Training Approval',
      requestDate: asOfDate.subtract(const Duration(days: 1, hours: 1)),
      status: ManagerRequestStatus.pending,
      avatarUrl: 'https://i.pravatar.cc/150?img=4',
      priority: ManagerRequestPriority.urgent,
    ),
    PendingRequest(
      id: '104',
      employeeName: 'Morgan Lee',
      team: 'Product',
      requestType: 'Compensation Review',
      requestDate: asOfDate.subtract(
        const Duration(days: 3, hours: 19, minutes: 15),
      ),
      status: ManagerRequestStatus.pending,
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
      priority: ManagerRequestPriority.standard,
    ),
  ];
}

const managerTeamMetricSnapshot = TeamMetricSnapshot(
  productivity: 87,
  satisfaction: 92,
  taskCompletion: 78,
  weeklyData: [65, 70, 75, 82, 87, 85, 90],
);
