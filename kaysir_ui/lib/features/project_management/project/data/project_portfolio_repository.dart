import '../models/project_custom_attribute.dart';
import '../models/project_portfolio_item.dart';

class ProjectPortfolioRepository {
  const ProjectPortfolioRepository();

  List<ProjectPortfolioItem> fetchProjects() =>
      List.unmodifiable(demoProjectPortfolio);

  ProjectPortfolioItem? findById(String projectId) {
    for (final project in demoProjectPortfolio) {
      if (project.id == projectId) return project;
    }
    return null;
  }
}

final List<ProjectPortfolioItem> demoProjectPortfolio = [
  ProjectPortfolioItem(
    id: 'retail-modernization',
    name: 'Retail Modernization',
    owner: 'Maya Santoso',
    client: 'Kaysir Retail',
    sponsor: 'Retail Operations',
    businessDomain: 'Retail Operations',
    summary:
        'Modernizes branch sales workflows with guided checkout, inventory visibility, and refreshed store-team routines.',
    customAttributes: const [
      ProjectCustomAttribute(
        key: 'store-cluster',
        label: 'Store Cluster',
        type: ProjectCustomAttributeType.text,
        value: 'Jakarta pilot',
        isPinned: true,
      ),
      ProjectCustomAttribute(
        key: 'launch-wave',
        label: 'Launch Wave',
        type: ProjectCustomAttributeType.text,
        value: 'Wave 2',
        isPinned: true,
      ),
      ProjectCustomAttribute(
        key: 'sku-scope',
        label: 'SKU Scope',
        type: ProjectCustomAttributeType.number,
        value: '1200',
        unit: 'SKUs',
        isPinned: true,
      ),
    ],
    startDate: DateTime(2026, 5, 1),
    endDate: DateTime(2026, 8, 14),
    progress: 0.62,
    budgetUsed: 0.58,
    health: ProjectHealth.onTrack,
    timelineTaskIds: ['1', '1.1', '1.2'],
    milestones: [
      ProjectMilestone(
        label: 'Discovery',
        dueDate: DateTime(2026, 5, 17),
        isComplete: true,
      ),
      ProjectMilestone(
        label: 'Pilot',
        dueDate: DateTime(2026, 6, 21),
        isComplete: false,
      ),
      ProjectMilestone(
        label: 'Rollout',
        dueDate: DateTime(2026, 8, 7),
        isComplete: false,
      ),
    ],
    risks: [
      ProjectDeliveryRisk(
        title: 'Store readiness',
        detail: 'Pilot branches need shift-by-shift training coverage.',
        severity: ProjectHealth.atRisk,
      ),
      ProjectDeliveryRisk(
        title: 'Inventory feed',
        detail: 'Daily sync is stable and monitored by operations.',
        severity: ProjectHealth.onTrack,
      ),
    ],
    team: [
      ProjectTeamMember(
        name: 'Maya Santoso',
        role: 'Delivery Lead',
        allocation: 0.8,
      ),
      ProjectTeamMember(
        name: 'Dian Lestari',
        role: 'Retail Analyst',
        allocation: 0.6,
      ),
      ProjectTeamMember(name: 'Iqbal Karim', role: 'QA Lead', allocation: 0.4),
    ],
  ),
  ProjectPortfolioItem(
    id: 'warehouse-automation',
    name: 'Warehouse Automation',
    owner: 'Rafi Prakoso',
    client: 'Fulfillment Ops',
    sponsor: 'Supply Chain',
    businessDomain: 'General Business',
    summary:
        'Introduces scanner-assisted receiving, sensor events, and dispatch automation for high-volume fulfillment lanes.',
    customAttributes: const [
      ProjectCustomAttribute(
        key: 'workstream',
        label: 'Workstream',
        type: ProjectCustomAttributeType.text,
        value: 'Fulfillment automation',
        isPinned: true,
      ),
      ProjectCustomAttribute(
        key: 'region',
        label: 'Region',
        type: ProjectCustomAttributeType.text,
        value: 'West Java',
        isPinned: true,
      ),
    ],
    startDate: DateTime(2026, 4, 8),
    endDate: DateTime(2026, 7, 19),
    progress: 0.44,
    budgetUsed: 0.71,
    health: ProjectHealth.atRisk,
    timelineTaskIds: ['2'],
    milestones: [
      ProjectMilestone(
        label: 'Sensors',
        dueDate: DateTime(2026, 5, 24),
        isComplete: true,
      ),
      ProjectMilestone(
        label: 'Integration',
        dueDate: DateTime(2026, 6, 30),
        isComplete: false,
      ),
      ProjectMilestone(
        label: 'UAT',
        dueDate: DateTime(2026, 7, 12),
        isComplete: false,
      ),
    ],
    risks: [
      ProjectDeliveryRisk(
        title: 'Device lead time',
        detail: 'Backup sensor supplier is ready if the primary order slips.',
        severity: ProjectHealth.atRisk,
      ),
      ProjectDeliveryRisk(
        title: 'Budget pressure',
        detail: 'Automation lane scope is being sequenced by throughput value.',
        severity: ProjectHealth.atRisk,
      ),
    ],
    team: [
      ProjectTeamMember(
        name: 'Rafi Prakoso',
        role: 'Program Manager',
        allocation: 0.7,
      ),
      ProjectTeamMember(
        name: 'Laras Amalia',
        role: 'Ops Architect',
        allocation: 0.5,
      ),
      ProjectTeamMember(
        name: 'Tomi Nugraha',
        role: 'Integration Engineer',
        allocation: 0.7,
      ),
    ],
  ),
  ProjectPortfolioItem(
    id: 'mobile-field-app',
    name: 'Mobile Field App',
    owner: 'Nadia Putri',
    client: 'Service Team',
    sponsor: 'Customer Service',
    businessDomain: 'Software Development',
    summary:
        'Equips field teams with offline work orders, photo evidence, and visit resolution from mobile devices.',
    customAttributes: const [
      ProjectCustomAttribute(
        key: 'release-train',
        label: 'Release Train',
        type: ProjectCustomAttributeType.text,
        value: 'Mobile Q3',
        isPinned: true,
      ),
      ProjectCustomAttribute(
        key: 'target-environment',
        label: 'Target Environment',
        type: ProjectCustomAttributeType.choice,
        value: 'Production',
        options: ['Development', 'Staging', 'Production'],
        isPinned: true,
      ),
    ],
    startDate: DateTime(2026, 5, 20),
    endDate: DateTime(2026, 9, 4),
    progress: 0.18,
    budgetUsed: 0.22,
    health: ProjectHealth.blocked,
    timelineTaskIds: ['3'],
    milestones: [
      ProjectMilestone(
        label: 'API Ready',
        dueDate: DateTime(2026, 6, 11),
        isComplete: false,
      ),
      ProjectMilestone(
        label: 'Beta',
        dueDate: DateTime(2026, 7, 28),
        isComplete: false,
      ),
      ProjectMilestone(
        label: 'Launch',
        dueDate: DateTime(2026, 8, 31),
        isComplete: false,
      ),
    ],
    risks: [
      ProjectDeliveryRisk(
        title: 'API contract drift',
        detail: 'Service history endpoints need a signed payload contract.',
        severity: ProjectHealth.blocked,
      ),
      ProjectDeliveryRisk(
        title: 'Offline cache scope',
        detail: 'Product and visit evidence caches need final size limits.',
        severity: ProjectHealth.atRisk,
      ),
    ],
    team: [
      ProjectTeamMember(
        name: 'Nadia Putri',
        role: 'Product Owner',
        allocation: 0.6,
      ),
      ProjectTeamMember(
        name: 'Arman Yusuf',
        role: 'Mobile Engineer',
        allocation: 0.8,
      ),
      ProjectTeamMember(
        name: 'Sari Wibowo',
        role: 'UX Researcher',
        allocation: 0.3,
      ),
    ],
  ),
  ProjectPortfolioItem(
    id: 'finance-close-suite',
    name: 'Finance Close Suite',
    owner: 'Bagas Wicaksono',
    client: 'Finance Office',
    sponsor: 'Corporate Finance',
    businessDomain: 'General Business',
    summary:
        'Packages period close controls, reconciliation evidence, and audit exports for finance teams.',
    customAttributes: const [
      ProjectCustomAttribute(
        key: 'workstream',
        label: 'Workstream',
        type: ProjectCustomAttributeType.text,
        value: 'Finance close',
        isPinned: true,
      ),
      ProjectCustomAttribute(
        key: 'kpi-owner',
        label: 'KPI Owner',
        type: ProjectCustomAttributeType.text,
        value: 'Corporate Controller',
        isPinned: true,
      ),
    ],
    startDate: DateTime(2026, 3, 18),
    endDate: DateTime(2026, 6, 29),
    progress: 0.81,
    budgetUsed: 0.76,
    health: ProjectHealth.onTrack,
    timelineTaskIds: ['4'],
    milestones: [
      ProjectMilestone(
        label: 'Controls',
        dueDate: DateTime(2026, 4, 19),
        isComplete: true,
      ),
      ProjectMilestone(
        label: 'Reports',
        dueDate: DateTime(2026, 5, 30),
        isComplete: true,
      ),
      ProjectMilestone(
        label: 'Audit',
        dueDate: DateTime(2026, 6, 22),
        isComplete: false,
      ),
    ],
    risks: [
      ProjectDeliveryRisk(
        title: 'Audit evidence',
        detail: 'Evidence exports are ready for the final reviewer sample.',
        severity: ProjectHealth.onTrack,
      ),
      ProjectDeliveryRisk(
        title: 'Close calendar',
        detail: 'June cutoff depends on finance office acceptance timing.',
        severity: ProjectHealth.atRisk,
      ),
    ],
    team: [
      ProjectTeamMember(
        name: 'Bagas Wicaksono',
        role: 'Finance Lead',
        allocation: 0.7,
      ),
      ProjectTeamMember(
        name: 'Citra Maheswari',
        role: 'Controls Analyst',
        allocation: 0.5,
      ),
      ProjectTeamMember(
        name: 'Yoga Pratama',
        role: 'Report Engineer',
        allocation: 0.6,
      ),
    ],
  ),
];
