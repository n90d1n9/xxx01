import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product_profile.dart';
import '../models/product_profile_search.dart';
import '../states/workspace_provider.dart';
import 'product_profile_details_dialog.dart';
import 'profile_picker_content.dart';
import 'profile_picker_dialog_shell.dart';

const _profilePickerSearchScopeId = 'profile_picker';

Future<void> showProfilePicker({
  required BuildContext context,
  required List<ProductProfile> profiles,
  required ProductProfile activeProfile,
  required ValueChanged<String> onProfileSelected,
}) {
  return showDialog<void>(
    context: context,
    builder:
        (context) => ProviderScope(
          overrides: [
            productProfileSearchProfilesProvider(
              _profilePickerSearchScopeId,
            ).overrideWithValue(profiles),
          ],
          child: ProfilePickerDialog(
            activeProfile: activeProfile,
            onProfileSelected: onProfileSelected,
          ),
        ),
  );
}

class ProfilePickerDialog extends ConsumerStatefulWidget {
  final ProductProfile activeProfile;
  final ValueChanged<String> onProfileSelected;

  const ProfilePickerDialog({
    super.key,
    required this.activeProfile,
    required this.onProfileSelected,
  });

  @override
  ConsumerState<ProfilePickerDialog> createState() =>
      _ProfilePickerDialogState();
}

class _ProfilePickerDialogState extends ConsumerState<ProfilePickerDialog> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    ref
        .read(
          productProfileSearchQueryProvider(
            _profilePickerSearchScopeId,
          ).notifier,
        )
        .state = '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profiles = ref.watch(
      productProfileSearchProfilesProvider(_profilePickerSearchScopeId),
    );
    final query = ref.watch(
      productProfileSearchQueryProvider(_profilePickerSearchScopeId),
    );
    final selectedMatchTypes = ref.watch(
      productProfileSearchMatchTypesProvider(_profilePickerSearchScopeId),
    );
    final results = ref.watch(
      productProfileSearchResultsProvider(_profilePickerSearchScopeId),
    );
    final suggestions = ref.watch(
      productProfileSearchSuggestionsProvider(_profilePickerSearchScopeId),
    );
    final dialogHeight = profilePickerDialogHeightFor(
      MediaQuery.sizeOf(context),
    );

    return ProfilePickerDialogShell(
      height: dialogHeight,
      child: ProfilePickerContent(
        searchController: _searchController,
        activeProfile: widget.activeProfile,
        profiles: profiles,
        query: query,
        selectedMatchTypes: selectedMatchTypes,
        results: results,
        suggestions: suggestions,
        onQueryChanged: _setQuery,
        onMatchTypesChanged: _setMatchTypes,
        onProfileSelected: (profileId) {
          widget.onProfileSelected(profileId);
          Navigator.of(context).pop();
        },
        onProfileDetailsRequested: _showProfileDetails,
      ),
    );
  }

  void _setQuery(String query) {
    ref
        .read(
          productProfileSearchQueryProvider(
            _profilePickerSearchScopeId,
          ).notifier,
        )
        .state = query;
  }

  void _setMatchTypes(Set<ProductProfileSearchMatchType> matchTypes) {
    ref
        .read(
          productProfileSearchMatchTypesProvider(
            _profilePickerSearchScopeId,
          ).notifier,
        )
        .state = matchTypes;
  }

  Future<void> _showProfileDetails(String profileId) async {
    final profile = productProfileFor(
      profiles: ref.read(
        productProfileSearchProfilesProvider(_profilePickerSearchScopeId),
      ),
      profileId: profileId,
    );
    var selectedFromDetails = false;

    await showProductProfileDetailsDialog(
      context: context,
      profile: profile,
      selected: profile.id == widget.activeProfile.id,
      onProfileSelected: (profileId) {
        selectedFromDetails = true;
        widget.onProfileSelected(profileId);
      },
    );

    if (selectedFromDetails && mounted) {
      Navigator.of(context).pop();
    }
  }
}
