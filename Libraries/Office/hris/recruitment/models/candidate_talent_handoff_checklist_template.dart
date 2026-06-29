import 'candidate_talent_handoff_checklist_item.dart';
import 'candidate_talent_handoff_models.dart';

enum CandidateTalentHandoffChecklistOwnerSource {
  handoffOwner,
  receivingManager,
}

class CandidateTalentHandoffChecklistTemplateTask {
  final CandidateTalentHandoffChecklistCategory category;
  final String title;
  final String detail;
  final int dueOffsetDays;
  final bool requiredBeforeStart;
  final CandidateTalentHandoffChecklistOwnerSource ownerSource;

  const CandidateTalentHandoffChecklistTemplateTask({
    required this.category,
    required this.title,
    required this.detail,
    required this.dueOffsetDays,
    required this.requiredBeforeStart,
    required this.ownerSource,
  });

  CandidateTalentHandoffChecklistItem toItem({
    required String id,
    required CandidateTalentHandoff handoff,
    required DateTime asOfDate,
    required DateTime createdAt,
  }) {
    return CandidateTalentHandoffChecklistItem(
      id: id,
      handoffId: handoff.id,
      candidateId: handoff.candidateId,
      candidateName: handoff.candidateName,
      role: handoff.role,
      department: handoff.department,
      category: category,
      status: CandidateTalentHandoffChecklistStatus.open,
      title: title,
      ownerName: _ownerName(handoff),
      dueDate: _safeDueDate(
        targetDate: handoff.targetStartDate.add(Duration(days: dueOffsetDays)),
        asOfDate: asOfDate,
      ),
      detail: detail,
      requiredBeforeStart: requiredBeforeStart,
      createdAt: createdAt,
    );
  }

  String _ownerName(CandidateTalentHandoff handoff) {
    return switch (ownerSource) {
      CandidateTalentHandoffChecklistOwnerSource.handoffOwner =>
        handoff.ownerName,
      CandidateTalentHandoffChecklistOwnerSource.receivingManager =>
        handoff.receivingManagerName,
    };
  }
}

class CandidateTalentHandoffChecklistTemplate {
  final String id;
  final String label;
  final CandidateTalentHandoffType handoffType;
  final List<CandidateTalentHandoffChecklistTemplateTask> tasks;

  const CandidateTalentHandoffChecklistTemplate({
    required this.id,
    required this.label,
    required this.handoffType,
    required this.tasks,
  });

  factory CandidateTalentHandoffChecklistTemplate.forHandoff(
    CandidateTalentHandoff handoff,
  ) {
    return switch (handoff.type) {
      CandidateTalentHandoffType.offerTransition => offerTransition,
      CandidateTalentHandoffType.preboarding => preboarding,
      CandidateTalentHandoffType.talentBench => talentBench,
      CandidateTalentHandoffType.deferred => deferred,
    };
  }

  static const offerTransition = CandidateTalentHandoffChecklistTemplate(
    id: 'handoff-template-offer-transition',
    label: 'Offer transition checklist',
    handoffType: CandidateTalentHandoffType.offerTransition,
    tasks: [
      CandidateTalentHandoffChecklistTemplateTask(
        category: CandidateTalentHandoffChecklistCategory.paperwork,
        title: 'Complete offer and contract handoff',
        detail: 'Confirm signed offer, contract, and acceptance handoff.',
        dueOffsetDays: -5,
        requiredBeforeStart: true,
        ownerSource: CandidateTalentHandoffChecklistOwnerSource.handoffOwner,
      ),
      CandidateTalentHandoffChecklistTemplateTask(
        category: CandidateTalentHandoffChecklistCategory.payroll,
        title: 'Confirm payroll profile readiness',
        detail: 'Prepare payroll profile, tax setup, and bank data owner.',
        dueOffsetDays: -4,
        requiredBeforeStart: true,
        ownerSource: CandidateTalentHandoffChecklistOwnerSource.handoffOwner,
      ),
      CandidateTalentHandoffChecklistTemplateTask(
        category: CandidateTalentHandoffChecklistCategory.access,
        title: 'Prepare system access package',
        detail: 'Request email, HRIS, collaboration, and role system access.',
        dueOffsetDays: -3,
        requiredBeforeStart: true,
        ownerSource: CandidateTalentHandoffChecklistOwnerSource.handoffOwner,
      ),
      CandidateTalentHandoffChecklistTemplateTask(
        category: CandidateTalentHandoffChecklistCategory.managerKickoff,
        title: 'Schedule manager kickoff',
        detail: 'Book first manager session and align first-week outcomes.',
        dueOffsetDays: -1,
        requiredBeforeStart: true,
        ownerSource:
            CandidateTalentHandoffChecklistOwnerSource.receivingManager,
      ),
      CandidateTalentHandoffChecklistTemplateTask(
        category: CandidateTalentHandoffChecklistCategory.mentor,
        title: 'Confirm mentor introduction',
        detail: 'Confirm mentor match and schedule the first intro session.',
        dueOffsetDays: -1,
        requiredBeforeStart: true,
        ownerSource:
            CandidateTalentHandoffChecklistOwnerSource.receivingManager,
      ),
    ],
  );

