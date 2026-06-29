import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:docx_template/docx_template.dart';

// Enum for closing types
enum ClosingType { financial, yearEnd, monthEnd, accountingPeriod }

// Model class for financial data
class FinancialData {
  double totalAssets;
  double totalLiabilities;
  double totalEquity;
  double totalIncome;
  double totalExpenses;
  double netProfit;
  double zakat;
  Map<String, double> partnerShares;

  FinancialData({
    this.totalAssets = 0.0,
    this.totalLiabilities = 0.0,
    this.totalEquity = 0.0,
    this.totalIncome = 0.0,
    this.totalExpenses = 0.0,
    this.netProfit = 0.0,
    this.zakat = 0.0,
    Map<String, double>? partnerShares,
  }) : partnerShares = partnerShares ?? {};

  // Calculate equity (assets - liabilities)
  void calculateEquity() {
    totalEquity = totalAssets - totalLiabilities;
  }

  // Calculate net profit (income - expenses)
  void calculateNetProfit() {
    netProfit = totalIncome - totalExpenses;
  }

  // Calculate zakat (2.5% of net profit if applicable)
  void calculateZakat() {
    zakat = netProfit * 0.025; // 2.5% zakat rate
  }

  // Create a copy with new values
  FinancialData copyWith({
    double? totalAssets,
    double? totalLiabilities,
    double? totalEquity,
    double? totalIncome,
    double? totalExpenses,
    double? netProfit,
    double? zakat,
    Map<String, double>? partnerShares,
  }) {
    return FinancialData(
      totalAssets: totalAssets ?? this.totalAssets,
      totalLiabilities: totalLiabilities ?? this.totalLiabilities,
      totalEquity: totalEquity ?? this.totalEquity,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      netProfit: netProfit ?? this.netProfit,
      zakat: zakat ?? this.zakat,
      partnerShares: partnerShares ?? Map.from(this.partnerShares),
    );
  }
}

