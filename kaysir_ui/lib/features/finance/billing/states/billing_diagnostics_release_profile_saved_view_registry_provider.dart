import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'billing_business_domain_pack_provider.dart';
import 'billing_diagnostics_screen_context_provider.dart';
import '../widgets/diagnostics_release_profile_saved_view_registry.dart';

/// Provides domain-pack release profile diagnostics saved-view contributions.
final billingDiagnosticsReleaseProfileSavedViewProfileCatalogProvider =
    Provider<BillingDiagnosticsReleaseProfileSavedViewProfileCatalog>((ref) {
      return ref
          .watch(billingBusinessDomainPackRegistryProvider)
          .releaseProfileSavedViewProfileCatalog;
    });

/// Provides the saved-view registry used by release profile diagnostics.
final billingDiagnosticsReleaseProfileSavedViewRegistryProvider =
    Provider<BillingDiagnosticsReleaseProfileSavedViewRegistry>((ref) {
      final screenContext = ref.watch(billingDiagnosticsScreenContextProvider);
      final catalog = ref.watch(
        billingDiagnosticsReleaseProfileSavedViewProfileCatalogProvider,
      );

      return catalog.registryForBusinessDomain(
        screenContext.overview.businessDomain,
      );
    });
