import 'package:flutter/material.dart';

import 'login_brand_panel.dart';

class LoginShell extends StatelessWidget {
  const LoginShell({
    super.key,
    required this.appName,
    required this.logoAsset,
    required this.formPanel,
  });

  final String appName;
  final String logoAsset;
  final Widget formPanel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 920;

        return DecoratedBox(
          decoration: _backgroundDecoration(context),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child:
                    isWide
                        ? _DesktopLoginLayout(
                          appName: appName,
                          logoAsset: logoAsset,
                          formPanel: formPanel,
                        )
                        : _CompactLoginLayout(
                          appName: appName,
                          logoAsset: logoAsset,
                          formPanel: formPanel,
                        ),
              ),
            ),
          ),
        );
      },
    );
  }

  BoxDecoration _backgroundDecoration(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BoxDecoration(
      color: colorScheme.surface,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          colorScheme.surface,
          colorScheme.surfaceContainerHighest.withValues(alpha: 0.82),
          colorScheme.tertiaryContainer.withValues(alpha: 0.34),
        ],
        stops: const [0, 0.58, 1],
      ),
    );
  }
}

class _DesktopLoginLayout extends StatelessWidget {
  const _DesktopLoginLayout({
    required this.appName,
    required this.logoAsset,
    required this.formPanel,
  });

  final String appName;
  final String logoAsset;
  final Widget formPanel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            flex: 11,
            child: LoginBrandPanel(appName: appName, logoAsset: logoAsset),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 9,
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: formPanel,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactLoginLayout extends StatelessWidget {
  const _CompactLoginLayout({
    required this.appName,
    required this.logoAsset,
    required this.formPanel,
  });

  final String appName;
  final String logoAsset;
  final Widget formPanel;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LoginBrandPanel(
            appName: appName,
            logoAsset: logoAsset,
            compact: true,
          ),
          const SizedBox(height: 16),
          formPanel,
        ],
      ),
    );
  }
}
