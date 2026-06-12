import 'package:flutter/material.dart';
import 'package:ky_gantt/ky_gantt.dart' as ky;

import '../../project/models/project_portfolio_item.dart';
import '../gantt_dashboard.dart' as gantt;

class GanttTaskAvatarService {
  const GanttTaskAvatarService({this.palette = defaultPalette});

  static const defaultPalette = [
    Color(0xFF4F46E5),
    Color(0xFF0F766E),
    Color(0xFFBE185D),
    Color(0xFF475569),
    Color(0xFFEA580C),
    Color(0xFF15803D),
  ];

  final List<Color> palette;

  List<ky.KyGanttTaskAvatar> avatarsForTask(
    gantt.GanttTask task,
    Map<String, ProjectPortfolioItem> projectsById,
  ) {
    final project = projectsById[task.projectId];
    if (project == null || project.team.isEmpty) return const [];

    return [
      for (final member in project.team) avatarForMember(project, member),
    ];
  }

  ky.KyGanttTaskAvatar avatarForMember(
    ProjectPortfolioItem project,
    ProjectTeamMember member,
  ) {
    return ky.KyGanttTaskAvatar(
      id: avatarIdFor(project, member),
      label: member.name,
      initials: initialsFor(member.name),
      tooltip: tooltipFor(member),
      color: colorFor(member.name),
    );
  }

  String avatarIdFor(ProjectPortfolioItem project, ProjectTeamMember member) {
    final projectSlug = _slug(project.id);
    final memberSlug = _slug('${member.name} ${member.role}');
    final readableId = [
      projectSlug,
      memberSlug,
    ].where((part) => part.isNotEmpty).join('-');

    if (readableId.isNotEmpty) return readableId;

    return 'task-avatar-${_stableHash('${project.id}-${member.name}-${member.role}')}';
  }

  String initialsFor(String name) {
    final parts =
        name
            .trim()
            .split(RegExp(r'\s+'))
            .where((part) => part.isNotEmpty)
            .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.characters.take(2).toString().toUpperCase();
    }

    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }

  String tooltipFor(ProjectTeamMember member) {
    final allocation = (member.allocation * 100).round();
    return '${member.name} - ${member.role}, $allocation% allocated';
  }

  Color colorFor(String seed) {
    final activePalette = palette.isEmpty ? defaultPalette : palette;
    final hash = _stableHash(seed);
    return activePalette[hash % activePalette.length];
  }

  String _slug(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  int _stableHash(String value) {
    return value.codeUnits.fold<int>(
      0,
      (hash, unit) => ((hash * 31) + unit) & 0x7fffffff,
    );
  }
}
