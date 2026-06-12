import 'incoming_talent_profile_timeline.dart';

class IncomingTalentProfileTimelineSummary {
  final int totalProfiles;
  final int attentionProfiles;
  final int calibratedProfiles;
  final int openInterventions;
  final int watchDevelopmentOutcomes;
  final int openDevelopmentFollowUps;
  final int watchDevelopmentFollowUps;
  final int watchDevelopmentResolutions;
  final int openCareerSupportActions;
  final int watchCareerSupportOutcomes;
  final int programMilestoneRevisions;
  final int programCompletionExtensions;
  final int watchPromotionStabilizations;
  final int openPromotionFollowUps;
  final int watchPromotionFollowUps;
  final int watchPromotionResolutions;
  final int highReadinessProfiles;
  final String nextAction;

  const IncomingTalentProfileTimelineSummary({
    required this.totalProfiles,
    required this.attentionProfiles,
    required this.calibratedProfiles,
    required this.openInterventions,
    required this.watchDevelopmentOutcomes,
    required this.openDevelopmentFollowUps,
    required this.watchDevelopmentFollowUps,
    required this.watchDevelopmentResolutions,
    required this.openCareerSupportActions,
    required this.watchCareerSupportOutcomes,
    required this.programMilestoneRevisions,
    required this.programCompletionExtensions,
    required this.watchPromotionStabilizations,
    required this.openPromotionFollowUps,
    required this.watchPromotionFollowUps,
    required this.watchPromotionResolutions,
    required this.highReadinessProfiles,
    required this.nextAction,
  });

  factory IncomingTalentProfileTimelineSummary.fromTimelines(
    List<IncomingTalentProfileTimeline> timelines,
  ) {
    final attentionProfiles =
        timelines.where((timeline) => timeline.needsAttention).length;
    final calibratedProfiles =
        timelines.where((timeline) => timeline.hasCalibration).length;
    final openInterventions = timelines.fold<int>(
      0,
      (total, timeline) => total + timeline.openInterventionCount,
    );
    final watchDevelopmentOutcomes = timelines.fold<int>(
      0,
      (total, timeline) => total + timeline.watchDevelopmentOutcomeCount,
    );
    final openDevelopmentFollowUps = timelines.fold<int>(
      0,
      (total, timeline) => total + timeline.openDevelopmentFollowUpCount,
    );
    final watchDevelopmentFollowUps = timelines.fold<int>(
      0,
      (total, timeline) => total + timeline.watchDevelopmentFollowUpCount,
    );
    final watchDevelopmentResolutions = timelines.fold<int>(
      0,
      (total, timeline) => total + timeline.watchDevelopmentResolutionCount,
    );
    final openCareerSupportActions = timelines.fold<int>(
      0,
      (total, timeline) => total + timeline.openCareerSupportCount,
    );
    final watchCareerSupportOutcomes = timelines.fold<int>(
      0,
      (total, timeline) => total + timeline.watchCareerSupportOutcomeCount,
    );
    final programMilestoneRevisions = timelines.fold<int>(
      0,
      (total, timeline) => total + timeline.programMilestoneRevisionCount,
    );
    final programCompletionExtensions = timelines.fold<int>(
      0,
      (total, timeline) => total + timeline.programCompletionExtensionCount,
    );
    final watchPromotionStabilizations = timelines.fold<int>(
      0,
      (total, timeline) => total + timeline.watchPromotionStabilizationCount,
    );
    final openPromotionFollowUps = timelines.fold<int>(
      0,
      (total, timeline) => total + timeline.openPromotionFollowUpCount,
    );
    final watchPromotionFollowUps = timelines.fold<int>(
      0,
      (total, timeline) => total + timeline.watchPromotionFollowUpCount,
    );
    final watchPromotionResolutions = timelines.fold<int>(
      0,
      (total, timeline) => total + timeline.watchPromotionResolutionCount,
    );
    final highReadinessProfiles =
        timelines.where((timeline) => timeline.readinessScore >= 85).length;

    return IncomingTalentProfileTimelineSummary(
      totalProfiles: timelines.length,
      attentionProfiles: attentionProfiles,
      calibratedProfiles: calibratedProfiles,
      openInterventions: openInterventions,
      watchDevelopmentOutcomes: watchDevelopmentOutcomes,
      openDevelopmentFollowUps: openDevelopmentFollowUps,
      watchDevelopmentFollowUps: watchDevelopmentFollowUps,
      watchDevelopmentResolutions: watchDevelopmentResolutions,
      openCareerSupportActions: openCareerSupportActions,
      watchCareerSupportOutcomes: watchCareerSupportOutcomes,
      programMilestoneRevisions: programMilestoneRevisions,
      programCompletionExtensions: programCompletionExtensions,
      watchPromotionStabilizations: watchPromotionStabilizations,
      openPromotionFollowUps: openPromotionFollowUps,
      watchPromotionFollowUps: watchPromotionFollowUps,
      watchPromotionResolutions: watchPromotionResolutions,
      highReadinessProfiles: highReadinessProfiles,
      nextAction: _nextAction(
        totalProfiles: timelines.length,
        attentionProfiles: attentionProfiles,
        calibratedProfiles: calibratedProfiles,
        openTalentActions:
            openInterventions +
            openDevelopmentFollowUps +
            openCareerSupportActions +
            openPromotionFollowUps,
        watchDevelopmentOutcomes: watchDevelopmentOutcomes,
        watchDevelopmentFollowUps: watchDevelopmentFollowUps,
        watchDevelopmentResolutions: watchDevelopmentResolutions,
        watchCareerSupportOutcomes: watchCareerSupportOutcomes,
        programMilestoneRevisions: programMilestoneRevisions,
        programCompletionExtensions: programCompletionExtensions,
        watchPromotionStabilizations: watchPromotionStabilizations,
        watchPromotionFollowUps: watchPromotionFollowUps,
        watchPromotionResolutions: watchPromotionResolutions,
      ),
    );
  }

