import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/billing_product_release_channel.dart';
import '../widgets/billing_product_release_channel_launch_dispatch_plan.dart';
import '../widgets/billing_product_release_channel_launch_queue.dart';
import '../widgets/billing_product_release_channel_launch_runbook.dart';
import 'billing_business_domain_blueprint_provider.dart';
import 'billing_business_domain_profile_provider.dart';

final billingBusinessDomainModuleProductReleaseChannelLaunchPlanProvider =
    Provider.family<BillingProductReleaseChannelLaunchPlan, bool>((
      ref,
      hasTenant,
    ) {
      return BillingProductReleaseChannelLaunchPlan.forMatrix(
        ref.watch(
          billingBusinessDomainModuleProductReleaseChannelMatrixProvider(
            hasTenant,
          ),
        ),
      );
    });

final billingDefaultDomainModuleProductReleaseChannelLaunchPlanProvider =
    Provider.family<BillingProductReleaseChannelLaunchPlan, bool>((
      ref,
      hasTenant,
    ) {
      return BillingProductReleaseChannelLaunchPlan.forMatrix(
        ref.watch(
          billingDefaultDomainModuleProductReleaseChannelMatrixProvider(
            hasTenant,
          ),
        ),
      );
    });

final billingTenantDomainModuleProductReleaseChannelLaunchPlanProvider =
    Provider.family<
      BillingProductReleaseChannelLaunchPlan,
      BillingBusinessDomainBlueprintRequest
    >((ref, request) {
      return BillingProductReleaseChannelLaunchPlan.forMatrix(
        ref.watch(
          billingTenantDomainModuleProductReleaseChannelMatrixProvider(request),
        ),
      );
    });

final billingDefaultDomainModuleProductReleaseChannelLaunchDispatchPlanProvider =
    Provider.family<
      BillingProductReleaseChannelLaunchDispatchPlan,
      BillingDefaultNavigationDispatchSnapshotRequest
    >((ref, request) {
      return BillingProductReleaseChannelLaunchDispatchPlan.fromLaunchPlan(
        launchPlan: ref.watch(
          billingDefaultDomainModuleProductReleaseChannelLaunchPlanProvider(
            request.hasTenant,
          ),
        ),
        dispatchSnapshot: ref.watch(
          billingDefaultDomainModuleDestinationDispatchSnapshotProvider(
            request,
          ),
        ),
      );
    });

final billingTenantDomainModuleProductReleaseChannelLaunchDispatchPlanProvider =
    Provider.family<
      BillingProductReleaseChannelLaunchDispatchPlan,
      BillingNavigationDispatchSnapshotRequest
    >((ref, request) {
      return BillingProductReleaseChannelLaunchDispatchPlan.fromLaunchPlan(
        launchPlan: ref.watch(
          billingTenantDomainModuleProductReleaseChannelLaunchPlanProvider(
            BillingBusinessDomainBlueprintRequest(
              preferences: request.preferences,
              hasTenant: request.hasTenant,
            ),
          ),
        ),
        dispatchSnapshot: ref.watch(
          billingTenantDomainModuleDestinationDispatchSnapshotProvider(request),
        ),
      );
    });

final billingDefaultDomainModuleProductReleaseChannelLaunchRunbookProvider =
    Provider.family<
      BillingProductReleaseChannelLaunchRunbook,
      BillingDefaultNavigationDispatchSnapshotRequest
    >((ref, request) {
      return BillingProductReleaseChannelLaunchRunbook.fromDispatchPlan(
        ref.watch(
          billingDefaultDomainModuleProductReleaseChannelLaunchDispatchPlanProvider(
            request,
          ),
        ),
      );
    });

final billingTenantDomainModuleProductReleaseChannelLaunchRunbookProvider =
    Provider.family<
      BillingProductReleaseChannelLaunchRunbook,
      BillingNavigationDispatchSnapshotRequest
    >((ref, request) {
      return BillingProductReleaseChannelLaunchRunbook.fromDispatchPlan(
        ref.watch(
          billingTenantDomainModuleProductReleaseChannelLaunchDispatchPlanProvider(
            request,
          ),
        ),
      );
    });

final billingDefaultDomainModuleProductReleaseChannelLaunchQueueProvider =
    Provider.family<
      BillingProductReleaseChannelLaunchQueue,
      BillingDefaultNavigationDispatchSnapshotRequest
    >((ref, request) {
      return BillingProductReleaseChannelLaunchQueue.fromRunbook(
        ref.watch(
          billingDefaultDomainModuleProductReleaseChannelLaunchRunbookProvider(
            request,
          ),
        ),
      );
    });

final billingTenantDomainModuleProductReleaseChannelLaunchQueueProvider =
    Provider.family<
      BillingProductReleaseChannelLaunchQueue,
      BillingNavigationDispatchSnapshotRequest
    >((ref, request) {
      return BillingProductReleaseChannelLaunchQueue.fromRunbook(
        ref.watch(
          billingTenantDomainModuleProductReleaseChannelLaunchRunbookProvider(
            request,
          ),
        ),
      );
    });
