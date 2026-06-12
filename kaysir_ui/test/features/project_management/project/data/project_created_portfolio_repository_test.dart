import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_created_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';

void main() {
  test(
    'created portfolio repository saves and restores project records',
    () async {
      final store = MemoryProjectCreatedPortfolioSnapshotStore();
      final repository = ProjectCreatedPortfolioRepository(store: store);
      final project = ProjectPortfolioItem(
        id: 'campus-renovation',
        name: 'Campus Renovation',
        owner: 'Dewi Lestari',
        client: 'Education Office',
        sponsor: 'Academic Operations',
        summary:
            'Coordinates classroom renovation, inspection proof, and opening readiness.',
        startDate: DateTime(2026, 6),
        endDate: DateTime(2026, 8),
        progress: 0.2,
        budgetUsed: 0.1,
        health: ProjectHealth.atRisk,
        businessDomain: 'Education Program',
        customAttributes: const [
          ProjectCustomAttribute(
            key: 'campus',
            label: 'Campus',
            type: ProjectCustomAttributeType.text,
            value: 'North Campus',
            isPinned: true,
          ),
          ProjectCustomAttribute(
            key: 'student-impact',
            label: 'Student Impact',
            type: ProjectCustomAttributeType.number,
            value: '640',
            unit: 'students',
            isPinned: true,
          ),
        ],
        milestones: [
          ProjectMilestone(
            label: 'Kickoff',
            dueDate: DateTime(2026, 6),
            isComplete: true,
          ),
        ],
        risks: const [
          ProjectDeliveryRisk(
            title: 'Inspection readiness',
            detail: 'Site proof needs owner signoff.',
            severity: ProjectHealth.atRisk,
          ),
        ],
        team: const [
          ProjectTeamMember(
            name: 'Dewi Lestari',
            role: 'Delivery Lead',
            allocation: 0.7,
          ),
        ],
      );

      await repository.save([project]);

      final restored = await repository.load();

      expect(restored, hasLength(1));
      expect(restored.single.id, 'campus-renovation');
      expect(restored.single.businessDomain, 'Education Program');
      expect(restored.single.customAttributes, hasLength(2));
      expect(restored.single.customAttributes.first.label, 'Campus');
      expect(
        restored.single.customAttributes.last.displayValue,
        '640 students',
      );
      expect(restored.single.health, ProjectHealth.atRisk);
      expect(restored.single.milestones.single.label, 'Kickoff');
      expect(restored.single.risks.single.title, 'Inspection readiness');
      expect(restored.single.team.single.allocation, 0.7);
    },
  );

  test('created portfolio repository tolerates stale snapshots', () async {
    final store = MemoryProjectCreatedPortfolioSnapshotStore();
    final repository = ProjectCreatedPortfolioRepository(store: store);

    await store.write({
      'version': 1,
      'projects': [
        {'id': 'missing-required-data'},
      ],
    });

    expect(await repository.load(), isEmpty);
  });
}
