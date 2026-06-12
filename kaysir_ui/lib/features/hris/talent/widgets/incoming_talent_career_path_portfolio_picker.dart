import 'package:flutter/material.dart';

import '../models/incoming_talent_career_path_models.dart';
import '../models/incoming_talent_development_portfolio_models.dart';

class IncomingTalentCareerPathPortfolioPicker extends StatelessWidget {
  final IncomingTalentCareerPathDraft draft;
  final List<IncomingTalentDevelopmentPortfolio> portfolios;
  final ValueChanged<String?> onChanged;

  const IncomingTalentCareerPathPortfolioPicker({
    super.key,
    required this.draft,
    required this.portfolios,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey('career-path-${draft.portfolioId}'),
      initialValue: _portfolioExists ? draft.portfolioId : null,
      decoration: const InputDecoration(
        labelText: 'IDP portfolio',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.assignment_turned_in_outlined),
      ),
      items:
          portfolios
              .map(
                (portfolio) => DropdownMenuItem(
                  value: portfolio.id,
                  child: Text(
                    '${portfolio.candidateName} - ${portfolio.priority.label}',
                  ),
                ),
              )
              .toList(),
      onChanged: portfolios.isEmpty ? null : onChanged,
      validator:
          (value) => validateIncomingTalentCareerPathRequired(
            value,
            'an IDP portfolio',
          ),
    );
  }

  bool get _portfolioExists {
    return portfolios.any((portfolio) => portfolio.id == draft.portfolioId);
  }
}
