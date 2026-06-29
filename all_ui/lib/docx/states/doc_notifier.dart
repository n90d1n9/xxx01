import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/quill_delta.dart' as d;
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/legacy.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../models/aiaction.dart';
import '../models/chart_data.dart';
import '../models/chart_type.dart';
import '../models/document_outline.dart';
import '../models/document_table.dart';
import '../models/document_template.dart';
import '../models/document_theme.dart';
import '../models/document_version.dart';
import '../models/drawing_data.dart';
import '../models/export_options.dart';
import '../models/footnote.dart';
import '../models/page_layout.dart';
import '../models/page_settings.dart';
import '../models/spell_check_error.dart';
import '../models/spell_check_service.dart';
import '../models/aiassistant_service.dart';
import '../models/cloud_sync_service.dart';
import '../models/collaboration_service.dart';
import '../models/document_metadata.dart';
import '../models/document_state.dart';
import '../models/document_storage_service.dart';
import '../models/folder.dart';
import '../models/spell_check_service.dart';
import '../services/document_statistics.dart';
import '../services/docx_service.dart';
import '../services/pdf_service.dart';

class DocumentNotifier extends StateNotifier<DocumentState> {
  final DocumentStorageService _storage;
  final DocxService _docxService;
  final PdfService _pdfService;
  final AIAssistantService _aiService;
  final CloudSyncService _cloudSync;
  final CollaborationService _collaboration;
  final SpellCheckService _spellCheck;
  final Uuid _uuid = const Uuid();
  Timer? _spellCheckTimer;

  DocumentNotifier(
    this._storage,
    this._docxService,
    this._pdfService,
    this._aiService,
    this._cloudSync,
    this._collaboration,
    this._spellCheck,
  ) : super(
        DocumentState(
          controller: quill.QuillController.basic(),
          metadata: DocumentMetadata(
            id: const Uuid().v4(),
            title: 'Untitled Document',
            createdAt: DateTime.now(),
            modifiedAt: DateTime.now(),
          ),
        ),
      ) {
    state.controller.addListener(_onDocumentChanged);
    _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    try {
      await _storage.initialize();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to initialize storage: $e');
    }
  }

  void _onDocumentChanged() {
    if (!state.hasUnsavedChanges) {
      final stats = _calculateStatistics();
      state = state.copyWith(
        hasUnsavedChanges: true,
        metadata: state.metadata.copyWith(
          wordCount: stats['words'],
          characterCount: stats['characters'],
          modifiedAt: DateTime.now(),
        ),
      );
    }
  }

  Map<String, int> _calculateStatistics() {
    final text = state.controller.document.toPlainText();
    final words =
        text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
    final characters = text.length;
    return {'words': words, 'characters': characters};
  }

  Future<void> createNewDocument() async {
    final newController = quill.QuillController.basic();
    newController.addListener(_onDocumentChanged);

    state.controller.removeListener(_onDocumentChanged);

    state = DocumentState(
      controller: newController,
      metadata: DocumentMetadata(
        id: _uuid.v4(),
        title: 'Untitled Document',
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
      ),
      hasUnsavedChanges: false,
    );
  }

  Future<void> createFromTemplate(DocumentTemplate template) async {
    final newController = quill.QuillController.basic();
    if (template.content.isNotEmpty) {
      newController.document.insert(0, template.content);
    }
    newController.addListener(_onDocumentChanged);

    state.controller.removeListener(_onDocumentChanged);

    state = DocumentState(
      controller: newController,
      metadata: DocumentMetadata(
        id: _uuid.v4(),
        title: template.name,
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
      ),
      hasUnsavedChanges: template.content.isNotEmpty,
    );
  }

  Future<void> saveDocument() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final content = jsonEncode(state.controller.document.toDelta().toJson());
      await _storage.saveDocument(state.metadata.id, content, state.metadata);

      // Create version snapshot
      final version = DocumentVersion(
        id: _uuid.v4(),
        timestamp: DateTime.now(),
        content: content,
        description: 'Saved at ${DateTime.now().toLocal()}',
      );

      final updatedVersions = [...state.versions, version];
      await _storage.saveVersions(state.metadata.id, updatedVersions);

      // Trigger cloud sync
      state = state.copyWith(isSyncing: true);
      await _cloudSync.syncDocument(state.metadata.id, content, state.metadata);

