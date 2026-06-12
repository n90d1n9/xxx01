import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/service_center_models.dart';
import 'service_center_meta_label.dart';
import 'service_center_status_styles.dart';

class KnowledgeBasePanel extends StatelessWidget {
  final List<PolicyArticle> policies;

  const KnowledgeBasePanel({super.key, required this.policies});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      title: 'Knowledge Base',
      icon: Icons.policy_outlined,
      subtitle: '${policies.length} answers',
      emptyMessage: 'No policy articles match filters',
      children: policies.map((policy) => _PolicyTile(policy: policy)).toList(),
    );
  }
}

class _PolicyTile extends StatelessWidget {
  final PolicyArticle policy;

  const _PolicyTile({required this.policy});

  @override
  Widget build(BuildContext context) {
    final color = policyTypeColor(policy.type);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  policy.title,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(label: policyTypeLabel(policy.type), color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            policy.summary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              ServiceCenterMetaLabel(
                icon: Icons.visibility_outlined,
                label: '${policy.views} views',
              ),
              ServiceCenterMetaLabel(
                icon: Icons.thumb_up_alt_outlined,
                label:
                    '${(policy.helpfulRate * 100).toStringAsFixed(0)}% helpful',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
