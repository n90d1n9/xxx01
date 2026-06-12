import 'package:flutter/material.dart';

import '../../shared/widgets/hris_ui.dart';
import '../models/manager_models.dart';
import 'manager_status_styles.dart';

class ManagerTeamPanel extends StatelessWidget {
  final List<TeamMember> members;
  final ValueChanged<TeamMember> onMessage;
  final ValueChanged<TeamMember> onCall;
  final ValueChanged<TeamMember> onOpenProfile;

  const ManagerTeamPanel({
    super.key,
    required this.members,
    required this.onMessage,
    required this.onCall,
    required this.onOpenProfile,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.groups_2_outlined,
      title: 'My team',
      subtitle: 'Availability, capacity, and quick contact',
      emptyMessage: 'No team members match the current view',
      children:
          members.isEmpty
              ? []
              : [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 720 ? 2 : 1;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: columns == 1 ? 3.35 : 2.75,
                      ),
                      itemCount: members.length,
                      itemBuilder:
                          (context, index) => _TeamMemberCard(
                            member: members[index],
                            onMessage: () => onMessage(members[index]),
                            onCall: () => onCall(members[index]),
                            onOpenProfile: () => onOpenProfile(members[index]),
                          ),
                    );
                  },
                ),
              ],
    );
  }
}

class _TeamMemberCard extends StatelessWidget {
  final TeamMember member;
  final VoidCallback onMessage;
  final VoidCallback onCall;
  final VoidCallback onOpenProfile;

  const _TeamMemberCard({
    required this.member,
    required this.onMessage,
    required this.onCall,
    required this.onOpenProfile,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = managerTeamStatusColor(member.status);

    return HrisListSurface(
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundImage: NetworkImage(member.avatarUrl),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: HrisColors.surface, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  '${member.role} • ${member.team}',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 8),
                HrisMetricStrip(
                  items: [
                    HrisMetricStripItem(
                      label: 'Capacity',
                      value: '${member.capacityPercent}%',
                    ),
                    HrisMetricStripItem(
                      label: 'Score',
                      value: '${member.performanceScore}%',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: 'Message',
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                onPressed: onMessage,
              ),
              IconButton(
                tooltip: 'Call',
                icon: const Icon(Icons.call_outlined),
                onPressed: onCall,
              ),
              IconButton(
                tooltip: 'Open profile',
                icon: const Icon(Icons.person_outline_rounded),
                onPressed: onOpenProfile,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
