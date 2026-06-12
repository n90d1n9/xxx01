import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_task_avatar_service.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';

void main() {
  const service = GanttTaskAvatarService();

  group('GanttTaskAvatarService', () {
    test('builds taskbar avatars from the linked project team', () {
      final avatars = service.avatarsForTask(_task, {_project.id: _project});

      expect(avatars, hasLength(3));
      expect(
        avatars.first.id,
        'retail-modernization-maya-santoso-product-lead',
      );
      expect(avatars.first.label, 'Maya Santoso');
      expect(avatars.first.initials, 'MS');
      expect(avatars.first.displayInitials, 'MS');
      expect(
        avatars.first.tooltip,
        'Maya Santoso - Product Lead, 80% allocated',
      );
      expect(avatars.first.color, service.colorFor('Maya Santoso'));
    });

    test('returns no avatars for unlinked or empty-team tasks', () {
      expect(service.avatarsForTask(_task, const {}), isEmpty);
      expect(
        service.avatarsForTask(_task, {_emptyProject.id: _emptyProject}),
        isEmpty,
      );
    });

    test('normalizes initials, readable ids, and configurable colors', () {
      const customPalette = [Color(0xFF101828)];
      const customService = GanttTaskAvatarService(palette: customPalette);
      const fallbackPaletteService = GanttTaskAvatarService(palette: []);
      const member = ProjectTeamMember(
        name: ' QA Lead ',
        role: 'Delivery Owner',
        allocation: 1,
      );

      expect(service.initialsFor('Maya Santoso'), 'MS');
      expect(service.initialsFor('Omar'), 'OM');
      expect(service.initialsFor('  '), '?');
      expect(
        service.avatarIdFor(_project, member),
        'retail-modernization-qa-lead-delivery-owner',
      );
      expect(customService.colorFor('Maya Santoso'), customPalette.single);
      expect(
        GanttTaskAvatarService.defaultPalette,
        contains(fallbackPaletteService.colorFor('Maya Santoso')),
      );
    });
  });
}

final _task = gantt.GanttTask(
  id: 'build',
  title: 'Build Storefront',
  startDate: DateTime(2026, 1, 5),
  endDate: DateTime(2026, 1, 20),
  projectId: 'retail-modernization',
);

final _project = ProjectPortfolioItem(
  id: 'retail-modernization',
  name: 'Retail Modernization',
  owner: 'Alya',
  client: 'Northwind',
  startDate: DateTime(2026, 1),
  endDate: DateTime(2026, 3, 31),
  progress: 0.42,
  budgetUsed: 0.38,
  health: ProjectHealth.onTrack,
  milestones: const [],
  team: const [
    ProjectTeamMember(
      name: 'Maya Santoso',
      role: 'Product Lead',
      allocation: 0.8,
    ),
    ProjectTeamMember(
      name: 'Omar Hakim',
      role: 'Engineering Lead',
      allocation: 0.75,
    ),
    ProjectTeamMember(name: 'Lina Putri', role: 'QA Lead', allocation: 0.5),
  ],
);

final _emptyProject = ProjectPortfolioItem(
  id: 'retail-modernization',
  name: 'Retail Modernization',
  owner: 'Alya',
  client: 'Northwind',
  startDate: DateTime(2026, 1),
  endDate: DateTime(2026, 3, 31),
  progress: 0.42,
  budgetUsed: 0.38,
  health: ProjectHealth.onTrack,
  milestones: const [],
);
