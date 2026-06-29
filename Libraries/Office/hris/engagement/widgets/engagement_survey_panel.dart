import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/engagement_models.dart';
import 'engagement_meta_label.dart';
import 'engagement_status_styles.dart';

class EngagementSurveyPanel extends StatelessWidget {
  final List<EngagementSurvey> surveys;

  const EngagementSurveyPanel({super.key, required this.surveys});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      title: 'Pulse Surveys',
      icon: Icons.fact_check_outlined,
      subtitle: '${surveys.length} surveys',
      emptyMessage: 'No surveys match filters',
      children: surveys.map((survey) => _SurveyTile(survey: survey)).toList(),
    );
  }
}

class _SurveyTile extends StatelessWidget {
  final EngagementSurvey survey;

  const _SurveyTile({required this.survey});

  @override
  Widget build(BuildContext context) {
    final color = surveyStatusColor(survey.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  survey.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              HrisStatusPill(
                label: surveyStatusLabel(survey.status),
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 10),
          HrisProgressBar(
            value: survey.responseRate / 100,
            color: color,
            label: '${survey.responseRate}% response',
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              EngagementMetaLabel(
                icon: Icons.favorite_border,
                label: 'eNPS ${survey.eNps}',
              ),
              EngagementMetaLabel(
                icon: Icons.calendar_today_outlined,
                label: DateFormat('MMM d').format(survey.closesAt),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
