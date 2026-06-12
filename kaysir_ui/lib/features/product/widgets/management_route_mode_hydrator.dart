import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/experience_profile.dart';
import '../models/management_pack.dart';
import '../models/sales_channel_profile.dart';
import '../states/management_workspace_preferences_controller.dart';
import 'experience_profile_scope.dart';

/// Hydrates product pack, channel profile, and experience context from a route.
class ProductManagementRouteModeHydrator extends ConsumerStatefulWidget {
  const ProductManagementRouteModeHydrator({
    super.key,
    required this.child,
    this.initialPackId,
    this.initialChannelProfileId,
    this.experienceProfile,
  });

  final Widget child;
  final ProductManagementPackId? initialPackId;
  final ProductSalesChannelProfileId? initialChannelProfileId;
  final ProductExperienceProfile? experienceProfile;

  @override
  ConsumerState<ProductManagementRouteModeHydrator> createState() =>
      _ProductManagementRouteModeHydratorState();
}

class _ProductManagementRouteModeHydratorState
    extends ConsumerState<ProductManagementRouteModeHydrator> {
  @override
  void initState() {
    super.initState();
    unawaited(_syncInitialProductMode());
  }

  @override
  void didUpdateWidget(ProductManagementRouteModeHydrator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPackId != widget.initialPackId ||
        oldWidget.initialChannelProfileId != widget.initialChannelProfileId) {
      unawaited(_syncInitialProductMode());
    }
  }

  @override
  Widget build(BuildContext context) {
    final experienceProfile = widget.experienceProfile;
    if (experienceProfile == null) return widget.child;

    return ProductExperienceProfileScope(
      profile: experienceProfile,
      child: widget.child,
    );
  }

  Future<void> _syncInitialProductMode() async {
    final initialPackId = widget.initialPackId;
    final initialProfileId = widget.initialChannelProfileId;
    final hasInitialProductMode =
        initialPackId != null || initialProfileId != null;
    final controller = ref.read(
      productManagementWorkspacePreferencesControllerProvider,
    );

    if (!hasInitialProductMode) {
      await controller.hydrate();
      return;
    }

    await controller.hydrate(applyChannelProfile: false);
    if (!mounted) return;

    await controller.applyRouteSelection(
      packId: initialPackId,
      channelProfileId: initialProfileId,
    );
  }
}
