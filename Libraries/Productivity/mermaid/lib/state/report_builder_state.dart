import '../model/pagination_config.dart';
import '../model/report_configuration.dart';
import '../model/report_data.dart';
import '../model/report_page.dart';
import 'drag_drop_state.dart';

class ReportBuilderState {
  final ReportConfiguration? currentConfig;
  final ReportData? currentData;
  final bool isLoading;
  final String? error;
  final List<ReportConfiguration> savedReports;
  final ReportPage? currentPage;
  final bool showPreview;
  final Map<String, bool> expandedGroups;

  final List<ReportPage> pages;
  final int currentPageIndex;
  final PaginationConfig paginationConfig;
  final DragDropState dragDropState;
  final bool isPreviewMode;
  final double zoom;
  final Map<String, dynamic>? data;

  ReportBuilderState({
    this.currentConfig,
    this.currentData,
    this.isLoading = false,
    this.error,
    this.savedReports = const [],
    this.currentPage,
    this.showPreview = false,
    this.expandedGroups = const {},
    this.pages = const [],
    this.currentPageIndex = 0,
    this.paginationConfig = const PaginationConfig(),
    this.dragDropState = const DragDropState(),
    this.isPreviewMode = false,
    this.zoom = 1.0,
    this.data,
  });

  ReportBuilderState copyWith({
    ReportConfiguration? currentConfig,
    ReportData? currentData,
    bool? isLoading,
    String? error,
    List<ReportConfiguration>? savedReports,
    ReportPage? currentPage,
    bool? showPreview,
    Map<String, bool>? expandedGroups,
    List<ReportPage>? pages,
    int? currentPageIndex,
    PaginationConfig? paginationConfig,
    DragDropState? dragDropState,
    bool? isPreviewMode,
    double? zoom,
    Map<String, dynamic>? data,
  }) {
    return ReportBuilderState(
      currentConfig: currentConfig ?? this.currentConfig,
      currentData: currentData ?? this.currentData,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      savedReports: savedReports ?? this.savedReports,
      currentPage: currentPage ?? this.currentPage,
      showPreview: showPreview ?? this.showPreview,
      expandedGroups: expandedGroups ?? this.expandedGroups,
      pages: pages ?? this.pages,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      paginationConfig: paginationConfig ?? this.paginationConfig,
      dragDropState: dragDropState ?? this.dragDropState,
      isPreviewMode: isPreviewMode ?? this.isPreviewMode,
      zoom: zoom ?? this.zoom,
      data: data ?? this.data,
    );
  }
}
