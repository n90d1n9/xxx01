import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';

import '../states/billing_diagnostics_release_profile_filter_provider.dart';
import '../utils/billing_diagnostics_route_location.dart';
import 'release_profile_domain_filter.dart';
import 'release_profile_status_filter.dart';

/// App-bar action that copies a shareable billing diagnostics link.
class BillingDiagnosticsLinkAction extends StatelessWidget {
  final String? tenantId;
  final String? businessDomain;
  final BillingDiagnosticsReleaseProfileFilterState releaseProfileFilterState;
  final Uri? baseUri;
  final String copiedMessage;

  const BillingDiagnosticsLinkAction({
    super.key,
    this.tenantId,
    this.businessDomain,
    this.releaseProfileFilterState =
        const BillingDiagnosticsReleaseProfileFilterState(),
    this.baseUri,
    this.copiedMessage = 'Diagnostics link copied',
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const ValueKey('billing-diagnostics-copy-link-action'),
      tooltip: 'Copy diagnostics link',
      visualDensity: VisualDensity.compact,
      color: const Color(0xFF475569),
      onPressed: () => _copyLink(context),
      icon: const Icon(Icons.link_rounded),
    );
  }

  Future<void> _copyLink(BuildContext context) async {
    final link = billingDiagnosticsBrowserLink(
      tenantId: tenantId,
      businessDomain: businessDomain,
      releaseProfileFilterState: releaseProfileFilterState,
      baseUri: baseUri,
    );

    await Clipboard.setData(ClipboardData(text: link));
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(copiedMessage),
        ),
      );
  }
}

@Preview(name: 'Diagnostics link action')
Widget diagnosticsLinkActionPreview() {
  return MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: const Text('Billing Diagnostics'),
        actions: [
          BillingDiagnosticsLinkAction(
            tenantId: 'tenant-a',
            businessDomain: 'commerce',
            releaseProfileFilterState:
                BillingDiagnosticsReleaseProfileFilterState(
                  statusOption:
                      BillingReleaseProfileStatusFilterOption.standard,
                  domainSelection:
                      BillingReleaseProfileDomainFilterSelection.domain(
                        'retail',
                      ),
                ),
            baseUri: Uri.parse('https://app.kaysir.local/'),
          ),
        ],
      ),
    ),
  );
}
