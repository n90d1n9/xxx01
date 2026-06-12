import '../models/omni_channel_activity.dart';
import '../models/omni_channel_activity_action.dart';
import '../models/omni_channel_activity_module_manifest.dart';
import '../models/omni_channel_activity_registry_diagnostics.dart';
import '../models/omni_channel_activity_triage.dart';
import 'omni_channel_activity_action_registry_diagnostics_builder.dart';
import 'omni_channel_activity_module_registry_diagnostics_builder.dart';
import 'omni_channel_activity_triage_registry_diagnostics_builder.dart';

/// Coordinates focused registry diagnostics builders into one read model.
class OmniChannelActivityRegistryDiagnosticsBuilder {
  final OmniChannelActivityActionRegistryDiagnosticsBuilder actionBuilder;
  final OmniChannelActivityTriageRegistryDiagnosticsBuilder triageBuilder;
  final OmniChannelActivityModuleRegistryDiagnosticsBuilder moduleBuilder;

  const OmniChannelActivityRegistryDiagnosticsBuilder({
    this.actionBuilder =
        const OmniChannelActivityActionRegistryDiagnosticsBuilder(),
    this.triageBuilder =
        const OmniChannelActivityTriageRegistryDiagnosticsBuilder(),
    this.moduleBuilder =
        const OmniChannelActivityModuleRegistryDiagnosticsBuilder(),
  });

  OmniChannelActivityRegistryDiagnostics build({
    required OmniChannelActivityFeed feed,
    required OmniChannelActivityActionRegistry actionRegistry,
    required Iterable<OmniChannelActivityTriageDimensionDefinition>
    triageDimensions,
    Iterable<OmniChannelActivityModuleManifest> moduleManifests = const [],
  }) {
    final resolvedTriageDimensions = triageDimensions.toList(growable: false);
    final actionDiagnostics = actionBuilder.build(
      feed: feed,
      actionRegistry: actionRegistry,
    );
    final triageDiagnostics = triageBuilder.build(
      feed: feed,
      triageDimensions: resolvedTriageDimensions,
    );
    final moduleDiagnostics = moduleBuilder.build(
      feed: feed,
      actionContributorDescriptors:
          actionRegistry.resolvedContributorDescriptors,
      triageDimensions: resolvedTriageDimensions,
      moduleManifests: moduleManifests,
    );

    return OmniChannelActivityRegistryDiagnostics(
      entryCount: feed.entries.length,
      moduleCount: moduleDiagnostics.modules.length,
      modules: moduleDiagnostics.modules,
      moduleRegistrationIssues: moduleDiagnostics.registrationIssues,
      actionContributorCount: actionRegistry.contributors.length,
      actionContributors: actionDiagnostics.contributors,
      contributorRegistrationIssues:
          actionDiagnostics.contributorRegistrationIssues,
      duplicateActions: actionDiagnostics.duplicateActions,
      duplicateDimensions: triageDiagnostics.duplicateDimensions,
      triageDimensions: triageDiagnostics.dimensions,
      actions: actionDiagnostics.actions,
    );
  }
}
