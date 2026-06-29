import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/manager_seed_data.dart';
import '../models/manager_models.dart';

const managerAllTeamsScope = 'All teams';

final managerAsOfDateProvider = Provider<DateTime>(
  (ref) => DateTime(2026, 5, 30, 12),
);

final managerSelectedTeamProvider = StateProvider<String>(
  (ref) => managerAllTeamsScope,
);

final managerAttentionOnlyProvider = StateProvider<bool>((ref) => false);

final teamMembersProvider = Provider<List<TeamMember>>(
  (ref) => managerTeamMembers,
);

final pendingRequestsProvider = Provider<List<PendingRequest>>(
  (ref) => buildManagerPendingRequests(ref.watch(managerAsOfDateProvider)),
);

final teamMetricsProvider = Provider<TeamMetricSnapshot>(
  (ref) => managerTeamMetricSnapshot,
);

final managerTeamScopesProvider = Provider<List<String>>((ref) {
  final teams = ref.watch(teamMembersProvider).map((member) => member.team);
  final sortedTeams = teams.toSet().toList()..sort();
  return [managerAllTeamsScope, ...sortedTeams];
});

final filteredTeamMembersProvider = Provider<List<TeamMember>>((ref) {
  final selectedTeam = ref.watch(managerSelectedTeamProvider);
  final attentionOnly = ref.watch(managerAttentionOnlyProvider);

  return ref.watch(teamMembersProvider).where((member) {
    return _matchesTeam(member.team, selectedTeam) &&
        (!attentionOnly || member.needsAttention);
  }).toList();
});

final filteredPendingRequestsProvider = Provider<List<PendingRequest>>((ref) {
  final selectedTeam = ref.watch(managerSelectedTeamProvider);
  final attentionOnly = ref.watch(managerAttentionOnlyProvider);

  return ref.watch(pendingRequestsProvider).where((request) {
    return _matchesTeam(request.team, selectedTeam) &&
        (!attentionOnly || request.needsAttention);
  }).toList();
});

final managerRiskSummaryProvider = Provider<ManagerRiskSummary>((ref) {
  return ManagerRiskSummary.fromData(
    members: ref.watch(filteredTeamMembersProvider),
    requests: ref.watch(filteredPendingRequestsProvider),
    asOfDate: ref.watch(managerAsOfDateProvider),
  );
});

final managerSelfServiceSummaryProvider = Provider<ManagerSelfServiceSummary>((
  ref,
) {
  return ManagerSelfServiceSummary.fromData(
    members: ref.watch(filteredTeamMembersProvider),
    requests: ref.watch(filteredPendingRequestsProvider),
    metrics: ref.watch(teamMetricsProvider),
  );
});

bool _matchesTeam(String team, String selectedTeam) {
  return selectedTeam == managerAllTeamsScope || team == selectedTeam;
}
