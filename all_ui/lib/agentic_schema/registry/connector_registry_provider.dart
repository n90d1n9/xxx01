import 'package:flutter_riverpod/legacy.dart';

import 'connector_library_state.dart';
import 'connector_registry.dart';
import 'model/connector_category.dart';
import 'model/prebuilt_connector.dart';

class ConnectorLibraryNotifier extends StateNotifier<ConnectorLibraryState> {
  ConnectorLibraryNotifier() : super(ConnectorLibraryState()) {
    _initialize();
  }

  void _initialize() {
    ConnectorRegistry.initialize();
    final connectors = ConnectorRegistry.getAll();
    state = state.copyWith(
      connectors: connectors,
      filteredConnectors: connectors,
    );
  }

  void search(String query) {
    if (query.isEmpty) {
      state = state.copyWith(
        searchQuery: '',
        filteredConnectors: state.connectors,
      );
      return;
    }

    final filtered =
        state.connectors.where((connector) {
          final q = query.toLowerCase();
          return connector.name.toLowerCase().contains(q) ||
              connector.description.toLowerCase().contains(q) ||
              connector.category.name.toLowerCase().contains(q);
        }).toList();

    state = state.copyWith(searchQuery: query, filteredConnectors: filtered);
  }

  void filterByCategory(ConnectorCategory? category) {
    if (category == null) {
      state = state.copyWith(
        selectedCategory: null,
        filteredConnectors: state.connectors,
      );
      return;
    }

    final filtered =
        state.connectors.where((c) => c.category == category).toList();

    state = state.copyWith(
      selectedCategory: category,
      filteredConnectors: filtered,
    );
  }

  void selectConnector(PrebuiltConnector? connector) {
    state = state.copyWith(selectedConnector: connector);
  }
}

final connectorLibraryProvider =
    StateNotifierProvider<ConnectorLibraryNotifier, ConnectorLibraryState>(
      (ref) => ConnectorLibraryNotifier(),
    );
