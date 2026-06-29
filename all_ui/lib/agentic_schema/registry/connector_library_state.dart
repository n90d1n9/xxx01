import 'model/connector_category.dart';
import 'model/prebuilt_connector.dart';

class ConnectorLibraryState {
  final List<PrebuiltConnector> connectors;
  final List<PrebuiltConnector> filteredConnectors;
  final ConnectorCategory? selectedCategory;
  final String searchQuery;
  final PrebuiltConnector? selectedConnector;
  final bool isLoading;

  ConnectorLibraryState({
    this.connectors = const [],
    this.filteredConnectors = const [],
    this.selectedCategory,
    this.searchQuery = '',
    this.selectedConnector,
    this.isLoading = false,
  });

  ConnectorLibraryState copyWith({
    List<PrebuiltConnector>? connectors,
    List<PrebuiltConnector>? filteredConnectors,
    ConnectorCategory? selectedCategory,
    String? searchQuery,
    PrebuiltConnector? selectedConnector,
    bool? isLoading,
  }) {
    return ConnectorLibraryState(
      connectors: connectors ?? this.connectors,
      filteredConnectors: filteredConnectors ?? this.filteredConnectors,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedConnector: selectedConnector ?? this.selectedConnector,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
