import 'incoming_talent_development_program.dart';

class IncomingTalentDevelopmentProgramSummary {
  final int totalCount;
  final int draftCount;
  final int activeCount;
  final int pausedCount;
  final int archivedCount;
  final int totalCapacity;
  final String nextAction;

  const IncomingTalentDevelopmentProgramSummary({
    required this.totalCount,
    required this.draftCount,
    required this.activeCount,
    required this.pausedCount,
    required this.archivedCount,
    required this.totalCapacity,
    required this.nextAction,
  });

  factory IncomingTalentDevelopmentProgramSummary.fromPrograms(
    List<IncomingTalentDevelopmentProgram> programs,
  ) {
    final draftCount = _countStatus(
      programs,
      IncomingTalentDevelopmentProgramStatus.draft,
    );
    final activeCount = _countStatus(
      programs,
      IncomingTalentDevelopmentProgramStatus.active,
    );
    final pausedCount = _countStatus(
      programs,
      IncomingTalentDevelopmentProgramStatus.paused,
    );
    final archivedCount = _countStatus(
      programs,
      IncomingTalentDevelopmentProgramStatus.archived,
    );
    final totalCapacity = programs.fold<int>(
      0,
      (total, program) =>
          program.status == IncomingTalentDevelopmentProgramStatus.active
              ? total + program.capacity
              : total,
    );

    return IncomingTalentDevelopmentProgramSummary(
      totalCount: programs.length,
      draftCount: draftCount,
      activeCount: activeCount,
      pausedCount: pausedCount,
      archivedCount: archivedCount,
      totalCapacity: totalCapacity,
      nextAction: _nextAction(
        totalCount: programs.length,
        draftCount: draftCount,
        activeCount: activeCount,
        pausedCount: pausedCount,
      ),
    );
  }
}

int _countStatus(
  List<IncomingTalentDevelopmentProgram> programs,
  IncomingTalentDevelopmentProgramStatus status,
) {
  return programs.where((program) => program.status == status).length;
}

String _nextAction({
  required int totalCount,
  required int draftCount,
  required int activeCount,
  required int pausedCount,
}) {
  if (totalCount == 0) return 'Create development programs for IDP demand.';
  if (draftCount > 0) return 'Activate $draftCount draft programs.';
  if (pausedCount > 0) return 'Review $pausedCount paused programs.';
  if (activeCount > 0) return 'Enroll talent into $activeCount programs.';
  return 'Create an active program before enrollment.';
}
