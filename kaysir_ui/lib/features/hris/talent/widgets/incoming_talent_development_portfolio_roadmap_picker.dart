import 'package:flutter/material.dart';

import '../models/incoming_talent_development_portfolio_models.dart';
import '../models/incoming_talent_development_roadmap_models.dart';

class IncomingTalentDevelopmentPortfolioRoadmapPicker extends StatelessWidget {
  final IncomingTalentDevelopmentPortfolioDraft draft;
  final List<IncomingTalentDevelopmentRoadmap> roadmaps;
  final ValueChanged<String?> onChanged;

  const IncomingTalentDevelopmentPortfolioRoadmapPicker({
    super.key,
    required this.draft,
    required this.roadmaps,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey('portfolio-${draft.roadmapId}'),
      initialValue: _roadmapExists ? draft.roadmapId : null,
      decoration: const InputDecoration(
        labelText: 'Development roadmap',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.route_outlined),
      ),
      items:
          roadmaps
              .map(
                (roadmap) => DropdownMenuItem(
                  value: roadmap.id,
                  child: Text(
                    '${roadmap.candidateName} - ${roadmap.status.label}',
                  ),
                ),
              )
              .toList(),
      onChanged: roadmaps.isEmpty ? null : onChanged,
      validator:
          (value) => validateIncomingTalentDevelopmentPortfolioRequired(
            value,
            'a development roadmap',
          ),
    );
  }

  bool get _roadmapExists {
    return roadmaps.any((roadmap) => roadmap.id == draft.roadmapId);
  }
}
