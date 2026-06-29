// Enhanced Element Models with Data Binding
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:queue_ui/report/report.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart' show PdfPageFormat;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:docx_template/docx_template.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fl_chart/fl_chart.dart';

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
      home: const ReportEditorScreen(reportId: ''),
    );
  }
}

final dummy = '''
{
  "id": "report-123456",
  "title": "Quarterly Financial Analysis Q1 2025",
  "description": "Comprehensive analysis of company financial performance for Q1 2025 including revenue, expenses, and growth projections.",
  "defaultPaperSize": "A4",
  "continuousPaper": false,
  "defaultOrientation": "portrait",
  "showPageNumbers": true,
  "headerTemplate": "<div style='text-align: center; font-size: 10pt;'>{{title}} - {{date}}</div>",
  "footerTemplate": "<div style='text-align: right; font-size: 8pt;'>Page {{pageNumber}} of {{totalPages}}</div>",
  "reportSettings": {
    "companyName": "TechCorp International",
    "reportPeriod": "Q1 2025",
    "department": "Finance",
    "confidentialityLevel": "Internal",
    "authorId": "user-789",
    "createdDate": "2025-03-10T09:15:30Z",
    "lastModified": "2025-03-23T14:22:45Z",
    "version": "1.2.1",
    "enableCharts": true,
    "themeColor": "#2C3E50"
  },
  "pages": [
    {
      "id": "page-001",
      "title": "Executive Summary",
      "orientation": "portrait",
      "paperSize": "A4",
      "margins": {
        "top": 20,
        "right": 20,
        "bottom": 20,
        "left": 20
      },
      "elements": [
        {
          "id": "text-001",
          "type": "text",
          "content": "Executive Summary This report highlights the company's financial performance for Q1 2025, showing a 12% increase in revenue compared to Q4 2024 and a 15% increase compared to Q1 2024.",
          "position": {
            "x": 50,
            "y": 50,
            "width": 500,
            "height": 200
          },
          "style": {
            "fontFamily": "Arial",
            "fontSize": 12,
            "textAlign": "left"
          }
        },
        {
          "id": "image-001",
          "type": "image",
          "source": "assets/company-logo.png",
          "position": {
            "x": 450,
            "y": 10,
            "width": 100,
            "height": 30
          }
        }
      ]
    },
    {
      "id": "page-002",
      "title": "Revenue Analysis",
      "orientation": "landscape",
      "paperSize": "A4",
      "margins": {
        "top": 15,
        "right": 15,
        "bottom": 15,
        "left": 15
      },
      "elements": [
        {
          "id": "chart-001",
          "type": "chart",
          "chartType": "bar",
          "data": {
            "labels": ["Jan", "Feb", "Mar"],
            "datasets": [
              {
                "label": "Revenue (in millions USD)",
                "data": [4.2, 5.3, 6.1]
              },
              {
                "label": "Previous Quarter",
                "data": [3.8, 4.2, 5.0]
              }
            ]
          },
          "position": {
            "x": 50,
            "y": 100,
            "width": 700,
            "height": 350
          },
          "options": {
            "title": "Q1 2025 Revenue Comparison",
            "legendPosition": "bottom"
          }
        },
        {
          "id": "text-002",
          "type": "text",
          "content": "## Revenue Analysis The chart shows consistent growth throughout Q1 2025, with March showing the highest revenue at \$6.1M. All months show improvement over the previous quarter.",
          "position": {
            "x": 50,
            "y": 50,
            "width": 700,
            "height": 100
          },
          "style": {
            "fontFamily": "Arial",
            "fontSize": 11,
            "textAlign": "left"
          }
        }
      ]
    },
    {
      "id": "page-003",
      "title": "Expense Breakdown",
      "orientation": "portrait",
      "paperSize": "A4",
      "margins": {
        "top": 20,
        "right": 20,
        "bottom": 20,
        "left": 20
      },
      "elements": [
        {
          "id": "table-001",
          "type": "table",
          "position": {
            "x": 50,
            "y": 100,
            "width": 500,
            "height": 300
          },
          "data": {
            "headers": ["Category", "Q1 2024", "Q1 2025", "Change (%)"],
            "rows": [
              ["Research & Development", "\$1.2M", "\$1.5M", "+25%"],
              ["Marketing", "\$0.8M", "\$1.1M", "+37.5%"],
              ["Operations", "\$2.1M", "\$2.3M", "+9.5%"],
              ["Administration", "\$0.6M", "\$0.7M", "+16.7%"],
              ["Other", "\$0.3M", "\$0.4M", "+33.3%"]
            ]
          },
          "style": {
            "headerBackground": "#f2f2f2",
            "headerTextColor": "#333333",
            "alternateRowColor": "#f9f9f9",
            "borderColor": "#dddddd"
          }
        },
        {
          "id": "text-003",
          "type": "text",
          "content": "## Expense Analysis Expenses have increased across all departments, with the largest percentage increase in Marketing (37.5%). The overall expense increase of 20.2% is outpaced by revenue growth, improving our profit margins.",
          "position": {
            "x": 50,
            "y": 50,
            "width": 500,
            "height": 100
          },
          "style": {
            "fontFamily": "Arial",
            "fontSize": 11,
            "textAlign": "left"
          }
        }
      ]
    },
    {
      "id": "page-004",
      "title": "Growth Projections",
      "orientation": "portrait",
      "paperSize": "A4",
      "margins": {
        "top": 20,
        "right": 20,
        "bottom": 20,
        "left": 20
      },
      "elements": [
        {
          "id": "chart-002",
          "type": "chart",
          "chartType": "line",
          "data": {
            "labels": ["Q1", "Q2", "Q3", "Q4"],
            "datasets": [
              {
                "label": "Projected Revenue 2025",
                "data": [15.6, 17.2, 18.5, 21.0],
                "borderColor": "#3498db"
              },
              {
                "label": "Actual Revenue 2024",
                "data": [13.2, 14.5, 15.8, 16.9],
                "borderColor": "#e74c3c"
              }
            ]
          },
          "position": {
            "x": 50,
            "y": 100,
            "width": 500,
            "height": 300
          },
          "options": {
            "title": "2025 Revenue Projections",
            "legendPosition": "bottom"
          }
        },
        {
          "id": "text-004",
          "type": "text",
          "content": "## Growth Projections Based on Q1 performance and current market conditions, we project continued growth throughout 2025. The annual growth target of 18% appears achievable with the current trajectory.",
          "position": {
            "x": 50,
            "y": 50,
            "width": 500,
            "height": 100
          },
          "style": {
            "fontFamily": "Arial",
            "fontSize": 11,
            "textAlign": "left"
          }
        }
      ]
    },
    {
      "id": "page-005",
      "title": "Recommendations",
      "orientation": "portrait",
      "paperSize": "A4",
      "margins": {
        "top": 20,
        "right": 20,
        "bottom": 20,
        "left": 20
      },
      "elements": [
        {
          "id": "text-005",
          "type": "text",
          "content": "# Recommendations 1. **Increase Marketing Investment**: The high ROI from marketing initiatives suggests further investment would accelerate growth. 2. **Optimize Operations**: While operations costs increased by 9.5%, there are opportunities to improve efficiency with targeted process improvements. 3. **Expand Product Line**: Research shows demand for complementary products that could be developed with minimal additional R&D. 4. **International Expansion**: Analysis indicates European markets are ready for entry in Q3 2025.",
          "position": {
            "x": 50,
            "y": 50,
            "width": 500,
            "height": 400
          },
          "style": {
            "fontFamily": "Arial",
            "fontSize": 12,
            "textAlign": "left"
          }
        }
      ]
    }
  ]
}
''';

enum PaperSize { a4, a3, letter, legal, continuous, tabloid }

enum ElementType { text, richText, image, chart, table, watermark, background }

class ReportElement {
  final ElementType type;
  final Map<String, dynamic>? properties;
  final String id;
  final Offset position;
  final Size size;
  String? dataField; // Field to bind dynamic data

  ReportElement({
    required this.type,
    this.properties,
    required this.id,
    required this.position,
    required this.size,
    this.dataField,
  });

  // CopyWith
  ReportElement copyWith({
    ElementType? type,
    Map<String, dynamic>? properties,
    String? id,
    Offset? position,
    Size? size,
    String? dataField,
  }) {
    return ReportElement(
      type: type ?? this.type,
      properties: properties ?? Map.from(this.properties!),
      id: id ?? this.id,
      position: position ?? this.position,
      size: size ?? this.size,
      dataField: dataField ?? this.dataField,
    );
  }

  // ToJson
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'properties': properties,
      'id': id,
      'position': {'dx': position.dx, 'dy': position.dy},
      'size': {'width': size.width, 'height': size.height},
      'dataField': dataField,
    };
  }

  // FromJson
  /* factory ReportElement.fromJson(Map<String, dynamic> json) {
    return ReportElement(
      type: ElementType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      properties: Map<String, dynamic>.from(json['properties']),
      id: json['id'],
      position: Offset(json['position']['dx'], json['position']['dy']),
      size: Size(json['size']['width'], json['size']['height']),
      dataField: json['dataField'],
    );
  } */
  factory ReportElement.fromJson(Map<String, dynamic> json) {
    return ReportElement(
      type: ElementType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      properties: Map<String, dynamic>.from(json['properties']),
      id: json['id'],
      position: Offset(json['position']['dx'], json['position']['dy']),
      size: Size(json['size']['width'], json['size']['height']),
      dataField: json['dataField'],
    );
  }

  @override
  String toString() {
    return 'ReportElement(type: $type, properties: $properties, id: $id, position: $position, size: $size, dataField: $dataField)';
  }
}

class ReportPage {
  final String id;
  final List<ReportElement> elements;
  final PaperSize paperSize;
  final Map<String, dynamic> pageSettings;
  final String name;
  final Orientation orientation;

  ReportPage({
    required this.id,
    required this.elements,
    required this.paperSize,
    required this.pageSettings,
    this.name = '',
    this.orientation = Orientation.portrait,
  });

  // CopyWith
  ReportPage copyWith({
    String? id,
    List<ReportElement>? elements,
    PaperSize? paperSize,
    Map<String, dynamic>? pageSettings,
    Orientation? orientation,
    String? name,
  }) {
    return ReportPage(
      id: id ?? this.id,
      elements: elements ?? List.from(this.elements),
      paperSize: paperSize ?? this.paperSize,
      pageSettings: pageSettings ?? Map.from(this.pageSettings),
      orientation: orientation ?? this.orientation,
      name: name ?? this.name,
    );
  }

  // ToJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'elements': elements.map((element) => element.toJson()).toList(),
      'paperSize': paperSize.toString().split('.').last,
      'pageSettings': pageSettings,
    };
  }

  // FromJson
  factory ReportPage.fromJson(Map<String, dynamic> json) {
    return ReportPage(
      id: json['id'],
      elements:
          (json['elements'] as List)
              .map((e) => ReportElement.fromJson(e))
              .toList(),
      paperSize: PaperSize.values.firstWhere(
        (e) => e.toString().split('.').last == json['paperSize'],
      ),
      pageSettings: Map<String, dynamic>.from(json['pageSettings']),
    );
  }

  @override
  String toString() {
    return 'ReportPage(id: $id, elements: $elements, paperSize: $paperSize, pageSettings: $pageSettings)';
  }
}

class Report {
  final String id;
  final String title;
  final List<ReportPage> pages;
  final PaperSize defaultPaperSize;
  final bool continuousPaper;
  final Map<String, dynamic> reportSettings;

  final String description;

  final Orientation defaultOrientation;

  final bool showPageNumbers;

  final String headerTemplate;

  final String footerTemplate;

  Report({
    required this.id,
    required this.title,
    required this.pages,
    required this.defaultPaperSize,
    required this.continuousPaper,
    required this.reportSettings,
    this.description = '',
    this.defaultOrientation = Orientation.portrait,
    this.showPageNumbers = true,
    this.headerTemplate = '',
    this.footerTemplate = '',
  });

  // CopyWith
  Report copyWith({
    String? id,
    String? title,
    List<ReportPage>? pages,
    PaperSize? defaultPaperSize,
    bool? continuousPaper,
    Map<String, dynamic>? reportSettings,
    String? description,
    Orientation? defaultOrientation,
    bool? showPageNumbers,
    String? headerTemplate,
    String? footerTemplate,
  }) {
    return Report(
      id: id ?? this.id,
      title: title ?? this.title,
      pages: pages ?? List.from(this.pages),
      defaultPaperSize: defaultPaperSize ?? this.defaultPaperSize,
      continuousPaper: continuousPaper ?? this.continuousPaper,
      reportSettings: reportSettings ?? Map.from(this.reportSettings),
      description: description ?? this.description,
      defaultOrientation: defaultOrientation ?? this.defaultOrientation,
      showPageNumbers: showPageNumbers ?? this.showPageNumbers,
      headerTemplate: headerTemplate ?? this.headerTemplate,
      footerTemplate: footerTemplate ?? this.footerTemplate,
    );
  }

  // ToJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'pages': pages.map((page) => page.toJson()).toList(),
      'defaultPaperSize': defaultPaperSize.toString().split('.').last,
      'continuousPaper': continuousPaper,
      'reportSettings': reportSettings,
    };
  }

  // FromJson
  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      title: json['title'],
      pages:
          (json['pages'] as List).map((e) => ReportPage.fromJson(e)).toList(),
      defaultPaperSize: PaperSize.values.firstWhere(
        (e) => e.toString().split('.').last == json['defaultPaperSize'],
      ),
      continuousPaper: json['continuousPaper'],
      reportSettings: Map<String, dynamic>.from(json['reportSettings']),
    );
  }

  @override
  String toString() {
    return 'Report(id: $id, title: $title, pages: $pages, defaultPaperSize: $defaultPaperSize, continuousPaper: $continuousPaper, reportSettings: $reportSettings)';
  }
}

// Dynamic Data Source Provider
final dynamicDataProvider = StateProvider<Map<String, dynamic>>((ref) {
  // Sample data for testing
  return {
    'customerName': 'John Doe',
    'invoiceNumber': 'INV-2025-001',
    'date': '2025-03-23',
    'totalAmount': '\$1,250.00',
    'items': [
      {'name': 'Product A', 'qty': 2, 'price': '\$300.00', 'total': '\$600.00'},
      {'name': 'Product B', 'qty': 1, 'price': '\$450.00', 'total': '\$450.00'},
      {'name': 'Service C', 'qty': 1, 'price': '\$200.00', 'total': '\$200.00'},
    ],
    'chartData': {
      'labels': ['Jan', 'Feb', 'Mar', 'Apr', 'May'],
      'values': [12, 19, 3, 5, 2],
    },
  };
});

