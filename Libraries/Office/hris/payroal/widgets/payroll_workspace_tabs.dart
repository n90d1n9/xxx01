import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

class PayrollWorkspaceTabSpec {
  final String label;
  final IconData icon;
  final Widget child;

  const PayrollWorkspaceTabSpec({
    required this.label,
    required this.icon,
    required this.child,
  });
}

class PayrollWorkspaceTabs extends StatelessWidget {
  final List<PayrollWorkspaceTabSpec> tabs;

  const PayrollWorkspaceTabs({super.key, required this.tabs});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            decoration: hrisPanelDecoration(),
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: HrisColors.primary,
              unselectedLabelColor: HrisColors.muted,
              indicatorColor: HrisColors.primary,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: [
                for (final tab in tabs)
                  Tab(icon: Icon(tab.icon), text: tab.label),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                for (final tab in tabs)
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: tab.child,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PayrollWorkspaceSection extends StatelessWidget {
  final List<Widget> children;

  const PayrollWorkspaceSection({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final spacedChildren = <Widget>[];
    for (var index = 0; index < children.length; index++) {
      if (index > 0) spacedChildren.add(const SizedBox(height: 16));
      spacedChildren.add(children[index]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: spacedChildren,
    );
  }
}
