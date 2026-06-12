import 'package:flutter/material.dart';

import '../models/project_portfolio_item.dart';

class ProjectTeamAvatarSummary extends StatelessWidget {
  const ProjectTeamAvatarSummary({
    required this.members,
    this.maxVisible = 3,
    super.key,
  });

  final List<ProjectTeamMember> members;
  final int maxVisible;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final averageAllocationPercent =
        (members.fold<int>(
                  0,
                  (sum, member) => sum + (member.allocation * 100).round(),
                ) /
                members.length)
            .round();
    final contributorLabel =
        '${members.length} contributor${members.length == 1 ? '' : 's'}';

    return Row(
      key: const ValueKey('project-team-avatar-summary'),
      children: [
        ProjectTeamAvatarStack(members: members, maxVisible: maxVisible),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            contributorLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          '$averageAllocationPercent% avg',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class ProjectTeamAvatarStack extends StatelessWidget {
  const ProjectTeamAvatarStack({
    required this.members,
    this.maxVisible = 3,
    this.size = 26,
    this.overlap = 9,
    super.key,
  });

  final List<ProjectTeamMember> members;
  final int maxVisible;
  final double size;
  final double overlap;

  @override
  Widget build(BuildContext context) {
    final normalizedMax = maxVisible.clamp(1, 5).toInt();
    final hasOverflow = members.length > normalizedMax;
    final visibleMemberCount =
        hasOverflow
            ? (normalizedMax - 1).clamp(0, normalizedMax).toInt()
            : normalizedMax;
    final visibleMembers = members.take(visibleMemberCount).toList();
    final overflowMembers = members.skip(visibleMemberCount).toList();
    final overflowCount = members.length - visibleMembers.length;
    final itemCount = visibleMembers.length + (overflowCount > 0 ? 1 : 0);
    if (itemCount == 0) return const SizedBox.shrink();

    final step = size - overlap;
    final width = size + ((itemCount - 1) * step);

    return SizedBox(
      key: const ValueKey('project-team-avatar-stack'),
      width: width,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var index = 0; index < visibleMembers.length; index++)
            Positioned(
              left: index * step,
              child: _ProjectTeamAvatarChip(
                member: visibleMembers[index],
                size: size,
              ),
            ),
          if (overflowCount > 0)
            Positioned(
              left: visibleMembers.length * step,
              child: _ProjectTeamAvatarOverflow(
                members: overflowMembers,
                size: size,
              ),
            ),
        ],
      ),
    );
  }
}

class _ProjectTeamAvatarChip extends StatelessWidget {
  const _ProjectTeamAvatarChip({required this.member, required this.size});

  final ProjectTeamMember member;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = _avatarColor(context, member.name);
    final foregroundColor =
        ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark
            ? Colors.white
            : colorScheme.onSurface;
    final label = _memberLabel(member);

    return Semantics(
      container: true,
      label: 'Project team member: $label',
      child: Tooltip(
        message: label,
        excludeFromSemantics: true,
        waitDuration: const Duration(milliseconds: 350),
        child: ExcludeSemantics(
          child: Container(
            key: ValueKey('project-team-avatar-${_avatarKey(member)}'),
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.surface, width: 2),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.14),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              _initials(member.name),
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w900,
                fontSize: size <= 22 ? 9 : 10,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProjectTeamAvatarOverflow extends StatelessWidget {
  const _ProjectTeamAvatarOverflow({required this.members, required this.size});

  final List<ProjectTeamMember> members;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final count = members.length;
    final labels = members.map(_memberLabel).toList();
    final title =
        count == 1 ? '1 more team member' : '$count more team members';
    final tooltip = '$title\n${labels.join('\n')}';

    return Semantics(
      container: true,
      label: '$title: ${labels.join(', ')}',
      child: Tooltip(
        message: tooltip,
        excludeFromSemantics: true,
        waitDuration: const Duration(milliseconds: 350),
        child: ExcludeSemantics(
          child: Container(
            key: const ValueKey('project-team-avatar-overflow'),
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.surface, width: 2),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.14),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '+$count',
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w900,
                fontSize: size <= 22 ? 9 : 10,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _memberLabel(ProjectTeamMember member) {
  return '${member.name} - ${member.role}, '
      '${(member.allocation * 100).round()}% allocated';
}

String _initials(String value) {
  final words = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty);
  if (words.isEmpty) return '?';

  final initials = words.take(2).map((word) => word.characters.first).join();
  return initials.toUpperCase();
}

String _avatarKey(ProjectTeamMember member) {
  return member.name
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}

Color _avatarColor(BuildContext context, String seed) {
  final colorScheme = Theme.of(context).colorScheme;
  final palette = [
    colorScheme.primary,
    colorScheme.tertiary,
    colorScheme.secondary,
    Colors.teal.shade700,
    Colors.indigo.shade600,
    Colors.pink.shade600,
  ];
  final hash = seed.codeUnits.fold<int>(0, (sum, unit) => sum + unit);
  return palette[hash % palette.length];
}