// Enhanced Canvas with Drag and Drop
class DraggableReportCanvas extends ConsumerStatefulWidget {
  final Report report;
  final int pageIndex;
  final Function(ReportElement) onElementSelected;
  final Function(ReportElement) onElementUpdated;

  const DraggableReportCanvas({
    Key? key,
    required this.report,
    required this.pageIndex,
    required this.onElementSelected,
    required this.onElementUpdated,
  }) : super(key: key);

  @override
  _DraggableReportCanvasState createState() => _DraggableReportCanvasState();
}

class _DraggableReportCanvasState extends ConsumerState<DraggableReportCanvas> {
  ReportElement? selectedElement;
  bool isDragging = false;
  Offset dragStart = Offset.zero;
  Offset elementStartPosition = Offset.zero;
  Size? resizeStartSize;
  bool isResizing = false;
  ResizeDirection? resizeDirection;

  @override
  Widget build(BuildContext context) {
    final currentPage = widget.report.pages[widget.pageIndex];
    final pageSize = _getPaperSize(currentPage.paperSize);
    final dynamicData = ref.watch(dynamicDataProvider);

    return Stack(
      children: [
        // Canvas Container
        Container(
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
          child: DragTarget<ElementType>(
            onAccept: (elementType) {
              _addNewElement(elementType, pageSize);
            },
            builder: (context, candidateData, rejectedData) {
              return Stack(
                children: [
                  // Background element (if any)
                  _buildBackgroundElement(currentPage),

                  // Watermark (if any)
                  _buildWatermarkElement(currentPage),

                  // Regular elements
                  ...currentPage.elements.map((element) {
                    return _buildDraggableElement(element, dynamicData);
                  }).toList(),

                  // Page number at bottom
                  if (widget.report.reportSettings['showPageNumbers'] as bool)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          (widget.report.reportSettings['pageNumberFormat']
                                  as String)
                              .replaceAll(
                                '{current}',
                                (widget.pageIndex + 1).toString(),
                              )
                              .replaceAll(
                                '{total}',
                                widget.report.pages.length.toString(),
                              ),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundElement(ReportPage page) {
    final background = page.elements.firstWhere(
      (element) => element.type == ElementType.background,
      orElse:
          () => ReportElement(
            id: 'default-bg',
            type: ElementType.background,
            properties: {'type': 'color', 'color': '#FFFFFF', 'opacity': 1.0},
            position: Offset.zero,
            size: _getPaperSize(page.paperSize),
          ),
    );

    if (background.properties!['type'] == 'color') {
      return Container(
        color: _parseColor(
          background.properties!['color'],
          opacity: background.properties!['opacity'] ?? 1.0,
        ),
      );
    } else if (background.properties!['type'] == 'image') {
      return Opacity(
        opacity: background.properties!['opacity'] ?? 1.0,
        child: Image.network(
          background.properties!['url'] ?? '',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade200,
              child: Center(
                child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
              ),
            );
          },
        ),
      );
    }

    return Container(color: Colors.white);
  }

  Widget _buildWatermarkElement(ReportPage page) {
    final watermark = page.elements.firstWhere(
      (element) => element.type == ElementType.watermark,
      orElse:
          () => ReportElement(
            id: 'no-watermark',
            type: ElementType.watermark,
            properties: {
              'text': '',
              'opacity': 0.0,
              'rotation': 0.0,
              'fontSize': 0.0,
              'color': '#FFFFFF',
            },
            position: Offset.zero,
            size: Size.zero,
          ),
    );

    if (watermark.id == 'no-watermark' || watermark.properties!['text'] == '') {
      return SizedBox();
    }

    return Center(
      child: Opacity(
        opacity: watermark.properties!['opacity'] ?? 0.1,
        child: Transform.rotate(
          angle: (watermark.properties!['rotation'] ?? 45.0) * 3.14159 / 180,
          child: Text(
            watermark.properties!['text'] ?? 'WATERMARK',
            style: TextStyle(
              fontSize: watermark.properties!['fontSize'] ?? 64.0,
              color: _parseColor(watermark.properties!['color'] ?? '#CCCCCC'),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDraggableElement(
    ReportElement element,
    Map<String, dynamic> dynamicData,
  ) {
    if (element.type == ElementType.background ||
        element.type == ElementType.watermark) {
      return SizedBox();
    }

    // Apply binding with dynamic data if dataField is specified
    ReportElement bindedElement = element;
    if (element.dataField != null &&
        dynamicData.containsKey(element.dataField)) {
      Map<String, dynamic> updatedProps = Map<String, dynamic>.from(
        element.properties!,
      );

      // Apply data binding based on element type
      switch (element.type) {
        case ElementType.text:
        case ElementType.richText:
          updatedProps['content'] = dynamicData[element.dataField].toString();
          break;
        case ElementType.table:
          if (element.dataField == 'items' && dynamicData['items'] is List) {
            List items = dynamicData['items'] as List;
            List<List> tableData = [
              ['Item', 'Qty', 'Price', 'Total'], // Header row
            ];

            for (var item in items) {
              tableData.add([
                item['name'].toString(),
                item['qty'].toString(),
                item['price'].toString(),
                item['total'].toString(),
              ]);
            }
            updatedProps['data'] = tableData;
          }
          break;
        case ElementType.chart:
          if (element.dataField == 'chartData') {
            var chartData = dynamicData['chartData'];
            updatedProps['data'] = {
              'labels': chartData['labels'],
              'datasets': [
                {
                  'data': chartData['values'],
                  'color': updatedProps['data']['datasets'][0]['color'],
                },
              ],
            };
          }
          break;
        default:
          break;
      }

      bindedElement = element.copyWith(properties: updatedProps);
    }

    return Positioned(
      left: element.position.dx,
      top: element.position.dy,
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedElement = element;
          });
          widget.onElementSelected(element);
        },
        onPanStart: (details) {
          setState(() {
            isDragging = true;
            selectedElement = element;
            dragStart = details.localPosition;
            elementStartPosition = element.position;
          });
          widget.onElementSelected(element);
        },
        onPanUpdate: (details) {
          if (!isDragging || selectedElement?.id != element.id) return;

          final delta = details.localPosition - dragStart;
          final newPosition = elementStartPosition + delta;

          final updatedElement = element.copyWith(position: newPosition);
          widget.onElementUpdated(updatedElement);
        },
        onPanEnd: (details) {
          setState(() {
            isDragging = false;
          });
        },
        child: Stack(
          children: [
            Container(
              width: element.size.width,
              height: element.size.height,
              decoration: BoxDecoration(
                border:
                    selectedElement?.id == element.id
                        ? Border.all(color: Colors.blue, width: 1)
                        : null,
              ),
              child: _buildElementWidget(bindedElement),
            ),
            if (selectedElement?.id == element.id) _buildResizeHandles(element),
          ],
        ),
      ),
    );
  }

  Widget _buildResizeHandles(ReportElement element) {
    return Stack(
      children: [
        // Top-left handle
        _buildResizeHandle(element, Alignment.topLeft, ResizeDirection.topLeft),
        // Top-right handle
        _buildResizeHandle(
          element,
          Alignment.topRight,
          ResizeDirection.topRight,
        ),
        // Bottom-left handle
        _buildResizeHandle(
          element,
          Alignment.bottomLeft,
          ResizeDirection.bottomLeft,
        ),
        // Bottom-right handle
        _buildResizeHandle(
          element,
          Alignment.bottomRight,
          ResizeDirection.bottomRight,
        ),
      ],
    );
  }

  Widget _buildResizeHandle(
    ReportElement element,
    Alignment alignment,
    ResizeDirection direction,
  ) {
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: GestureDetector(
          onPanStart: (details) {
            setState(() {
              isResizing = true;
              resizeDirection = direction;
              resizeStartSize = element.size;
              elementStartPosition = element.position;
              dragStart = details.globalPosition;
            });
          },
          onPanUpdate: (details) {
            if (!isResizing) return;

            final delta = details.globalPosition - dragStart;
            Size newSize = element.size;
            Offset newPosition = element.position;

            switch (direction) {
              case ResizeDirection.topLeft:
                newSize = Size(
                  resizeStartSize!.width - delta.dx,
                  resizeStartSize!.height - delta.dy,
                );
                newPosition = Offset(
                  elementStartPosition.dx + delta.dx,
                  elementStartPosition.dy + delta.dy,
                );
                break;
              case ResizeDirection.topRight:
                newSize = Size(
                  resizeStartSize!.width + delta.dx,
                  resizeStartSize!.height - delta.dy,
                );
                newPosition = Offset(
                  elementStartPosition.dx,
                  elementStartPosition.dy + delta.dy,
                );
                break;
              case ResizeDirection.bottomLeft:
                newSize = Size(
                  resizeStartSize!.width - delta.dx,
                  resizeStartSize!.height + delta.dy,
                );
                newPosition = Offset(
                  elementStartPosition.dx + delta.dx,
                  elementStartPosition.dy,
                );
                break;
              case ResizeDirection.bottomRight:
                newSize = Size(
                  resizeStartSize!.width + delta.dx,
                  resizeStartSize!.height + delta.dy,
                );
                break;
            }

            // Ensure minimum size
            newSize = Size(max(50, newSize.width), max(30, newSize.height));

            final updatedElement = element.copyWith(
              size: newSize,
              position: newPosition,
            );
            widget.onElementUpdated(updatedElement);
          },
          onPanEnd: (details) {
            setState(() {
              isResizing = false;
              resizeDirection = null;
            });
          },
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.blue, width: 1),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildElementWidget(ReportElement element) {
    switch (element.type) {
      case ElementType.text:
        return TextElementWidget(element: element);
      case ElementType.richText:
        return RichTextElementWidget(element: element);
      case ElementType.image:
        return ImageElementWidget(element: element);
      case ElementType.chart:
        return ChartElementWidget(element: element);
      case ElementType.table:
        return TableElementWidget(element: element);
      case ElementType.watermark:
        return SizedBox(); // Handled separately at the page level
      case ElementType.background:
        return SizedBox(); // Handled separately at the page level
    }
  }

  void _addNewElement(ElementType elementType, Size pageSize) {
    // Calculate center position
    final centerX = (pageSize.width / 2) - 100;
    final centerY = (pageSize.height / 2) - 50;

    // Create default properties based on element type
    Map<String, dynamic> defaultProperties = {};
    Size defaultSize = Size(200, 100);

    switch (elementType) {
      case ElementType.text:
        defaultProperties = {
          'content': 'Text Element',
          'fontSize': 14.0,
          'fontWeight': 'normal',
          'color': '#000000',
        };
        defaultSize = Size(200, 50);
        break;
      case ElementType.richText:
        defaultProperties = {
          'content': 'Rich Text Element',
          'fontSize': 14.0,
          'formatting': [],
        };
        defaultSize = Size(300, 100);
        break;
      case ElementType.image:
        defaultProperties = {'source': 'placeholder'};
        defaultSize = Size(200, 150);
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
        };
        defaultSize = Size(300, 200);
        break;
      case ElementType.table:
        defaultProperties = {
          'data': [
            ['Header 1', 'Header 2', 'Header 3'],
            ['Row 1, Cell 1', 'Row 1, Cell 2', 'Row 1, Cell 3'],
            ['Row 2, Cell 1', 'Row 2, Cell 2', 'Row 2, Cell 3'],
          ],
        };
        defaultSize = Size(400, 200);
        break;
      case ElementType.watermark:
        defaultProperties = {
          'text': 'WATERMARK',
          'opacity': 0.1,
          'rotation': 45.0,
          'fontSize': 64.0,
          'color': '#CCCCCC',
        };
        defaultSize = Size.zero; // Size is managed differently for watermarks
        break;
      case ElementType.background:
        defaultProperties = {
          'type': 'color',
          'color': '#F9F9F9',
          'opacity': 1.0,
        };
        defaultSize = pageSize; // Full page size
        break;
    }

    // Create the new element
    final newElement = ReportElement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: elementType,
      properties: defaultProperties,
      position: Offset(centerX, centerY),
      size: defaultSize,
    );

    // Update the page with the new element
    _updatePageWithElement(newElement);
  }

  void _updatePageWithElement(ReportElement element) {
    final currentReport = widget.report;
    final currentPage = currentReport.pages[widget.pageIndex];

    // If the element is a background or watermark, replace any existing ones
    List<ReportElement> updatedElements = [...currentPage.elements];

    if (element.type == ElementType.background ||
        element.type == ElementType.watermark) {
      updatedElements.removeWhere((e) => e.type == element.type);
    }

    updatedElements.add(element);

    final updatedPage = ReportPage(
      id: currentPage.id,
      elements: updatedElements,
      paperSize: currentPage.paperSize,
      pageSettings: currentPage.pageSettings,
    );

    final updatedPages = [...currentReport.pages];
    updatedPages[widget.pageIndex] = updatedPage;

    final updatedReport = Report(
      id: currentReport.id,
      title: currentReport.title,
      pages: updatedPages,
      defaultPaperSize: currentReport.defaultPaperSize,
      continuousPaper: currentReport.continuousPaper,
      reportSettings: currentReport.reportSettings,
    );

    // Update the report in the provider
    ref.read(currentReportProvider.notifier).state = updatedReport;
    ref.read(reportsProvider.notifier).updateReport(updatedReport);
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
      case PaperSize.tabloid:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  Color _parseColor(String hexColor, {double opacity = 1.0}) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return Color(int.parse(hexColor, radix: 16)).withValues(alpha: opacity);
  }
}

enum ResizeDirection { topLeft, topRight, bottomLeft, bottomRight }

// Updated Element Widgets that Support Data Binding

class RichTextElementWidget extends StatelessWidget {
  final ReportElement element;
  final Map<String, dynamic>? data;
  final bool editable;

  const RichTextElementWidget({
    super.key,
    required this.element,
    this.data,
    this.editable = true,
  });

  @override
  Widget build(BuildContext context) {
    final properties = element.properties;
    final rawContent =
        properties!['content'] as String? ?? '<p>Rich Text Element</p>';
    final fontSize = properties!['fontSize'] as double? ?? 14.0;
    final textColor = _parseColor(properties!['color'] ?? '#000000');

    // Process dynamic data if available and not in edit mode
    final content =
        !editable && data != null
            ? _resolveDataVariables(rawContent, data!)
            : rawContent;

    return Container(
      width: element.size.width,
      height: element.size.height,
      padding: EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        border: editable ? Border.all(color: Colors.grey.shade300) : null,
      ),
      child: SingleChildScrollView(
        child: Html(
          data: content,
          style: {
            'body': Style(
              fontSize: FontSize(fontSize),
              color: textColor,
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
            ),
          },
        ),
      ),
    );
  }

  // Helper method to resolve data variables in text
  String _resolveDataVariables(String text, Map<String, dynamic> data) {
    // Replace variables in the format {{variableName}} with data values
    final regex = RegExp(r'\{\{(.*?)\}\}');
    return text.replaceAllMapped(regex, (match) {
      final variable = match.group(1)?.trim();
      if (variable != null && data.containsKey(variable)) {
        return data[variable].toString();
      }
      return match.group(0) ?? '';
    });
  }

  Color _parseColor(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}

// Element Properties Panel to Bind Dynamic Data
class ElementPropertiesPanel extends ConsumerWidget {
  final ReportElement? selectedElement;
  final Function(ReportElement) onElementUpdated;

  const ElementPropertiesPanel({
    Key? key,
    required this.selectedElement,
    required this.onElementUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (selectedElement == null) {
      return Card(
        elevation: 0,
        color: Colors.grey.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'No element selected',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  'Select an element on the canvas to edit its properties',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Get available data fields
    final dynamicData = ref.watch(dynamicDataProvider);
    final dataFields = ['None', ...dynamicData.keys.toList()];

    return ListView(
      shrinkWrap: true,
      children: [
        // Element Type
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            '${selectedElement!.type.toString().split('.').last} Properties',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),

        // Position and Size
        ExpansionTile(
          title: Text('Position & Size'),
          initiallyExpanded: true,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'X',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      controller: TextEditingController(
                        text: selectedElement!.position.dx.toStringAsFixed(0),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          final newX =
                              double.tryParse(value) ??
                              selectedElement!.position.dx;
                          onElementUpdated(
                            selectedElement!.copyWith(
                              position: Offset(
                                newX,
                                selectedElement!.position.dy,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Y',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      controller: TextEditingController(
                        text: selectedElement!.position.dy.toStringAsFixed(0),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          final newY =
                              double.tryParse(value) ??
                              selectedElement!.position.dy;
                          onElementUpdated(
                            selectedElement!.copyWith(
                              position: Offset(
                                selectedElement!.position.dx,
                                newY,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Width',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      controller: TextEditingController(
                        text: selectedElement!.size.width.toStringAsFixed(0),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          final newWidth =
                              double.tryParse(value) ??
                              selectedElement!.size.width;
                          onElementUpdated(
                            selectedElement!.copyWith(
                              size: Size(
                                newWidth,
                                selectedElement!.size.height,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Height',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      controller: TextEditingController(
                        text: selectedElement!.size.height.toStringAsFixed(0),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          final newHeight =
                              double.tryParse(value) ??
                              selectedElement!.size.height;
                          onElementUpdated(
                            selectedElement!.copyWith(
                              size: Size(
                                selectedElement!.size.width,
                                newHeight,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Data Binding
        ExpansionTile(
          title: Text('Data Binding'),
          initiallyExpanded: true,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: DropdownButtonFormField(
                decoration: InputDecoration(
                  labelText: 'Bind to Data Field',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                value: selectedElement!.dataField ?? 'None',
                items:
                    dataFields.map((field) {
                      return DropdownMenuItem(value: field, child: Text(field));
                    }).toList(),
                onChanged: (newValue) {
                  onElementUpdated(
                    selectedElement!.copyWith(
                      dataField: newValue == 'None' ? null : newValue,
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        // Element-specific properties
        _buildElementSpecificProperties(),

        Divider(height: 24),

        // Delete button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ElevatedButton.icon(
            icon: Icon(Icons.delete, color: Colors.white),
            label: Text(
              'Delete Element',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () {
              _deleteSelectedElement(ref);
            },
          ),
        ),
      ],
    );
  }

  void _deleteSelectedElement(WidgetRef ref) {
    if (selectedElement == null) return;

    final currentReport = ref.read(currentReportProvider);
    if (currentReport == null) return;

    final pageIndex = ref.read(currentPageIndexProvider);
    final currentPage = currentReport.pages[pageIndex];

    final updatedElements =
        currentPage.elements
            .where((element) => element.id != selectedElement!.id)
            .toList();

    final updatedPage = ReportPage(
      id: currentPage.id,
      elements: updatedElements,
      paperSize: currentPage.paperSize,
      pageSettings: currentPage.pageSettings,
    );

    final updatedPages = [...currentReport.pages];
    updatedPages[pageIndex] = updatedPage;

    final updatedReport = currentReport.copyWith(pages: updatedPages);

    ref.read(currentReportProvider.notifier).state = updatedReport;
    ref.read(reportsProvider.notifier).updateReport(updatedReport);

    // Clear selection
    ref.read(selectedElementProvider.notifier).state = null;
  }

  Widget _buildElementSpecificProperties() {
    if (selectedElement == null) return SizedBox();

    switch (selectedElement!.type) {
      case ElementType.text:
        return _buildTextProperties();
      case ElementType.richText:
        return _buildRichTextProperties();
      case ElementType.image:
        return _buildImageProperties();
      case ElementType.chart:
        return _buildChartProperties();
      case ElementType.table:
        return _buildTableProperties();
      case ElementType.watermark:
        return _buildWatermarkProperties();
      case ElementType.background:
        return _buildBackgroundProperties();
      default:
        return SizedBox();
    }
  }

  Widget _buildTextProperties() {
    final properties = selectedElement!.properties;

    return ExpansionTile(
      title: Text('Text Properties'),
      initiallyExpanded: true,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Content',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            controller: TextEditingController(
              text: properties!['content'] ?? '',
            ),
            maxLines: 5,
            minLines: 1,
            onChanged: (value) {
              final updatedProps = Map<String, dynamic>.from(properties);
              updatedProps['content'] = value;
              onElementUpdated(
                selectedElement!.copyWith(properties: updatedProps),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Font Size',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  controller: TextEditingController(
                    text: (properties!['fontSize'] ?? 14.0).toString(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      final newFontSize = double.tryParse(value) ?? 14.0;
                      final updatedProps = Map<String, dynamic>.from(
                        properties,
                      );
                      updatedProps['fontSize'] = newFontSize;
                      onElementUpdated(
                        selectedElement!.copyWith(properties: updatedProps),
                      );
                    }
                  },
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField(
                  decoration: InputDecoration(
                    labelText: 'Font Weight',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  value: properties!['fontWeight'] ?? 'normal',
                  items:
                      ['normal', 'bold'].map((weight) {
                        return DropdownMenuItem(
                          value: weight,
                          child: Text(weight),
                        );
                      }).toList(),
                  onChanged: (newValue) {
                    final updatedProps = Map<String, dynamic>.from(properties);
                    updatedProps['fontWeight'] = newValue;
                    onElementUpdated(
                      selectedElement!.copyWith(properties: updatedProps),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Text Color',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    suffixIcon: Container(
                      width: 24,
                      height: 24,
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _parseColor(properties!['color'] ?? '#000000'),
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  controller: TextEditingController(
                    text: properties!['color'] ?? '#000000',
                  ),
                  onChanged: (value) {
                    final updatedProps = Map<String, dynamic>.from(properties);
                    updatedProps['color'] = value;
                    onElementUpdated(
                      selectedElement!.copyWith(properties: updatedProps),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: DropdownButtonFormField(
            decoration: InputDecoration(
              labelText: 'Text Alignment',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            value: properties!['textAlign'] ?? 'left',
            items:
                ['left', 'center', 'right', 'justify'].map((alignment) {
                  return DropdownMenuItem(
                    value: alignment,
                    child: Text(alignment),
                  );
                }).toList(),
            onChanged: (newValue) {
              final updatedProps = Map<String, dynamic>.from(properties);
              updatedProps['textAlign'] = newValue;
              onElementUpdated(
                selectedElement!.copyWith(properties: updatedProps),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRichTextProperties() {
    final properties = selectedElement!.properties;

    return ExpansionTile(
      title: Text('Rich Text Properties'),
      initiallyExpanded: true,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Content',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              helperText:
                  'Use the formatting options below to style selected text',
            ),
            controller: TextEditingController(
              text: properties!['content'] ?? '',
            ),
            maxLines: 5,
            minLines: 2,
            onChanged: (value) {
              final updatedProps = Map<String, dynamic>.from(properties);
              updatedProps['content'] = value;
              onElementUpdated(
                selectedElement!.copyWith(properties: updatedProps),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Font Size',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            controller: TextEditingController(
              text: (properties!['fontSize'] ?? 14.0).toString(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              if (value.isNotEmpty) {
                final newFontSize = double.tryParse(value) ?? 14.0;
                final updatedProps = Map<String, dynamic>.from(properties);
                updatedProps['fontSize'] = newFontSize;
                onElementUpdated(
                  selectedElement!.copyWith(properties: updatedProps),
                );
              }
            },
          ),
        ),

        // A more advanced rich text editor would be implemented here
        // For now, this is a simplified representation
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Formatting Tools',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'This would include a rich text formatting toolbar with options for:',
              ),
              SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• Bold, Italic, Underline formatting'),
                    Text('• Text color selection'),
                    Text('• Highlighting'),
                    Text('• Alignment options'),
                    Text('• List formatting'),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'The formatting is applied to selected text and stored in the "formatting" array property',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageProperties() {
    final properties = selectedElement!.properties;

    return ExpansionTile(
      title: Text('Image Properties'),
      initiallyExpanded: true,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: DropdownButtonFormField(
            decoration: InputDecoration(
              labelText: 'Source Type',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            value: properties!['sourceType'] ?? 'url',
            items:
                ['url', 'file', 'placeholder'].map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
            onChanged: (newValue) {
              final updatedProps = Map<String, dynamic>.from(properties);
              updatedProps['sourceType'] = newValue;
              onElementUpdated(
                selectedElement!.copyWith(properties: updatedProps),
              );
            },
          ),
        ),
        if (properties!['sourceType'] == 'url' ||
            properties!['sourceType'] == null)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Image URL',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              controller: TextEditingController(text: properties!['url'] ?? ''),
              onChanged: (value) {
                final updatedProps = Map<String, dynamic>.from(properties);
                updatedProps['url'] = value;
                onElementUpdated(
                  selectedElement!.copyWith(properties: updatedProps),
                );
              },
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: DropdownButtonFormField(
            decoration: InputDecoration(
              labelText: 'Fit',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            value: properties!['fit'] ?? 'contain',
            items:
                [
                  'fill',
                  'contain',
                  'cover',
                  'fitWidth',
                  'fitHeight',
                  'none',
                ].map((fit) {
                  return DropdownMenuItem(value: fit, child: Text(fit));
                }).toList(),
            onChanged: (newValue) {
              final updatedProps = Map<String, dynamic>.from(properties);
              updatedProps['fit'] = newValue;
              onElementUpdated(
                selectedElement!.copyWith(properties: updatedProps),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Border Width',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  controller: TextEditingController(
                    text: (properties!['borderWidth'] ?? 0.0).toString(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      final borderWidth = double.tryParse(value) ?? 0.0;
                      final updatedProps = Map<String, dynamic>.from(
                        properties,
                      );
                      updatedProps['borderWidth'] = borderWidth;
                      onElementUpdated(
                        selectedElement!.copyWith(properties: updatedProps),
                      );
                    }
                  },
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Border Color',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    suffixIcon: Container(
                      width: 24,
                      height: 24,
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _parseColor(
                          properties!['borderColor'] ?? '#000000',
                        ),
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  controller: TextEditingController(
                    text: properties!['borderColor'] ?? '#000000',
                  ),
                  onChanged: (value) {
                    final updatedProps = Map<String, dynamic>.from(properties);
                    updatedProps['borderColor'] = value;
                    onElementUpdated(
                      selectedElement!.copyWith(properties: updatedProps),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Border Radius',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            controller: TextEditingController(
              text: (properties!['borderRadius'] ?? 0.0).toString(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              if (value.isNotEmpty) {
                final borderRadius = double.tryParse(value) ?? 0.0;
                final updatedProps = Map<String, dynamic>.from(properties);
                updatedProps['borderRadius'] = borderRadius;
                onElementUpdated(
                  selectedElement!.copyWith(properties: updatedProps),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChartProperties() {
    final properties = selectedElement!.properties;

    return ExpansionTile(
      title: Text('Chart Properties'),
      initiallyExpanded: true,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: DropdownButtonFormField(
            decoration: InputDecoration(
              labelText: 'Chart Type',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            value: properties!['type'] ?? 'bar',
            items:
                ['bar', 'line', 'pie', 'radar', 'scatter'].map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
            onChanged: (newValue) {
              final updatedProps = Map<String, dynamic>.from(properties);
              updatedProps['type'] = newValue;
              onElementUpdated(
                selectedElement!.copyWith(properties: updatedProps),
              );
            },
          ),
        ),

        // Chart data editor would be implemented here
        // For now, this is a simplified representation
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Chart Data', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('This would include an interface for:'),
              SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• Editing labels (x-axis values)'),
                    Text('• Adding/removing data series'),
                    Text('• Editing values for each data point'),
                    Text('• Customizing colors for each series'),
                    Text('• Setting other chart options'),
                  ],
                ),
              ),
              SizedBox(height: 8),
              ElevatedButton.icon(
                icon: Icon(Icons.edit),
                label: Text('Edit Chart Data'),
                onPressed: () {
                  // Would open a chart data editor dialog
                },
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: CheckboxListTile(
            title: Text('Show Legend'),
            value: properties!['showLegend'] ?? true,
            contentPadding: EdgeInsets.zero,
            onChanged: (value) {
              final updatedProps = Map<String, dynamic>.from(properties);
              updatedProps['showLegend'] = value;
              onElementUpdated(
                selectedElement!.copyWith(properties: updatedProps),
              );
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Chart Title',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            controller: TextEditingController(text: properties!['title'] ?? ''),
            onChanged: (value) {
              final updatedProps = Map<String, dynamic>.from(properties);
              updatedProps['title'] = value;
              onElementUpdated(
                selectedElement!.copyWith(properties: updatedProps),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTableProperties() {
    final properties = selectedElement!.properties;
    final tableData =
        properties!['data'] as List<List>? ??
        [
          [''],
        ];

    return ExpansionTile(
      title: Text('Table Properties'),
      initiallyExpanded: true,
      children: [
        // Table editor would be implemented here
        // For now, this is a simplified representation
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Table Data', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(
                'Current table size: ${tableData.length} rows × ${tableData[0].length} columns',
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.add),
                    label: Text('Add Row'),
                    onPressed: () {
                      final updatedProps = Map<String, dynamic>.from(
                        properties,
                      );
                      final updatedData = List<List>.from(tableData);

                      // Add a new row with empty cells
                      updatedData.add(
                        List.generate(tableData[0].length, (index) => ''),
                      );

                      updatedProps['data'] = updatedData;
                      onElementUpdated(
                        selectedElement!.copyWith(properties: updatedProps),
                      );
                    },
                  ),
                  SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: Icon(Icons.add),
                    label: Text('Add Column'),
                    onPressed: () {
                      final updatedProps = Map<String, dynamic>.from(
                        properties,
                      );
                      final updatedData = List<List>.from(tableData);

                      // Add a new column to each row
                      for (int i = 0; i < updatedData.length; i++) {
                        updatedData[i] = [...updatedData[i], ''];
                      }

                      updatedProps['data'] = updatedData;
                      onElementUpdated(
                        selectedElement!.copyWith(properties: updatedProps),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 8),
              ElevatedButton.icon(
                icon: Icon(Icons.edit_outlined),
                label: Text('Edit Table Data'),
                onPressed: () {
                  // Would open a table editor dialog
                },
              ),
            ],
          ),
        ),

        Divider(),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Border Width',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  controller: TextEditingController(
                    text: (properties!['borderWidth'] ?? 1.0).toString(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      final borderWidth = double.tryParse(value) ?? 1.0;
                      final updatedProps = Map<String, dynamic>.from(
                        properties,
                      );
                      updatedProps['borderWidth'] = borderWidth;
                      onElementUpdated(
                        selectedElement!.copyWith(properties: updatedProps),
                      );
                    }
                  },
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Border Color',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    suffixIcon: Container(
                      width: 24,
                      height: 24,
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _parseColor(
                          properties!['borderColor'] ?? '#000000',
                        ),
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  controller: TextEditingController(
                    text: properties!['borderColor'] ?? '#000000',
                  ),
                  onChanged: (value) {
                    final updatedProps = Map<String, dynamic>.from(properties);
                    updatedProps['borderColor'] = value;
                    onElementUpdated(
                      selectedElement!.copyWith(properties: updatedProps),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: CheckboxListTile(
            title: Text('Show Header Row'),
            value: properties!['showHeader'] ?? true,
            contentPadding: EdgeInsets.zero,
            onChanged: (value) {
              final updatedProps = Map<String, dynamic>.from(properties);
              updatedProps['showHeader'] = value;
              onElementUpdated(
                selectedElement!.copyWith(properties: updatedProps),
              );
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: CheckboxListTile(
            title: Text('Alternating Row Colors'),
            value: properties!['alternatingColors'] ?? false,
            contentPadding: EdgeInsets.zero,
            onChanged: (value) {
              final updatedProps = Map<String, dynamic>.from(properties);
              updatedProps['alternatingColors'] = value;
              onElementUpdated(
                selectedElement!.copyWith(properties: updatedProps),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWatermarkProperties() {
    final properties = selectedElement!.properties;

    return ExpansionTile(
      title: Text('Watermark Properties'),
      initiallyExpanded: true,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Watermark Text',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            controller: TextEditingController(
              text: properties!['text'] ?? 'WATERMARK',
            ),
            onChanged: (value) {
              final updatedProps = Map<String, dynamic>.from(properties);
              updatedProps['text'] = value;
              onElementUpdated(
                selectedElement!.copyWith(properties: updatedProps),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Opacity',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  controller: TextEditingController(
                    text: (properties!['opacity'] ?? 0.1).toString(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      final opacity = double.tryParse(value) ?? 0.1;
                      final updatedProps = Map<String, dynamic>.from(
                        properties,
                      );
                      updatedProps['opacity'] = opacity.clamp(0.0, 1.0);
                      onElementUpdated(
                        selectedElement!.copyWith(properties: updatedProps),
                      );
                    }
                  },
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Rotation (degrees)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  controller: TextEditingController(
                    text: (properties!['rotation'] ?? 45.0).toString(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      final rotation = double.tryParse(value) ?? 45.0;
                      final updatedProps = Map<String, dynamic>.from(
                        properties,
                      );
                      updatedProps['rotation'] = rotation;
                      onElementUpdated(
                        selectedElement!.copyWith(properties: updatedProps),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Font Size',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  controller: TextEditingController(
                    text: (properties!['fontSize'] ?? 64.0).toString(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      final fontSize = double.tryParse(value) ?? 64.0;
                      final updatedProps = Map<String, dynamic>.from(
                        properties,
                      );
                      updatedProps['fontSize'] = fontSize;
                      onElementUpdated(
                        selectedElement!.copyWith(properties: updatedProps),
                      );
                    }
                  },
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Color',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    suffixIcon: Container(
                      width: 24,
                      height: 24,
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _parseColor(properties!['color'] ?? '#CCCCCC'),
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  controller: TextEditingController(
                    text: properties!['color'] ?? '#CCCCCC',
                  ),
                  onChanged: (value) {
                    final updatedProps = Map<String, dynamic>.from(properties);
                    updatedProps['color'] = value;
                    onElementUpdated(
                      selectedElement!.copyWith(properties: updatedProps),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundProperties() {
    final properties = selectedElement!.properties;

    return ExpansionTile(
      title: Text('Background Properties'),
      initiallyExpanded: true,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: DropdownButtonFormField(
            decoration: InputDecoration(
              labelText: 'Background Type',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            value: properties!['type'] ?? 'color',
            items:
                ['color', 'image'].map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
            onChanged: (newValue) {
              final updatedProps = Map<String, dynamic>.from(properties);
              updatedProps['type'] = newValue;
              onElementUpdated(
                selectedElement!.copyWith(properties: updatedProps),
              );
            },
          ),
        ),

        if (properties!['type'] == 'color' || properties!['type'] == null)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Background Color',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      suffixIcon: Container(
                        width: 24,
                        height: 24,
                        margin: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _parseColor(properties!['color'] ?? '#FFFFFF'),
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    controller: TextEditingController(
                      text: properties!['color'] ?? '#FFFFFF',
                    ),
                    onChanged: (value) {
                      final updatedProps = Map<String, dynamic>.from(
                        properties,
                      );
                      updatedProps['color'] = value;
                      onElementUpdated(
                        selectedElement!.copyWith(properties: updatedProps),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

        if (properties!['type'] == 'image')
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Image URL',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              controller: TextEditingController(text: properties!['url'] ?? ''),
              onChanged: (value) {
                final updatedProps = Map<String, dynamic>.from(properties);
                updatedProps['url'] = value;
                onElementUpdated(
                  selectedElement!.copyWith(properties: updatedProps),
                );
              },
            ),
          ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Opacity',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            controller: TextEditingController(
              text: (properties!['opacity'] ?? 1.0).toString(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              if (value.isNotEmpty) {
                final opacity = double.tryParse(value) ?? 1.0;
                final updatedProps = Map<String, dynamic>.from(properties);
                updatedProps['opacity'] = opacity.clamp(0.0, 1.0);
                onElementUpdated(
                  selectedElement!.copyWith(properties: updatedProps),
                );
              }
            },
          ),
        ),
      ],
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

// Element Widget Implementations
class TextElementWidget extends StatelessWidget {
  final ReportElement element;
  final Map<String, dynamic>? data;
  final bool editable;

  const TextElementWidget({
    super.key,
    required this.element,
    this.data,
    this.editable = true,
  });

  @override
  Widget build(BuildContext context) {
    final properties = element.properties;
    final rawContent = properties!['content'] as String? ?? 'Text Element';
    final fontSize = properties!['fontSize'] as double? ?? 14.0;
    final fontWeight =
        properties!['fontWeight'] == 'bold'
            ? FontWeight.bold
            : FontWeight.normal;
    final color = _parseColor(properties!['color'] ?? '#000000');
    final textAlign = _getTextAlign(properties!['textAlign']);

    // Process dynamic data if available and not in edit mode
    final content =
        !editable && data != null
            ? _resolveDataVariables(rawContent, data!)
            : rawContent;

    return Container(
      width: element.size.width,
      height: element.size.height,
      padding: EdgeInsets.all(4.0),
      child: Text(
        content,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        ),
        textAlign: textAlign,
        overflow: TextOverflow.clip,
      ),
    );
  }

  // Helper method to resolve data variables in text
  String _resolveDataVariables(String text, Map<String, dynamic> data) {
    // Replace variables in the format {{variableName}} with data values
    final regex = RegExp(r'\{\{(.*?)\}\}');
    return text.replaceAllMapped(regex, (match) {
      final variable = match.group(1)?.trim();
      if (variable != null && data.containsKey(variable)) {
        return data[variable].toString();
      }
      return match.group(0) ?? '';
    });
  }

  TextAlign _getTextAlign(String? align) {
    switch (align) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      case 'justify':
        return TextAlign.justify;
      case 'left':
      default:
        return TextAlign.left;
    }
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
  final Map<String, dynamic>? data;
  final bool editable;

  const ImageElementWidget({
    super.key,
    required this.element,
    this.data,
    this.editable = true,
  });

  @override
  Widget build(BuildContext context) {
    final properties = element.properties;
    final sourceType = properties!['sourceType'] ?? 'url';
    final fit = _getBoxFit(properties!['fit'] ?? 'contain');
    final borderWidth = properties!['borderWidth'] as double? ?? 0.0;
    final borderColor = _parseColor(properties!['borderColor'] ?? '#000000');
    final borderRadius = properties!['borderRadius'] as double? ?? 0.0;

    return Container(
      width: element.size.width,
      height: element.size.height,
      decoration: BoxDecoration(
        border:
            borderWidth > 0
                ? Border.all(color: borderColor, width: borderWidth)
                : null,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: _buildImageWidget(sourceType, properties, fit),
      ),
    );
  }

  Widget _buildImageWidget(
    String sourceType,
    Map<String, dynamic> properties,
    BoxFit fit,
  ) {
    // Process dynamic data if available and not in edit mode
    String url = '';
    if (sourceType == 'url') {
      url = properties!['url'] as String? ?? '';

      // If we have data and we're not in edit mode, check for variables in the URL
      if (!editable && data != null && url.contains('{{')) {
        url = _resolveDataVariables(url, data!);
      }
    }

    switch (sourceType) {
      case 'url':
        if (url.isEmpty) {
          return _buildPlaceholder();
        }
        return Image.network(
          url,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder();
          },
        );
      case 'file':
        // In a real app, this would use a file path from storage
        // We can also check for data-based file paths here
        final filePath = properties!['filePath'] as String? ?? '';
        final resolvedPath =
            !editable && data != null
                ? _resolveDataVariables(filePath, data!)
                : filePath;

        if (resolvedPath.isEmpty) {
          return _buildPlaceholder();
        }

        // In a real implementation, you'd verify the file exists
        // This is just a placeholder
        return _buildPlaceholder();
      case 'data':
        // When image comes from data binding
        if (!editable && data != null) {
          final imageKey = properties!['dataKey'] as String? ?? '';
          if (data!.containsKey(imageKey) && data![imageKey] is String) {
            // Assuming data[imageKey] is a URL or file path
            // You could also support base64 encoded images
            return Image.network(
              data![imageKey],
              fit: fit,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholder();
              },
            );
          }
        }
        return _buildPlaceholder();
      case 'placeholder':
      default:
        return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(Icons.image, size: 48, color: Colors.grey.shade400),
      ),
    );
  }

  // Helper method to resolve data variables in text
  String _resolveDataVariables(String text, Map<String, dynamic> data) {
    // Replace variables in the format {{variableName}} with data values
    final regex = RegExp(r'\{\{(.*?)\}\}');
    return text.replaceAllMapped(regex, (match) {
      final variable = match.group(1)?.trim();
      if (variable != null && data.containsKey(variable)) {
        return data[variable].toString();
      }
      return match.group(0) ?? '';
    });
  }

  BoxFit _getBoxFit(String fit) {
    switch (fit) {
      case 'fill':
        return BoxFit.fill;
      case 'contain':
        return BoxFit.contain;
      case 'cover':
        return BoxFit.cover;
      case 'fitWidth':
        return BoxFit.fitWidth;
      case 'fitHeight':
        return BoxFit.fitHeight;
      case 'none':
        return BoxFit.none;
      default:
        return BoxFit.contain;
    }
  }

  Color _parseColor(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}

class TableElementWidget extends StatelessWidget {
  final ReportElement element;
  final Map<String, dynamic>? data;
  final bool editable;

  const TableElementWidget({
    super.key,
    required this.element,
    this.data,
    this.editable = true,
  });

  @override
  Widget build(BuildContext context) {
    final properties = element.properties;
    List<List> tableData =
        properties!['data'] as List<List>? ??
        [
          ['Header 1', 'Header 2', 'Header 3'],
          ['Cell 1', 'Cell 2', 'Cell 3'],
        ];

    // If we have data binding and not in edit mode, process the table data
    if (!editable && data != null) {
      // First check if there's a dataSource property that points to a data array
      final dataSource = properties!['dataSource'] as String?;
      if (dataSource != null &&
          data!.containsKey(dataSource) &&
          data![dataSource] is List) {
        // Handle data sourced from an array in the data map
        tableData = _processDataSourceTable(data![dataSource], properties);
      } else {
        // Otherwise process each cell for variables
        tableData = _processTableCells(tableData, data!);
      }
    }

    final borderWidth = properties!['borderWidth'] as double? ?? 1.0;
    final borderColor = _parseColor(properties!['borderColor'] ?? '#000000');
    final showHeader = properties!['showHeader'] as bool? ?? true;
    final alternatingColors =
        properties!['alternatingColors'] as bool? ?? false;

    return Container(
      width: element.size.width,
      height: element.size.height,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: SingleChildScrollView(
        child: Table(
          border: TableBorder.all(color: borderColor, width: borderWidth),
          defaultColumnWidth: IntrinsicColumnWidth(),
          children: _buildTableRows(
            tableData,
            showHeader,
            alternatingColors,
            borderColor,
          ),
        ),
      ),
    );
  }

  // Process table data where each cell may contain variables
  List<List> _processTableCells(
    List<List> tableData,
    Map<String, dynamic> data,
  ) {
    return tableData.map((row) {
      return row.map((cell) => _resolveDataVariables(cell, data)).toList();
    }).toList();
  }

  // Process table data from a data source array
  List<List> _processDataSourceTable(
    dynamic dataSource,
    Map<String, dynamic> properties,
  ) {
    if (dataSource is! List) {
      return [
        ['No data'],
      ];
    }

    // Get column definitions
    final columns = properties!['columns'] as List<Map<String, dynamic>>? ?? [];
    if (columns.isEmpty) {
      return [
        ['No columns defined'],
      ];
    }

    // Create header row
    final List<List> result = [
      columns.map((col) => col['title'] as String? ?? 'Column').toList(),
    ];

    // Create data rows
    for (var item in dataSource) {
      if (item is Map) {
        final List row = [];
        for (var col in columns) {
          final field = col['field'] as String?;
          if (field != null && item.containsKey(field)) {
            row.add(item[field].toString());
          } else {
            row.add('');
          }
        }
        result.add(row);
      }
    }

    return result;
  }

  List<TableRow> _buildTableRows(
    List<List> data,
    bool showHeader,
    bool alternatingColors,
    Color borderColor,
  ) {
    List<TableRow> rows = [];

    for (int i = 0; i < data.length; i++) {
      final isHeader = i == 0 && showHeader;
      final isEvenRow = i % 2 == 0;

      Color? rowColor;
      if (isHeader) {
        rowColor = Colors.grey.shade200;
      } else if (alternatingColors && !isEvenRow) {
        rowColor = Colors.grey.shade50;
      }

      rows.add(
        TableRow(
          decoration: BoxDecoration(color: rowColor),
          children:
              data[i].map((cell) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    cell,
                    style: TextStyle(
                      fontWeight:
                          isHeader ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
        ),
      );
    }

    return rows;
  }

  // Helper method to resolve data variables in text
  String _resolveDataVariables(String text, Map<String, dynamic> data) {
    // Replace variables in the format {{variableName}} with data values
    final regex = RegExp(r'\{\{(.*?)\}\}');
    return text.replaceAllMapped(regex, (match) {
      final variable = match.group(1)?.trim();
      if (variable != null && data.containsKey(variable)) {
        return data[variable].toString();
      }
      return match.group(0) ?? '';
    });
  }

  Color _parseColor(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}

class ChartElementWidget extends StatelessWidget {
  final ReportElement element;
  final Map<String, dynamic>? data;
  final bool editable;

  const ChartElementWidget({
    super.key,
    required this.element,
    this.data,
    this.editable = true,
  });

  @override
  Widget build(BuildContext context) {
    final properties = element.properties;
    final chartType = properties!['type'] as String? ?? 'bar';

    // Get chart data either directly from properties or from the data binding
    Map<String, dynamic> chartData =
        properties!['data'] as Map<String, dynamic>? ??
        {'labels': [], 'datasets': []};

    // If we have data binding and not in edit mode, process the chart data
    if (!editable && data != null) {
      final dataSource = properties!['dataSource'] as String?;
      if (dataSource != null && data!.containsKey(dataSource)) {
        // Use data binding to get chart data
        chartData = _processChartData(data![dataSource], chartType, properties);
      }
    }

    final showLegend = properties!['showLegend'] as bool? ?? true;
    final title = properties!['title'] as String? ?? '';
    final resolvedTitle =
        !editable && data != null ? _resolveDataVariables(title, data!) : title;

    return Container(
      width: element.size.width,
      height: element.size.height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: _buildChartWidget(chartType, chartData, showLegend, resolvedTitle),
    );
  }

  Widget _buildChartWidget(
    String chartType,
    Map<String, dynamic> chartData,
    bool showLegend,
    String title,
  ) {
    // In a real implementation, you would render different chart types
    // using a charting library like fl_chart

    // This is a placeholder implementation that shows how you'd integrate with fl_chart
    return Column(
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        Expanded(child: _buildChartByType(chartType, chartData)),
        if (showLegend)
          Container(
            padding: EdgeInsets.all(8),
            color: Colors.grey.shade100,
            child: _buildLegend(chartData),
          ),
      ],
    );
  }

  Widget _buildChartByType(String chartType, Map<String, dynamic> chartData) {
    switch (chartType) {
      case 'line':
        return _buildLineChart(chartData);
      case 'bar':
        return _buildBarChart(chartData);
      case 'pie':
        return _buildPieChart(chartData);
      case 'scatter':
        return _buildScatterChart(chartData);
      default:
        return _buildPlaceholder(chartType);
    }
  }

  Widget _buildPlaceholder(String chartType) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_getChartIcon(chartType), size: 48, color: Colors.blue),
          SizedBox(height: 8),
          Text(
            '$chartType Chart',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            'Placeholder for $chartType chart',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // Sample implementation for line chart
  Widget _buildLineChart(Map<String, dynamic> chartData) {
    // Check if we have the necessary data for a line chart
    final labels = chartData['labels'] as List<dynamic>? ?? [];
    final datasets = chartData['datasets'] as List<dynamic>? ?? [];

    if (labels.isEmpty || datasets.isEmpty) {
      return _buildPlaceholder('line');
    }

    // In a real implementation, you would convert the data to LineChartData
    // This is a simplified version
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(show: true),
          borderData: FlBorderData(show: true),
          // In a real implementation, you would convert datasets to line chart spots
          lineBarsData:
              datasets.map<LineChartBarData>((dataset) {
                final data = dataset['data'] as List<dynamic>? ?? [];
                final color = _parseColor(dataset['color'] ?? '#1976D2');

                return LineChartBarData(
                  spots: List.generate(
                    data.length,
                    (i) => FlSpot(
                      i.toDouble(),
                      (data[i] is num) ? data[i].toDouble() : 0.0,
                    ),
                  ),
                  isCurved: true,
                  color: color,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(show: false),
                );
              }).toList(),
        ),
      ),
    );
  }

  // Sample implementation for bar chart
  Widget _buildBarChart(Map<String, dynamic> chartData) {
    // Similar to line chart, but would use BarChart from fl_chart
    return _buildPlaceholder('bar');
  }

  // Sample implementation for pie chart
  Widget _buildPieChart(Map<String, dynamic> chartData) {
    // Similar implementation using PieChart from fl_chart
    return _buildPlaceholder('pie');
  }

  // Sample implementation for scatter chart
  Widget _buildScatterChart(Map<String, dynamic> chartData) {
    // Similar implementation using ScatterChart from fl_chart
    return _buildPlaceholder('scatter');
  }

  // Build chart legend
  Widget _buildLegend(Map<String, dynamic> chartData) {
    final datasets = chartData['datasets'] as List<dynamic>? ?? [];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          datasets.map<Widget>((dataset) {
            final label = dataset['label'] as String? ?? 'Series';
            final color = _parseColor(dataset['color'] ?? '#1976D2');

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Container(width: 12, height: 12, color: color),
                  SizedBox(width: 4),
                  Text(label),
                ],
              ),
            );
          }).toList(),
    );
  }

  // Process chart data from data binding
  Map<String, dynamic> _processChartData(
    dynamic sourceData,
    String chartType,
    Map<String, dynamic> properties,
  ) {
    // Default structure
    Map<String, dynamic> result = {'labels': [], 'datasets': []};

    // We need to handle different data formats based on chart type
    switch (chartType) {
      case 'pie':
        if (sourceData is List) {
          // For pie charts, we need a single dataset with multiple values
          final labelField = properties!['labelField'] as String? ?? 'label';
          final valueField = properties!['valueField'] as String? ?? 'value';
          final colorField = properties!['colorField'] as String? ?? 'color';

          List labels = [];
          List<double> values = [];
          List colors = [];

          for (var item in sourceData) {
            if (item is Map) {
              labels.add(item[labelField]?.toString() ?? '');
              values.add(
                item[valueField] is num
                    ? (item[valueField] as num).toDouble()
                    : 0.0,
              );
              colors.add(item[colorField]?.toString() ?? '#1976D2');
            }
          }

          result['labels'] = labels;
          result['datasets'] = [
            {'label': 'Dataset', 'data': values, 'backgroundColor': colors},
          ];
        }
        break;

      case 'line':
      case 'bar':
      default:
        if (sourceData is Map) {
          // For line/bar charts with multiple datasets
          final labels = sourceData['labels'] as List<dynamic>? ?? [];
          final datasets = sourceData['datasets'] as List<dynamic>? ?? [];

          result['labels'] = labels;
          result['datasets'] = datasets;
        } else if (sourceData is List) {
          // For line/bar charts with a single dataset
          final xField = properties!['xField'] as String? ?? 'x';
          final yField = properties!['yField'] as String? ?? 'y';

          List labels = [];
          List<double> values = [];

          for (var item in sourceData) {
            if (item is Map) {
              labels.add(item[xField]?.toString() ?? '');
              values.add(
                item[yField] is num ? (item[yField] as num).toDouble() : 0.0,
              );
            }
          }

          result['labels'] = labels;
          result['datasets'] = [
            {
              'label': properties!['seriesLabel'] ?? 'Series',
              'data': values,
              'color': properties!['seriesColor'] ?? '#1976D2',
            },
          ];
        }
        break;
    }

    return result;
  }

  // Helper method to resolve data variables in text
  String _resolveDataVariables(String text, Map<String, dynamic> data) {
    // Replace variables in the format {{variableName}} with data values
    final regex = RegExp(r'\{\{(.*?)\}\}');
    return text.replaceAllMapped(regex, (match) {
      final variable = match.group(1)?.trim();
      if (variable != null && data.containsKey(variable)) {
        return data[variable].toString();
      }
      return match.group(0) ?? '';
    });
  }

  IconData _getChartIcon(String chartType) {
    switch (chartType) {
      case 'line':
        return Icons.show_chart;
      case 'pie':
        return Icons.pie_chart;
      case 'radar':
        return Icons.radar;
      case 'scatter':
        return Icons.scatter_plot;
      case 'bar':
      default:
        return Icons.bar_chart;
    }
  }

  Color _parseColor(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}

// Export Functionality
class ReportExporter {
  final Report report;

  ReportExporter(this.report);

  Future<Uint8List> exportToPdf() async {
    // In a real application, you would use a PDF library like pdf or printing
    // This is a placeholder implementation
    await Future.delayed(Duration(seconds: 1)); // Simulate processing time

    // Return dummy data
    return Uint8List.fromList([0, 1, 2, 3, 4]);
  }

  Future<Uint8List> exportToDocx() async {
    // In a real application, you would use a DOCX library like docx
    // This is a placeholder implementation
    await Future.delayed(Duration(seconds: 1)); // Simulate processing time

    // Return dummy data
    return Uint8List.fromList([0, 1, 2, 3, 4]);
  }

  Future<void> saveFile(Uint8List bytes, String fileName) async {
    // Use file_picker or path_provider to save the file
    // This is a placeholder implementation
    print('Saving $fileName with ${bytes.length} bytes');
  }
}

// Export Options Dialog
class ExportOptionsDialog extends StatefulWidget {
  final Report report;
  final Function(ExportFormat, ExportOptions) onExport;

  const ExportOptionsDialog({
    super.key,
    required this.report,
    required this.onExport,
  });

  @override
  _ExportOptionsDialogState createState() => _ExportOptionsDialogState();
}

class _ExportOptionsDialogState extends State<ExportOptionsDialog> {
  String _selectedFormat = 'pdf';
  bool _isExporting = false;
  bool _includeWatermark = true;
  bool _exportAllPages = true;
  List<int> _selectedPages = [];

  @override
  void initState() {
    super.initState();
    _selectedPages = List.generate(
      widget.report.pages.length,
      (index) => index,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Export Report'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Format'),
            Row(
              children: [
                Radio(
                  value: 'pdf',
                  groupValue: _selectedFormat,
                  onChanged: (value) {
                    setState(() {
                      _selectedFormat = value!;
                    });
                  },
                ),
                Text('PDF'),
                SizedBox(width: 16),
                Radio(
                  value: 'docx',
                  groupValue: _selectedFormat,
                  onChanged: (value) {
                    setState(() {
                      _selectedFormat = value!;
                    });
                  },
                ),
                Text('DOCX'),
              ],
            ),
            SizedBox(height: 16),
            Text('Pages'),
            Row(
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: _exportAllPages,
                  onChanged: (value) {
                    setState(() {
                      _exportAllPages = value!;
                      if (_exportAllPages) {
                        _selectedPages = List.generate(
                          widget.report.pages.length,
                          (index) => index,
                        );
                      }
                    });
                  },
                ),
                Text('All Pages'),
                SizedBox(width: 16),
                Radio<bool>(
                  value: false,
                  groupValue: _exportAllPages,
                  onChanged: (value) {
                    setState(() {
                      _exportAllPages = value!;
                    });
                  },
                ),
                Text('Select Pages'),
              ],
            ),
            if (!_exportAllPages)
              Container(
                height: 200,
                margin: EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListView.builder(
                  itemCount: widget.report.pages.length,
                  itemBuilder: (context, index) {
                    return CheckboxListTile(
                      title: Text('Page ${index + 1}'),
                      value: _selectedPages.contains(index),
                      onChanged: (value) {
                        setState(() {
                          if (value!) {
                            _selectedPages.add(index);
                          } else {
                            _selectedPages.remove(index);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            SizedBox(height: 16),
            CheckboxListTile(
              title: Text('Include Watermark'),
              value: _includeWatermark,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) {
                setState(() {
                  _includeWatermark = value!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isExporting ? null : _exportReport,
          child:
              _isExporting
                  ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : Text('Export'),
        ),
      ],
    );
  }

  void _exportReport() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final exporter = ReportExporter(widget.report);

      Uint8List bytes;
      String fileName = widget.report.title.replaceAll(' ', '_').toLowerCase();

      if (_selectedFormat == 'pdf') {
        bytes = await exporter.exportToPdf();
        fileName = '$fileName.pdf';
      } else {
        bytes = await exporter.exportToDocx();
        fileName = '$fileName.docx';
      }

      await exporter.saveFile(bytes, fileName);

      // Inform the user
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Report exported as $fileName')));

      Navigator.of(context).pop();
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }
}

// Main Report Editor Screen
class ReportEditorScreen extends ConsumerStatefulWidget {
  final String reportId;

  const ReportEditorScreen({super.key, required this.reportId});

  @override
  _ReportEditorScreenState createState() => _ReportEditorScreenState();
}

class _ReportEditorScreenState extends ConsumerState<ReportEditorScreen> {
  ReportElement? selectedElement;
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load the report
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportsNotifier = ref.read(reportsProvider.notifier);
      final report = reportsNotifier.getReportById(widget.reportId);
      if (report != null) {
        ref.read(currentReportProvider.notifier).state = report;
        ref.read(currentPageIndexProvider.notifier).state = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final report = ref.watch(currentReportProvider);
    final pageIndex = ref.watch(currentPageIndexProvider);
    final selectedElementId = ref.watch(selectedElementProvider);

    if (report == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Report Editor')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(report.title),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            tooltip: 'Save Report',
            onPressed: _saveReport,
          ),
          IconButton(
            icon: Icon(Icons.file_download),
            tooltip: 'Export Report',
            onPressed: _showExportDialog,
          ),
          IconButton(
            icon: Icon(Icons.settings),
            tooltip: 'Report Settings',
            onPressed: _showReportSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildToolbar(),
          Expanded(
            child: Row(
              children: [
                _buildElementPalette(),
                Expanded(child: _buildReportCanvas(report, pageIndex)),
                _buildPropertiesPanel(report, pageIndex, selectedElementId),
              ],
            ),
          ),
          _buildPageControls(report),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          TextButton.icon(
            icon: Icon(Icons.add),
            label: Text('Add Page'),
            onPressed: _addNewPage,
          ),
          VerticalDivider(width: 24, thickness: 1),
          TextButton.icon(
            icon: Icon(Icons.delete_outline),
            label: Text('Delete Page'),
            onPressed: _deleteCurrentPage,
          ),
          VerticalDivider(width: 24, thickness: 1),
          TextButton.icon(
            icon: Icon(Icons.copy),
            label: Text('Duplicate Page'),
            onPressed: _duplicateCurrentPage,
          ),
          Spacer(),
          TextButton.icon(
            icon: Icon(Icons.preview),
            label: Text('Preview'),
            onPressed: _previewReport,
          ),
        ],
      ),
    );
  }

  Widget _buildElementPalette() {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Elements',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(8),
              children: [
                _buildDraggableElement(
                  'Text',
                  Icons.text_fields,
                  ElementType.text,
                ),
                _buildDraggableElement(
                  'Rich Text',
                  Icons.format_color_text,
                  ElementType.richText,
                ),
                _buildDraggableElement('Image', Icons.image, ElementType.image),
                _buildDraggableElement(
                  'Table',
                  Icons.table_chart,
                  ElementType.table,
                ),
                _buildDraggableElement(
                  'Chart',
                  Icons.bar_chart,
                  ElementType.chart,
                ),
                Divider(),
                _buildDraggableElement(
                  'Background',
                  Icons.format_color_fill,
                  ElementType.background,
                ),
                _buildDraggableElement(
                  'Watermark',
                  Icons.opacity,
                  ElementType.watermark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableElement(
    String name,
    IconData icon,
    ElementType elementType,
  ) {
    return Draggable<ElementType>(
      data: elementType,
      feedback: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 8),
            Text(name, style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      child: Card(
        elevation: 0,
        color: Colors.grey.shade50,
        margin: EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.blue),
              SizedBox(width: 12),
              Text(name),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportCanvas(Report report, int pageIndex) {
    if (report.pages.isEmpty) {
      return Center(child: Text('No pages available. Add a page to start.'));
    }

    return Center(
      child: DraggableReportCanvas(
        report: report,
        pageIndex: pageIndex,
        onElementSelected: (element) {
          ref.read(selectedElementProvider.notifier).state = element.id;
        },
        onElementUpdated: (updatedElement) {
          _updateElement(updatedElement);
        },
      ),
    );
  }

  Widget _buildPropertiesPanel(
    Report report,
    int pageIndex,
    String? selectedElementId,
  ) {
    ReportElement? selectedElement;

    if (selectedElementId != null && report.pages.isNotEmpty) {
      selectedElement = report.pages[pageIndex].elements.firstWhere(
        (element) => element.id == selectedElementId,
        orElse:
            () => ReportElement(
              id: '',
              type: ElementType.text,
              properties: {},
              position: const Offset(0, 0),
              size: const Size(0, 0),
            ),
      );
    }

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Colors.grey.shade300)),
      ),
      child: ElementPropertiesPanel(
        selectedElement: selectedElement,
        onElementUpdated: _updateElement,
      ),
    );
  }

  Widget _buildPageControls(Report report) {
    final pageCount = report.pages.length;
    final currentIndex = ref.watch(currentPageIndexProvider);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.first_page),
            onPressed:
                currentIndex > 0
                    ? () {
                      ref.read(currentPageIndexProvider.notifier).state = 0;
                    }
                    : null,
          ),
          IconButton(
            icon: Icon(Icons.navigate_before),
            onPressed:
                currentIndex > 0
                    ? () {
                      ref.read(currentPageIndexProvider.notifier).state =
                          currentIndex - 1;
                    }
                    : null,
          ),
          SizedBox(width: 24),
          Text('Page ${currentIndex + 1} of $pageCount'),
          SizedBox(width: 24),
          IconButton(
            icon: Icon(Icons.navigate_next),
            onPressed:
                currentIndex < pageCount - 1
                    ? () {
                      ref.read(currentPageIndexProvider.notifier).state =
                          currentIndex + 1;
                    }
                    : null,
          ),
          IconButton(
            icon: Icon(Icons.last_page),
            onPressed:
                currentIndex < pageCount - 1
                    ? () {
                      ref.read(currentPageIndexProvider.notifier).state =
                          pageCount - 1;
                    }
                    : null,
          ),
        ],
      ),
    );
  }

  void _updateElement(ReportElement updatedElement) {
    final report = ref.read(currentReportProvider);
    final pageIndex = ref.read(currentPageIndexProvider);

    if (report == null || pageIndex >= report.pages.length) return;

    final currentPage = report.pages[pageIndex];
    final elementIndex = currentPage.elements.indexWhere(
      (e) => e.id == updatedElement.id,
    );

    if (elementIndex >= 0) {
      final reportsNotifier = ref.read(reportsProvider.notifier);
      final updatedPage = currentPage.copyWith(
        elements: List.from(currentPage.elements)
          ..[elementIndex] = updatedElement,
      );

      final updatedReport = report.copyWith(
        pages: List.from(report.pages)..[pageIndex] = updatedPage,
      );

      ref.read(currentReportProvider.notifier).state = updatedReport;
      reportsNotifier.updateReport(updatedReport);
    }
  }

  void _addNewPage() {
    const uuid = Uuid();
    final report = ref.read(currentReportProvider);
    if (report == null) return;

    final reportsNotifier = ref.read(reportsProvider.notifier);
    final newPage = ReportPage(
      id: uuid.v4(),
      name: 'Page ${report.pages.length + 1}',
      elements: [],
      paperSize: report.defaultPaperSize,
      orientation: report.defaultOrientation,
      pageSettings: {},
    );

    final updatedReport = report.copyWith(
      pages: List.from(report.pages)..add(newPage),
    );

    ref.read(currentReportProvider.notifier).state = updatedReport;
    ref.read(currentPageIndexProvider.notifier).state =
        updatedReport.pages.length - 1;
    reportsNotifier.updateReport(updatedReport);
  }

  void _deleteCurrentPage() {
    final report = ref.read(currentReportProvider);
    final pageIndex = ref.read(currentPageIndexProvider);

    if (report == null || report.pages.length <= 1) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cannot delete the last page')));
      return;
    }

    final reportsNotifier = ref.read(reportsProvider.notifier);
    final updatedPages = List.from(report.pages)..removeAt(pageIndex);
    final updatedReport = report.copyWith(
      pages: List<ReportPage>.from(updatedPages),
    );

    ref.read(currentReportProvider.notifier).state = updatedReport;
    ref.read(currentPageIndexProvider.notifier).state =
        pageIndex >= updatedPages.length ? updatedPages.length - 1 : pageIndex;
    ref.read(selectedElementProvider.notifier).state = null;

    reportsNotifier.updateReport(updatedReport);
  }

  void _duplicateCurrentPage() {
    const uuid = Uuid();
    final report = ref.read(currentReportProvider);
    final pageIndex = ref.read(currentPageIndexProvider);

    if (report == null || pageIndex >= report.pages.length) return;

    final currentPage = report.pages[pageIndex];
    final duplicatedElements =
        currentPage.elements.map((e) => e.copyWith(id: uuid.v4())).toList();

    final duplicatedPage = currentPage.copyWith(
      id: uuid.v4(),
      name: '${currentPage.name} (Copy)',
      elements: duplicatedElements,
    );

    List<ReportPage> updatedPages = List.from(report.pages)
      ..insert(pageIndex + 1, duplicatedPage);
    final updatedReport = report.copyWith(pages: updatedPages);

    final reportsNotifier = ref.read(reportsProvider.notifier);
    ref.read(currentReportProvider.notifier).state = updatedReport;
    ref.read(currentPageIndexProvider.notifier).state = pageIndex + 1;
    ref.read(selectedElementProvider.notifier).state = null;

    reportsNotifier.updateReport(updatedReport);
  }

  void _saveReport() async {
    final report = ref.read(currentReportProvider);
    if (report == null) return;

    final reportsNotifier = ref.read(reportsProvider.notifier);
    reportsNotifier.updateReport(report);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report saved successfully'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showExportDialog() {
    final report = ref.read(currentReportProvider);
    if (report == null) return;

    showDialog(
      context: context,
      builder:
          (context) => ExportOptionsDialog(
            report: report,
            onExport: (exportFormat, options) {
              _exportReport(exportFormat, options);
              Navigator.of(context).pop();
            },
          ),
    );
  }

  void _exportReport(ExportFormat format, ExportOptions options) async {
    final report = ref.read(currentReportProvider);
    if (report == null) return;

    try {
      final exportService = ref.read(exportServiceProvider);
      final filePath = await exportService.exportReport(
        report: report,
        format: format,
        options: options,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report exported successfully to: $filePath'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () {
              launchUrl(Uri.file(filePath));
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export report: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showReportSettings() {
    final report = ref.read(currentReportProvider);
    if (report == null) return;

    showDialog(
      context: context,
      builder:
          (context) => ReportSettingsDialog(
            report: report,
            onSave: (updatedReport) {
              final reportsNotifier = ref.read(reportsProvider.notifier);
              ref.read(currentReportProvider.notifier).state = updatedReport;
              reportsNotifier.updateReport(updatedReport);
              Navigator.of(context).pop();
            },
          ),
    );
  }

  void _previewReport() {
    final report = ref.read(currentReportProvider);
    if (report == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReportPreviewScreen(report: report),
      ),
    );
  }
}

// Report Settings Dialog
class ReportSettingsDialog extends StatefulWidget {
  final Report report;
  final Function(Report) onSave;

  const ReportSettingsDialog({
    Key? key,
    required this.report,
    required this.onSave,
  }) : super(key: key);

  @override
  _ReportSettingsDialogState createState() => _ReportSettingsDialogState();
}

class _ReportSettingsDialogState extends State<ReportSettingsDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late PaperSize _defaultPaperSize;
  late Orientation _defaultOrientation;
  late bool _continuousPaper;
  late bool _showPageNumbers;
  late String _headerTemplate;
  late String _footerTemplate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.report.title);
    _descriptionController = TextEditingController(
      text: widget.report.description,
    );
    _defaultPaperSize = widget.report.defaultPaperSize;
    _defaultOrientation = widget.report.defaultOrientation;
    _continuousPaper = widget.report.continuousPaper;
    _showPageNumbers = widget.report.showPageNumbers;
    _headerTemplate = widget.report.headerTemplate ?? '';
    _footerTemplate = widget.report.footerTemplate ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Report Settings'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 600,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Report Title',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              Text(
                'Default Paper Size',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<PaperSize>(
                value: _defaultPaperSize,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                items:
                    PaperSize.values.map((paperSize) {
                      return DropdownMenuItem(
                        value: paperSize,
                        child: Text(paperSizeToString(paperSize)),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _defaultPaperSize = value;
                    });
                  }
                },
              ),
              SizedBox(height: 16),
              Text(
                'Default Orientation',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              SegmentedButton<Orientation>(
                segments: [
                  ButtonSegment(
                    value: Orientation.portrait,
                    label: Text('Portrait'),
                    icon: Icon(Icons.stay_current_portrait),
                  ),
                  ButtonSegment(
                    value: Orientation.landscape,
                    label: Text('Landscape'),
                    icon: Icon(Icons.stay_current_landscape),
                  ),
                ],
                selected: {_defaultOrientation},
                onSelectionChanged: (Set<Orientation> selected) {
                  setState(() {
                    _defaultOrientation = selected.first;
                  });
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SwitchListTile(
                      title: Text('Continuous Paper'),
                      subtitle: Text('Print as a single continuous document'),
                      value: _continuousPaper,
                      onChanged: (value) {
                        setState(() {
                          _continuousPaper = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: SwitchListTile(
                      title: Text('Show Page Numbers'),
                      subtitle: Text('Add page numbers to the output'),
                      value: _showPageNumbers,
                      onChanged: (value) {
                        setState(() {
                          _showPageNumbers = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Header Template',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText:
                      'Enter header template. Use {{page}} for page number, {{date}} for current date.',
                ),
                //initialValue: _headerTemplate,
                onChanged: (value) {
                  _headerTemplate = value;
                },
              ),
              SizedBox(height: 16),
              Text(
                'Footer Template',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText:
                      'Enter footer template. Use {{page}} for page number, {{total}} for total pages.',
                ),
                controller: TextEditingController(text: _footerTemplate),
                onChanged: (value) {
                  _footerTemplate = value;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final updatedReport = widget.report.copyWith(
              title: _titleController.text,
              description: _descriptionController.text,
              defaultPaperSize: _defaultPaperSize,
              defaultOrientation: _defaultOrientation,
              continuousPaper: _continuousPaper,
              showPageNumbers: _showPageNumbers,
              headerTemplate: _headerTemplate.isEmpty ? null : _headerTemplate,
              footerTemplate: _footerTemplate.isEmpty ? null : _footerTemplate,
            );
            widget.onSave(updatedReport);
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}

// Report Preview Screen
class ReportPreviewScreen extends ConsumerStatefulWidget {
  final Report report;

  const ReportPreviewScreen({super.key, required this.report});

  @override
  _ReportPreviewScreenState createState() => _ReportPreviewScreenState();
}

class _ReportPreviewScreenState extends ConsumerState<ReportPreviewScreen> {
  int currentPageIndex = 0;
  double zoomLevel = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preview: ${widget.report.title}'),
        actions: [
          IconButton(
            icon: Icon(Icons.file_download),
            tooltip: 'Export',
            onPressed: _exportReport,
          ),
          IconButton(
            icon: Icon(Icons.print),
            tooltip: 'Print',
            onPressed: _printReport,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildToolbar(),
          Expanded(child: Center(child: _buildPreviewPage())),
          _buildPageControls(),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.zoom_out),
            onPressed: () {
              setState(() {
                zoomLevel = max(0.5, zoomLevel - 0.1);
              });
            },
          ),
          Slider(
            value: zoomLevel,
            min: 0.5,
            max: 2.0,
            divisions: 15,
            label: '${(zoomLevel * 100).round()}%',
            onChanged: (value) {
              setState(() {
                zoomLevel = value;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.zoom_in),
            onPressed: () {
              setState(() {
                zoomLevel = min(2.0, zoomLevel + 0.1);
              });
            },
          ),
          SizedBox(width: 24),
          ToggleButtons(
            isSelected: [
              widget.report.defaultOrientation == Orientation.portrait,
              widget.report.defaultOrientation == Orientation.landscape,
            ],
            onPressed: null, // Read-only in preview mode
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stay_current_portrait),
                    SizedBox(height: 4),
                    Text('Portrait'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stay_current_landscape),
                    SizedBox(height: 4),
                    Text('Landscape'),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(width: 24),
          Text(paperSizeToString(widget.report.defaultPaperSize)),
        ],
      ),
    );
  }

  Widget _buildPreviewPage() {
    if (widget.report.pages.isEmpty) {
      return Center(child: Text('No pages available'));
    }

    if (currentPageIndex >= widget.report.pages.length) {
      currentPageIndex = 0;
    }

    final page = widget.report.pages[currentPageIndex];

    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 3.0,
      boundaryMargin: EdgeInsets.all(100),
      child: Transform.scale(
        scale: zoomLevel,
        child: Container(
          width: getPaperWidth(page.paperSize, page.orientation),
          height: getPaperHeight(page.paperSize, page.orientation),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: ReportPageRenderer(
            page: page,
            pageNumber: currentPageIndex + 1,
            totalPages: widget.report.pages.length,
            showPageNumbers: widget.report.showPageNumbers,
            headerTemplate: widget.report.headerTemplate,
            footerTemplate: widget.report.footerTemplate,
            data: {}, // In preview mode, we don't have dynamic data
          ),
        ),
      ),
    );
  }

  Widget _buildPageControls() {
    final pageCount = widget.report.pages.length;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.first_page),
            onPressed:
                currentPageIndex > 0
                    ? () {
                      setState(() {
                        currentPageIndex = 0;
                      });
                    }
                    : null,
          ),
          IconButton(
            icon: Icon(Icons.navigate_before),
            onPressed:
                currentPageIndex > 0
                    ? () {
                      setState(() {
                        currentPageIndex--;
                      });
                    }
                    : null,
          ),
          SizedBox(width: 24),
          Text('Page ${currentPageIndex + 1} of $pageCount'),
          SizedBox(width: 24),
          IconButton(
            icon: Icon(Icons.navigate_next),
            onPressed:
                currentPageIndex < pageCount - 1
                    ? () {
                      setState(() {
                        currentPageIndex++;
                      });
                    }
                    : null,
          ),
          IconButton(
            icon: Icon(Icons.last_page),
            onPressed:
                currentPageIndex < pageCount - 1
                    ? () {
                      setState(() {
                        currentPageIndex = pageCount - 1;
                      });
                    }
                    : null,
          ),
        ],
      ),
    );
  }

  void _exportReport() {
    showDialog(
      context: context,
      builder:
          (context) => ExportOptionsDialog(
            report: widget.report,
            onExport: (exportFormat, options) async {
              Navigator.of(context).pop();

              try {
                final exportService = ref.read(exportServiceProvider);
                final filePath = await exportService.exportReport(
                  report: widget.report,
                  format: exportFormat,
                  options: options,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Report exported successfully to: $filePath'),
                    behavior: SnackBarBehavior.floating,
                    action: SnackBarAction(
                      label: 'Open',
                      onPressed: () {
                        launchUrl(Uri.file(filePath));
                      },
                    ),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to export report: ${e.toString()}'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
    );
  }

  void _printReport() async {
    try {
      final printService = ref.read(printServiceProvider);
      await printService.printReport(widget.report);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report sent to printer'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to print report: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Report Page Renderer
class ReportPageRenderer extends StatelessWidget {
  final ReportPage page;
  final int pageNumber;
  final int totalPages;
  final bool showPageNumbers;
  final String? headerTemplate;
  final String? footerTemplate;
  final Map<String, dynamic> data;

  const ReportPageRenderer({
    Key? key,
    required this.page,
    required this.pageNumber,
    required this.totalPages,
    this.showPageNumbers = true,
    this.headerTemplate,
    this.footerTemplate,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background elements
        ...page.elements
            .where(
              (element) =>
                  element.type == ElementType.background ||
                  element.type == ElementType.watermark,
            )
            .map(
              (element) => Positioned(
                left: element.position.dx,
                top: element.position.dy,
                child: _buildElementWidget(element),
              ),
            ),

        // Header
        if (headerTemplate != null)
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            height: 40,
            child: _buildHeader(),
          ),

        // Footer
        if (footerTemplate != null || showPageNumbers)
          Positioned(
            left: 0,
            bottom: 0,
            right: 0,
            height: 40,
            child: _buildFooter(),
          ),

        // Regular elements
        ...page.elements
            .where(
              (element) =>
                  element.type != ElementType.background &&
                  element.type != ElementType.watermark,
            )
            .map(
              (element) => Positioned(
                left: element.position.dx,
                top: element.position.dy,
                child: _buildElementWidget(element),
              ),
            ),
      ],
    );
  }

  Widget _buildElementWidget(ReportElement element) {
    switch (element.type) {
      case ElementType.text:
        return TextElementWidget(element: element, data: data, editable: false);
      case ElementType.richText:
        return RichTextElementWidget(
          element: element,
          data: data,
          editable: false,
        );
      case ElementType.image:
        return ImageElementWidget(
          element: element,
          data: data,
          editable: false,
        );
      case ElementType.table:
        return TableElementWidget(
          element: element,
          data: data,
          editable: false,
        );
      case ElementType.chart:
        return ChartElementWidget(
          element: element,
          data: data,
          editable: false,
        );
      case ElementType.background:
        return BackgroundElementWidget(
          element: element,
          pageSize: Size(
            getPaperWidth(page.paperSize, page.orientation),
            getPaperHeight(page.paperSize, page.orientation),
          ),
        );
      case ElementType.watermark:
        return WatermarkElementWidget(
          element: element,
          pageSize: Size(
            getPaperWidth(page.paperSize, page.orientation),
            getPaperHeight(page.paperSize, page.orientation),
          ),
        );
      default:
        return Container();
    }
  }

  Widget _buildHeader() {
    if (headerTemplate == null) return SizedBox();

    final processedText = _processTemplate(headerTemplate!);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      alignment: Alignment.center,
      child: Text(
        processedText,
        style: TextStyle(fontSize: 10, color: Colors.grey),
      ),
    );
  }

  Widget _buildFooter() {
    String processedText = '';

    if (footerTemplate != null) {
      processedText = _processTemplate(footerTemplate!);
    } else if (showPageNumbers) {
      processedText = 'Page $pageNumber of $totalPages';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      alignment: Alignment.center,
      child: Text(
        processedText,
        style: TextStyle(fontSize: 10, color: Colors.grey),
      ),
    );
  }

  String _processTemplate(String template) {
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';

    return template
        .replaceAll('{{page}}', pageNumber.toString())
        .replaceAll('{{total}}', totalPages.toString())
        .replaceAll('{{date}}', dateStr);
  }
}

// Background Element Widget
class BackgroundElementWidget extends StatelessWidget {
  final ReportElement element;
  final Size pageSize;

  const BackgroundElementWidget({
    Key? key,
    required this.element,
    required this.pageSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        element.properties!['backgroundColor'] ?? Colors.white;
    final borderColor = element.properties!['borderColor'];
    final borderWidth = element.properties!['borderWidth'] ?? 0.0;
    final backgroundImage = element.properties!['backgroundImage'];

    return Container(
      width: pageSize.width,
      height: pageSize.height,
      decoration: BoxDecoration(
        color: backgroundColor,
        border:
            borderColor != null && borderWidth > 0
                ? Border.all(color: borderColor, width: borderWidth)
                : null,
        image:
            backgroundImage != null
                ? DecorationImage(
                  image: MemoryImage(backgroundImage),
                  fit: BoxFit.cover,
                  opacity: element.properties!['opacity'] ?? 1.0,
                )
                : null,
      ),
    );
  }
}

// Watermark Element Widget
class WatermarkElementWidget extends StatelessWidget {
  final ReportElement element;
  final Size pageSize;

  const WatermarkElementWidget({
    Key? key,
    required this.element,
    required this.pageSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final text = element.properties!['text'] ?? '';
    final textColor =
        element.properties!['textColor'] ?? Colors.grey.withValues(alpha: 0.2);
    final fontSize = element.properties!['fontSize'] ?? 60.0;
    final rotation = element.properties!['rotation'] ?? 45.0;
    final opacity = element.properties!['opacity'] ?? 0.2;
    final watermarkImage = element.properties!['watermarkImage'];

    return Container(
      width: pageSize.width,
      height: pageSize.height,
      alignment: Alignment.center,
      child: Opacity(
        opacity: opacity,
        child:
            watermarkImage != null
                ? Transform.rotate(
                  angle: rotation * pi / 180,
                  child: Image.memory(
                    watermarkImage,
                    fit: BoxFit.contain,
                    width: min(pageSize.width, pageSize.height) * 0.5,
                  ),
                )
                : Transform.rotate(
                  angle: rotation * pi / 180,
                  child: Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
      ),
    );
  }
}

// Helper function to get paper dimensions
double getPaperWidth(PaperSize size, Orientation orientation) {
  final dimensions = getPaperDimensions(size);
  return orientation == Orientation.portrait
      ? dimensions.width
      : dimensions.height;
}

double getPaperHeight(PaperSize size, Orientation orientation) {
  final dimensions = getPaperDimensions(size);
  return orientation == Orientation.portrait
      ? dimensions.height
      : dimensions.width;
}

Size getPaperDimensions(PaperSize size) {
  // Dimensions in points (1/72 inch)
  switch (size) {
    case PaperSize.a4:
      return Size(595, 842); // 210 x 297 mm
    case PaperSize.a3:
      return Size(842, 1191); // 297 x 420 mm
    case PaperSize.letter:
      return Size(612, 792); // 8.5 x 11 inches
    case PaperSize.legal:
      return Size(612, 1008); // 8.5 x 14 inches
    case PaperSize.tabloid:
      return Size(792, 1224); // 11 x 17 inches
    default:
      return Size(595, 842); // Default to A4
  }
}

String paperSizeToString(PaperSize size) {
  switch (size) {
    case PaperSize.a4:
      return 'A4 (210 × 297 mm)';
    case PaperSize.a3:
      return 'A3 (297 × 420 mm)';
    case PaperSize.letter:
      return 'Letter (8.5 × 11 in)';
    case PaperSize.legal:
      return 'Legal (8.5 × 14 in)';
    case PaperSize.tabloid:
      return 'Tabloid (11 × 17 in)';
    default:
      return 'Unknown';
  }
}

// Export Service Provider
final exportServiceProvider = Provider<ExportService>((ref) => ExportService());

// Export Service
class ExportService {
  Future exportReport({
    required Report report,
    required ExportFormat format,
    required ExportOptions options,
  }) async {
    // Create a temporary directory to store the export
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = '${report.title.replaceAll(' ', '_')}_$timestamp';

    String filePath;

    switch (format) {
      case ExportFormat.pdf:
        filePath = await _exportToPdf(report, options, tempDir, fileName);
        break;
      case ExportFormat.docx:
        filePath = await _exportToDocx(report, options, tempDir, fileName);
        break;
      default:
        throw Exception('Export format not supported');
    }

    return filePath;
  }

  Future _exportToPdf(
    Report report,
    ExportOptions options,
    Directory tempDir,
    String fileName,
  ) async {
    final pdfDocument = pw.Document();

    // Generate PDF content
    for (int i = 0; i < report.pages.length; i++) {
      final page = report.pages[i];

      pdfDocument.addPage(
        pw.Page(
          pageFormat: _getPdfPageFormat(page.paperSize, page.orientation),
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                // PDF content generation would go here
                // This would need to be implemented using the pdf package
                pw.Center(child: pw.Text('Page ${i + 1} content')),

                // Footer with page numbers if enabled
                if (report.showPageNumbers)
                  pw.Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: pw.Center(
                      child: pw.Text(
                        'Page ${i + 1} of ${report.pages.length}',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      );
    }

    // Save the PDF to a file
    final file = File('${tempDir.path}/$fileName.pdf');
    await file.writeAsBytes(await pdfDocument.save());

    return file.path;
  }

  PdfPageFormat _getPdfPageFormat(PaperSize size, Orientation orientation) {
    switch (size) {
      case PaperSize.a4:
        return orientation == Orientation.portrait
            ? PdfPageFormat.a4
            : PdfPageFormat.a4.landscape;
      case PaperSize.a3:
        return orientation == Orientation.portrait
            ? PdfPageFormat.a3
            : PdfPageFormat.a3.landscape;
      case PaperSize.letter:
        return orientation == Orientation.portrait
            ? PdfPageFormat.letter
            : PdfPageFormat.letter.landscape;
      case PaperSize.legal:
        return orientation == Orientation.portrait
            ? PdfPageFormat.legal
            : PdfPageFormat.legal.landscape;
      /* case PaperSize.tabloid:
        return orientation == Orientation.portrait
            ? PdfPageFormat.PageFormat(11 * 72.0, 17 * 72.0)
            : PdfPageFormat.PageFormat(17 * 72.0, 11 * 72.0); */
      default:
        return PdfPageFormat.a4;
    }
  }

  Future _exportToDocx(
    Report report,
    ExportOptions options,
    Directory tempDir,
    String fileName,
  ) async {
    final templateFile = await rootBundle.load('assets/template.docx');
    final docx = await DocxTemplate.fromBytes(
      templateFile.buffer.asUint8List(),
    );

    // Add title section
    /* docx.add(
      Section(
        children: [
          Paragraph(text: report.title, style: 'Heading1'),
          if (report.description.isNotEmpty)
            Paragraph(text: report.description, style: 'Normal'),
        ],
      ),
    );
 */
    // Create sections for each page
    for (int i = 0; i < report.pages.length; i++) {
      final page = report.pages[i];

      // Convert the page content to DOCX elements
      // This would require mapping each ReportElement to a DOCX element
      /*  final Section pageSection = Section(
        properties: SectionProperties(
          pageSize: _getDocxPageSize(page.paperSize, page.orientation),
        ),
        children: [
          // Header
          if (report.headerTemplate != null)
            Paragraph(
              text: _processTemplate(
                report.headerTemplate!,
                pageNumber: i + 1,
                totalPages: report.pages.length,
              ),
              style: 'Header',
            ),

          // Page content would be generated here
          Paragraph(text: 'Page ${i + 1} content', style: 'Normal'),

          // Footer
          if (report.showPageNumbers)
            Paragraph(
              text: 'Page ${i + 1} of ${report.pages.length}',
              style: 'Footer',
            ),
        ],
      );

      docx.sections.add(pageSection); */
    }

    // Save the DOCX to a file
    final file = File('${tempDir.path}/$fileName.docx');
    //await file.writeAsBytes(await docx.save());

    return file.path;
  }

  /* PageSize _getDocxPageSize(PaperSize size, Orientation orientation) {
    switch (size) {
      case PaperSize.a4:
        return orientation == Orientation.portrait
            ? PageSize.a4
            : PageSize(PageOrientation.landscape, 29.7, 21.0);
      case PaperSize.a3:
        return orientation == Orientation.portrait
            ? PageSize(PageOrientation.portrait, 29.7, 42.0)
            : PageSize(PageOrientation.landscape, 42.0, 29.7);
      case PaperSize.letter:
        return orientation == Orientation.portrait
            ? PageSize.letter
            : PageSize(PageOrientation.landscape, 27.9, 21.6);
      case PaperSize.legal:
        return orientation == Orientation.portrait
            ? PageSize(PageOrientation.portrait, 21.6, 35.6)
            : PageSize(PageOrientation.landscape, 35.6, 21.6);
      case PaperSize.tabloid:
        return orientation == Orientation.portrait
            ? PageSize(PageOrientation.portrait, 27.9, 43.2)
            : PageSize(PageOrientation.landscape, 43.2, 27.9);
      default:
        return PageSize.a4;
    }
  } */

  String _processTemplate(
    String template, {
    required int pageNumber,
    required int totalPages,
  }) {
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';

    return template
        .replaceAll('{{page}}', pageNumber.toString())
        .replaceAll('{{total}}', totalPages.toString())
        .replaceAll('{{date}}', dateStr);
  }
}

// Print Service
class PrintService {
  Future<void> printReport(Report report) async {
    // Create a temporary PDF file for printing
    final exportService = ExportService();
    final tempPdfPath = await exportService.exportReport(
      report: report,
      format: ExportFormat.pdf,
      options: ExportOptions(includeHeaderFooter: true, watermarkEnabled: true),
    );

    // Use the printing package to show the print dialog
    final pdfData = await File(tempPdfPath).readAsBytes();
    await Printing.sharePdf(bytes: pdfData, filename: '${report.title}.pdf');
  }
}

// Export Format Enum
enum ExportFormat { pdf, docx }

// Export Options
class ExportOptions {
  final bool includeHeaderFooter;
  final bool watermarkEnabled;
  final bool compressed;
  final bool protectDocument;
  final String? password;

  ExportOptions({
    this.includeHeaderFooter = true,
    this.watermarkEnabled = true,
    this.compressed = true,
    this.protectDocument = false,
    this.password,
  });
}

// Riverpod Providers
final reportsProvider = StateNotifierProvider<ReportsNotifier, List<Report>>((
  ref,
) {
  return ReportsNotifier();
});

final currentReportProvider = StateProvider<Report?>((ref) => null);

final currentPageIndexProvider = StateProvider<int>((ref) => 0);

final selectedElementProvider = StateProvider<String?>((ref) => null);

// Reports Notifier
class ReportsNotifier extends StateNotifier<List<Report>> {
  ReportsNotifier() : super([]) {
    _loadReports();
  }

  Future<void> _loadReports() async {
    final prefs = await SharedPreferences.getInstance();
    List reportsJson = [dummy]; //prefs.getStringList('reports') ?? [dummy];

    state =
        reportsJson.map((json) => Report.fromJson(jsonDecode(json))).toList();
  }

  Future<void> _saveReports() async {
    final prefs = await SharedPreferences.getInstance();
    final reportsJson =
        state.map((report) => jsonEncode(report.toJson())).toList();

    await prefs.setStringList('reports', reportsJson);
  }

  void addReport(Report report) {
    state = [...state, report];
    _saveReports();
  }

  void updateReport(Report updatedReport) {
    state =
        state
            .map(
              (report) =>
                  report.id == updatedReport.id ? updatedReport : report,
            )
            .toList();
    _saveReports();
  }

  void deleteReport(String reportId) {
    state = state.where((report) => report.id != reportId).toList();
    _saveReports();
  }

  Report? getReportById(String id) {
    try {
      return state.firstWhere((report) => report.id == id);
    } catch (e) {
      return null;
    }
  }
}

// Define the provider
final printServiceProvider = Provider<PrintService>((ref) {
  return PrintService();
});
/* 
class PrintService {
  // Generate and return PDF bytes
  Future<Uint8List> generatePdf({
    required List<ReportPage> pages,
    required PaperSize paperSize,
    required Map<String, dynamic> data,
    bool showPageNumbers = true,
    String? watermarkText,
  }) async {
    final pdf = pw.Document();
    
    // Create a PDF format based on paper size
    final format = _getPdfPageFormat(paperSize);
    
    // Process each page
    for (int i = 0; i < pages.length; i++) {
      final page = pages[i];
      
      pdf.addPage(
        pw.Page(
          pageFormat: format,
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                // Add background if exists
                if (page.backgroundImage != null)
                  pw.Positioned.fill(
                    child: pw.Image(
                      pw.MemoryImage(page.backgroundImage!),
                      fit: pw.BoxFit.cover,
                    ),
                  ),
                
                // Add watermark if specified
                if (watermarkText != null)
                  pw.Positioned.fill(
                    child: pw.Center(
                      child: pw.Transform.rotate(
                        angle: -0.5,
                        child: pw.Text(
                          watermarkText,
                          style: pw.TextStyle(
                            color: PdfColors.grey300,
                            fontSize: 60,
                          ),
                        ),
                      ),
                    ),
                  ),
                
                // Add all elements
                ...page.elements.map((element) => _buildPdfElement(element, data)),
                
                // Add page number if enabled
                if (showPageNumbers)
                  pw.Positioned(
                    bottom: 10,
                    right: 10,
                    child: pw.Text(
                      'Page ${i + 1} of ${pages.length}',
                      style: pw.TextStyle(
                        fontSize: 8,
                        color: PdfColors.grey,
                      ),
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
  
  // Export as PDF file
  Future<File> exportPdf({
    required List<ReportPage> pages,
    required PaperSize paperSize,
    required Map<String, dynamic> data,
    required String filename,
    bool showPageNumbers = true,
    String? watermarkText,
  }) async {
    final bytes = await generatePdf(
      pages: pages,
      paperSize: paperSize,
      data: data,
      showPageNumbers: showPageNumbers,
      watermarkText: watermarkText,
    );
    
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$filename.pdf';
    final file = File(path);
    await file.writeAsBytes(bytes);
    
    return file;
  }
  
  // Print the document
  Future<void> printReport({
    required List<ReportPage> pages,
    required PaperSize paperSize,
    required Map<String, dynamic> data,
    bool showPageNumbers = true,
    String? watermarkText,
  }) async {
    final bytes = await generatePdf(
      pages: pages,
      paperSize: paperSize,
      data: data,
      showPageNumbers: showPageNumbers,
      watermarkText: watermarkText,
    );
    
    await Printing.layoutPdf(
      onLayout: (_) => bytes,
    );
  }
  
  // Export as DOCX
  Future<File> exportDocx({
    required List<ReportPage> pages,
    required PaperSize paperSize,
    required Map<String, dynamic> data,
    required String filename,
  }) async {
    // In a real implementation, you would:
    // 1. Load a template DOCX file with placeholders
    // 2. Replace placeholders with actual data
    // 3. Save the file
    
    // This is a simplified version
    final docxTemplate = await DocxTemplate('assets/templates/report_template.docx');
    final content = Content();
    
    // Add data to content
    // This depends on your template structure, but might look like:
    content.add(TextContent('title', data['title'] ?? 'Report'));
    content.add(TextContent('date', DateTime.now().toString()));
    
    // Add tables, charts, etc. based on elements
    // ...
    
    final outputBytes = await docxTemplate.generate(content);
    
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$filename.docx';
    final file = File(path);
    await file.writeAsBytes(outputBytes!);
    
    return file;
  }
  
  // Helper method to convert ReportElement to PDF Widget
  pw.Widget _buildPdfElement(ReportElement element, Map<String, dynamic> data) {
    return pw.Positioned(
      left: element.position.dx,
      top: element.position.dy,
      width: element.size.width,
      height: element.size.height,
      child: _getPdfWidgetForElement(element, data),
    );
  }
  
  // Convert element to appropriate PDF widget
  pw.Widget _getPdfWidgetForElement(ReportElement element, Map<String, dynamic> data) {
    switch (element.type) {
      case ElementType.text:
        return _buildPdfTextElement(element, data);
      case ElementType.richText:
        return _buildPdfRichTextElement(element, data);
      case ElementType.image:
        return _buildPdfImageElement(element, data);
      case ElementType.table:
        return _buildPdfTableElement(element, data);
      case ElementType.chart:
        return _buildPdfChartElement(element, data);
      default:
        return pw.Container();
    }
  }
  
  // Build PDF text element
  pw.Widget _buildPdfTextElement(ReportElement element, Map<String, dynamic> data) {
    final properties = element.properties;
    final textContent = _resolveDataVariables(properties!['content'] ?? 'Text', data);
    final fontSize = properties!['fontSize'] as double? ?? 14.0;
    final fontWeight = properties!['fontWeight'] == 'bold' ? pw.FontWeight.bold : pw.FontWeight.normal;
    final hexColor = properties!['color'] ?? '#000000';
    final color = _parsePdfColor(hexColor);
    final textAlign = _getPdfTextAlign(properties!['textAlign']);
    
    return pw.Container(
      padding: pw.EdgeInsets.all(4.0),
      child: pw.Text(
        textContent,
        style: pw.TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        ),
        textAlign: textAlign,
      ),
    );
  }
  
  // Build PDF rich text element
  pw.Widget _buildPdfRichTextElement(ReportElement element, Map<String, dynamic> data) {
    // This would be more complex in a real implementation
    // Here's a simplified version
    final properties = element.properties;
    final htmlContent = _resolveDataVariables(properties!['content'] ?? '<p>Rich Text</p>', data);
    
    // For simplicity, we're just extracting plain text from HTML
    // In a real app, you'd want to parse HTML and create rich text spans
    final plainText = htmlContent.replaceAll(RegExp(r'<[^>]*>'), '');
    
    return pw.Container(
      padding: pw.EdgeInsets.all(4.0),
      child: pw.Text(plainText),
    );
  }
  
  // Build PDF image element
  pw.Widget _buildPdfImageElement(ReportElement element, Map<String, dynamic> data) {
    final properties = element.properties;
    final sourceType = properties!['sourceType'] ?? 'url';
    final fit = _getPdfBoxFit(properties!['fit'] ?? 'contain');
    
    // In reality, you'd need to handle network images, load them, and convert to PDF images
    // This is a simplified version
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
      ),
      child: pw.Center(
        child: pw.Text('Image Placeholder'),
      ),
    );
  }
  
  // Build PDF table element
  pw.Widget _buildPdfTableElement(ReportElement element, Map<String, dynamic> data) {
    final properties = element.properties;
    
    // Resolve data from variables if needed
    List<List> tableData = properties!['data'] as List<List>? ?? [
      ['Header 1', 'Header 2', 'Header 3'],
      ['Cell 1', 'Cell 2', 'Cell 3'],
    ];
    
    // Process data variables in cells
    tableData = tableData.map((row) {
      return row.map((cell) => _resolveDataVariables(cell, data)).toList();
    }).toList();
    
    final borderWidth = properties!['borderWidth'] as double? ?? 1.0;
    final showHeader = properties!['showHeader'] as bool? ?? true;
    
    // Create table rows
    List<pw.TableRow> rows = [];
    for (int i = 0; i < tableData.length; i++) {
      final isHeader = i == 0 && showHeader;
      
      rows.add(
        pw.TableRow(
          decoration: isHeader ? pw.BoxDecoration(color: PdfColors.grey200) : null,
          children: tableData[i].map((cell) {
            return pw.Padding(
              padding: pw.EdgeInsets.all(8.0),
              child: pw.Text(
                cell,
                style: pw.TextStyle(
                  fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      );
    }
    
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: borderWidth),
      children: rows,
    );
  }
  
  // Build PDF chart element
  pw.Widget _buildPdfChartElement(ReportElement element, Map<String, dynamic> data) {
    final properties = element.properties;
    final chartType = properties!['type'] as String? ?? 'bar';
    final title = properties!['title'] as String? ?? '';
    
    // Creating actual charts in PDF would require more complex implementation
    // This is just a placeholder
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      padding: pw.EdgeInsets.all(8),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          if (title.isNotEmpty)
            pw.Text(
              title,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          pw.SizedBox(height: 10),
          pw.Text('$chartType Chart', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          pw.Text('Chart would be rendered here'),
        ],
      ),
    );
  }
  
  // Helper method to resolve data variables in text
  String _resolveDataVariables(String text, Map<String, dynamic> data) {
    // Replace variables in the format {{variableName}} with data values
    final regex = RegExp(r'\{\{(.*?)\}\}');
    return text.replaceAllMapped(regex, (match) {
      final variable = match.group(1)?.trim();
      if (variable != null && data.containsKey(variable)) {
        return data[variable].toString();
      }
      return match.group(0) ?? '';
    });
  }
  
  // Convert hex color to PDF color
  PdfColor _parsePdfColor(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      final r = int.parse(hexColor.substring(0, 2), radix: 16) / 255;
      final g = int.parse(hexColor.substring(2, 4), radix: 16) / 255;
      final b = int.parse(hexColor.substring(4, 6), radix: 16) / 255;
      return PdfColor(r, g, b);
    }
    return PdfColors.black;
  }
  
  // Get PDF text alignment
  pw.TextAlign _getPdfTextAlign(String? align) {
    switch (align) {
      case 'center':
        return pw.TextAlign.center;
      case 'right':
        return pw.TextAlign.right;
      case 'justify':
        return pw.TextAlign.justify;
      case 'left':
      default:
        return pw.TextAlign.left;
    }
  }
  
  // Get PDF box fit
  pw.BoxFit _getPdfBoxFit(String fit) {
    switch (fit) {
      case 'fill':
        return pw.BoxFit.fill;
      case 'contain':
        return pw.BoxFit.contain;
      case 'cover':
        return pw.BoxFit.cover;
      case 'fitWidth':
        return pw.BoxFit.fitWidth;
      case 'fitHeight':
        return pw.BoxFit.fitHeight;
      case 'none':
        return pw.BoxFit.none;
      default:
        return pw.BoxFit.contain;
    }
  }
  
  // Get PDF page format
  PdfPageFormat _getPdfPageFormat(PaperSize size) {
    switch (size) {
      case PaperSize.a3:
        return PdfPageFormat.a3;
      case PaperSize.legal:
        return PdfPageFormat.a5;
      case PaperSize.letter:
        return PdfPageFormat.letter;
      case PaperSize.tabloid:
        // For custom, you would need to have width and height in the size
        return PdfPageFormat(595.28, 841.89); // Default to A4
      case PaperSize.a4:
      default:
        return PdfPageFormat.a4;
    }
  }
} */
