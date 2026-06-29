import 'candidate_development_calibration_profile.dart';

class CandidateDevelopmentCalibrationSummary {
  final int totalCount;
  final int readyCount;
  final int monitorCount;
  final int blockedCount;
  final double averageReadinessScore;
  final String nextAction;

  const CandidateDevelopmentCalibrationSummary({
    required this.totalCount,
    required this.readyCount,
    required this.monitorCount,
    required this.blockedCount,
    required this.averageReadinessScore,
    required this.nextAction,
  });

  factory CandidateDevelopmentCalibrationSummary.fromProfiles(
    List<CandidateDevelopmentCalibrationProfile> profiles,
  ) {
    final readyCount =
        profiles
            .where(
              (item) =>
                  item.status == CandidateDevelopmentCalibrationStatus.ready,
            )
            .length;
    final monitorCount =
        profiles
            .where(
              (item) =>
                  item.status == CandidateDevelopmentCalibrationStatus.monitor,
            )
            .length;
    final blockedCount =
        profiles
            .where(
              (item) =>
                  item.status == CandidateDevelopmentCalibrationStatus.blocked,
            )
            .length;
    final totalScore = profiles.fold<int>(
      0,
      (total, item) => total + item.readinessScore,
    );

    return CandidateDevelopmentCalibrationSummary(
      totalCount: profiles.length,
      readyCount: readyCount,
      monitorCount: monitorCount,
      blockedCount: blockedCount,
      averageReadinessScore:
          profiles.isEmpty ? 0 : totalScore / profiles.length,
      nextAction: _summaryNextAction(
        totalCount: profiles.length,
        blockedCount: blockedCount,
        monitorCount: monitorCount,
        readyCount: readyCount,
      ),
    );
  }
}

String _summaryNextAction({
  required int totalCount,
  required int blockedCount,
  required int monitorCount,
  required int readyCount,
}) {
  if (totalCount == 0) return 'Create development objectives to calibrate.';
  if (blockedCount > 0) {
    return 'Escalate $blockedCount blocked development calibrations.';
  }
  if (monitorCount > 0) return 'Review $monitorCount monitored calibrations.';
  if (readyCount > 0) return 'Confirm $readyCount ready candidates.';
  return 'Development calibration is clear.';
}