// Controller class for the closing report
class ClosingReportController extends ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  ClosingType _selectedClosingType = ClosingType.financial;
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime.now();
  FinancialData _financialData = FinancialData(
    partnerShares: {'Partner A': 0.0, 'Partner B': 0.0, 'Partner C': 0.0},
  );
  String _notes = '';
  String _reportTitle = 'Syirkah Syariah Financial Closing Report';
  String _companyName = 'Syirkah Syariah Company';

  // Getters
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  ClosingType get selectedClosingType => _selectedClosingType;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  FinancialData get financialData => _financialData;
  String get notes => _notes;
  String get reportTitle => _reportTitle;
  String get companyName => _companyName;

  // Update methods
  void selectClosingType(ClosingType type) {
    _selectedClosingType = type;
    _updateReportTitle();
    notifyListeners();
  }

  void updateStartDate(DateTime date) {
    _startDate = date;
    notifyListeners();
  }

  void updateEndDate(DateTime date) {
    _endDate = date;
    notifyListeners();
  }

  void updateCompanyName(String name) {
    _companyName = name;
    notifyListeners();
  }

  void updateNotes(String notes) {
    _notes = notes;
    notifyListeners();
  }

  void _updateReportTitle() {
    switch (_selectedClosingType) {
      case ClosingType.financial:
        _reportTitle = 'Syirkah Syariah Financial Closing Report';
        break;
      case ClosingType.yearEnd:
        _reportTitle = 'Syirkah Syariah Year-End Closing Report';
        break;
      case ClosingType.monthEnd:
        _reportTitle = 'Syirkah Syariah Month-End Closing Report';
        break;
      case ClosingType.accountingPeriod:
        _reportTitle = 'Syirkah Syariah Accounting Period Closing Report';
        break;
    }
    notifyListeners();
  }

  void updateFinancialData({
    double? totalAssets,
    double? totalLiabilities,
    double? totalIncome,
    double? totalExpenses,
    Map<String, double>? partnerShares,
  }) {
    // Create a copy of the current financial data
    final updatedData = _financialData.copyWith(
      totalAssets: totalAssets,
      totalLiabilities: totalLiabilities,
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      partnerShares: partnerShares,
    );

    // Calculate derived values
    updatedData.calculateEquity();
    updatedData.calculateNetProfit();
    updatedData.calculateZakat();

    // Update financial data
    _financialData = updatedData;
    notifyListeners();
  }

  // Initialize with sample data (in a real app, this would load from a database)
  void loadSampleData() {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    Future.delayed(const Duration(milliseconds: 800), () {
      _financialData = FinancialData(
        totalAssets: 1250000.0,
        totalLiabilities: 450000.0,
        totalIncome: 750000.0,
        totalExpenses: 550000.0,
        partnerShares: {
          'Partner A': 40.0, // 40%
          'Partner B': 35.0, // 35%
          'Partner C': 25.0, // 25%
        },
      );

      // Calculate derived values
      _financialData.calculateEquity();
      _financialData.calculateNetProfit();
      _financialData.calculateZakat();

      _isLoading = false;
      notifyListeners();
    });
  }

  // Generate PDF report
  Future<File> generatePdfReport() async {
    final pdf = pw.Document();

    // Add font
    final font = await PdfGoogleFonts.nunitoRegular();
    final fontBold = await PdfGoogleFonts.nunitoBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    _companyName,
                    style: pw.TextStyle(font: fontBold, fontSize: 18),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    _reportTitle,
                    style: pw.TextStyle(font: fontBold, fontSize: 16),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Period: ${DateFormat('dd MMM yyyy').format(_startDate)} - ${DateFormat('dd MMM yyyy').format(_endDate)}',
                    style: pw.TextStyle(font: font, fontSize: 12),
                  ),
                  pw.Divider(),
                ],
              ),
            ),

            // Financial summary
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,

              children: [
                pw.Table(
                  border: pw.TableBorder.all(width: 0.5),
                  children: [
                    // Table headers
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Description',
                            style: pw.TextStyle(font: fontBold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Amount',
                            style: pw.TextStyle(font: fontBold),
                          ),
                        ),
                      ],
                    ),
                    // Table rows
                    _buildPdfTableRow(
                      'Total Assets',
                      _financialData.totalAssets,
                      font,
                    ),
                    _buildPdfTableRow(
                      'Total Liabilities',
                      _financialData.totalLiabilities,
                      font,
                    ),
                    _buildPdfTableRow(
                      'Total Equity',
                      _financialData.totalEquity,
                      fontBold,
                    ),
                    _buildPdfTableRow(
                      'Total Income',
                      _financialData.totalIncome,
                      font,
                    ),
                    _buildPdfTableRow(
                      'Total Expenses',
                      _financialData.totalExpenses,
                      font,
                    ),
                    _buildPdfTableRow(
                      'Net Profit',
                      _financialData.netProfit,
                      fontBold,
                    ),
                    _buildPdfTableRow(
                      'Zakat (2.5%)',
                      _financialData.zakat,
                      fontBold,
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            // Profit distribution
            pw.Column(
              /* title:  */
              children: [
                pw.Text(
                  'Profit Distribution (After Zakat)',
                  style: pw.TextStyle(font: fontBold, fontSize: 14),
                ),
                pw.Table(
                  border: pw.TableBorder.all(width: 0.5),
                  children: [
                    // Table headers
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Partner',
                            style: pw.TextStyle(font: fontBold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Share (%)',
                            style: pw.TextStyle(font: fontBold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Amount',
                            style: pw.TextStyle(font: fontBold),
                          ),
                        ),
                      ],
                    ),
                    // Partner rows
                    ..._financialData.partnerShares.entries.map((entry) {
                      final partnerAmount =
                          (_financialData.netProfit - _financialData.zakat) *
                          (entry.value / 100);
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              entry.key,
                              style: pw.TextStyle(font: font),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              '${entry.value.toStringAsFixed(2)}%',
                              style: pw.TextStyle(font: font),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              NumberFormat.currency(
                                locale: 'id',
                                symbol: 'Rp',
                                decimalDigits: 2,
                              ).format(partnerAmount),
                              style: pw.TextStyle(font: font),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            // Notes
            if (_notes.isNotEmpty)
              pw.Column(
                children: [
                  pw.Text(
                    'Notes',
                    style: pw.TextStyle(font: fontBold, fontSize: 14),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey),
                      borderRadius: const pw.BorderRadius.all(
                        pw.Radius.circular(5),
                      ),
                    ),
                    child: pw.Text(_notes, style: pw.TextStyle(font: font)),
                  ),
                ],
              ),

            pw.SizedBox(height: 20),

            // Signatures
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Prepared by:', style: pw.TextStyle(font: font)),
                    pw.SizedBox(height: 40),
                    pw.Text(
                      '________________',
                      style: pw.TextStyle(font: font),
                    ),
                    pw.Text('Finance Manager', style: pw.TextStyle(font: font)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Approved by:', style: pw.TextStyle(font: font)),
                    pw.SizedBox(height: 40),
                    pw.Text(
                      '________________',
                      style: pw.TextStyle(font: font),
                    ),
                    pw.Text('Director', style: pw.TextStyle(font: font)),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            // Footer
            pw.Footer(
              title: pw.Text(
                'Generated on ${DateFormat('dd MMMM yyyy HH:mm').format(DateTime.now())}',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              ),
            ),
          ];
        },
      ),
    );

    // Save the PDF
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/syirkah_report.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  // Helper for building PDF table rows
  pw.TableRow _buildPdfTableRow(String label, double value, pw.Font font) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(label, style: pw.TextStyle(font: font)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            NumberFormat.currency(
              locale: 'id',
              symbol: 'Rp',
              decimalDigits: 2,
            ).format(value),
            style: pw.TextStyle(font: font),
          ),
        ),
      ],
    );
  }

  // Generate DOCX report
  Future<File> generateDocxReport() async {
    // Get the template from assets
    final docxBytes = await rootBundle.load(
      'assets/templates/syirkah_report_template.docx',
    );

    // Create a template processor
    final docx = await DocxTemplate.fromBytes(docxBytes.buffer.asUint8List());

    // Prepare partner shares data
    final partnerSharesData =
        _financialData.partnerShares.entries.map((entry) {
          final partnerAmount =
              (_financialData.netProfit - _financialData.zakat) *
              (entry.value / 100);
          return {
            'name': entry.key,
            'percentage': '${entry.value.toStringAsFixed(2)}%',
            'amount': NumberFormat.currency(
              locale: 'id',
              symbol: 'Rp',
              decimalDigits: 2,
            ).format(partnerAmount),
          };
        }).toList();

    // Prepare the content with proper Content() formatting
    final content = Content();
    content['company_name'] = TextContent('company_name', _companyName);
    content['report_title'] = TextContent('report_title', _reportTitle);
    content['period_start'] = TextContent(
      'period_start',
      DateFormat('dd MMM yyyy').format(_startDate),
    );
    content['period_end'] = TextContent(
      'period_end',
      DateFormat('dd MMM yyyy').format(_endDate),
    );
    content['total_assets'] = TextContent(
      'total_assets',
      NumberFormat.currency(
        locale: 'id',
        symbol: 'Rp',
        decimalDigits: 2,
      ).format(_financialData.totalAssets),
    );
    content['total_liabilities'] = TextContent(
      'total_liabilities',
      NumberFormat.currency(
        locale: 'id',
        symbol: 'Rp',
        decimalDigits: 2,
      ).format(_financialData.totalLiabilities),
    );
    content['total_equity'] = TextContent(
      'total_equity',
      NumberFormat.currency(
        locale: 'id',
        symbol: 'Rp',
        decimalDigits: 2,
      ).format(_financialData.totalEquity),
    );
    content['total_income'] = TextContent(
      'total_income',
      NumberFormat.currency(
        locale: 'id',
        symbol: 'Rp',
        decimalDigits: 2,
      ).format(_financialData.totalIncome),
    );
    content['total_expenses'] = TextContent(
      'total_expenses',
      NumberFormat.currency(
        locale: 'id',
        symbol: 'Rp',
        decimalDigits: 2,
      ).format(_financialData.totalExpenses),
    );
    content['net_profit'] = TextContent(
      'net_profit',
      NumberFormat.currency(
        locale: 'id',
        symbol: 'Rp',
        decimalDigits: 2,
      ).format(_financialData.netProfit),
    );
    content['zakat'] = TextContent(
      'zakat',
      NumberFormat.currency(
        locale: 'id',
        symbol: 'Rp',
        decimalDigits: 2,
      ).format(_financialData.zakat),
    );
    content['notes'] = TextContent('notes', _notes);
    content['generated_date'] = TextContent(
      'generated_date',
      DateFormat('dd MMMM yyyy HH:mm').format(DateTime.now()),
    );
    //content['partners'] = TableContent(partnerSharesData);
    //content['partners'] = TableContent('partners', partnerSharesData);
    // Generate the report
    final docxFile = await docx.generate(content);

    // Save the file
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/syirkah_report.docx');
    await file.writeAsBytes(docxFile!);

    return file;
  }
}

