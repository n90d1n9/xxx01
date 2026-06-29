import 'incoming_talent_activation_follow_up_models.dart';
import 'incoming_talent_development_check_in_models.dart';
import 'incoming_talent_development_intervention.dart';

class IncomingTalentDevelopmentInterventionSourceOption {
  final IncomingTalentDevelopmentInterventionSource source;
  final String id;
  final String label;
  final String detail;

  const IncomingTalentDevelopmentInterventionSourceOption({
    required this.source,
    required this.id,
    required this.label,
    required this.detail,
  });

  factory IncomingTalentDevelopmentInterventionSourceOption.fromCheckIn(
    IncomingTalentDevelopmentCheckIn checkIn,
  ) {
    return IncomingTalentDevelopmentInterventionSourceOption(
      source: IncomingTalentDevelopmentInterventionSource.checkIn,
      id: checkIn.id,
      label: '${checkIn.candidateName} - ${checkIn.trend.label}',
      detail: '${checkIn.department} - ${checkIn.confidenceScore}/5 confidence',
    );
  }

  factory IncomingTalentDevelopmentInterventionSourceOption.fromFollowUp(
    IncomingTalentActivationFollowUpAction action,
  ) {
    return IncomingTalentDevelopmentInterventionSourceOption(
      source: IncomingTalentDevelopmentInterventionSource.activationFollowUp,
      id: action.id,
      label: '${action.candidateName} - ${action.actionType.label}',
      detail:
          '${action.department} - ${action.programCompletionExtensionCount} extensions',
    );
  }

  String get key => '${source.name}:$id';
}