  int get openTalentActions {
    return openInterventions +
        openDevelopmentFollowUps +
        openCareerSupportActions +
        openPromotionFollowUps;
  }

  static String _nextAction({
    required int totalProfiles,
    required int attentionProfiles,
    required int calibratedProfiles,
    required int openTalentActions,
    required int watchDevelopmentOutcomes,
    required int watchDevelopmentFollowUps,
    required int watchDevelopmentResolutions,
    required int watchCareerSupportOutcomes,
    required int programMilestoneRevisions,
    required int programCompletionExtensions,
    required int watchPromotionStabilizations,
    required int watchPromotionFollowUps,
    required int watchPromotionResolutions,
  }) {
    if (totalProfiles == 0) {
      return 'Complete outcome reviews to build profile timelines.';
    }
    if (watchPromotionFollowUps > 0) {
      final noun = watchPromotionFollowUps == 1 ? 'action' : 'actions';
      return 'Resolve $watchPromotionFollowUps promotion follow-up $noun.';
    }
    if (watchPromotionResolutions > 0) {
      final noun = watchPromotionResolutions == 1 ? 'review' : 'reviews';
      return 'Resolve $watchPromotionResolutions promotion resolution $noun.';
    }
    if (openTalentActions > 0) {
      return 'Resolve $openTalentActions open talent actions.';
    }
    if (watchDevelopmentResolutions > 0) {
      final noun = watchDevelopmentResolutions == 1 ? 'review' : 'reviews';
      return 'Resolve $watchDevelopmentResolutions follow-up resolution $noun.';
    }
    if (watchDevelopmentFollowUps > 0) {
      final noun = watchDevelopmentFollowUps == 1 ? 'follow-up' : 'follow-ups';
      return 'Resolve $watchDevelopmentFollowUps intervention outcome $noun.';
    }
    if (watchDevelopmentOutcomes > 0) {
      final noun = watchDevelopmentOutcomes == 1 ? 'outcome' : 'outcomes';
      return 'Follow up $watchDevelopmentOutcomes development intervention $noun.';
    }
    if (programMilestoneRevisions > 0) {
      final noun = programMilestoneRevisions == 1 ? 'revision' : 'revisions';
      return 'Resolve $programMilestoneRevisions program milestone $noun.';
    }
    if (programCompletionExtensions > 0) {
      final noun = programCompletionExtensions == 1 ? 'decision' : 'decisions';
      return 'Resolve $programCompletionExtensions program extension $noun.';
    }
    if (watchPromotionStabilizations > 0) {
      final noun = watchPromotionStabilizations == 1 ? 'review' : 'reviews';
      return 'Resolve $watchPromotionStabilizations promotion stabilization $noun.';
    }
    if (watchCareerSupportOutcomes > 0) {
      return 'Follow up $watchCareerSupportOutcomes career support outcomes.';
    }
    if (attentionProfiles > 0) {
      return 'Review $attentionProfiles profiles needing support.';
    }
    final uncalibratedProfiles = totalProfiles - calibratedProfiles;
    if (uncalibratedProfiles > 0) {
      return 'Calibrate $uncalibratedProfiles active profiles.';
    }
    return 'Profile timelines are current.';
  }
}
