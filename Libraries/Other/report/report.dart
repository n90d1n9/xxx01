// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:docx_template/docx_template.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Report Layout Builder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        fontFamily: 'Poppins',
      ),
      home: const ReportBuilderScreen(),
    );
  }
}

// Models
enum PaperSize { a4, a3, letter, legal, continuous }

enum ElementType { text, richText, image, chart, table, watermark, background }

class ReportElement {
  final ElementType type;
  final Map<String, dynamic> properties;
  final String id;

  ReportElement({
    required this.type,
    required this.properties,
    required this.id,
  });
}

class ReportPage {
  final String id;
  final List<ReportElement> elements;
  final PaperSize paperSize;
  final Map<String, dynamic> pageSettings;

  ReportPage({
    required this.id,
    required this.elements,
    required this.paperSize,
    required this.pageSettings,
  });
}

class Report {
  final String id;
  final String title;
  final List<ReportPage> pages;
  final PaperSize defaultPaperSize;
  final bool continuousPaper;
  final Map<String, dynamic> reportSettings;

  Report({
    required this.id,
    required this.title,
    required this.pages,
    required this.defaultPaperSize,
    required this.continuousPaper,
    required this.reportSettings,
  });
}

// Providers
final currentReportProvider = StateProvider<Report?>((ref) => null);

final reportsProvider = StateNotifierProvider<ReportsNotifier, List<Report>>((
  ref,
) {
  return ReportsNotifier();
});

class ReportsNotifier extends StateNotifier<List<Report>> {
  ReportsNotifier() : super([]);

  void addReport(Report report) {
    state = [...state, report];
  }

  void updateReport(Report report) {
    state = [
      for (final r in state)
        if (r.id == report.id) report else r,
    ];
  }

  void deleteReport(String reportId) {
    state = state.where((report) => report.id != reportId).toList();
  }
}

// Elements Provider
final reportElementsProvider =
    StateNotifierProvider.family<ElementsNotifier, List<ReportElement>, String>(
      (ref, pageId) => ElementsNotifier(),
    );

class ElementsNotifier extends StateNotifier<List<ReportElement>> {
  ElementsNotifier() : super([]);

  void addElement(ReportElement element) {
    state = [...state, element];
  }

  void updateElement(ReportElement element) {
    state = [
      for (final e in state)
        if (e.id == element.id) element else e,
    ];
  }

  void deleteElement(String elementId) {
    state = state.where((element) => element.id != elementId).toList();
  }

  void reorderElements(List<ReportElement> elements) {
    state = elements;
  }
}

// Main Screen
class ReportBuilderScreen extends ConsumerStatefulWidget {
  const ReportBuilderScreen({super.key});

  @override
  _ReportBuilderScreenState createState() => _ReportBuilderScreenState();
}

class _ReportBuilderScreenState extends ConsumerState<ReportBuilderScreen> {
  int _selectedPageIndex = 0;
  ElementType _selectedElementType = ElementType.text;

