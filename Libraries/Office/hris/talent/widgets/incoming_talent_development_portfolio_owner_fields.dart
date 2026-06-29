import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/incoming_talent_development_portfolio_models.dart';
import '../states/incoming_talent_development_portfolio_provider.dart';
import 'incoming_talent_development_portfolio_form_fields.dart';

class IncomingTalentDevelopmentPortfolioOwnerFields extends ConsumerWidget {
  final TextEditingController ownerController;
  final TextEditingController mentorController;

  const IncomingTalentDevelopmentPortfolioOwnerFields({
    super.key,
    required this.ownerController,
    required this.mentorController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(
      incomingTalentDevelopmentPortfolioDraftProvider.notifier,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final ownerField = IncomingTalentDevelopmentPortfolioTextInput(
          controller: ownerController,
          label: 'Portfolio owner',
          icon: Icons.badge_outlined,
          onChanged: notifier.setPortfolioOwnerName,
          validator:
              (value) => validateIncomingTalentDevelopmentPortfolioRequired(
                value,
                'a portfolio owner',
              ),
        );
        final mentorField = IncomingTalentDevelopmentPortfolioTextInput(
          controller: mentorController,
          label: 'Mentor',
          icon: Icons.supervisor_account_outlined,
          onChanged: notifier.setMentorName,
          validator:
              (value) => validateIncomingTalentDevelopmentPortfolioRequired(
                value,
                'a mentor',
              ),
        );

        if (constraints.maxWidth < 620) {
          return Column(
            children: [ownerField, const SizedBox(height: 12), mentorField],
          );
        }

        return Row(
          children: [
            Expanded(child: ownerField),
            const SizedBox(width: 12),
            Expanded(child: mentorField),
          ],
        );
      },
    );
  }
}
