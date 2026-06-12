import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/billing_business_domain_pack.dart';
import '../utils/billing_business_domain_pack_readiness.dart';
import '../utils/billing_business_domain_packs.dart';
import '../utils/domain_pack_contract.dart';
import '../widgets/billing_release_workspace_profile.dart';

final billingBusinessDomainPackRegistryProvider =
    Provider<BillingBusinessDomainPackRegistry>((ref) {
      return standardBillingDomainPackRegistry();
    });

final billingBusinessDomainPackRegistryReadinessProvider =
    Provider.family<BillingBusinessDomainPackRegistryReadinessReport, bool>((
      ref,
      hasTenant,
    ) {
      return BillingBusinessDomainPackRegistryReadinessReport.forRegistry(
        ref.watch(billingBusinessDomainPackRegistryProvider),
        hasTenant: hasTenant,
      );
    });

final billingBusinessDomainPackContractRegistryProvider =
    Provider.family<DomainPackContractRegistryReport, bool>((ref, hasTenant) {
      return DomainPackContractRegistryReport.fromReadiness(
        ref.watch(
          billingBusinessDomainPackRegistryReadinessProvider(hasTenant),
        ),
      );
    });

final billingReleaseWorkspaceProfileCatalogProvider =
    Provider<BillingReleaseWorkspaceProfileCatalog>((ref) {
      return ref
          .watch(billingBusinessDomainPackRegistryProvider)
          .releaseWorkspaceProfileCatalog;
    });
