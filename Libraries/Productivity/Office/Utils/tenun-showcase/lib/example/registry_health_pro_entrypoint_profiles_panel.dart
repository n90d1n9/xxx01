import 'package:flutter/material.dart';
import 'package:tenun_pro/tenun_pro.dart'
    show
        TenunProEntrypointProfile,
        auditTenunProDistributionReadiness,
        tenunProEntrypointProfiles;

/// Displays commercial Tenun Pro entrypoint metadata in Registry Health.
class RegistryHealthProEntrypointProfilesPanel extends StatelessWidget {
  const RegistryHealthProEntrypointProfilesPanel({
    super.key,
    required this.profiles,
    this.visibleLimit = 6,
  });

  final List<TenunProEntrypointProfile> profiles;
  final int visibleLimit;

  @override
  Widget build(BuildContext context) {
    final visibleLabels = registryHealthProEntrypointProfileLabels(
      profiles,
      visibleLimit: visibleLimit,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          registryHealthProEntrypointProfileSummary(profiles),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (visibleLabels.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final label in visibleLabels)
                Chip(label: Text(label), visualDensity: VisualDensity.compact),
            ],
          ),
        ],
      ],
    );
  }
}

String registryHealthProEntrypointProfileSummary(
  Iterable<TenunProEntrypointProfile> profiles,
) {
  final profileList = profiles.toList(growable: false);
  final uniqueTypes = _uniqueChartTypeNames(profileList);
  final entrypointLabel = profileList.length == 1
      ? 'entrypoint'
      : 'entrypoints';
  final chartTypeLabel = uniqueTypes.length == 1 ? 'chart type' : 'chart types';

  return '${profileList.length} commercial $entrypointLabel, '
      '${uniqueTypes.length} $chartTypeLabel.';
}

List<String> registryHealthProEntrypointProfileLabels(
  Iterable<TenunProEntrypointProfile> profiles, {
  int visibleLimit = 6,
}) {
  if (visibleLimit <= 0) {
    return const <String>[];
  }

  return List.unmodifiable([
    for (final profile in profiles.take(visibleLimit))
      '${profile.label}: ${profile.chartCount} types - ${profile.registrationFunctionName}',
  ]);
}

Map<String, dynamic> registryHealthProEntrypointProfilesJson(
  Iterable<TenunProEntrypointProfile> profiles, {
  int visibleLimit = 6,
}) {
  final profileList = profiles.toList(growable: false);
  final uniqueTypes = _uniqueChartTypeNames(profileList);
  final distributionReadiness = auditTenunProDistributionReadiness(
    profiles: profileList,
  );

  return {
    'summary': registryHealthProEntrypointProfileSummary(profileList),
    'entrypointCount': profileList.length,
    'uniqueChartTypeCount': uniqueTypes.length,
    'labels': registryHealthProEntrypointProfileLabels(
      profileList,
      visibleLimit: visibleLimit,
    ),
    'registrationFunctions': [
      for (final profile in profileList) profile.registrationFunctionName,
    ],
    'importStatements': [
      for (final profile in profileList) profile.importStatement,
    ],
    'distributionChannels': _distributionChannelsJson(profileList),
    'distributionReadiness': distributionReadiness.toJson(),
    'packageInstalls': [
      for (final profile in profileList) profile.packageInstall.toJson(),
    ],
    'onboardingGuides': [
      for (final profile in profileList) profile.onboardingGuide.toJson(),
    ],
    'quickStarts': [
      for (final profile in profileList) profile.quickStart.toJson(),
    ],
    'profiles': [for (final profile in profileList) profile.toJson()],
  };
}

List<TenunProEntrypointProfile> registryHealthProEntrypointProfiles() {
  return tenunProEntrypointProfiles;
}

List<Map<String, dynamic>> _distributionChannelsJson(
  Iterable<TenunProEntrypointProfile> profiles,
) {
  final seen = <String>{};
  final out = <Map<String, dynamic>>[];

  for (final profile in profiles) {
    for (final option in profile.packageInstall.distributionOptions) {
      if (seen.add(option.id)) {
        out.add({
          'id': option.id,
          'label': option.label,
          'description': option.description,
          'isRecommended': option.isRecommended,
          'requiresAuthentication': option.requiresAuthentication,
          'authenticationHint': option.authenticationHint,
        });
      }
    }
  }

  return List.unmodifiable(out);
}

List<String> _uniqueChartTypeNames(
  Iterable<TenunProEntrypointProfile> profiles,
) {
  final out = <String>[];
  final seen = <String>{};

  for (final profile in profiles) {
    for (final typeName in profile.chartTypeNames) {
      if (seen.add(typeName)) {
        out.add(typeName);
      }
    }
  }

  out.sort();
  return List.unmodifiable(out);
}