class SyirkahClosingReportScreen extends StatelessWidget {
  const SyirkahClosingReportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create the standalone controller provider
    return ChangeNotifierProvider(
      create: (_) {
        final controller = ClosingReportController();
        // Load sample data when the screen is created
        controller.loadSampleData();
        return controller;
      },
      child: const _SyirkahClosingReportView(),
    );
  }
}

class _SyirkahClosingReportView extends StatefulWidget {
  const _SyirkahClosingReportView({Key? key}) : super(key: key);

  @override
  _SyirkahClosingReportViewState createState() =>
      _SyirkahClosingReportViewState();
}

class _SyirkahClosingReportViewState extends State<_SyirkahClosingReportView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ClosingReportController>(context);

    if (controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Syirkah Syariah Closing Report'),
        backgroundColor: Colors.green[700],
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'pdf':
                  final pdfFile = await controller.generatePdfReport();
                  await Share.shareXFiles([
                    XFile(pdfFile.path),
                  ], text: 'Syirkah Closing Report');
                  break;
                case 'docx':
                  final docxFile = await controller.generateDocxReport();
                  await Share.shareXFiles([
                    XFile(docxFile.path),
                  ], text: 'Syirkah Closing Report');
                  break;
                case 'print':
                  final pdf = await controller.generatePdfReport();
                  await Printing.layoutPdf(
                    onLayout: (_) => pdf.readAsBytes(),
                    name: controller.reportTitle,
                  );
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'pdf',
                    child: ListTile(
                      leading: Icon(Icons.picture_as_pdf),
                      title: Text('Export to PDF'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'docx',
                    child: ListTile(
                      leading: Icon(Icons.description),
                      title: Text('Export to DOCX'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'print',
                    child: ListTile(
                      leading: Icon(Icons.print),
                      title: Text('Print Report'),
                    ),
                  ),
                ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Report Preview'), Tab(text: 'Edit Report')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Report Preview Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Report Header
                Text(
                  controller.companyName,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  controller.reportTitle,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Period: ${DateFormat('dd MMM yyyy').format(controller.startDate)} - ${DateFormat('dd MMM yyyy').format(controller.endDate)}',
                  style: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
                ),
                const Divider(thickness: 1.0),
                const SizedBox(height: 16.0),

                // Financial Summary
                const Text(
                  'Financial Summary',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Card(
                  elevation: 2.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildSummaryRow(
                          'Total Assets',
                          controller.financialData.totalAssets,
                        ),
                        _buildSummaryRow(
                          'Total Liabilities',
                          controller.financialData.totalLiabilities,
                        ),
                        const Divider(),
                        _buildSummaryRow(
                          'Total Equity',
                          controller.financialData.totalEquity,
                          isBold: true,
                        ),
                        const SizedBox(height: 16.0),
                        _buildSummaryRow(
                          'Total Income',
                          controller.financialData.totalIncome,
                        ),
                        _buildSummaryRow(
                          'Total Expenses',
                          controller.financialData.totalExpenses,
                        ),
                        const Divider(),
                        _buildSummaryRow(
                          'Net Profit',
                          controller.financialData.netProfit,
                          isBold: true,
                        ),
                        _buildSummaryRow(
                          'Zakat (2.5%)',
                          controller.financialData.zakat,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),

                // Profit Distribution
                const Text(
                  'Profit Distribution (After Zakat)',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Card(
                  elevation: 2.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: const [
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Partner',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Share (%)',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Amount',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        ...controller.financialData.partnerShares.entries.map((
                          entry,
                        ) {
                          final partnerAmount =
                              (controller.financialData.netProfit -
                                  controller.financialData.zakat) *
                              (entry.value / 100);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                Expanded(flex: 3, child: Text(entry.key)),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${entry.value.toStringAsFixed(2)}%',
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    NumberFormat.currency(
                                      locale: 'id',
                                      symbol: 'Rp',
                                      decimalDigits: 2,
                                    ).format(partnerAmount),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),

                // Notes
                if (controller.notes.isNotEmpty) ...[
                  const Text(
                    'Notes',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Card(
                    elevation: 2.0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(controller.notes),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                ],

                // Signatures
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Prepared by:'),
                        SizedBox(height: 40.0),
                        Text('________________'),
                        Text('Finance Manager'),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Approved by:'),
                        SizedBox(height: 40.0),
                        Text('________________'),
                        Text('Director'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),

                // Generated date
                Text(
                  'Generated on ${DateFormat('dd MMMM yyyy HH:mm').format(DateTime.now())}',
                  style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Edit Report Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Report Type
                  const Text(
                    'Report Type',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Card(
                    elevation: 2.0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          RadioListTile<ClosingType>(
                            title: const Text('Financial Closing'),
                            value: ClosingType.financial,
                            groupValue: controller.selectedClosingType,
                            onChanged: (ClosingType? value) {
                              if (value != null) {
                                controller.selectClosingType(value);
                              }
                            },
                          ),
                          RadioListTile<ClosingType>(
                            title: const Text('Year-End Closing'),
                            value: ClosingType.yearEnd,
                            groupValue: controller.selectedClosingType,
                            onChanged: (ClosingType? value) {
                              if (value != null) {
                                controller.selectClosingType(value);
                              }
                            },
                          ),
                          RadioListTile<ClosingType>(
                            title: const Text('Month-End Closing'),
                            value: ClosingType.monthEnd,
                            groupValue: controller.selectedClosingType,
                            onChanged: (ClosingType? value) {
                              if (value != null) {
                                controller.selectClosingType(value);
                              }
                            },
                          ),
                          RadioListTile<ClosingType>(
                            title: const Text('Accounting Period Close'),
                            value: ClosingType.accountingPeriod,
                            groupValue: controller.selectedClosingType,
                            onChanged: (ClosingType? value) {
                              if (value != null) {
                                controller.selectClosingType(value);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Company Information
                  const Text(
                    'Company Information',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Card(
                    elevation: 2.0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        initialValue: controller.companyName,
                        decoration: const InputDecoration(
                          labelText: 'Company Name',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          controller.updateCompanyName(value);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter company name';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Date Range
                  const Text(
                    'Reporting Period',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Card(
                    elevation: 2.0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectStartDate(context),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Start Date',
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(
                                  DateFormat(
                                    'dd MMM yyyy',
                                  ).format(controller.startDate),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectEndDate(context),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'End Date',
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(
                                  DateFormat(
                                    'dd MMM yyyy',
                                  ).format(controller.endDate),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Financial Data
                  const Text(
                    'Financial Data',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Card(
                    elevation: 2.0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Assets
                          TextFormField(
                            initialValue:
                                controller.financialData.totalAssets.toString(),
                            decoration: const InputDecoration(
                              labelText: 'Total Assets',
                              border: OutlineInputBorder(),
                              prefixText: 'Rp ',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final amount = double.tryParse(value) ?? 0.0;
                              controller.updateFinancialData(
                                totalAssets: amount,
                              );
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter total assets';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16.0),

                          // Liabilities
                          TextFormField(
                            initialValue:
                                controller.financialData.totalLiabilities
                                    .toString(),
                            decoration: const InputDecoration(
                              labelText: 'Total Liabilities',
                              border: OutlineInputBorder(),
                              prefixText: 'Rp ',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final amount = double.tryParse(value) ?? 0.0;
                              controller.updateFinancialData(
                                totalLiabilities: amount,
                              );
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter total liabilities';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16.0),

                          // Income
                          TextFormField(
                            initialValue:
                                controller.financialData.totalIncome.toString(),
                            decoration: const InputDecoration(
                              labelText: 'Total Income',
                              border: OutlineInputBorder(),
                              prefixText: 'Rp ',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final amount = double.tryParse(value) ?? 0.0;
                              controller.updateFinancialData(
                                totalIncome: amount,
                              );
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter total income';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16.0),

                          // Expenses
                          TextFormField(
                            initialValue:
                                controller.financialData.totalExpenses
                                    .toString(),
                            decoration: const InputDecoration(
                              labelText: 'Total Expenses',
                              border: OutlineInputBorder(),
                              prefixText: 'Rp ',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final amount = double.tryParse(value) ?? 0.0;
                              controller.updateFinancialData(
                                totalExpenses: amount,
                              );
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter total expenses';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Partner Shares
                  const Text(
                    'Partner Shares (%)',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Card(
                    elevation: 2.0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          ...controller.financialData.partnerShares.entries.map(
                            (entry) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: TextFormField(
                                  initialValue: entry.value.toString(),
                                  decoration: InputDecoration(
                                    labelText: entry.key,
                                    border: const OutlineInputBorder(),
                                    suffixText: '%',
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    final percentage =
                                        double.tryParse(value) ?? 0.0;
                                    final updatedShares =
                                        Map<String, double>.from(
                                          controller
                                              .financialData
                                              .partnerShares,
                                        );
                                    updatedShares[entry.key] = percentage;
                                    controller.updateFinancialData(
                                      partnerShares: updatedShares,
                                    );
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter share percentage';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Please enter a valid number';
                                    }
                                    return null;
                                  },
                                ),
                              );
                            },
                          ).toList(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Notes
                  const Text(
                    'Notes',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Card(
                    elevation: 2.0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        initialValue: controller.notes,
                        decoration: const InputDecoration(
                          labelText: 'Additional Notes',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 5,
                        onChanged: (value) {
                          controller.updateNotes(value);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50.0,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Switch to preview tab
                          _tabController.animateTo(0);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Report updated successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                      ),
                      child: const Text(
                        'Update Report',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build summary rows
  Widget _buildSummaryRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            NumberFormat.currency(
              locale: 'id',
              symbol: 'Rp',
              decimalDigits: 2,
            ).format(value),
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to show start date picker
  Future<void> _selectStartDate(BuildContext context) async {
    final controller = Provider.of<ClosingReportController>(
      context,
      listen: false,
    );

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green[700]!,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != controller.startDate) {
      controller.updateStartDate(picked);
    }
  }

  // Helper method to show end date picker
  Future<void> _selectEndDate(BuildContext context) async {
    final controller = Provider.of<ClosingReportController>(
      context,
      listen: false,
    );

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green[700]!,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != controller.endDate) {
      controller.updateEndDate(picked);
    }
  }
}

// Usage example in main.dart:
/*
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Syirkah Syariah App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SyirkahClosingReportScreen(),
    );
  }
}
*/
