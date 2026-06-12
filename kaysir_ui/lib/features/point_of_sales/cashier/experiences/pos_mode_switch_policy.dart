import 'pos_experience.dart';
import 'pos_experience_launch_checklist.dart';
import 'pos_experience_screen_fit.dart';
import 'pos_product_profile.dart';

enum POSModeSwitchDisposition { allowed, confirm, blocked }

class POSModeSwitchDecision {
  final POSExperience experience;
  final POSProductProfile? productProfile;
  final POSExperienceScreenFitDiagnostic screenFit;
  final POSExperienceLaunchChecklist? launchChecklist;
  final POSModeSwitchDisposition disposition;
  final List<String> reasons;

  const POSModeSwitchDecision({
    required this.experience,
    required this.productProfile,
    required this.screenFit,
    required this.launchChecklist,
    required this.disposition,
    required this.reasons,
  });

  bool get canSwitch => disposition != POSModeSwitchDisposition.blocked;

  bool get needsConfirmation => disposition == POSModeSwitchDisposition.confirm;

  bool get isBlocked => disposition == POSModeSwitchDisposition.blocked;

  String get title {
    switch (disposition) {
      case POSModeSwitchDisposition.allowed:
        return 'Switch POS mode';
      case POSModeSwitchDisposition.confirm:
        return 'Review mode switch';
      case POSModeSwitchDisposition.blocked:
        return 'Mode unavailable';
    }
  }

  String get message {
    if (reasons.isEmpty) {
      return '${experience.label} is ready to use.';
    }

    return reasons.join('\n');
  }

  String get statusLabel {
    switch (disposition) {
      case POSModeSwitchDisposition.allowed:
        final warningCount = launchChecklist?.warningCount ?? 0;
        return warningCount == 0 ? 'Launch ready' : 'Review';
      case POSModeSwitchDisposition.confirm:
        return 'Confirm';
      case POSModeSwitchDisposition.blocked:
        return 'Blocked';
    }
  }
}

abstract final class POSModeSwitchPolicy {
  static POSModeSwitchDecision evaluate({
    required POSExperience experience,
    required double viewportWidth,
    POSProductProfile? productProfile,
  }) {
    final screenFit = POSExperienceScreenFitDiagnostic.from(
      viewportWidth: viewportWidth,
      manifest: experience.manifest,
    );
    final launchChecklist = productProfile?.launchChecklist;
    final launchFailures = launchChecklist?.failures.toList() ?? const [];

    if (launchFailures.isNotEmpty) {
      return POSModeSwitchDecision(
        experience: experience,
        productProfile: productProfile,
        screenFit: screenFit,
        launchChecklist: launchChecklist,
        disposition: POSModeSwitchDisposition.blocked,
        reasons: launchFailures
            .map((failure) => '${failure.label}: ${failure.detail}')
            .toList(growable: false),
      );
    }

    if (!screenFit.supported) {
      return POSModeSwitchDecision(
        experience: experience,
        productProfile: productProfile,
        screenFit: screenFit,
        launchChecklist: launchChecklist,
        disposition: POSModeSwitchDisposition.confirm,
        reasons: [
          '${experience.label} is not declared for ${screenFit.formFactorLabel} screens. Supported screens: ${screenFit.supportedFormFactorLabel}.',
        ],
      );
    }

    return POSModeSwitchDecision(
      experience: experience,
      productProfile: productProfile,
      screenFit: screenFit,
      launchChecklist: launchChecklist,
      disposition: POSModeSwitchDisposition.allowed,
      reasons: const [],
    );
  }
}
