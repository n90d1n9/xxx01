import '../models/employee_directory_models.dart';
import '../models/employee_skill_inventory_models.dart';

EmployeeSkillInventoryProfile buildEmployeeSkillInventoryProfile({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  return EmployeeSkillInventoryProfile(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: _dateOnly(asOfDate),
    records: _recordsFor(member, asOfDate),
  );
}

EmployeeSkillEvidenceDraft buildEmployeeSkillEvidenceDraft({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final watchlist = member.status == EmployeeDirectoryStatus.watchlist;
  return EmployeeSkillEvidenceDraft(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: _dateOnly(asOfDate),
    skillName: _primarySkill(member),
    category: _categoryFor(member),
    evidenceType: EmployeeSkillEvidenceType.projectDelivery,
    verifier: member.manager,
    evidenceSummary: '',
    observedLevel: watchlist ? 2 : 3,
    requiredLevel: member.isHighPerformer ? 5 : 4,
    criticality:
        watchlist
            ? EmployeeSkillCriticality.critical
            : EmployeeSkillCriticality.core,
    nextReviewDate: _dateOnly(asOfDate).add(const Duration(days: 30)),
  );
}

List<EmployeeSkillRecord> _recordsFor(
  EmployeeDirectoryMember member,
  DateTime asOfDate,
) {
  final today = _dateOnly(asOfDate);
  if (member.id == '4') {
    return [
      EmployeeSkillRecord(
        id: '${member.id}-skill-roadmap-analytics',
        employeeId: member.id,
        category: EmployeeSkillInventoryCategory.domain,
        skillName: 'Roadmap analytics',
        owner: member.manager,
        currentLevel: 2,
        requiredLevel: 4,
        criticality: EmployeeSkillCriticality.critical,
        status: EmployeeSkillVerificationStatus.evidenceDue,
        lastVerifiedDate: today.subtract(const Duration(days: 96)),
        nextReviewDate: today.subtract(const Duration(days: 1)),
        evidenceCount: 1,
        evidenceSummary:
            'Current roadmap recovery metrics need updated delivery evidence.',
      ),
      EmployeeSkillRecord(
        id: '${member.id}-skill-stakeholder-alignment',
        employeeId: member.id,
        category: EmployeeSkillInventoryCategory.leadership,
        skillName: 'Stakeholder alignment',
        owner: 'People Partner',
        currentLevel: 3,
        requiredLevel: 4,
        criticality: EmployeeSkillCriticality.core,
        status: EmployeeSkillVerificationStatus.inReview,
        lastVerifiedDate: today.subtract(const Duration(days: 48)),
        nextReviewDate: today.add(const Duration(days: 5)),
        evidenceCount: 2,
        evidenceSummary:
            'Support plan notes are waiting for stakeholder feedback review.',
      ),
      EmployeeSkillRecord(
        id: '${member.id}-skill-product-discovery',
        employeeId: member.id,
        category: EmployeeSkillInventoryCategory.domain,
        skillName: 'Product discovery',
        owner: member.manager,
        currentLevel: 4,
        requiredLevel: 4,
        criticality: EmployeeSkillCriticality.core,
        status: EmployeeSkillVerificationStatus.verified,
        lastVerifiedDate: today.subtract(const Duration(days: 22)),
        nextReviewDate: today.add(const Duration(days: 92)),
        evidenceCount: 4,
        evidenceSummary:
            'Recent discovery playback showed clear opportunity framing.',
      ),
    ];
  }

  if (member.id == '5') {
    return [
      EmployeeSkillRecord(
        id: '${member.id}-skill-brand-operations',
        employeeId: member.id,
        category: EmployeeSkillInventoryCategory.operations,
        skillName: 'Brand operations',
        owner: member.manager,
        currentLevel: 2,
        requiredLevel: 3,
        criticality: EmployeeSkillCriticality.core,
        status: EmployeeSkillVerificationStatus.evidenceDue,
        lastVerifiedDate: null,
        nextReviewDate: today.add(const Duration(days: 7)),
        evidenceCount: 0,
        evidenceSummary:
            'Onboarding portfolio evidence still needs manager validation.',
      ),
      EmployeeSkillRecord(
        id: '${member.id}-skill-campaign-analytics',
        employeeId: member.id,
        category: EmployeeSkillInventoryCategory.domain,
        skillName: 'Campaign analytics',
        owner: 'People Academy',
        currentLevel: 3,
        requiredLevel: 3,
        criticality: EmployeeSkillCriticality.growth,
        status: EmployeeSkillVerificationStatus.inReview,
        lastVerifiedDate: null,
        nextReviewDate: today.add(const Duration(days: 18)),
        evidenceCount: 1,
        evidenceSummary: 'First campaign dashboard submission is in review.',
      ),
    ];
  }

  final highPerformer = member.isHighPerformer;
  return [
    EmployeeSkillRecord(
      id: '${member.id}-skill-primary',
      employeeId: member.id,
      category: _categoryFor(member),
      skillName: _primarySkill(member),
      owner: member.manager,
      currentLevel: highPerformer ? 5 : 4,
      requiredLevel: highPerformer ? 5 : 4,
      criticality: EmployeeSkillCriticality.core,
      status: EmployeeSkillVerificationStatus.verified,
      lastVerifiedDate: today.subtract(const Duration(days: 30)),
      nextReviewDate: today.add(const Duration(days: 120)),
      evidenceCount: highPerformer ? 5 : 3,
      evidenceSummary:
          'Manager review confirmed current role capability coverage.',
    ),
    EmployeeSkillRecord(
      id: '${member.id}-skill-secondary',
      employeeId: member.id,
      category: EmployeeSkillInventoryCategory.leadership,
      skillName: _secondarySkill(member),
      owner: 'People Academy',
      currentLevel: highPerformer ? 4 : 3,
      requiredLevel: 4,
      criticality:
          highPerformer
              ? EmployeeSkillCriticality.growth
              : EmployeeSkillCriticality.core,
      status:
          highPerformer
              ? EmployeeSkillVerificationStatus.verified
              : EmployeeSkillVerificationStatus.inReview,
      lastVerifiedDate:
          highPerformer ? today.subtract(const Duration(days: 44)) : null,
      nextReviewDate: today.add(Duration(days: highPerformer ? 100 : 21)),
      evidenceCount: highPerformer ? 4 : 1,
      evidenceSummary:
          highPerformer
              ? 'Peer review confirmed strong cross-functional practice.'
              : 'Evidence is being reviewed by People Academy.',
    ),
  ];
}

EmployeeSkillInventoryCategory _categoryFor(EmployeeDirectoryMember member) {
  return switch (member.department) {
    'Engineering' => EmployeeSkillInventoryCategory.technical,
    'Product' => EmployeeSkillInventoryCategory.domain,
    'Design' => EmployeeSkillInventoryCategory.domain,
    'Human Resources' => EmployeeSkillInventoryCategory.compliance,
    _ => EmployeeSkillInventoryCategory.operations,
  };
}

String _primarySkill(EmployeeDirectoryMember member) {
  return switch (member.department) {
    'Engineering' => 'Flutter architecture',
    'Design' => 'Design systems',
    'Product' => 'Roadmap analytics',
    'Human Resources' => 'HR operations governance',
    _ => 'Operational excellence',
  };
}

String _secondarySkill(EmployeeDirectoryMember member) {
  return switch (member.department) {
    'Engineering' => 'Production readiness',
    'Design' => 'Research synthesis',
    'Product' => 'Stakeholder alignment',
    'Human Resources' => 'Employee relations',
    _ => 'Stakeholder communication',
  };
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