      state = state.copyWith(
        hasUnsavedChanges: false,
        isLoading: false,
        versions: updatedVersions,
        currentVersionIndex: updatedVersions.length - 1,
        isSyncing: false,
        lastSyncTime: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSyncing: false,
        errorMessage: 'Failed to save document: $e',
      );
    }
  }

  Future<void> loadDocument(String id) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final content = await _storage.loadDocument(id);
      final metadata = await _storage.loadMetadata(id);
      final versions = await _storage.loadVersions(id);

      if (content == null || metadata == null) {
        throw Exception('Document not found');
      }

      final delta = d.Delta.fromJson(jsonDecode(content));
      final newController = quill.QuillController(
        document: quill.Document.fromDelta(delta),
        selection: const TextSelection.collapsed(offset: 0),
      );
      newController.addListener(_onDocumentChanged);

      state.controller.removeListener(_onDocumentChanged);

      state = DocumentState(
        controller: newController,
        metadata: metadata,
        hasUnsavedChanges: false,
        isLoading: false,
        versions: versions,
        currentVersionIndex: versions.isEmpty ? -1 : versions.length - 1,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load document: $e',
      );
    }
  }

  Future<void> importFromDocx() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['docx', 'doc'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final bytes = await file.readAsBytes();
        final text = await _docxService.extractTextFromDocx(bytes);

        final newController = quill.QuillController.basic();
        newController.document.insert(0, text);
        newController.addListener(_onDocumentChanged);

        state.controller.removeListener(_onDocumentChanged);

        final fileName = result.files.single.name.replaceAll(
          RegExp(r'\.[^.]+$'),
          '',
        );

        state = DocumentState(
          controller: newController,
          metadata: DocumentMetadata(
            id: _uuid.v4(),
            title: fileName,
            createdAt: DateTime.now(),
            modifiedAt: DateTime.now(),
          ),
          hasUnsavedChanges: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to import DOCX: $e',
      );
    }
  }

  Future<void> importFromPdf() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final bytes = await file.readAsBytes();
        final text = await _pdfService.extractTextFromPdf(bytes);

        final newController = quill.QuillController.basic();
        newController.document.insert(0, text);
        newController.addListener(_onDocumentChanged);

        state.controller.removeListener(_onDocumentChanged);

        final fileName = result.files.single.name.replaceAll(
          RegExp(
            r'\.[^.]+)'
            '',
          ),
          '',
        );

        state = DocumentState(
          controller: newController,
          metadata: DocumentMetadata(
            id: _uuid.v4(),
            title: fileName,
            createdAt: DateTime.now(),
            modifiedAt: DateTime.now(),
          ),
          hasUnsavedChanges: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to import PDF: $e',
      );
    }
  }

  Future<String> exportToDocx() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final text = state.controller.document.toPlainText();
      final bytes = await _docxService.createDocx(text, state.metadata);

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          '${state.metadata.title.replaceAll(RegExp(r'[^\w\s-]'), '_')}.docx';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);

      state = state.copyWith(isLoading: false, hasUnsavedChanges: false);
      return file.path;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to export DOCX: $e',
      );
      rethrow;
    }
  }

  Future<String> exportToPdf({ExportOptions? options}) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final text = state.controller.document.toPlainText();
      final exportOptions = options ?? const ExportOptions();
      final bytes = await _pdfService.createAdvancedPdf(
        text,
        state.metadata,
        exportOptions,
      );

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          '${state.metadata.title.replaceAll(RegExp(r'[^\w\s-]'), '_')}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);

      state = state.copyWith(isLoading: false);
      return file.path;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to export PDF: $e',
      );
      rethrow;
    }
  }

  void updateTitle(String title) {
    state = state.copyWith(
      metadata: state.metadata.copyWith(title: title),
      hasUnsavedChanges: true,
    );
  }

  void toggleFavorite() {
    state = state.copyWith(
      metadata: state.metadata.copyWith(isFavorite: !state.metadata.isFavorite),
      hasUnsavedChanges: true,
    );
  }

  void moveToFolder(String? folderId) {
    state = state.copyWith(
      metadata: state.metadata.copyWith(folderId: folderId),
      hasUnsavedChanges: true,
    );
  }

  Future<void> insertImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final bytes = await file.readAsBytes();
        final base64Image = base64Encode(bytes);

        // Insert image as base64 in document
        final index = state.controller.selection.baseOffset;
        state.controller.document.insert(
          index,
          '\n[Image: ${result.files.single.name}]\n',
        );

        // Note: Full image embedding requires flutter_quill_extensions
        // This is a placeholder implementation
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to insert image: $e');
    }
  }

  Future<List<String>> exportToMultipleFormats() async {
    final List<String> exportedPaths = [];
    final List<String> errors = [];

    try {
      state = state.copyWith(isLoading: true, clearError: true);

      // Export to DOCX
      try {
        final docxPath = await exportToDocx();
        exportedPaths.add(docxPath);
      } catch (e) {
        errors.add('DOCX: $e');
      }

      // Export to PDF
      try {
        final pdfPath = await exportToPdf();
        exportedPaths.add(pdfPath);
      } catch (e) {
        errors.add('PDF: $e');
      }

      // Export to TXT
      try {
        final text = state.controller.document.toPlainText();
        final directory = await getApplicationDocumentsDirectory();
        final fileName =
            '${state.metadata.title.replaceAll(RegExp(r'[^\w\s-]'), '_')}.txt';
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(text);
        exportedPaths.add(file.path);
      } catch (e) {
        errors.add('TXT: $e');
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage:
            errors.isNotEmpty
                ? 'Some exports failed: ${errors.join(", ")}'
                : null,
      );
      return exportedPaths;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to export: $e',
      );
      return exportedPaths;
    }
  }

  Future<void> applyAIAction(AIAction action) async {
    try {
      state = state.copyWith(
        isAIProcessing: true,
        clearError: true,
        clearAIResult: true,
      );

      // Get selected text or full document
      final selection = state.controller.selection;
      String textToProcess;

      if (selection.baseOffset != selection.extentOffset) {
        // Use selected text
        final start =
            selection.baseOffset < selection.extentOffset
                ? selection.baseOffset
                : selection.extentOffset;
        final end =
            selection.baseOffset > selection.extentOffset
                ? selection.baseOffset
                : selection.extentOffset;
        textToProcess = state.controller.document.toPlainText().substring(
          start,
          end,
        );
      } else {
        // Use full document if no selection
        textToProcess = state.controller.document.toPlainText();
        if (textToProcess.trim().isEmpty) {
          throw Exception('No text to process');
        }
      }

      // Process with AI
      final result = await _aiService.processText(textToProcess, action);

      state = state.copyWith(isAIProcessing: false, aiResult: result);
    } catch (e) {
      state = state.copyWith(isAIProcessing: false, errorMessage: e.toString());
    }
  }

  void replaceWithAIResult() {
    if (state.aiResult == null) return;

    final selection = state.controller.selection;

    if (selection.baseOffset != selection.extentOffset) {
      // Replace selected text
      final start =
          selection.baseOffset < selection.extentOffset
              ? selection.baseOffset
              : selection.extentOffset;
      final end =
          selection.baseOffset > selection.extentOffset
              ? selection.baseOffset
              : selection.extentOffset;

      state.controller.replaceText(
        start,
        end - start,
        state.aiResult!,
        TextSelection.collapsed(offset: start + state.aiResult!.length),
      );
    } else {
      // Replace entire document
      final docLength = state.controller.document.length - 1;
      state.controller.replaceText(
        0,
        docLength,
        state.aiResult!,
        TextSelection.collapsed(offset: state.aiResult!.length),
      );
    }

    state = state.copyWith(clearAIResult: true);
  }

  void insertAIResult() {
    if (state.aiResult == null) return;

    final offset = state.controller.selection.baseOffset;
    state.controller.document.insert(offset, '\n\n${state.aiResult!}\n\n');
    state = state.copyWith(clearAIResult: true);
  }

  void clearAIResult() {
    state = state.copyWith(clearAIResult: true);
  }

  // Table operations
  void insertTable(int rows, int columns) {
    final table = DocumentTable.empty(rows, columns);
    final tables = [...state.tables, table];

    // Insert table reference in document
    final offset = state.controller.selection.baseOffset;
    state.controller.document.insert(offset, '\n[TABLE:${table.id}]\n');

    state = state.copyWith(tables: tables, hasUnsavedChanges: true);
  }

  void updateTableCell(String tableId, int row, int col, String value) {
    final tables =
        state.tables.map((table) {
          if (table.id == tableId) {
            final newData = List<List<String>>.from(
              table.data.map((r) => List<String>.from(r)),
            );
            newData[row][col] = value;
            return DocumentTable(
              id: table.id,
              rows: table.rows,
              columns: table.columns,
              data: newData,
              hasHeader: table.hasHeader,
            );
          }
          return table;
        }).toList();

    state = state.copyWith(tables: tables, hasUnsavedChanges: true);
  }

  void addTableRow(String tableId) {
    final tables =
        state.tables.map((table) {
          if (table.id == tableId) {
            final newRow = List<String>.filled(table.columns, '');
            final newData = [...table.data, newRow];
            return DocumentTable(
              id: table.id,
              rows: table.rows + 1,
              columns: table.columns,
              data: newData,
              hasHeader: table.hasHeader,
            );
          }
          return table;
        }).toList();

    state = state.copyWith(tables: tables, hasUnsavedChanges: true);
  }

  void addTableColumn(String tableId) {
    final tables =
        state.tables.map((table) {
          if (table.id == tableId) {
            final newData = table.data.map((row) => [...row, '']).toList();
            return DocumentTable(
              id: table.id,
              rows: table.rows,
              columns: table.columns + 1,
              data: newData,
              hasHeader: table.hasHeader,
            );
          }
          return table;
        }).toList();

    state = state.copyWith(tables: tables, hasUnsavedChanges: true);
  }

  void deleteTableRow(String tableId, int rowIndex) {
    final tables =
        state.tables.map((table) {
          if (table.id == tableId && table.rows > 1) {
            final newData = List<List<String>>.from(table.data);
            newData.removeAt(rowIndex);
            return DocumentTable(
              id: table.id,
              rows: table.rows - 1,
              columns: table.columns,
              data: newData,
              hasHeader: table.hasHeader,
            );
          }
          return table;
        }).toList();

    state = state.copyWith(tables: tables, hasUnsavedChanges: true);
  }

  void deleteTableColumn(String tableId, int colIndex) {
    final tables =
        state.tables.map((table) {
          if (table.id == tableId && table.columns > 1) {
            final newData =
                table.data.map((row) {
                  final newRow = List<String>.from(row);
                  newRow.removeAt(colIndex);
                  return newRow;
                }).toList();
            return DocumentTable(
              id: table.id,
              rows: table.rows,
              columns: table.columns - 1,
              data: newData,
              hasHeader: table.hasHeader,
            );
          }
          return table;
        }).toList();

    state = state.copyWith(tables: tables, hasUnsavedChanges: true);
  }

  void deleteTable(String tableId) {
    final tables = state.tables.where((t) => t.id != tableId).toList();
    state = state.copyWith(tables: tables, hasUnsavedChanges: true);
  }

  // Chart operations
  void insertChart(
    ChartType type,
    String title,
    List<String> labels,
    List<double> values,
  ) {
    final chart = ChartData(
      id: _uuid.v4(),
      type: type,
      title: title,
      labels: labels,
      values: values,
    );
    final charts = [...state.charts, chart];

    // Insert chart reference in document
    final offset = state.controller.selection.baseOffset;
    state.controller.document.insert(offset, '\n[CHART:${chart.id}]\n');

    state = state.copyWith(charts: charts, hasUnsavedChanges: true);
  }

  void updateChart(
    String chartId,
    String title,
    List<String> labels,
    List<double> values,
  ) {
    final charts =
        state.charts.map((chart) {
          if (chart.id == chartId) {
            return ChartData(
              id: chart.id,
              type: chart.type,
              title: title,
              labels: labels,
              values: values,
              color: chart.color,
            );
          }
          return chart;
        }).toList();

    state = state.copyWith(charts: charts, hasUnsavedChanges: true);
  }

  void deleteChart(String chartId) {
    final charts = state.charts.where((c) => c.id != chartId).toList();
    state = state.copyWith(charts: charts, hasUnsavedChanges: true);
  }

  // Drawing operations
  void insertDrawing(Uint8List imageBytes, double width, double height) {
    final drawing = DrawingData(
      id: _uuid.v4(),
      imageBytes: imageBytes,
      width: width,
      height: height,
    );
    final drawings = [...state.drawings, drawing];

    // Insert drawing reference in document
    final offset = state.controller.selection.baseOffset;
    state.controller.document.insert(offset, '\n[DRAWING:${drawing.id}]\n');

    state = state.copyWith(drawings: drawings, hasUnsavedChanges: true);
  }

  void deleteDrawing(String drawingId) {
    final drawings = state.drawings.where((d) => d.id != drawingId).toList();
    state = state.copyWith(drawings: drawings, hasUnsavedChanges: true);
  }

  // Shape operations (simple geometric shapes as drawings)
  Future<void> insertShape(String shapeType) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint =
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.fill;

    const size = 200.0;

    switch (shapeType) {
      case 'rectangle':
        canvas.drawRect(const Rect.fromLTWH(0, 0, size, size * 0.6), paint);
        break;
      case 'circle':
        canvas.drawCircle(const Offset(size / 2, size / 2), size / 2, paint);
        break;
      case 'triangle':
        final path =
            Path()
              ..moveTo(size / 2, 0)
              ..lineTo(size, size)
              ..lineTo(0, size)
              ..close();
        canvas.drawPath(path, paint);
        break;
      case 'star':
        _drawStar(canvas, paint, size);
        break;
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData != null) {
      insertDrawing(byteData.buffer.asUint8List(), size, size);
    }
  }

  void _drawStar(Canvas canvas, Paint paint, double size) {
    final path = Path();
    final center = Offset(size / 2, size / 2);
    final outerRadius = size / 2;
    final innerRadius = size / 4;
    const points = 5;

    for (var i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = (i * 3.14159) / points - 3.14159 / 2;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  double cos(double radians) =>
      radians.isNaN
          ? 0
          : (radians - (radians / (2 * 3.14159)).floor() * 2 * 3.14159).abs() <
              3.14159 / 2
          ? 1 -
              radians * radians / 2 +
              radians * radians * radians * radians / 24
          : -1 + (radians - 3.14159) * (radians - 3.14159) / 2;

  double sin(double radians) => cos(radians - 3.14159 / 2);

  // Page layout operations
  void updatePageSettings(PageSettings settings) {
    state = state.copyWith(pageSettings: settings, hasUnsavedChanges: true);
    _calculatePagination();
  }

  void setPageLayout(PageLayout layout) {
    state = state.copyWith(currentLayout: layout, hasUnsavedChanges: true);
  }

  void _calculatePagination() {
    final text = state.controller.document.toPlainText();
    final settings = state.pageSettings;

    // Rough estimate: ~40 lines per page for standard settings
    final charsPerLine = 80;
    final linesPerPage = (settings.getContentHeight() / 20).floor();
    final totalChars = text.length;
    final totalLines = (totalChars / charsPerLine).ceil();
    final pages = (totalLines / linesPerPage).ceil().clamp(1, 9999);

    state = state.copyWith(totalPages: pages);
  }

  // Footnote operations
  void addFootnote(String text) {
    final offset = state.controller.selection.baseOffset;
    final number = state.footnotes.length + 1;
    final footnote = Footnote(
      id: _uuid.v4(),
      number: number,
      text: text,
      offset: offset,
    );

    final footnotes = [...state.footnotes, footnote];

    // Insert footnote reference in document
    state.controller.document.insert(offset, '[${number}]');

    state = state.copyWith(footnotes: footnotes, hasUnsavedChanges: true);
  }

  void updateFootnote(String id, String text) {
    final footnotes =
        state.footnotes.map((f) {
          if (f.id == id) {
            return Footnote(
              id: f.id,
              number: f.number,
              text: text,
              offset: f.offset,
            );
          }
          return f;
        }).toList();

    state = state.copyWith(footnotes: footnotes, hasUnsavedChanges: true);
  }

  void deleteFootnote(String id) {
    final footnotes = state.footnotes.where((f) => f.id != id).toList();

    // Renumber remaining footnotes
    final renumbered =
        footnotes.asMap().entries.map((entry) {
          return Footnote(
            id: entry.value.id,
            number: entry.key + 1,
            text: entry.value.text,
            offset: entry.value.offset,
          );
        }).toList();

    state = state.copyWith(footnotes: renumbered, hasUnsavedChanges: true);
  }

  // Outline generation
  List<DocumentOutline> generateOutline() {
    final text = state.controller.document.toPlainText();
    final lines = text.split('\n');
    final outline = <DocumentOutline>[];

    int offset = 0;
    for (final line in lines) {
      // Detect headings (simple heuristic: all caps or starts with #)
      if (line.trim().isNotEmpty) {
        if (line.startsWith('#')) {
          final level = line.indexOf(' ');
          final title = line.substring(level + 1);
          outline.add(
            DocumentOutline(
              id: _uuid.v4(),
              title: title,
              level: level,
              offset: offset,
            ),
          );
        } else if (line == line.toUpperCase() && line.length > 3) {
          outline.add(
            DocumentOutline(
              id: _uuid.v4(),
              title: line,
              level: 1,
              offset: offset,
            ),
          );
        }
      }
      offset += line.length + 1;
    }

    return outline;
  }

  // Collaboration features
  void enableCollaboration(String userId, String userName) {
    _collaboration.initialize(userId, userName);
    state = state.copyWith(
      isCollaborationEnabled: true,
      collaborators: _collaboration.activeUsers,
    );
  }

  void disableCollaboration() {
    _collaboration.disable();
    state = state.copyWith(isCollaborationEnabled: false, collaborators: []);
  }

  void updateCollaboratorCursor(int position) {
    if (state.isCollaborationEnabled) {
      final userId = state.collaborators.firstOrNull?.id ?? 'local';
      _collaboration.updateCursorPosition(userId, position);
      state = state.copyWith(collaborators: _collaboration.activeUsers);
    }
  }

  void addMockCollaborator(String name) {
    _collaboration.addMockUser(name);
    state = state.copyWith(collaborators: _collaboration.activeUsers);
  }

  // Styling features
  void applyTheme(DocumentTheme theme) {
    state = state.copyWith(currentTheme: theme, hasUnsavedChanges: true);
  }

  // Spell check features
  void toggleSpellCheck() {
    final enabled = !state.spellCheckEnabled;
    state = state.copyWith(spellCheckEnabled: enabled);

    if (enabled) {
      _startSpellCheck();
    } else {
      _spellCheckTimer?.cancel();
      state = state.copyWith(spellErrors: []);
    }
  }

  void _startSpellCheck() {
    _spellCheckTimer?.cancel();
    _spellCheckTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _runSpellCheck();
    });
    _runSpellCheck(); // Run immediately
  }

  void _runSpellCheck() {
    if (!state.spellCheckEnabled) return;

    final text = state.controller.document.toPlainText();
    final errors = _spellCheck.checkText(text);
    state = state.copyWith(spellErrors: errors);
  }

  void addWordToDictionary(String word) {
    _spellCheck.addToDictionary(word);
    _runSpellCheck();
  }

  void ignoreSpellingError(String word) {
    _spellCheck.ignoreWord(word);
    _runSpellCheck();
  }

  void replaceWithSuggestion(SpellCheckError error, String suggestion) {
    state.controller.replaceText(
      error.offset,
      error.word.length,
      suggestion,
      TextSelection.collapsed(offset: error.offset + suggestion.length),
    );
    _runSpellCheck();
  }

  void addTag(String tag) {
    if (state.metadata.tags.contains(tag)) return;
    final tags = [...state.metadata.tags, tag];
    state = state.copyWith(
      metadata: state.metadata.copyWith(tags: tags),
      hasUnsavedChanges: true,
    );
  }

  void removeTag(String tag) {
    final tags = state.metadata.tags.where((t) => t != tag).toList();
    state = state.copyWith(
      metadata: state.metadata.copyWith(tags: tags),
      hasUnsavedChanges: true,
    );
  }

  Future<void> deleteDocument(String id) async {
    await _storage.deleteDocument(id);
  }

  Future<void> duplicateDocument() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      // Create a new document with same content
      final newId = _uuid.v4();
      final content = jsonEncode(state.controller.document.toDelta().toJson());
      final newMetadata = state.metadata.copyWith(
        id: newId,
        title: '${state.metadata.title} (Copy)',
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
      );

      await _storage.saveDocument(newId, content, newMetadata);

      // Load the duplicated document
      final delta = d.Delta.fromJson(jsonDecode(content));
      final newController = quill.QuillController(
        document: quill.Document.fromDelta(delta),
        selection: const TextSelection.collapsed(offset: 0),
      );
      newController.addListener(_onDocumentChanged);

      state.controller.removeListener(_onDocumentChanged);

      state = DocumentState(
        controller: newController,
        metadata: newMetadata,
        hasUnsavedChanges: false,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to duplicate document: $e',
      );
    }
  }

  void restoreVersion(int index) {
    if (index < 0 || index >= state.versions.length) return;

    final version = state.versions[index];
    final delta = d.Delta.fromJson(jsonDecode(version.content));
    final newController = quill.QuillController(
      document: quill.Document.fromDelta(delta),
      selection: const TextSelection.collapsed(offset: 0),
    );
    newController.addListener(_onDocumentChanged);

    state.controller.removeListener(_onDocumentChanged);

    state = state.copyWith(
      controller: newController,
      currentVersionIndex: index,
      hasUnsavedChanges: true,
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  @override
  void dispose() {
    state.controller.removeListener(_onDocumentChanged);
    state.controller.dispose();
    super.dispose();
  }
}
