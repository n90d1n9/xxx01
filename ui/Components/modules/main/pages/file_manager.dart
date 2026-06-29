import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:image_picker/image_picker.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
//import 'package:syncfusion_flutter_words/flutter_words.dart';

class FileManager extends StatefulWidget {
  const FileManager({Key? key}) : super(key: key);

  @override
  State<FileManager> createState() => _FileManagerState();
}

class _FileManagerState extends State<FileManager> {
  // File paths for export
  String? excelFilePath, pdfFilePath, wordFilePath;

  // Function to export data to Excel
  Future<void> exportToExcel(List<Map<String, dynamic>> data) async {
    // Create a new Workbook.
    final xlsio.Workbook workbook = xlsio.Workbook();
    // Get the first worksheet.
    final xlsio.Worksheet sheet = workbook.worksheets[0];
    // Add data to the sheet.
    for (int i = 0; i < data.length; i++) {
      for (int j = 0; j < data[i].keys.length; j++) {
        sheet.getRangeByName('A${i + 1}').setValue(data[i].keys.elementAt(j));
        sheet.getRangeByName('B${i + 1}').setValue(data[i].values.elementAt(j));
      }
    }
     List<int> bytes = workbook.saveAsStream();
    //print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>$excelFilePath');
    File('excel_file_2.xlsx').writeAsBytes(bytes);
print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
    // Save the Excel file.
    //final Directory? directory = await getExternalStorageDirectory();

//final Directory directory = await getTemporaryDirectory();

//final Directory? directory = await getApplicationDocumentsDirectory();

//final Directory? directory = await getDownloadsDirectory();
String? filePath = await FilePicker.platform.getDirectoryPath();

    //excelFilePath = '${directory!.path}/excel_file.xlsx';
    excelFilePath = '$filePath/excel_file_new01.xlsx';
    // Worksheet sheet = workbook.worksheets[0];
    
    print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>$excelFilePath');
    File(excelFilePath!).writeAsBytes(bytes);

    
    await workbook.saveAsStream();//excelFilePath!);
    workbook.dispose();
    setState(() {});
  }

  // Function to export data to PDF
  Future<void> exportToPDF(List<Map<String, dynamic>> data) async {
    // Create a new PDF document.
    final PdfDocument document = PdfDocument();
    // Create a new page.
    final PdfPage page = document.pages.add();
    // Create a new graphics object.
    final PdfGraphics graphics = page.graphics;
    // Draw a rectangle for the table.
    graphics.drawRectangle(
        brush: PdfSolidBrush(PdfColor(0xFFFAFAFA, 0xFF000000, 0xFF000000)),
        pen: PdfPen(PdfColor(0xFF000000, 0xFF000000, 0xFF000000)),
        bounds: const Rect.fromLTWH(10, 10, 500, 200));
    // Draw the table header.
    graphics.drawString('Name', PdfStandardFont(PdfFontFamily.helvetica, 12),
        brush: PdfSolidBrush(PdfColor(0xFF000000, 0xFF000000, 0xFF000000)),
        bounds: const Rect.fromLTWH(10, 10, 100, 20));
    graphics.drawString('Age', PdfStandardFont(PdfFontFamily.helvetica, 12),
        brush: PdfSolidBrush(PdfColor(
          0xFF000000,
          0xFF000000,
          0xFF000000,
        )),
        bounds: const Rect.fromLTWH(110, 10, 100, 20));
    // Draw the table data.
    for (int i = 0; i < data.length; i++) {
      graphics.drawString(
          data[i]['name'], PdfStandardFont(PdfFontFamily.helvetica, 12),
          brush: PdfSolidBrush(PdfColor(0xFF000000, 0xFF000000, 0xFF000000)),
          bounds: Rect.fromLTWH(10, 30 + i * 20, 100, 20));
      graphics.drawString(data[i]['age'].toString(),
          PdfStandardFont(PdfFontFamily.helvetica, 12),
          brush: PdfSolidBrush(PdfColor(0xFF000000, 0xFF000000, 0xFF000000)),
          bounds: Rect.fromLTWH(110, 30 + i * 20, 100, 20));
    }
    // Save the PDF file.
    final Directory? directory = await getExternalStorageDirectory();
    pdfFilePath = '${directory!.path}/pdf_file.pdf';
    //await document.saveToFile(pdfFilePath!);
    await document.save(); //pdfFilePath!);
    setState(() {});
  }


  Future<void> _chooseDirectory() async {
    final pickedFile =
        await ImagePicker()..pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        // _messages.add(ChatMessage(image: pickedFile.path, isSentByMe: true));
      });
    }
  }

   Future<void> _pickFile() async {
    String? filePath = await FilePicker.platform.getDirectoryPath();//.pickFiles().then((value) => value!.files.first.path);
    //print()
    if (filePath != null) {
      setState(() {
        //_messages.add(ChatMessage(file: filePath, isSentByMe: true));
      });
    }
  }

  // Function to export data to Word
  /* Future<void> exportToWord(List<Map<String, dynamic>> data) async {
    // Create a new Word document.
    final WordDocument document = WordDocument();
    // Create a new paragraph.
    final Paragraph paragraph = document.addChild(Paragraph());
    // Add a table to the paragraph.
    final Table table = paragraph.addChild(Table());
    // Add header rows to the table.
    table.addRows(1);
    table.cells[0, 0].text = 'Name';
    table.cells[0, 1].text = 'Age';
    // Add data rows to the table.
    for (int i = 0; i < data.length; i++) {
      table.addRows(1);
      table.cells[i + 1, 0].text = data[i]['name'];
      table.cells[i + 1, 1].text = data[i]['age'].toString();
    }
    // Save the Word file.
    final Directory directory = await getExternalStorageDirectory();
    wordFilePath = '${directory.path}/word_file.docx';
    await document.saveToFile(wordFilePath!);
    setState(() {});
  } */

  @override
  Widget build(BuildContext context) {
    // Sample data for export
    final List<Map<String, dynamic>> data = [
      {'name': 'John Doe', 'age': 30},
      {'name': 'Jane Doe', 'age': 25},
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Manager'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => exportToExcel(data),
              child: const Text('Export to Excel'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => exportToPDF(data),
              child: const Text('Export to PDF'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => {}, //exportToWord(data),
              child: const Text('Export to Word'),
            ),
            const SizedBox(height: 16),
            // Display file paths if they are available
            if (excelFilePath != null) Text('Excel file path: $excelFilePath'),
            if (pdfFilePath != null) Text('PDF file path: $pdfFilePath'),
            if (wordFilePath != null) Text('Word file path: $wordFilePath'),
          ],
        ),
      ),
    );
  }
}