  static const preboarding = CandidateTalentHandoffChecklistTemplate(
    id: 'handoff-template-preboarding',
    label: 'Preboarding checklist',
    handoffType: CandidateTalentHandoffType.preboarding,
    tasks: [
      CandidateTalentHandoffChecklistTemplateTask(
        category: CandidateTalentHandoffChecklistCategory.access,
        title: 'Prepare system access package',
        detail: 'Request workspace, HRIS, and role tool access.',
        dueOffsetDays: -4,
        requiredBeforeStart: true,
        ownerSource: CandidateTalentHandoffChecklistOwnerSource.handoffOwner,
      ),
      CandidateTalentHandoffChecklistTemplateTask(
        category: CandidateTalentHandoffChecklistCategory.managerKickoff,
        title: 'Schedule manager kickoff',
        detail: 'Confirm kickoff date, manager owner, and start agenda.',
        dueOffsetDays: -2,
        requiredBeforeStart: true,
        ownerSource:
            CandidateTalentHandoffChecklistOwnerSource.receivingManager,
      ),
      CandidateTalentHandoffChecklistTemplateTask(
        category: CandidateTalentHandoffChecklistCategory.learning,
        title: 'Attach first learning plan',
        detail: 'Attach first learning path and checkpoint expectations.',
        dueOffsetDays: 3,
        requiredBeforeStart: false,
        ownerSource: CandidateTalentHandoffChecklistOwnerSource.handoffOwner,
      ),
    ],
  );

  static const talentBench = CandidateTalentHandoffChecklistTemplate(
    id: 'handoff-template-talent-bench',
    label: 'Talent bench checklist',
    handoffType: CandidateTalentHandoffType.talentBench,
    tasks: [
      CandidateTalentHandoffChecklistTemplateTask(
        category: CandidateTalentHandoffChecklistCategory.learning,
        title: 'Attach first learning plan',
        detail: 'Attach a bench learning path and next review cadence.',
        dueOffsetDays: 7,
        requiredBeforeStart: false,
        ownerSource: CandidateTalentHandoffChecklistOwnerSource.handoffOwner,
      ),
      CandidateTalentHandoffChecklistTemplateTask(
        category: CandidateTalentHandoffChecklistCategory.mentor,
        title: 'Confirm mentor introduction',
        detail: 'Confirm mentor support for bench development goals.',
        dueOffsetDays: 7,
        requiredBeforeStart: false,
        ownerSource:
            CandidateTalentHandoffChecklistOwnerSource.receivingManager,
      ),
    ],
  );

  static const deferred = CandidateTalentHandoffChecklistTemplate(
    id: 'handoff-template-deferred',
    label: 'Deferred handoff checklist',
    handoffType: CandidateTalentHandoffType.deferred,
    tasks: [
      CandidateTalentHandoffChecklistTemplateTask(
        category: CandidateTalentHandoffChecklistCategory.managerKickoff,
        title: 'Schedule manager recalibration',
        detail: 'Confirm blocker owner, recalibration date, and next decision.',
        dueOffsetDays: -7,
        requiredBeforeStart: true,
        ownerSource:
            CandidateTalentHandoffChecklistOwnerSource.receivingManager,
      ),
      CandidateTalentHandoffChecklistTemplateTask(
        category: CandidateTalentHandoffChecklistCategory.learning,
        title: 'Attach recovery learning plan',
        detail: 'Attach focused recovery learning actions before ramp.',
        dueOffsetDays: -5,
        requiredBeforeStart: true,
        ownerSource: CandidateTalentHandoffChecklistOwnerSource.handoffOwner,
      ),
    ],
  );

  static const values = [offerTransition, preboarding, talentBench, deferred];
}

DateTime _safeDueDate({
  required DateTime targetDate,
  required DateTime asOfDate,
}) {
  final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
  final today = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
  return target.isBefore(today) ? today : target;
}