  @override
  void initState() {
    super.initState();
    // Create a sample report
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sampleReport = Report(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Sample Report',
        pages: [
          ReportPage(
            id: '1',
            elements: [],
            paperSize: PaperSize.a4,
            pageSettings: {
              'margins': {
                'top': 20.0,
                'bottom': 20.0,
                'left': 20.0,
                'right': 20.0,
              },
              'orientation': 'portrait',
            },
          ),
        ],
        defaultPaperSize: PaperSize.a4,
        continuousPaper: false,
        reportSettings: {
          'showPageNumbers': true,
          'pageNumberFormat': 'Page {current} of {total}',
          'pageNumberPosition': 'bottom-center',
        },
      );

      ref.read(currentReportProvider.notifier).state = sampleReport;
      ref.read(reportsProvider.notifier).addReport(sampleReport);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentReport = ref.watch(currentReportProvider);

    if (currentReport == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentReport.title,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () => _saveReport(),
            tooltip: 'Save Report',
          ),
          IconButton(
            icon: Icon(Icons.print),
            onPressed: () => _printReport(),
            tooltip: 'Print Report',
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.file_download),
            tooltip: 'Export',
            onSelected: (value) => _exportReport(value),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'pdf', child: Text('Export as PDF')),
              PopupMenuItem(value: 'docx', child: Text('Export as DOCX')),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Left Sidebar: Pages and Settings
          Container(
            width: 250,
            color: Colors.white,
            child: Column(
              children: [
                // Report Settings Section
                ExpansionTile(
                  title: Text('Report Settings'),
                  initiallyExpanded: true,
                  children: [
                    _buildPaperSizeSelector(currentReport),
                    _buildContinuousPaperToggle(currentReport),
                    _buildPageNumberingSettings(currentReport),
                  ],
                ),

                Divider(),

                // Pages Section
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pages',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => _addNewPage(currentReport),
                        tooltip: 'Add new page',
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount: currentReport.pages.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: index == _selectedPageIndex ? 4 : 1,
                        margin: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        color: index == _selectedPageIndex
                            ? Colors.blue.shade50
                            : Colors.white,
                        child: ListTile(
                          title: Text('Page ${index + 1}'),
                          subtitle: Text(
                            currentReport.pages[index].paperSize
                                .toString()
                                .split('.')
                                .last,
                          ),
                          selected: index == _selectedPageIndex,
                          onTap: () {
                            setState(() {
                              _selectedPageIndex = index;
                            });
                          },
                          trailing: IconButton(
                            icon: Icon(Icons.more_vert),
                            onPressed: () =>
                                _showPageOptions(index, currentReport),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Central area: Canvas
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.grey[200],
              child: Center(child: _buildReportCanvas(currentReport)),
            ),
          ),

          // Right Sidebar: Element Tools
          Container(
            width: 280,
            color: Colors.white,
            child: Column(
              children: [
                // Element Types
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Elements',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildElementButton(ElementType.text, Icons.text_fields),
                    _buildElementButton(
                      ElementType.richText,
                      Icons.format_size,
                    ),
                    _buildElementButton(ElementType.image, Icons.image),
                    _buildElementButton(ElementType.chart, Icons.bar_chart),
                    _buildElementButton(ElementType.table, Icons.grid_on),
                    _buildElementButton(
                      ElementType.watermark,
                      Icons.water_damage,
                    ),
                    _buildElementButton(ElementType.background, Icons.image),
                  ],
                ),

                Divider(height: 32),

                // Element Properties
                Expanded(child: _buildElementProperties()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaperSizeSelector(Report report) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: DropdownButtonFormField<PaperSize>(
        decoration: InputDecoration(
          labelText: 'Default Paper Size',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        value: report.defaultPaperSize,
        items: PaperSize.values.map((size) {
          return DropdownMenuItem<PaperSize>(
            value: size,
            child: Text(size.toString().split('.').last),
          );
        }).toList(),
        onChanged: (newSize) {
          if (newSize != null) {
            _updateReportSetting('defaultPaperSize', newSize);
          }
        },
      ),
    );
  }

  Widget _buildContinuousPaperToggle(Report report) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Continuous Paper'),
          Switch(
            value: report.continuousPaper,
            onChanged: (value) {
              _updateReportSetting('continuousPaper', value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPageNumberingSettings(Report report) {
    final showPageNumbers = report.reportSettings['showPageNumbers'] as bool;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Show Page Numbers'),
              Switch(
                value: showPageNumbers,
                onChanged: (value) {
                  _updateReportSetting(
                    'showPageNumbers',
                    value,
                    reportSettings: true,
                  );
                },
              ),
            ],
          ),
          if (showPageNumbers) ...[
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                labelText: 'Page Number Format',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                hintText: 'Page {current} of {total}',
              ),
              controller: TextEditingController(
                text: report.reportSettings['pageNumberFormat'] as String,
              ),
              onChanged: (value) {
                _updateReportSetting(
                  'pageNumberFormat',
                  value,
                  reportSettings: true,
                );
              },
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Page Number Position',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              value: report.reportSettings['pageNumberPosition'] as String,
              items:
                  [
                    'top-left',
                    'top-center',
                    'top-right',
                    'bottom-left',
                    'bottom-center',
                    'bottom-right',
                  ].map((position) {
                    return DropdownMenuItem<String>(
                      value: position,
                      child: Text(position),
                    );
                  }).toList(),
              onChanged: (newPosition) {
                if (newPosition != null) {
                  _updateReportSetting(
                    'pageNumberPosition',
                    newPosition,
                    reportSettings: true,
                  );
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildElementButton(ElementType type, IconData icon) {
    final isSelected = _selectedElementType == type;
    final displayName = type.toString().split('.').last;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedElementType = type;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey.shade700,
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              displayName,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.blue.shade800 : Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElementProperties() {
    // This would display properties specific to the selected element type
    final elements = [
      'No element selected',
      'Select an element on the canvas to edit its properties',
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Properties',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Card(
          elevation: 0,
          color: Colors.grey.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: elements
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        e,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        SizedBox(height: 16),
        ElevatedButton.icon(
          icon: Icon(Icons.add),
          label: Text('Add ${_selectedElementType.toString().split('.').last}'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: () => _addElementToCanvas(),
        ),
      ],
    );
  }

  Widget _buildReportCanvas(Report report) {
    if (_selectedPageIndex >= report.pages.length) {
      _selectedPageIndex = report.pages.length - 1;
    }

    final currentPage = report.pages[_selectedPageIndex];
    final pageSize = _getPaperSize(currentPage.paperSize);

    return Container(
      width: pageSize.width,
      height: pageSize.height,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Page background (if any)
          // Watermark (if any)

          // Page elements would be rendered here based on their positions
          Center(
            child: Text(
              'Page ${_selectedPageIndex + 1}',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade400),
            ),
          ),

          // Page number at bottom
          if (report.reportSettings['showPageNumbers'] as bool)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  (report.reportSettings['pageNumberFormat'] as String)
                      .replaceAll(
                        '{current}',
                        (_selectedPageIndex + 1).toString(),
                      )
                      .replaceAll('{total}', report.pages.length.toString()),
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Size _getPaperSize(PaperSize size) {
    switch (size) {
      case PaperSize.a4:
        return Size(595, 842); // Points (roughly 210mm × 297mm)
      case PaperSize.a3:
        return Size(842, 1191); // Points (roughly 297mm × 420mm)
      case PaperSize.letter:
        return Size(612, 792); // Points (8.5" × 11")
      case PaperSize.legal:
        return Size(612, 1008); // Points (8.5" × 14")
      case PaperSize.continuous:
        return Size(595, 1000); // Arbitrary height for continuous paper
    }
  }

  void _addNewPage(Report report) {
    final newPageIndex = report.pages.length + 1;
    final newPage = ReportPage(
      id: newPageIndex.toString(),
      elements: [],
      paperSize: report.defaultPaperSize,
      pageSettings: {
        'margins': {'top': 20.0, 'bottom': 20.0, 'left': 20.0, 'right': 20.0},
        'orientation': 'portrait',
      },
    );

    final updatedReport = Report(
      id: report.id,
      title: report.title,
      pages: [...report.pages, newPage],
      defaultPaperSize: report.defaultPaperSize,
      continuousPaper: report.continuousPaper,
      reportSettings: report.reportSettings,
    );

    ref.read(currentReportProvider.notifier).state = updatedReport;
    ref.read(reportsProvider.notifier).updateReport(updatedReport);

    setState(() {
      _selectedPageIndex = updatedReport.pages.length - 1;
    });
  }

  void _showPageOptions(int index, Report report) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Page Settings'),
                onTap: () {
                  Navigator.pop(context);
                  _showPageSettingsDialog(index, report);
                },
              ),
              ListTile(
                leading: Icon(Icons.copy),
                title: Text('Duplicate Page'),
                onTap: () {
                  Navigator.pop(context);
                  _duplicatePage(index, report);
                },
              ),
              if (report.pages.length > 1)
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text(
                    'Delete Page',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _deletePage(index, report);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showPageSettingsDialog(int index, Report report) {
    final page = report.pages[index];
    PaperSize selectedSize = page.paperSize;
    String orientation = page.pageSettings['orientation'] as String;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Page Settings'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Paper Size'),
                  DropdownButton<PaperSize>(
                    value: selectedSize,
                    isExpanded: true,
                    items: PaperSize.values.map((size) {
                      return DropdownMenuItem<PaperSize>(
                        value: size,
                        child: Text(size.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedSize = value;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  Text('Orientation'),
                  Row(
                    children: [
                      Radio<String>(
                        value: 'portrait',
                        groupValue: orientation,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              orientation = value;
                            });
                          }
                        },
                      ),
                      Text('Portrait'),
                      SizedBox(width: 16),
                      Radio<String>(
                        value: 'landscape',
                        groupValue: orientation,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              orientation = value;
                            });
                          }
                        },
                      ),
                      Text('Landscape'),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _updatePageSettings(index, report, selectedSize, orientation);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _updatePageSettings(
    int index,
    Report report,
    PaperSize paperSize,
    String orientation,
  ) {
    final updatedPage = ReportPage(
      id: report.pages[index].id,
      elements: report.pages[index].elements,
      paperSize: paperSize,
      pageSettings: {
        ...report.pages[index].pageSettings,
        'orientation': orientation,
      },
    );

    final updatedPages = [...report.pages];
    updatedPages[index] = updatedPage;

    final updatedReport = Report(
      id: report.id,
      title: report.title,
      pages: updatedPages,
      defaultPaperSize: report.defaultPaperSize,
      continuousPaper: report.continuousPaper,
      reportSettings: report.reportSettings,
    );

    ref.read(currentReportProvider.notifier).state = updatedReport;
    ref.read(reportsProvider.notifier).updateReport(updatedReport);
  }

  void _duplicatePage(int index, Report report) {
    final originalPage = report.pages[index];
    final newPageId = (report.pages.length + 1).toString();

    final duplicatedPage = ReportPage(
      id: newPageId,
      elements: [...originalPage.elements], // Create a copy of elements
      paperSize: originalPage.paperSize,
      pageSettings: Map<String, dynamic>.from(originalPage.pageSettings),
    );

    final updatedPages = [...report.pages];
    // Insert after the current page
    updatedPages.insert(index + 1, duplicatedPage);

    final updatedReport = Report(
      id: report.id,
      title: report.title,
      pages: updatedPages,
      defaultPaperSize: report.defaultPaperSize,
      continuousPaper: report.continuousPaper,
      reportSettings: report.reportSettings,
    );

    ref.read(currentReportProvider.notifier).state = updatedReport;
    ref.read(reportsProvider.notifier).updateReport(updatedReport);

    setState(() {
      _selectedPageIndex = index + 1;
    });
  }

  void _deletePage(int index, Report report) {
    final updatedPages = [...report.pages];
    updatedPages.removeAt(index);

    final updatedReport = Report(
      id: report.id,
      title: report.title,
      pages: updatedPages,
      defaultPaperSize: report.defaultPaperSize,
      continuousPaper: report.continuousPaper,
      reportSettings: report.reportSettings,
    );

    ref.read(currentReportProvider.notifier).state = updatedReport;
    ref.read(reportsProvider.notifier).updateReport(updatedReport);

    setState(() {
      _selectedPageIndex = index > 0 ? index - 1 : 0;
    });
  }

  void _updateReportSetting(
    String key,
    dynamic value, {
    bool reportSettings = false,
  }) {
    final currentReport = ref.read(currentReportProvider);

    if (currentReport == null) return;

    Report updatedReport;

    if (reportSettings) {
      // Update a setting inside the reportSettings map
      final updatedReportSettings = Map<String, dynamic>.from(
        currentReport.reportSettings,
      );
      updatedReportSettings[key] = value;

      updatedReport = Report(
        id: currentReport.id,
        title: currentReport.title,
        pages: currentReport.pages,
        defaultPaperSize: currentReport.defaultPaperSize,
        continuousPaper: currentReport.continuousPaper,
        reportSettings: updatedReportSettings,
      );
    } else {
      // Update a top-level report property
      updatedReport = Report(
        id: currentReport.id,
        title: currentReport.title,
        pages: currentReport.pages,
        defaultPaperSize: key == 'defaultPaperSize'
            ? value
            : currentReport.defaultPaperSize,
        continuousPaper: key == 'continuousPaper'
            ? value
            : currentReport.continuousPaper,
        reportSettings: currentReport.reportSettings,
      );
    }

    ref.read(currentReportProvider.notifier).state = updatedReport;
    ref.read(reportsProvider.notifier).updateReport(updatedReport);
  }

  void _addElementToCanvas() {
    final currentReport = ref.read(currentReportProvider);

    if (currentReport == null ||
        _selectedPageIndex >= currentReport.pages.length)
      return;

    // Create default properties based on element type
    Map<String, dynamic> defaultProperties = {};

    switch (_selectedElementType) {
      case ElementType.text:
        defaultProperties = {
          'content': 'Text Element',
          'fontSize': 14.0,
          'fontWeight': 'normal',
          'color': '#000000',
          'position': {'x': 100.0, 'y': 100.0},
          'size': {'width': 200.0, 'height': 50.0},
        };
        break;
      case ElementType.richText:
        defaultProperties = {
          'content': 'Rich Text Element',
          'fontSize': 14.0,
          'formatting': [],
          'position': {'x': 100.0, 'y': 100.0},
          'size': {'width': 300.0, 'height': 100.0},
        };
        break;
      case ElementType.image:
        defaultProperties = {
          'source': 'placeholder',
          'position': {'x': 100.0, 'y': 100.0},
          'size': {'width': 200.0, 'height': 150.0},
        };
        break;
      case ElementType.chart:
        defaultProperties = {
          'type': 'bar',
          'data': {
            'labels': ['A', 'B', 'C', 'D'],
            'datasets': [
              {
                'data': [10, 20, 30, 40],
                'color': '#4285F4',
              },
            ],
          },
          'position': {'x': 100.0, 'y': 100.0},
          'size': {'width': 300.0, 'height': 200.0},
        };
        break;
      case ElementType.table:
        defaultProperties = {
          'data': [
            ['Header 1', 'Header 2', 'Header 3'],
            ['Row 1, Cell 1', 'Row 1, Cell 2', 'Row 1, Cell 3'],
            ['Row 2, Cell 1', 'Row 2, Cell 2', 'Row 2, Cell 3'],
          ],
          'position': {'x': 100.0, 'y': 100.0},
          'size': {'width': 400.0, 'height': 200.0},
        };
        break;
      case ElementType.watermark:
        defaultProperties = {
          'text': 'WATERMARK',
          'opacity': 0.1,
          'rotation': 45.0,
          'fontSize': 64.0,
          'color': '#CCCCCC',
          'position': {'x': 'center', 'y': 'center'},
        };
        break;
      case ElementType.background:
        defaultProperties = {
          'type': 'color', // or 'image'
          'color': '#F9F9F9',
          'opacity': 1.0,
        };
        break;
    }

    // Create the new element
    final newElement = ReportElement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _selectedElementType,
      properties: defaultProperties,
    );

    // Update the current page with the new element
    final currentPage = currentReport.pages[_selectedPageIndex];
    final updatedElements = [...currentPage.elements, newElement];

    final updatedPage = ReportPage(
      id: currentPage.id,
      elements: updatedElements,
      paperSize: currentPage.paperSize,
      pageSettings: currentPage.pageSettings,
    );

    final updatedPages = [...currentReport.pages];
    updatedPages[_selectedPageIndex] = updatedPage;

    final updatedReport = Report(
      id: currentReport.id,
      title: currentReport.title,
      pages: updatedPages,
      defaultPaperSize: currentReport.defaultPaperSize,
      continuousPaper: currentReport.continuousPaper,
      reportSettings: currentReport.reportSettings,
    );

    ref.read(currentReportProvider.notifier).state = updatedReport;
    ref.read(reportsProvider.notifier).updateReport(updatedReport);

    // Also add to element-specific provider for this page
    ref
        .read(reportElementsProvider(currentPage.id).notifier)
        .addElement(newElement);

    // Show snackbar to confirm element added
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_selectedElementType.toString().split('.').last} element added',
        ),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _saveReport() {
    // Implementation for saving the report would go here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report saved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _printReport() {
    final currentReport = ref.read(currentReportProvider);
    if (currentReport == null) return;

    // Navigate to print preview screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrintPreviewScreen(report: currentReport),
      ),
    );
  }

  void _exportReport(String format) async {
    final currentReport = ref.read(currentReportProvider);
    if (currentReport == null) return;

    try {
      if (format == 'pdf') {
        await _exportToPdf(currentReport);
      } else if (format == 'docx') {
        await _exportToDocx(currentReport);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Report exported to ${format.toUpperCase()} successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting report: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _exportToPdf(Report report) async {
    // Implementation for PDF export would go here
    final pdf = pw.Document();

    for (final page in report.pages) {
      pdf.addPage(
        pw.Page(
          pageFormat: _getPdfPageFormat(page.paperSize),
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Text('Page ${report.pages.indexOf(page) + 1}'),
            );
          },
        ),
      );
    }

    // Save PDF file
    final directory = await getApplicationDocumentsDirectory();
    final path =
        '${directory.path}/${report.title}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(path);
    await file.writeAsBytes(await pdf.save());
  }

  Future<void> _exportToDocx(Report report) async {
    // Implementation for DOCX export would go here
    // In a real implementation, you would use the docx_template package to create a DOCX file
    // For demonstration purposes, just create an empty file
    final directory = await getApplicationDocumentsDirectory();
    final path =
        '${directory.path}/${report.title}_${DateTime.now().millisecondsSinceEpoch}.docx';
    final file = File(path);
    await file.writeAsString('DOCX export implementation');
  }

  PdfPageFormat _getPdfPageFormat(PaperSize size) {
    switch (size) {
      case PaperSize.a4:
        return PdfPageFormat.a4;
      case PaperSize.a3:
        return PdfPageFormat.a3;
      case PaperSize.letter:
        return PdfPageFormat.letter;
      case PaperSize.legal:
        return PdfPageFormat.legal;
      case PaperSize.continuous:
        return PdfPageFormat(
          PdfPageFormat.a4.width,
          double.infinity,
          marginAll: 20,
        );
    }
  }
}

// Print Preview Screen
class PrintPreviewScreen extends StatelessWidget {
  final Report report;

  const PrintPreviewScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Print Preview'),
        actions: [
          IconButton(
            icon: Icon(Icons.print),
            onPressed: () => _printDocument(context),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: PdfPreview(
        build: (format) => _generatePdf(format),
        canChangeOrientation: true,
        canChangePageFormat: true,
        allowPrinting: true,
        allowSharing: true,
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    for (int i = 0; i < report.pages.length; i++) {
      final page = report.pages[i];

      pdf.addPage(
        pw.Page(
          pageFormat: format,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Expanded(
                  child: pw.Center(
                    child: pw.Text(
                      'Page ${i + 1} Content',
                      style: pw.TextStyle(fontSize: 24),
                    ),
                  ),
                ),

                // Page numbering if enabled
                if (report.reportSettings['showPageNumbers'] as bool)
                  pw.Container(
                    alignment: pw.Alignment.center,
                    margin: pw.EdgeInsets.only(bottom: 10),
                    child: pw.Text(
                      (report.reportSettings['pageNumberFormat'] as String)
                          .replaceAll('{current}', (i + 1).toString())
                          .replaceAll(
                            '{total}',
                            report.pages.length.toString(),
                          ),
                      style: pw.TextStyle(fontSize: 10),
                    ),
                  ),
              ],
            );
          },
        ),
      );
    }

    return pdf.save();
  }

  void _printDocument(BuildContext context) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => _generatePdf(format),
    );
  }
}

// Helper widgets for rendering elements
class TextElementWidget extends StatelessWidget {
  final ReportElement element;

  const TextElementWidget({super.key, required this.element});

  @override
  Widget build(BuildContext context) {
    final properties = element.properties;
    final position = properties['position'] as Map<String, dynamic>;
    final size = properties['size'] as Map<String, dynamic>;

    return Positioned(
      left: position['x'] as double,
      top: position['y'] as double,
      width: size['width'] as double,
      height: size['height'] as double,
      child: Text(
        properties['content'] as String,
        style: TextStyle(
          fontSize: properties['fontSize'] as double,
          fontWeight: properties['fontWeight'] == 'bold'
              ? FontWeight.bold
              : FontWeight.normal,
          color: _parseColor(properties['color'] as String),
        ),
      ),
    );
  }

  Color _parseColor(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}

class ImageElementWidget extends StatelessWidget {
  final ReportElement element;

  const ImageElementWidget({super.key, required this.element});

  @override
  Widget build(BuildContext context) {
    final properties = element.properties;
    final position = properties['position'] as Map<String, dynamic>;
    final size = properties['size'] as Map<String, dynamic>;

    return Positioned(
      left: position['x'] as double,
      top: position['y'] as double,
      width: size['width'] as double,
      height: size['height'] as double,
      child: properties['source'] == 'placeholder'
          ? Container(
              color: Colors.grey.shade200,
              child: Icon(Icons.image, size: 48, color: Colors.grey.shade400),
            )
          : Image.memory(
              Uint8List(0), // Replace with actual image data
              fit: BoxFit.contain,
            ),
    );
  }
}

class ChartElementWidget extends StatelessWidget {
  final ReportElement element;

  const ChartElementWidget({super.key, required this.element});

  @override
  Widget build(BuildContext context) {
    final properties = element.properties;
    final position = properties['position'] as Map<String, dynamic>;
    final size = properties['size'] as Map<String, dynamic>;
    final chartType = properties['type'] as String;
    final data = properties['data'] as Map<String, dynamic>;

    return Positioned(
      left: position['x'] as double,
      top: position['y'] as double,
      width: size['width'] as double,
      height: size['height'] as double,
      child: _buildChart(chartType, data),
    );
  }

  Widget _buildChart(String type, Map<String, dynamic> data) {
    switch (type) {
      case 'bar':
        return _buildBarChart(data);
      case 'line':
        return _buildLineChart(data);
      default:
        return Container(
          color: Colors.grey.shade200,
          child: Center(child: Text('Unsupported chart type: $type')),
        );
    }
  }

  Widget _buildBarChart(Map<String, dynamic> data) {
    final labels = (data['labels'] as List).cast<String>();
    final datasets = (data['datasets'] as List).cast<Map<String, dynamic>>();

    // Simple placeholder for bar chart
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Bar Chart',
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < labels.length) {
                          return Text(labels[index]);
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 30),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(
                  labels.length,
                  (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: datasets[0]['data'][index].toDouble(),
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(Map<String, dynamic> data) {
    // Simple placeholder for line chart
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Center(child: Text('Line Chart Placeholder')),
    );
  }
}

class TableElementWidget extends StatelessWidget {
  final ReportElement element;

  const TableElementWidget({super.key, required this.element});

  @override
  Widget build(BuildContext context) {
    final properties = element.properties;
    final position = properties['position'] as Map<String, dynamic>;
    final size = properties['size'] as Map<String, dynamic>;
    final tableData = (properties['data'] as List).cast<List<dynamic>>();

    return Positioned(
      left: position['x'] as double,
      top: position['y'] as double,
      width: size['width'] as double,
      height: size['height'] as double,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          child: Table(
            border: TableBorder.all(color: Colors.grey.shade300),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: tableData.map((row) {
              return TableRow(
                children: row.map((cell) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      cell.toString(),
                      style: TextStyle(
                        fontWeight: tableData.indexOf(row) == 0
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class WatermarkElementWidget extends StatelessWidget {
  final ReportElement element;

  const WatermarkElementWidget({super.key, required this.element});

  @override
  Widget build(BuildContext context) {
    final properties = element.properties;
    final text = properties['text'] as String;
    final opacity = properties['opacity'] as double;
    final rotation = properties['rotation'] as double;
    final fontSize = properties['fontSize'] as double;
    final colorStr = properties['color'] as String;

    return Center(
      child: Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: rotation * 3.14159 / 180, // Convert degrees to radians
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              color: _parseColor(colorStr),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Color _parseColor(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}

// Import libraries in pubspec.yaml
/*
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.3.6
  pdf: ^3.10.4
  printing: ^5.10.4
  file_picker: ^5.3.1
  docx_template: ^0.3.4
  fl_chart: ^0.63.0
  path_provider: ^2.1.0
*/
