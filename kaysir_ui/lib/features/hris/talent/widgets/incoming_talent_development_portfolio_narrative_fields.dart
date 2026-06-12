import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/incoming_talent_development_portfolio_models.dart';
import '../states/incoming_talent_development_portfolio_provider.dart';
import 'incoming_talent_development_portfolio_form_fields.dart';

class IncomingTalentDevelopmentPortfolioNarrativeFields extends ConsumerWidget {
  final TextEditingController competencyController;
  final TextEditingController goalController;
  final TextEditingController learningController;
  final TextEditingController evidenceController;

  const IncomingTalentDevelopmentPortfolioNarrativeFields({
    super.key,
    required this.competencyController,
    required this.goalController,
    required this.learningController,
    required this.evidenceController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(
      incomingTalentDevelopmentPortfolioDraftProvider.notifier,
    );

    return Column(
      children: [
        IncomingTalentDevelopmentPortfolioTextInput(
          controller: competencyController,
          label: 'Competency focus',
          icon: Icons.center_focus_strong_outlined,
          onChanged: notifier.setCompetencyFocus,
          validator: validateIncomingTalentDevelopmentPortfolioFocus,
        ),
        const SizedBox(height: 12),
        IncomingTalentDevelopmentPortfolioTextInput(
          controller: goalController,
          label: 'Growth goal',
          icon: Icons.psychology_alt_outlined,
          minLines: 3,
          onChanged: notifier.setGrowthGoal,
          validator:
              (value) => validateIncomingTalentDevelopmentPortfolioLongText(
                value,
                'growth goal',
              ),
        ),
        const SizedBox(height: 12),
        IncomingTalentDevelopmentPortfolioTextInput(
          controller: learningController,
          label: 'Learning path',
          icon: Icons.menu_book_outlined,
          minLines: 3,
          onChanged: notifier.setLearningPath,
          validator:
              (value) => validateIncomingTalentDevelopmentPortfolioLongText(
                value,
                'learning path',
              ),
        ),
        const SizedBox(height: 12),
        IncomingTalentDevelopmentPortfolioTextInput(
          controller: evidenceController,
          label: 'Evidence plan',
          icon: Icons.fact_check_outlined,
          minLines: 3,
          onChanged: notifier.setEvidencePlan,
          validator:
              (value) => validateIncomingTalentDevelopmentPortfolioLongText(
                value,
                'evidence plan',
              ),
        ),
      ],
    );
  }
}
