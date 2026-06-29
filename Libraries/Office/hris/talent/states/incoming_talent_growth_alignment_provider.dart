import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/incoming_talent_career_path_models.dart';
import '../models/incoming_talent_development_portfolio_models.dart';
import '../models/incoming_talent_development_program_models.dart';
import '../models/incoming_talent_growth_alignment_models.dart';
import 'incoming_talent_career_path_provider.dart';
import 'incoming_talent_development_portfolio_provider.dart';
import 'incoming_talent_development_program_enrollment_provider.dart';
import 'incoming_talent_development_program_provider.dart';
import 'talent_provider.dart';

final incomingTalentGrowthAlignmentSourcePortfoliosProvider =
    Provider<List<IncomingTalentDevelopmentPortfolio>>((ref) {
      return ref.watch(incomingTalentDevelopmentPortfoliosProvider);
    });

final incomingTalentGrowthAlignmentSourceProgramsProvider =
    Provider<List<IncomingTalentDevelopmentProgram>>((ref) {
      return ref.watch(incomingTalentDevelopmentProgramsProvider);
    });

final incomingTalentGrowthAlignmentSourceEnrollmentsProvider =
    Provider<List<IncomingTalentDevelopmentProgramEnrollment>>((ref) {
      return ref.watch(incomingTalentDevelopmentProgramEnrollmentsProvider);
    });

final incomingTalentGrowthAlignmentSourceCareerPathsProvider =
    Provider<List<IncomingTalentCareerPath>>((ref) {
      return ref.watch(incomingTalentCareerPathsProvider);
    });

final incomingTalentGrowthAlignmentItemsProvider = Provider<
  List<IncomingTalentGrowthAlignmentItem>
>((ref) {
  final selectedDepartment = ref.watch(talentDepartmentProvider);
  final attentionOnly = ref.watch(talentNeedsAttentionProvider);
  final items = buildIncomingTalentGrowthAlignments(
    portfolios:
        ref
            .watch(incomingTalentGrowthAlignmentSourcePortfoliosProvider)
            .where(
              (portfolio) =>
                  _matchesDepartment(selectedDepartment, portfolio.department),
            )
            .toList(),
    programs:
        ref
            .watch(incomingTalentGrowthAlignmentSourceProgramsProvider)
            .where(
              (program) =>
                  _matchesDepartment(selectedDepartment, program.department),
            )
            .toList(),
    enrollments:
        ref
            .watch(incomingTalentGrowthAlignmentSourceEnrollmentsProvider)
            .where(
              (enrollment) =>
                  _matchesDepartment(selectedDepartment, enrollment.department),
            )
            .toList(),
    careerPaths:
        ref
            .watch(incomingTalentGrowthAlignmentSourceCareerPathsProvider)
            .where(
              (careerPath) =>
                  _matchesDepartment(selectedDepartment, careerPath.department),
            )
            .toList(),
  );

  if (!attentionOnly) return items;
  return items.where((item) => item.needsAttention).toList();
});

final incomingTalentGrowthAlignmentSummaryProvider =
    Provider<IncomingTalentGrowthAlignmentSummary>((ref) {
      return IncomingTalentGrowthAlignmentSummary.fromItems(
        ref.watch(incomingTalentGrowthAlignmentItemsProvider),
      );
    });

bool _matchesDepartment(String selectedDepartment, String department) {
  return selectedDepartment == talentAllDepartments ||
      selectedDepartment == department;
}
