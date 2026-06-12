import 'incoming_talent_career_framework_level.dart';
import 'incoming_talent_career_path.dart';

/// Matched career path and framework level ready for promotion assessment.
class IncomingTalentPromotionReadinessSource {
  final IncomingTalentCareerPath careerPath;
  final IncomingTalentCareerFrameworkLevel frameworkLevel;

  const IncomingTalentPromotionReadinessSource({
    required this.careerPath,
    required this.frameworkLevel,
  });

  String get id => '${careerPath.id}|${frameworkLevel.id}';

  String get label {
    return '${careerPath.candidateName} -> ${frameworkLevel.levelCode} ${frameworkLevel.roleTitle}';
  }
}
