import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/hadith_provider.dart';
import '../widgets/graph_view.dart';
import '../widgets/grid_view.dart';
import '../widgets/language_selector.dart';
import '../widgets/list_view.dart';
import '../widgets/navigation_drawer.dart';
import '../widgets/new_network_graph.dart';
//import 'network_graph_view.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(viewModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr(ref, 'app_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_tree),
            tooltip: tr(ref, 'graph_view'),
            onPressed:
                () =>
                    ref.read(viewModeProvider.notifier).state = ViewMode.graph,
          ),
          IconButton(
            icon: const Icon(Icons.hub),
            tooltip: tr(ref, 'network_view'),
            onPressed:
                () =>
                    ref.read(viewModeProvider.notifier).state =
                        ViewMode.network,
          ),
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: tr(ref, 'list_view'),
            onPressed:
                () => ref.read(viewModeProvider.notifier).state = ViewMode.list,
          ),
          IconButton(
            icon: const Icon(Icons.grid_view),
            tooltip: tr(ref, 'grid_view'),
            onPressed:
                () => ref.read(viewModeProvider.notifier).state = ViewMode.grid,
          ),
          const LanguageSelector(),
        ],
      ),
      drawer: const MyNavigationDrawer(),
      body: Column(
        children: [
          const SearchBar(),
          Expanded(
            child: switch (viewMode) {
              ViewMode.graph => const GraphView(),
              ViewMode.network => const NetworkGraphView(),
              ViewMode.list => const MyListView(),
              ViewMode.grid => const MyGridView(),
            },
          ),
        ],
      ),
    );
  }
}
