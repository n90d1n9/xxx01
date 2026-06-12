import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'routes.dart';
import 'models/action.dart' as m;
import 'models/section_order.dart';
import 'states/workspace_provider.dart';
import 'widgets/content.dart';
import 'widgets/profile_menu.dart';

class Screen extends ConsumerStatefulWidget {
  static const routePath = Routes.routePath;
  static const profileRegistryPath = Routes.profileRegistryPath;
  static const checkoutPath = Routes.checkoutPath;
  static const ordersPath = Routes.ordersPath;

  const Screen({super.key});

  @override
  ConsumerState<Screen> createState() => _ScreenState();
}

class _ScreenState extends ConsumerState<Screen> {
  final Map<SectionSlot, GlobalKey> _sectionFocusKeys = {
    SectionSlot.channelStrategy: GlobalKey(),
  };

  @override
  Widget build(BuildContext context) {
    final workspace = ref.watch(viewStateProvider);
    final presentationProfile = ref.watch(presentationProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Commerce Workspace',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [ProfileMenu()],
      ),
      body: SafeArea(
        child: Content(
          workspace: workspace,
          onOpenCheckout: () => context.go(Screen.checkoutPath),
          onOpenOrders: () => context.go(workspace.primaryOrderLaunchLocation),
          onDestinationSelected: context.go,
          onActionSelected: context.go,
          onActionInvoked: _handleActionInvoked,
          sectionOrder: presentationProfile.sectionOrder,
          sectionFocusKeys: _sectionFocusKeys,
        ),
      ),
    );
  }

  void _handleActionInvoked(m.Action action) {
    final focusSection = action.focusSection;
    if (focusSection == null) {
      context.go(action.routePath);
      return;
    }

    if (action.routePath != Routes.routePath) {
      context.go(action.routePath);
      return;
    }

    _focusSection(focusSection);
  }

  void _focusSection(SectionSlot section) {
    final sectionContext = _sectionFocusKeys[section]?.currentContext;
    if (sectionContext == null) return;

    Scrollable.ensureVisible(
      sectionContext,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: 0.05,
    );
  }
}
