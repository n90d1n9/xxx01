import '../models/project_domain_pack.dart';
import '../models/project_custom_attribute.dart';

const projectDomainBusinessDomainOptions = [
  'Construction',
  'Software Development',
  'Music Event',
  'Government Program',
  'Education Program',
  'Wedding Organizer',
  'Retail Operations',
  'General Business',
];

const projectDomainPacks = [
  ProjectDomainPack(
    id: 'construction',
    businessDomain: 'Construction',
    label: 'Construction',
    statusVocabularyId: 'construction',
    statusAudienceId: 'stakeholder',
    customAttributeTemplates: [
      ProjectCustomAttributeTemplate(
        key: 'site-location',
        label: 'Site Location',
        type: ProjectCustomAttributeType.text,
        importance: ProjectCustomAttributeImportance.requiredField,
      ),
      ProjectCustomAttributeTemplate(
        key: 'permit-id',
        label: 'Permit ID',
        type: ProjectCustomAttributeType.text,
        importance: ProjectCustomAttributeImportance.requiredField,
      ),
      ProjectCustomAttributeTemplate(
        key: 'contract-package',
        label: 'Contract Package',
        type: ProjectCustomAttributeType.text,
      ),
      ProjectCustomAttributeTemplate(
        key: 'safety-level',
        label: 'Safety Level',
        type: ProjectCustomAttributeType.choice,
        options: ['Low', 'Medium', 'High'],
      ),
    ],
    playbookControlTemplate: ProjectDomainPlaybookControlTemplate(
      title: 'Confirm site controls',
      detail:
          'Validate access, permits, supplier readiness, safety checks, and phase-gate evidence.',
    ),
    riskRules: [
      ProjectDomainRiskRule(
        title: 'Permit readiness',
        detail:
            'Permit ID is not captured yet; confirm approval ownership before site execution.',
        severityId: 'atRisk',
        attributeKey: 'permit-id',
        trigger: ProjectDomainRiskRuleTrigger.missingAttribute,
      ),
      ProjectDomainRiskRule(
        title: 'High safety exposure',
        detail:
            'High safety level needs toolbox cadence, incident route, and site evidence review.',
        severityId: 'atRisk',
        attributeKey: 'safety-level',
        trigger: ProjectDomainRiskRuleTrigger.attributeEquals,
        expectedValue: 'high',
      ),
    ],
    milestoneTemplate: ProjectDomainMilestoneTemplate(
      kickoffLabel: 'Site kickoff',
      reviewLabel: 'Permit and build review',
      handoverLabel: 'Handover inspection',
      kickoffContextAttributeKey: 'site-location',
    ),
    teamTemplate: ProjectDomainTeamTemplate(
      leadRole: 'Construction Project Lead',
      sponsorRole: 'Permit and Site Sponsor',
      supportRole: 'Safety Coordinator',
      supportNameFallback: 'Site Team',
      supportContextAttributeKey: 'site-location',
    ),
  ),
  ProjectDomainPack(
    id: 'software-development',
    businessDomain: 'Software Development',
    label: 'Software',
    statusVocabularyId: 'software',
    statusAudienceId: 'team',
    customAttributeTemplates: [
      ProjectCustomAttributeTemplate(
        key: 'repository',
        label: 'Repository',
        type: ProjectCustomAttributeType.url,
        importance: ProjectCustomAttributeImportance.requiredField,
      ),
      ProjectCustomAttributeTemplate(
        key: 'release-train',
        label: 'Release Train',
        type: ProjectCustomAttributeType.text,
      ),
      ProjectCustomAttributeTemplate(
        key: 'target-environment',
        label: 'Target Environment',
        type: ProjectCustomAttributeType.choice,
        options: ['Development', 'Staging', 'Production'],
        importance: ProjectCustomAttributeImportance.requiredField,
      ),
      ProjectCustomAttributeTemplate(
        key: 'api-contract',
        label: 'API Contract',
        type: ProjectCustomAttributeType.boolean,
        importance: ProjectCustomAttributeImportance.requiredField,
      ),
    ],
    playbookControlTemplate: ProjectDomainPlaybookControlTemplate(
      title: 'Confirm release controls',
      detail:
          'Lock scope, acceptance criteria, dependency owners, QA evidence, and rollout readiness.',
    ),
    riskRules: [
      ProjectDomainRiskRule(
        title: 'API contract not signed',
        detail:
            'The release depends on an unsigned API contract; lock schema ownership before build work expands.',
        severityId: 'blocked',
        attributeKey: 'api-contract',
        trigger: ProjectDomainRiskRuleTrigger.booleanFalse,
      ),
      ProjectDomainRiskRule(
        title: 'API contract readiness',
        detail:
            'API contract status is not captured; confirm schema, payload, and acceptance ownership.',
        severityId: 'atRisk',
        attributeKey: 'api-contract',
        trigger: ProjectDomainRiskRuleTrigger.booleanMissing,
      ),
      ProjectDomainRiskRule(
        title: 'Repository traceability',
        detail:
            'Repository link is missing; traceability, release notes, and handoff evidence may scatter.',
        severityId: 'atRisk',
        attributeKey: 'repository',
        trigger: ProjectDomainRiskRuleTrigger.missingAttribute,
      ),
      ProjectDomainRiskRule(
        title: 'Production readiness',
        detail:
            'Production target is selected while progress is still early; confirm rollout, rollback, and support windows.',
        severityId: 'atRisk',
        attributeKey: 'target-environment',
        trigger: ProjectDomainRiskRuleTrigger.attributeEqualsWhenProgressBelow,
        expectedValue: 'production',
        progressBelow: 0.4,
      ),
    ],
    milestoneTemplate: ProjectDomainMilestoneTemplate(
      kickoffLabel: 'Backlog kickoff',
      reviewLabel: 'Release candidate review',
      handoverLabel: 'Production handover',
      kickoffContextAttributeKey: 'release-train',
      reviewContextAttributeKey: 'target-environment',
    ),
    teamTemplate: ProjectDomainTeamTemplate(
      leadRole: 'Product Owner',
      sponsorRole: 'Business Sponsor',
      supportRole: 'Release Lead',
      supportNameFallback: 'Release Crew',
      supportContextAttributeKey: 'target-environment',
    ),
  ),
  ProjectDomainPack(
    id: 'music-event',
    businessDomain: 'Music Event',
    label: 'Event',
    statusVocabularyId: 'event-production',
    statusAudienceId: 'client',
    customAttributeTemplates: [
      ProjectCustomAttributeTemplate(
        key: 'venue',
        label: 'Venue',
        type: ProjectCustomAttributeType.text,
        importance: ProjectCustomAttributeImportance.requiredField,
      ),
      ProjectCustomAttributeTemplate(
        key: 'expected-attendance',
        label: 'Expected Attendance',
        type: ProjectCustomAttributeType.number,
        unit: 'guests',
      ),
      ProjectCustomAttributeTemplate(
        key: 'talent-coordinator',
        label: 'Talent Coordinator',
        type: ProjectCustomAttributeType.text,
        importance: ProjectCustomAttributeImportance.optional,
      ),
      ProjectCustomAttributeTemplate(
        key: 'permit-window',
        label: 'Permit Window',
        type: ProjectCustomAttributeType.date,
        importance: ProjectCustomAttributeImportance.requiredField,
      ),
    ],
    playbookControlTemplate: ProjectDomainPlaybookControlTemplate(
      title: 'Confirm production controls',
      detail:
          'Lock run sheet, venue access, vendor call times, talent flow, and contingency owners.',
    ),
    riskRules: [
      ProjectDomainRiskRule(
        title: 'Venue confirmation',
        detail:
            'Venue is not captured yet; production, permit, and vendor plans need a confirmed location.',
        severityId: 'atRisk',
        attributeKey: 'venue',
        trigger: ProjectDomainRiskRuleTrigger.missingAttribute,
      ),
      ProjectDomainRiskRule(
        title: 'Crowd operations',
        detail:
            '{value} expected attendees require crowd flow, security, and medical readiness review.',
        severityId: 'atRisk',
        attributeKey: 'expected-attendance',
        trigger: ProjectDomainRiskRuleTrigger.numberAtLeast,
        threshold: 1000,
      ),
      ProjectDomainRiskRule(
        title: 'Permit window',
        detail:
            'Permit window is not captured; authority approval can become the critical path.',
        severityId: 'atRisk',
        attributeKey: 'permit-window',
        trigger: ProjectDomainRiskRuleTrigger.missingAttribute,
      ),
    ],
    milestoneTemplate: ProjectDomainMilestoneTemplate(
      kickoffLabel: 'Venue and permit lock',
      reviewLabel: 'Production rehearsal',
      handoverLabel: 'Show day handover',
      kickoffContextAttributeKey: 'venue',
    ),
    teamTemplate: ProjectDomainTeamTemplate(
      leadRole: 'Event Producer',
      sponsorRole: 'Client Sponsor',
      supportRole: 'Venue Operations Lead',
      supportNameFallback: 'Venue Crew',
      supportContextAttributeKey: 'venue',
    ),
  ),
  ProjectDomainPack(
    id: 'government-program',
    businessDomain: 'Government Program',
    label: 'Government',
    statusVocabularyId: 'government',
    statusAudienceId: 'stakeholder',
    customAttributeTemplates: [
      ProjectCustomAttributeTemplate(
        key: 'program-code',
        label: 'Program Code',
        type: ProjectCustomAttributeType.text,
        importance: ProjectCustomAttributeImportance.requiredField,
      ),
      ProjectCustomAttributeTemplate(
        key: 'procurement-method',
        label: 'Procurement Method',
        type: ProjectCustomAttributeType.choice,
        options: ['Direct', 'Tender', 'Framework'],
        importance: ProjectCustomAttributeImportance.requiredField,
      ),
      ProjectCustomAttributeTemplate(
        key: 'compliance-gate',
        label: 'Compliance Gate',
        type: ProjectCustomAttributeType.text,
        importance: ProjectCustomAttributeImportance.requiredField,
      ),
      ProjectCustomAttributeTemplate(
        key: 'public-reporting',
        label: 'Public Reporting',
        type: ProjectCustomAttributeType.boolean,
      ),
    ],
    playbookControlTemplate: ProjectDomainPlaybookControlTemplate(
      title: 'Confirm governance controls',
      detail:
          'Validate approvals, compliance evidence, public accountability, and escalation path.',
    ),
    riskRules: [
      ProjectDomainRiskRule(
        title: 'Tender dependency',
        detail:
            'Tender procurement needs evaluation dates, award controls, and contract readiness tracking.',
        severityId: 'atRisk',
        attributeKey: 'procurement-method',
        trigger: ProjectDomainRiskRuleTrigger.attributeEquals,
        expectedValue: 'tender',
      ),
      ProjectDomainRiskRule(
        title: 'Compliance gate',
        detail:
            'Compliance gate is not captured; approval evidence may be unclear during public review.',
        severityId: 'atRisk',
        attributeKey: 'compliance-gate',
        trigger: ProjectDomainRiskRuleTrigger.missingAttribute,
      ),
      ProjectDomainRiskRule(
        title: 'Public reporting exposure',
        detail:
            'Public reporting is enabled; align narrative, evidence, and release approvals early.',
        severityId: 'atRisk',
        attributeKey: 'public-reporting',
        trigger: ProjectDomainRiskRuleTrigger.booleanTrue,
      ),
    ],
    milestoneTemplate: ProjectDomainMilestoneTemplate(
      kickoffLabel: 'Mandate kickoff',
      reviewLabel: 'Procurement and compliance review',
      handoverLabel: 'Public handover',
      kickoffContextAttributeKey: 'program-code',
    ),
    teamTemplate: ProjectDomainTeamTemplate(
      leadRole: 'Program Owner',
      sponsorRole: 'Executive Sponsor',
      supportRole: 'Compliance Lead',
      supportNameFallback: 'Compliance Desk',
      supportContextAttributeKey: 'program-code',
    ),
  ),
  ProjectDomainPack(
    id: 'education-program',
    businessDomain: 'Education Program',
    label: 'Education',
    statusVocabularyId: 'education',
    statusAudienceId: 'stakeholder',
    customAttributeTemplates: [
      ProjectCustomAttributeTemplate(
        key: 'campus',
        label: 'Campus',
        type: ProjectCustomAttributeType.text,
        importance: ProjectCustomAttributeImportance.requiredField,
      ),
      ProjectCustomAttributeTemplate(
        key: 'semester',
        label: 'Semester',
        type: ProjectCustomAttributeType.text,
        importance: ProjectCustomAttributeImportance.requiredField,
      ),
      ProjectCustomAttributeTemplate(
        key: 'student-impact',
        label: 'Student Impact',
        type: ProjectCustomAttributeType.number,
        unit: 'students',
        importance: ProjectCustomAttributeImportance.requiredField,
      ),
      ProjectCustomAttributeTemplate(
        key: 'accreditation-impact',
        label: 'Accreditation Impact',
        type: ProjectCustomAttributeType.boolean,
      ),
    ],
    playbookControlTemplate: ProjectDomainPlaybookControlTemplate(
      title: 'Confirm academic controls',
      detail:
          'Align curriculum, learning operations, faculty coverage, learner readiness, and calendar risk.',
    ),
    riskRules: [
      ProjectDomainRiskRule(
        title: 'Campus readiness',
        detail:
            'Campus is not captured; facilities, academic calendar, and stakeholder plans need a clear site.',
        severityId: 'atRisk',
        attributeKey: 'campus',
        trigger: ProjectDomainRiskRuleTrigger.missingAttribute,
      ),
      ProjectDomainRiskRule(
        title: 'Student impact',
        detail:
            '{value} students are in scope; align communication, timetable, and support coverage.',
        severityId: 'atRisk',
        attributeKey: 'student-impact',
        trigger: ProjectDomainRiskRuleTrigger.numberAtLeast,
        threshold: 500,
      ),
      ProjectDomainRiskRule(
        title: 'Accreditation dependency',
        detail:
            'Accreditation impact is enabled; evidence and approval paths need formal ownership.',
        severityId: 'atRisk',
        attributeKey: 'accreditation-impact',
        trigger: ProjectDomainRiskRuleTrigger.booleanTrue,
      ),
    ],
    milestoneTemplate: ProjectDomainMilestoneTemplate(
      kickoffLabel: 'Academic kickoff',
      reviewLabel: 'Campus readiness review',
      handoverLabel: 'Program launch',
      kickoffContextAttributeKey: 'campus',
    ),
    teamTemplate: ProjectDomainTeamTemplate(
      leadRole: 'Academic Program Lead',
      sponsorRole: 'Academic Sponsor',
      supportRole: 'Campus Coordinator',
      supportNameFallback: 'Campus Team',
      supportContextAttributeKey: 'campus',
    ),
  ),
  ProjectDomainPack(
    id: 'wedding-organizer',
    businessDomain: 'Wedding Organizer',
    label: 'Wedding',
    statusVocabularyId: 'wedding',
    statusAudienceId: 'client',
    customAttributeTemplates: [
      ProjectCustomAttributeTemplate(
        key: 'venue',
        label: 'Venue',
        type: ProjectCustomAttributeType.text,
        importance: ProjectCustomAttributeImportance.requiredField,
      ),
      ProjectCustomAttributeTemplate(
        key: 'guest-count',
        label: 'Guest Count',
        type: ProjectCustomAttributeType.number,
        unit: 'guests',
        importance: ProjectCustomAttributeImportance.requiredField,
      ),
      ProjectCustomAttributeTemplate(
        key: 'ceremony-type',
        label: 'Ceremony Type',
        type: ProjectCustomAttributeType.text,
      ),
      ProjectCustomAttributeTemplate(
        key: 'vendor-package',
        label: 'Vendor Package',
        type: ProjectCustomAttributeType.text,
        importance: ProjectCustomAttributeImportance.requiredField,
      ),
    ],
    playbookControlTemplate: ProjectDomainPlaybookControlTemplate(
      title: 'Confirm wedding controls',
      detail:
          'Lock vendors, guest-impact decisions, venue readiness, planner handoff, and day-of timing.',
    ),
    riskRules: [
      ProjectDomainRiskRule(
        title: 'Venue lock',
        detail:
            'Venue is not captured yet; vendor timing, guest flow, and ceremony plan remain exposed.',
        severityId: 'atRisk',
        attributeKey: 'venue',
        trigger: ProjectDomainRiskRuleTrigger.missingAttribute,
      ),
      ProjectDomainRiskRule(
        title: 'Guest capacity',
        detail:
            '{value} guests need capacity, catering, parking, and contingency checks.',
        severityId: 'atRisk',
        attributeKey: 'guest-count',
        trigger: ProjectDomainRiskRuleTrigger.numberAtLeast,
        threshold: 300,
      ),
      ProjectDomainRiskRule(
        title: 'Vendor package',
        detail:
            'Vendor package is not captured; handoff, run sheet, and payment scope need confirmation.',
        severityId: 'atRisk',
        attributeKey: 'vendor-package',
        trigger: ProjectDomainRiskRuleTrigger.missingAttribute,
      ),
    ],
    milestoneTemplate: ProjectDomainMilestoneTemplate(
      kickoffLabel: 'Venue and vendor lock',
      reviewLabel: 'Run sheet finalization',
      handoverLabel: 'Event day handoff',
      kickoffContextAttributeKey: 'venue',
    ),
    teamTemplate: ProjectDomainTeamTemplate(
      leadRole: 'Lead Planner',
      sponsorRole: 'Client Sponsor',
      supportRole: 'Vendor Coordinator',
      supportNameFallback: 'Vendor Crew',
      supportContextAttributeKey: 'venue',
    ),
  ),
  ProjectDomainPack(
    id: 'retail-operations',
    businessDomain: 'Retail Operations',
    label: 'Retail',
    statusVocabularyId: 'retail-operations',
    statusAudienceId: 'team',
    customAttributeTemplates: [
      ProjectCustomAttributeTemplate(
        key: 'store-cluster',
        label: 'Store Cluster',
        type: ProjectCustomAttributeType.text,
        importance: ProjectCustomAttributeImportance.requiredField,
      ),
      ProjectCustomAttributeTemplate(
        key: 'launch-wave',
        label: 'Launch Wave',
        type: ProjectCustomAttributeType.text,
        importance: ProjectCustomAttributeImportance.requiredField,
      ),
      ProjectCustomAttributeTemplate(
        key: 'sku-scope',
        label: 'SKU Scope',
        type: ProjectCustomAttributeType.number,
        unit: 'SKUs',
      ),
      ProjectCustomAttributeTemplate(
        key: 'omnichannel-impact',
        label: 'Omnichannel Impact',
        type: ProjectCustomAttributeType.boolean,
      ),
    ],
    playbookControlTemplate: ProjectDomainPlaybookControlTemplate(
      title: 'Confirm retail rollout controls',
      detail:
          'Validate store wave readiness, merchandising scope, inventory cutover, staff enablement, and launch support.',
    ),
    riskRules: [
      ProjectDomainRiskRule(
        title: 'Launch wave readiness',
        detail:
            'Launch wave is not captured; store rollout, training, and support windows need sequencing.',
        severityId: 'atRisk',
        attributeKey: 'launch-wave',
        trigger: ProjectDomainRiskRuleTrigger.missingAttribute,
      ),
      ProjectDomainRiskRule(
        title: 'SKU scope pressure',
        detail:
            '{value} SKUs are in scope; catalog, inventory sync, and exception handling need review.',
        severityId: 'atRisk',
        attributeKey: 'sku-scope',
        trigger: ProjectDomainRiskRuleTrigger.numberAtLeast,
        threshold: 1000,
      ),
      ProjectDomainRiskRule(
        title: 'Omnichannel dependency',
        detail:
            'Omnichannel impact is enabled; checkout, fulfillment, and channel promise policies need aligned readiness.',
        severityId: 'atRisk',
        attributeKey: 'omnichannel-impact',
        trigger: ProjectDomainRiskRuleTrigger.booleanTrue,
      ),
    ],
    milestoneTemplate: ProjectDomainMilestoneTemplate(
      kickoffLabel: 'Store pilot ready',
      reviewLabel: 'Launch review',
      handoverLabel: 'Rollout handover',
      kickoffContextAttributeKey: 'store-cluster',
      reviewContextAttributeKey: 'launch-wave',
    ),
    teamTemplate: ProjectDomainTeamTemplate(
      leadRole: 'Store Rollout Lead',
      sponsorRole: 'Retail Sponsor',
      supportRole: 'Store Enablement Lead',
      supportNameFallback: 'Store Crew',
      supportContextAttributeKey: 'store-cluster',
    ),
  ),
  ProjectDomainPack(
    id: 'general-business',
    businessDomain: 'General Business',
    label: 'General',
    statusVocabularyId: 'general',
    statusAudienceId: 'stakeholder',
    customAttributeTemplates: [
      ProjectCustomAttributeTemplate(
        key: 'workstream',
        label: 'Workstream',
        type: ProjectCustomAttributeType.text,
        importance: ProjectCustomAttributeImportance.requiredField,
      ),
      ProjectCustomAttributeTemplate(
        key: 'region',
        label: 'Region',
        type: ProjectCustomAttributeType.text,
      ),
      ProjectCustomAttributeTemplate(
        key: 'priority',
        label: 'Priority',
        type: ProjectCustomAttributeType.choice,
        options: ['Low', 'Medium', 'High'],
        importance: ProjectCustomAttributeImportance.requiredField,
      ),
      ProjectCustomAttributeTemplate(
        key: 'kpi-owner',
        label: 'KPI Owner',
        type: ProjectCustomAttributeType.text,
      ),
    ],
    playbookControlTemplate: ProjectDomainPlaybookControlTemplate(
      title: 'Confirm operating rhythm',
      detail:
          'Align owner, next milestone, risk posture, and decision cadence before the next review.',
    ),
    riskRules: [
      ProjectDomainRiskRule(
        title: 'High priority workstream',
        detail:
            'High priority is selected; confirm decision owner, escalation path, and weekly evidence checks.',
        severityId: 'atRisk',
        attributeKey: 'priority',
        trigger: ProjectDomainRiskRuleTrigger.attributeEquals,
        expectedValue: 'high',
      ),
    ],
    milestoneTemplate: ProjectDomainMilestoneTemplate(
      kickoffLabel: 'Kickoff',
      reviewLabel: '',
      handoverLabel: 'Handover',
    ),
    teamTemplate: ProjectDomainTeamTemplate(
      leadRole: 'Project Lead',
      sponsorRole: 'Business Sponsor',
      supportRole: 'Workstream Coordinator',
      supportNameFallback: 'Delivery Team',
      supportContextAttributeKey: 'workstream',
    ),
  ),
];

ProjectDomainPack projectDomainPackForBusinessDomain(String businessDomain) {
  final normalizedId = normalizeProjectDomainId(businessDomain);
  for (final pack in projectDomainPacks) {
    if (pack.id == normalizedId) return pack;
  }

  return projectDomainPacks.last;
}

ProjectDomainPack projectDomainPackForStatusVocabularyId(String vocabularyId) {
  final normalizedVocabularyId = normalizeProjectDomainId(vocabularyId);
  for (final pack in projectDomainPacks) {
    if (pack.statusVocabularyId == normalizedVocabularyId) return pack;
  }

  return projectDomainPacks.last;
}

String normalizeProjectDomainId(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}
